import 'package:flutter/material.dart';
import 'package:nurseos_v3/features/patient/models/diagnosis_catalog.dart';

class SelectDiagnosisScreen extends StatefulWidget {
  final List<String> initialSelection;

  const SelectDiagnosisScreen({super.key, required this.initialSelection});

  @override
  State<SelectDiagnosisScreen> createState() => _SelectDiagnosisScreenState();
}

class _SelectDiagnosisScreenState extends State<SelectDiagnosisScreen> {
  late List<String> selected;
  String query = '';

  @override
  void initState() {
    super.initState();
    selected = List.from(widget.initialSelection);
  }

  void _toggle(String diagnosis) {
    setState(() {
      if (selected.contains(diagnosis)) {
        selected.remove(diagnosis);
      } else {
        selected.add(diagnosis);
      }
    });
  }

  void _done() => Navigator.pop(context, selected);

  @override
  Widget build(BuildContext context) {
    final filtered = diagnosisCatalog
        .where(
            (entry) => entry.label.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Diagnoses'),
        actions: [
          TextButton(
            onPressed: _done,
            child: const Text('Done', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Column(
        children: [
          // 🔍 Search Bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (val) => setState(() => query = val),
              decoration: const InputDecoration(
                labelText: 'Search diagnoses...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          // 📋 Filtered List
          Expanded(
            child: ListView(
              children: filtered.map((entry) {
                return CheckboxListTile(
                  title: Text(entry.label),
                  value: selected.contains(entry.label),
                  onChanged: (_) => _toggle(entry.label),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
