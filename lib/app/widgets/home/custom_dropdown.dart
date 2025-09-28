import 'package:flutter/material.dart';

class CustomDropdown<T> extends StatelessWidget {
  final T selectedValue;
  final List<T> items;
  final String labelText;
  final ValueChanged<T?> onChanged;
  final String Function(T)? itemLabel;
  final double width;

  const CustomDropdown({
    Key? key,
    required this.selectedValue,
    required this.items,
    required this.labelText,
    required this.onChanged,
    this.itemLabel,
    this.width = 100,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: DropdownButtonFormField<T>(
        value: selectedValue,
        decoration: InputDecoration(
          labelText: labelText,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        onChanged: onChanged,
        items: items
            .map(
              (item) => DropdownMenuItem<T>(
            value: item,
            child: Text(itemLabel != null ? itemLabel!(item) : item.toString()),
          ),
        )
            .toList(),
      ),
    );
  }
}
