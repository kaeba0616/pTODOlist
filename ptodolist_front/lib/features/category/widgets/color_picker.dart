import 'package:flutter/material.dart';
import 'package:ptodolist/core/utils/color_utils.dart';
import 'package:ptodolist/features/category/mocks/category_mock.dart';

class ColorPicker extends StatelessWidget {
  final String selectedColor;
  final ValueChanged<String> onColorSelected;

  const ColorPicker({
    super.key,
    required this.selectedColor,
    required this.onColorSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: categoryColorPresets.map((colorHex) {
        final isSelected = colorHex == selectedColor;
        return GestureDetector(
          onTap: () => onColorSelected(colorHex),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: parseHexColor(colorHex),
              shape: BoxShape.circle,
              border: isSelected
                  ? Border.all(color: Colors.white, width: 2)
                  : null,
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: parseHexColor(colorHex).withAlpha(128),
                        blurRadius: 8,
                      ),
                    ]
                  : null,
            ),
            child: isSelected
                ? const Icon(Icons.check, color: Colors.white, size: 18)
                : null,
          ),
        );
      }).toList(),
    );
  }
}
