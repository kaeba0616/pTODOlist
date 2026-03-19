package com.ptodolist.ptodolist

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import android.app.PendingIntent
import android.content.Intent
import android.net.Uri
import android.view.View
import android.graphics.Paint
import org.json.JSONArray

class PtodolistWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    companion object {
        private const val PREFS_NAME = "HomeWidgetPreferences"

        fun updateAppWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetId: Int
        ) {
            val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            val views = RemoteViews(context.packageName, R.layout.ptodolist_widget_layout)

            val date = prefs.getString("date", "") ?: ""
            val completedCount = prefs.getInt("completedCount", 0)
            val totalCount = prefs.getInt("totalCount", 0)
            val remainingCount = prefs.getInt("remainingCount", 0)
            val routinesJson = prefs.getString("routines", "[]") ?: "[]"

            // Header
            views.setTextViewText(R.id.widget_date, formatDate(date))
            views.setTextViewText(R.id.widget_count, "$completedCount/$totalCount")

            // Progress bar
            val progress = if (totalCount > 0) (completedCount * 100 / totalCount) else 0
            views.setProgressBar(R.id.widget_progress, 100, progress, false)

            // Parse routines
            val routines = JSONArray(routinesJson)

            // Clear routine list and add items
            views.removeAllViews(R.id.widget_routine_list)

            if (routines.length() == 0) {
                views.setViewVisibility(R.id.widget_empty, View.VISIBLE)
                views.setViewVisibility(R.id.widget_routine_list, View.GONE)
            } else {
                views.setViewVisibility(R.id.widget_empty, View.GONE)
                views.setViewVisibility(R.id.widget_routine_list, View.VISIBLE)

                for (i in 0 until routines.length()) {
                    val routine = routines.getJSONObject(i)
                    val id = routine.getString("id")
                    val title = routine.getString("title")
                    val isDone = routine.getBoolean("isDone")

                    val itemView = RemoteViews(context.packageName, R.layout.widget_routine_item)
                    itemView.setTextViewText(R.id.routine_title, title)

                    if (isDone) {
                        itemView.setImageViewResource(
                            R.id.routine_checkbox,
                            android.R.drawable.checkbox_on_background
                        )
                        // Strikethrough effect via text color
                        itemView.setTextColor(R.id.routine_title, 0xFF9CA3AF.toInt())
                    } else {
                        itemView.setImageViewResource(
                            R.id.routine_checkbox,
                            android.R.drawable.checkbox_off_background
                        )
                        itemView.setTextColor(R.id.routine_title, 0xFF111827.toInt())
                    }

                    // Toggle intent
                    val toggleIntent = Intent(context, PtodolistWidgetProvider::class.java).apply {
                        action = "TOGGLE_ROUTINE"
                        data = Uri.parse("ptodolist://toggle?routineId=$id")
                    }
                    val togglePending = PendingIntent.getBroadcast(
                        context, id.hashCode(), toggleIntent,
                        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                    )
                    itemView.setOnClickPendingIntent(R.id.routine_checkbox, togglePending)

                    views.addView(R.id.widget_routine_list, itemView)
                }
            }

            // Remaining count
            if (remainingCount > 0) {
                views.setTextViewText(R.id.widget_remaining, "+${remainingCount}개 더")
                views.setViewVisibility(R.id.widget_remaining, View.VISIBLE)
            } else {
                views.setViewVisibility(R.id.widget_remaining, View.GONE)
            }

            // Open app on header tap
            val openAppIntent = context.packageManager.getLaunchIntentForPackage(context.packageName)
            if (openAppIntent != null) {
                val openPending = PendingIntent.getActivity(
                    context, 0, openAppIntent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
                views.setOnClickPendingIntent(R.id.widget_header, openPending)
            }

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }

        private fun formatDate(dateStr: String): String {
            if (dateStr.isEmpty()) return ""
            try {
                val parts = dateStr.split("-")
                val month = parts[1].toInt()
                val day = parts[2].toInt()
                return "${month}월 ${day}일"
            } catch (e: Exception) {
                return dateStr
            }
        }
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)

        if (intent.action == "TOGGLE_ROUTINE") {
            // Forward the URI to Flutter via home_widget
            val uri = intent.data
            if (uri != null) {
                // Launch the app with the callback URI
                val launchIntent = context.packageManager
                    .getLaunchIntentForPackage(context.packageName)
                    ?.apply {
                        data = uri
                        addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    }
                if (launchIntent != null) {
                    context.startActivity(launchIntent)
                }
            }
        }
    }
}
