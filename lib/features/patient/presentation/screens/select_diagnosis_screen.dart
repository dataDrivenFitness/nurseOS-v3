import 'package:flutter/material.dart';
import 'package:nurseos_v3/features/patient/models/diagnosis_catalog.dart';
import 'package:nurseos_v3/features/patient/models/patient_risk.dart';

class SelectDiagnosisScreen extends StatefulWidget {
  final List<String> initialSelection;

  const SelectDiagnosisScreen({super.key, required this.initialSelection});

  @override
  State<SelectDiagnosisScreen> createState() => _SelectDiagnosisScreenState();
}

class _SelectDiagnosisScreenState extends State<SelectDiagnosisScreen>
    with TickerProviderStateMixin {
  late List<String> selected;
  late TabController _tabController;
  String query = '';
  String? selectedCategory;
  bool showSelectedOnly = false;

  // Get categories from the catalog
  List<String> get categories => ['All', ...getAvailableCategories()];

  // Mock recent diagnoses (in real app, get from user preferences)
  final List<String> recentDiagnoses = [
    'Myocardial Infarction',
    'Pneumonia',
    'Type 2 Diabetes',
    'Hypertension',
    'COPD Exacerbation'
  ];

  @override
  void initState() {
    super.initState();
    selected = List.from(widget.initialSelection);
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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

  void _clearAll() {
    setState(() {
      selected.clear();
    });
  }

  void _done() => Navigator.pop(context, selected);

  List<DiagnosisEntry> _getFilteredDiagnoses() {
    var filtered = diagnosisCatalog.where((entry) {
      // Text search
      final matchesQuery = query.isEmpty ||
          entry.label.toLowerCase().contains(query.toLowerCase()) ||
          (entry.code?.toLowerCase().contains(query.toLowerCase()) ?? false);

      // Category filter
      final matchesCategory = selectedCategory == null ||
          selectedCategory == 'All' ||
          entry.category == selectedCategory;

      // Show selected only filter
      final matchesSelection =
          !showSelectedOnly || selected.contains(entry.label);

      return matchesQuery && matchesCategory && matchesSelection;
    }).toList();

    // Sort by selected first, then by severity (high -> medium -> low), then alphabetically
    filtered.sort((a, b) {
      final aSelected = selected.contains(a.label);
      final bSelected = selected.contains(b.label);

      if (aSelected && !bSelected) return -1;
      if (!aSelected && bSelected) return 1;

      // If both selected or both not selected, sort by severity
      final severityOrder = {
        RiskLevel.high: 0,
        RiskLevel.medium: 1,
        RiskLevel.low: 2,
        RiskLevel.unknown: 3,
      };

      final aSeverity = severityOrder[a.severity] ?? 3;
      final bSeverity = severityOrder[b.severity] ?? 3;

      if (aSeverity != bSeverity) {
        return aSeverity.compareTo(bSeverity);
      }

      return a.label.compareTo(b.label);
    });

    return filtered;
  }

  Widget _buildSearchSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[50],
      child: Column(
        children: [
          // Search field
          TextField(
            onChanged: (val) => setState(() => query = val),
            decoration: InputDecoration(
              labelText: 'Search diagnoses or ICD codes...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: query.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => setState(() => query = ''),
                    )
                  : null,
              border: const OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          const SizedBox(height: 12),

          // Category filter chips
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final isSelected = selectedCategory == category ||
                    (selectedCategory == null && category == 'All');

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        selectedCategory = selected ? category : null;
                        if (category == 'All') selectedCategory = null;
                      });
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: selected.isEmpty ? Colors.grey[100] : Colors.blue[50],
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.checklist,
            color: selected.isEmpty ? Colors.grey : Colors.blue,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              selected.isEmpty
                  ? 'No diagnoses selected'
                  : '${selected.length} diagnosis${selected.length == 1 ? '' : 'es'} selected',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: selected.isEmpty ? Colors.grey[600] : Colors.blue[700],
              ),
            ),
          ),
          if (selected.isNotEmpty) ...[
            TextButton(
              onPressed: () =>
                  setState(() => showSelectedOnly = !showSelectedOnly),
              child: Text(showSelectedOnly ? 'Show All' : 'Show Selected'),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: _clearAll,
              child: const Text('Clear All'),
            ),
          ],
        ],
      ),
    );
  }

  Color _getRiskColor(RiskLevel severity) {
    switch (severity) {
      case RiskLevel.high:
        return Colors.red;
      case RiskLevel.medium:
        return Colors.orange;
      case RiskLevel.low:
        return Colors.green;
      case RiskLevel.unknown:
        return Colors.grey;
    }
  }

  String _getRiskLabel(RiskLevel severity) {
    switch (severity) {
      case RiskLevel.high:
        return 'High';
      case RiskLevel.medium:
        return 'Medium';
      case RiskLevel.low:
        return 'Low';
      case RiskLevel.unknown:
        return 'Unknown';
    }
  }

  Widget _buildDiagnosisCard(DiagnosisEntry entry) {
    final isSelected = selected.contains(entry.label);
    final riskColor = _getRiskColor(entry.severity);
    final riskLabel = _getRiskLabel(entry.severity);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: isSelected ? 2 : 0,
      color: isSelected ? Colors.blue[50] : null,
      child: ListTile(
        leading: Checkbox(
          value: isSelected,
          onChanged: (_) => _toggle(entry.label),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                entry.label,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            // Risk indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: riskColor.withAlpha(26),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: riskColor.withOpacity(0.3)),
              ),
              child: Text(
                riskLabel,
                style: TextStyle(
                  color: riskColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (entry.code != null)
              Text(
                'ICD: ${entry.code}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            Text(
              entry.category,
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 11,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        trailing: isSelected
            ? Icon(Icons.check_circle, color: Colors.blue[600])
            : null,
        onTap: () => _toggle(entry.label),
      ),
    );
  }

  Widget _buildRecentTab() {
    return Column(
      children: [
        _buildSelectionHeader(),
        Expanded(
          child: ListView(
            children: [
              if (recentDiagnoses.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Recently Used',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                ...recentDiagnoses.map((diagnosis) {
                  // Find the full entry for this diagnosis
                  final entry = diagnosisCatalog.firstWhere(
                    (e) => e.label == diagnosis,
                    orElse: () => DiagnosisEntry(
                      label: diagnosis,
                      severity: RiskLevel.unknown,
                      category: 'Other',
                    ),
                  );
                  return _buildDiagnosisCard(entry);
                }).toList(),
                const Divider(),
              ],
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Common Diagnoses',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              // Use the getCommonDiagnoses helper from the catalog
              ...getCommonDiagnoses()
                  .map((entry) => _buildDiagnosisCard(entry))
                  .toList(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchTab() {
    final filtered = _getFilteredDiagnoses();

    return Column(
      children: [
        _buildSearchSection(),
        _buildSelectionHeader(),
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        query.isEmpty
                            ? 'Enter search terms above'
                            : 'No diagnoses found',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      if (query.isNotEmpty) const SizedBox(height: 8),
                      if (query.isNotEmpty)
                        Text(
                          'Try different keywords or check spelling',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    return _buildDiagnosisCard(filtered[index]);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildSelectedTab() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.blue[50],
          child: Row(
            children: [
              Icon(Icons.playlist_add_check, color: Colors.blue[600]),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${selected.length} Selected Diagnoses',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue[700],
                  ),
                ),
              ),
              if (selected.isNotEmpty)
                TextButton(
                  onPressed: _clearAll,
                  child: const Text('Clear All'),
                ),
            ],
          ),
        ),
        Expanded(
          child: selected.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.checklist, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No diagnoses selected',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Select diagnoses from the other tabs',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: selected.length,
                  itemBuilder: (context, index) {
                    final diagnosis = selected[index];
                    final entry = diagnosisCatalog.firstWhere(
                      (e) => e.label == diagnosis,
                      orElse: () => DiagnosisEntry(
                        label: diagnosis,
                        severity: RiskLevel.unknown,
                        category: 'Other',
                      ),
                    );
                    return _buildDiagnosisCard(entry);
                  },
                ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Diagnoses'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: TabBar(
            controller: _tabController,
            tabs: [
              const Tab(
                icon: Icon(Icons.access_time),
                text: 'Recent',
              ),
              const Tab(
                icon: Icon(Icons.search),
                text: 'Search',
              ),
              Tab(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.checklist, size: 20),
                        SizedBox(height: 2),
                        Text('Selected', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                    if (selected.isNotEmpty)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            '${selected.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: _done,
            child: const Text(
              'Done',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRecentTab(),
          _buildSearchTab(),
          _buildSelectedTab(),
        ],
      ),
    );
  }
}
