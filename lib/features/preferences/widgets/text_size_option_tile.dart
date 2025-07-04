// 📁 lib/features/preferences/widgets/text_size_option_tile.dart

import 'package:flutter/material.dart';

class TextSizeOptionTile extends StatelessWidget {
  final String label;
  final String description;
  final bool selected;
  final VoidCallback onTap;

  const TextSizeOptionTile({
    super.key,
    required this.label,
    required this.description,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      // ✅ Use the newer textScaler property instead of deprecated textScaleFactor
      data: MediaQuery.of(context).copyWith(
        textScaler: const TextScaler.linear(1.0),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8.0),
        decoration: BoxDecoration(
          border: Border.all(
            color: selected ? Colors.blue : Colors.grey.shade300,
            width: selected ? 2.0 : 1.0,
          ),
          borderRadius: BorderRadius.circular(12),
          color: selected ? Colors.blue.shade50 : null,
        ),
        child: ListTile(
          title: Text(label),
          subtitle: Text(description),
          trailing: selected
              ? const Icon(Icons.radio_button_checked, color: Colors.blue)
              : const Icon(Icons.radio_button_unchecked, color: Colors.grey),
          onTap: onTap,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
