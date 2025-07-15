// 📁 lib/shared/widgets/select_items_screen.dart

import 'package:flutter/material.dart';
import 'package:nurseos_v3/core/theme/app_colors.dart';
import 'package:nurseos_v3/core/theme/spacing.dart';
import 'package:nurseos_v3/core/theme/shape_tokens.dart';
import 'package:nurseos_v3/shared/widgets/app_snackbar.dart';
import 'package:nurseos_v3/shared/widgets/nurse_scaffold.dart';
import 'package:nurseos_v3/shared/widgets/info_pill.dart';

/// Configuration for an item that can be selected
class SelectableItem {
  final String id;
  final String label;
  final String? code; // ICD code, allergen code, etc.
  final String category;
  final SelectableItemSeverity severity;
  final String? description;

  const SelectableItem({
    required this.id,
    required this.label,
    this.code,
    required this.category,
    this.severity = SelectableItemSeverity.unknown,
    this.description,
  });
}

/// Severity/risk levels for items
enum SelectableItemSeverity { high, medium, low, unknown }

/// Configuration for the SelectItemsScreen
class SelectItemsConfig {
  final String title;
  final String searchHint;
  final String noItemsMessage;
  final String noSelectionMessage;
  final String noSelectionSubMessage;
  final String
      itemTypePlural; // e.g., "diagnoses", "allergies", "diet restrictions"
  final String
      itemTypeSingular; // e.g., "diagnosis", "allergy", "diet restriction"
  final String codeLabel; // e.g., "ICD", "Code", "Type"
  final bool showSeverityIndicator;
  final bool showCodeField;
  final bool showCategoryFilter;
  final IconData tabRecentIcon;
  final IconData tabSearchIcon;
  final IconData tabSelectedIcon;
  final IconData emptyStateIcon;
  final Color? accentColor; // Color for selection indicators and highlights

  const SelectItemsConfig({
    required this.title,
    required this.searchHint,
    required this.noItemsMessage,
    required this.noSelectionMessage,
    required this.noSelectionSubMessage,
    required this.itemTypePlural,
    required this.itemTypeSingular,
    required this.codeLabel,
    this.showSeverityIndicator = true,
    this.showCodeField = true,
    this.showCategoryFilter = true,
    this.tabRecentIcon = Icons.access_time,
    this.tabSearchIcon = Icons.search,
    this.tabSelectedIcon = Icons.checklist,
    this.emptyStateIcon = Icons.checklist,
    this.accentColor,
  });
}

/// Reusable screen for selecting multiple items with search, categories, and tabs
class SelectItemsScreen extends StatefulWidget {
  final List<String> initialSelection;
  final List<SelectableItem> allItems;
  final List<String> recentItems;
  final List<String> commonItems; // 🔄 Keep original parameter
  final SelectItemsConfig config;
  final List<String>? favoriteItems; // 🆕 Optional favorites
  final Function(String itemId)? onToggleFavorite; // 🆕 Optional callback
  final Future<void> Function(List<String> selectedItems)?
      onDone; // 🆕 Optional done callback

  const SelectItemsScreen({
    super.key,
    required this.initialSelection,
    required this.allItems,
    required this.recentItems,
    required this.commonItems, // 🔄 Keep original
    required this.config,
    this.favoriteItems, // 🆕 Optional
    this.onToggleFavorite, // 🆕 Optional
    this.onDone, // 🆕 Optional
  });

  @override
  State<SelectItemsScreen> createState() => _SelectItemsScreenState();
}

class _SelectItemsScreenState extends State<SelectItemsScreen>
    with TickerProviderStateMixin {
  late List<String> selected;
  late TabController _tabController;
  String query = '';
  String? selectedCategory;
  bool showSelectedOnly = false;

  // 🆕 Getter to determine if favorites are enabled
  bool get _favoritesEnabled =>
      widget.favoriteItems != null && widget.onToggleFavorite != null;

  List<String> get categories {
    final cats = widget.allItems.map((item) => item.category).toSet().toList();
    cats.sort();
    return ['All', ...cats];
  }

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

  void _toggle(String itemId) {
    setState(() {
      if (selected.contains(itemId)) {
        selected.remove(itemId);
      } else {
        selected.add(itemId);
      }
    });
  }

  void _clearAll() {
    setState(() {
      selected.clear();
    });
  }

  void _done() async {
    // 🆕 Call custom onDone handler if provided
    if (widget.onDone != null) {
      await widget.onDone!(selected);
    } else {
      // 🔄 Default behavior - just pop with results
      Navigator.pop(context, selected);
    }
  }

  // 🆕 Show favorite toggle dialog (only when favorites enabled)
  void _showFavoriteDialog(SelectableItem item) {
    if (!_favoritesEnabled) return;

    final isFavorite = widget.favoriteItems!.contains(item.id);
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;
    final textScaler = MediaQuery.textScalerOf(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              isFavorite ? Icons.star : Icons.star_border,
              color: Colors.amber,
              size: textScaler.scale(24),
            ),
            const SizedBox(width: SpacingTokens.xs),
            Expanded(
              child: Text(
                isFavorite ? 'Remove from Favorites' : 'Add to Favorites',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontSize: textScaler.scale(18),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          isFavorite
              ? 'Remove "${item.label}" from your favorites?'
              : 'Add "${item.label}" to your favorites for quick access?',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontSize: textScaler.scale(14),
            color: colors.text,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: theme.textTheme.labelMedium?.copyWith(
                fontSize: textScaler.scale(14),
                color: colors.subdued,
              ),
            ),
          ),
          FilledButton(
            onPressed: () {
              widget.onToggleFavorite?.call(item.id);
              Navigator.pop(context);

              // Show feedback snackbar
              if (isFavorite) {
                AppSnackbar.warning(
                  context,
                  'Removed from favorites',
                  duration: const Duration(seconds: 2),
                );
              } else {
                AppSnackbar.success(
                  context,
                  'Added to favorites',
                  duration: const Duration(seconds: 2),
                );
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: isFavorite ? colors.danger : Colors.amber,
            ),
            child: Text(
              isFavorite ? 'Remove' : 'Add',
              style: theme.textTheme.labelMedium?.copyWith(
                fontSize: textScaler.scale(14),
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<SelectableItem> _getFilteredItems() {
    var filtered = widget.allItems.where((item) {
      // Text search
      final matchesQuery = query.isEmpty ||
          item.label.toLowerCase().contains(query.toLowerCase()) ||
          (item.code?.toLowerCase().contains(query.toLowerCase()) ?? false);

      // Category filter
      final matchesCategory = !widget.config.showCategoryFilter ||
          selectedCategory == null ||
          selectedCategory == 'All' ||
          item.category == selectedCategory;

      // Show selected only filter
      final matchesSelection = !showSelectedOnly || selected.contains(item.id);

      return matchesQuery && matchesCategory && matchesSelection;
    }).toList();

    // Sort by selected first, then by severity, then alphabetically
    filtered.sort((a, b) {
      final aSelected = selected.contains(a.id);
      final bSelected = selected.contains(b.id);

      if (aSelected && !bSelected) return -1;
      if (!aSelected && bSelected) return 1;

      // Sort by severity if showing severity indicator
      if (widget.config.showSeverityIndicator) {
        final severityOrder = {
          SelectableItemSeverity.high: 0,
          SelectableItemSeverity.medium: 1,
          SelectableItemSeverity.low: 2,
          SelectableItemSeverity.unknown: 3,
        };

        final aSeverity = severityOrder[a.severity] ?? 3;
        final bSeverity = severityOrder[b.severity] ?? 3;

        if (aSeverity != bSeverity) {
          return aSeverity.compareTo(bSeverity);
        }
      }

      return a.label.compareTo(b.label);
    });

    return filtered;
  }

  Widget _buildSearchSection() {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;
    final textScaler = MediaQuery.textScalerOf(context);
    final accentColor = widget.config.accentColor ?? colors.brandPrimary;

    return Container(
      padding: const EdgeInsets.all(SpacingTokens.md),
      decoration: BoxDecoration(
        color: colors.surface,
        boxShadow: [
          BoxShadow(
            color: colors.subdued.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search field
          TextField(
            onChanged: (val) => setState(() => query = val),
            style: theme.textTheme.bodyLarge?.copyWith(
              fontSize: textScaler.scale(16),
              color: colors.text,
            ),
            decoration: InputDecoration(
              hintText: widget.config.searchHint,
              hintStyle: theme.textTheme.bodyMedium?.copyWith(
                fontSize: textScaler.scale(14),
                color: colors.subdued,
              ),
              prefixIcon: Icon(
                Icons.search,
                color: colors.subdued,
                size: textScaler.scale(20),
              ),
              suffixIcon: query.isNotEmpty
                  ? IconButton(
                      icon: Icon(
                        Icons.clear,
                        color: colors.subdued,
                        size: textScaler.scale(20),
                      ),
                      onPressed: () => setState(() => query = ''),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: ShapeTokens.cardRadius,
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: colors.surfaceVariant,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: SpacingTokens.md,
                vertical: SpacingTokens.sm,
              ),
            ),
          ),

          // Category filter chips (only show if enabled)
          if (widget.config.showCategoryFilter) ...[
            const SizedBox(height: SpacingTokens.sm),
            SizedBox(
              height: 36,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final isSelected = selectedCategory == category ||
                      (selectedCategory == null && category == 'All');

                  return Padding(
                    padding: const EdgeInsets.only(right: SpacingTokens.xs),
                    child: FilterChip(
                      label: Text(
                        category,
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontSize: textScaler.scale(12),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: accentColor.withOpacity(0.15),
                      backgroundColor: colors.surfaceVariant,
                      shape: RoundedRectangleBorder(
                        borderRadius: ShapeTokens.pillRadius,
                      ),
                      side: BorderSide(
                        color: isSelected
                            ? accentColor
                            : colors.subdued.withOpacity(0.3),
                      ),
                      showCheckmark: false, // 🆕 Remove the checkmark
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
            const SizedBox(
                height: SpacingTokens
                    .md), // 🆕 Added bottom spacing after filter chips
          ],
        ],
      ),
    );
  }

  Widget _buildBottomSelectionBar() {
    if (selected.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;
    final textScaler = MediaQuery.textScalerOf(context);
    final accentColor = widget.config.accentColor ?? colors.brandPrimary;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.md,
        vertical: SpacingTokens.sm,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(
          top: BorderSide(
            color: accentColor.withAlpha(128), // 0.5 * 255 = 128 (match top)
            width: 1, // Ensure same thickness
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: accentColor,
              size: textScaler.scale(20),
            ),
            const SizedBox(width: SpacingTokens.xs),
            Expanded(
              child: Text(
                selected.length == 1
                    ? '1 ${widget.config.itemTypeSingular} selected'
                    : '${selected.length} ${widget.config.itemTypePlural} selected',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: textScaler.scale(15),
                  color: accentColor,
                ),
              ),
            ),
            TextButton(
              onPressed: _clearAll,
              child: Text(
                'Clear',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontSize: textScaler.scale(12),
                  color: colors.danger,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InfoPillType _getSeverityPillType(SelectableItemSeverity severity) {
    switch (severity) {
      case SelectableItemSeverity.high:
        return InfoPillType.danger; // Red/warning color
      case SelectableItemSeverity.medium:
        return InfoPillType.allergy; // Orange/warning color
      case SelectableItemSeverity.low:
        return InfoPillType.dietRestriction; // Green color
      case SelectableItemSeverity.unknown:
        return InfoPillType.diagnosis; // Default blue color
    }
  }

  String _getSeverityLabel(SelectableItemSeverity severity) {
    switch (severity) {
      case SelectableItemSeverity.high:
        return 'High';
      case SelectableItemSeverity.medium:
        return 'Med';
      case SelectableItemSeverity.low:
        return 'Low';
      case SelectableItemSeverity.unknown:
        return '';
    }
  }

  Widget _buildItemCard(SelectableItem item) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;
    final textScaler = MediaQuery.textScalerOf(context);
    final accentColor = widget.config.accentColor ?? colors.brandPrimary;
    final isSelected = selected.contains(item.id);
    final isFavorite =
        _favoritesEnabled && widget.favoriteItems!.contains(item.id); // 🆕
    final severityPillType = _getSeverityPillType(item.severity);
    final severityLabel = _getSeverityLabel(item.severity);

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.md,
        vertical: SpacingTokens.xs,
      ),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: ShapeTokens.cardRadius,
        border: isSelected
            ? Border.all(color: accentColor, width: 2)
            : Border.all(
                color: colors.subdued
                    .withOpacity(0.3), // 🆕 Increased from 0.1 to 0.3
                width: 1.5, // 🆕 Increased from 1 to 1.5
              ),
      ),
      child: ListTile(
        leading: Checkbox(
          value: isSelected,
          onChanged: (_) => _toggle(item.id),
          activeColor: accentColor,
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                item.label,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  fontSize: textScaler.scale(16),
                  color: isSelected ? accentColor : colors.text,
                ),
              ),
            ),
            // 🆕 Show favorite star if favorited
            if (isFavorite) ...[
              Icon(
                Icons.star,
                color: Colors.amber,
                size: textScaler.scale(16),
              ),
              const SizedBox(width: SpacingTokens.xs),
            ],
            // Compact severity indicator using InfoPill
            if (widget.config.showSeverityIndicator && severityLabel.isNotEmpty)
              InfoPill(
                text: severityLabel,
                type: severityPillType,
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.config.showCodeField && item.code != null)
              Text(
                '${widget.config.codeLabel}: ${item.code}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.subdued,
                  fontSize: textScaler.scale(12),
                ),
              ),
            Text(
              item.category,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.subdued.withOpacity(0.8),
                fontSize: textScaler.scale(11),
                fontStyle: FontStyle.italic,
              ),
            ),
            if (item.description != null)
              Text(
                item.description!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.subdued,
                  fontSize: textScaler.scale(11),
                ),
              ),
          ],
        ),
        onTap: () => _toggle(item.id),
        // 🆕 Long press handler with debug print
        onLongPress: () {
          print('🔗 Long pressed item: ${item.label} (${item.id})');
          if (_favoritesEnabled) {
            _showFavoriteDialog(item);
          } else {
            print(
                '   Favorites not enabled - would show favorites dialog here');
          }
        },
        contentPadding: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.sm,
          vertical: SpacingTokens.xs,
        ),
      ),
    );
  }

  Widget _buildRecentTab() {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;
    final textScaler = MediaQuery.textScalerOf(context);

    return ListView(
      children: [
        if (widget.recentItems.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.all(SpacingTokens.md),
            child: Text(
              'Recently Used',
              style: theme.textTheme.titleMedium?.copyWith(
                fontSize: textScaler.scale(16),
                fontWeight: FontWeight.w600,
                color: colors.text,
              ),
            ),
          ),
          ...widget.recentItems.map((itemId) {
            final item = widget.allItems.firstWhere(
              (e) => e.id == itemId,
              orElse: () => SelectableItem(
                id: itemId,
                label: itemId,
                category: 'Other',
              ),
            );
            return _buildItemCard(item);
          }),
          const SizedBox(height: SpacingTokens.lg),
        ],

        // 🆕 Conditional favorites section (only show if favorites enabled)
        if (_favoritesEnabled) ...[
          Padding(
            padding: const EdgeInsets.all(SpacingTokens.md),
            child: Row(
              children: [
                Icon(
                  Icons.star,
                  color: Colors.amber,
                  size: textScaler.scale(20),
                ),
                const SizedBox(width: SpacingTokens.xs),
                Text(
                  'Favorites',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontSize: textScaler.scale(16),
                    fontWeight: FontWeight.w600,
                    color: colors.text,
                  ),
                ),
              ],
            ),
          ),
          if (widget.favoriteItems!.isEmpty)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: SpacingTokens.md),
              padding: const EdgeInsets.all(SpacingTokens.lg),
              decoration: BoxDecoration(
                color: colors.surfaceVariant.withOpacity(0.5),
                borderRadius: ShapeTokens.cardRadius,
                border: Border.all(
                  color: colors.subdued.withOpacity(0.2),
                  style: BorderStyle.solid,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.star_border,
                    color: colors.subdued.withOpacity(0.7),
                    size: textScaler.scale(32),
                  ),
                  const SizedBox(height: SpacingTokens.xs),
                  Text(
                    'No favorites yet',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.subdued,
                      fontWeight: FontWeight.w500,
                      fontSize: textScaler.scale(14),
                    ),
                  ),
                  const SizedBox(height: SpacingTokens.xs),
                  Text(
                    'Long press any item to add to favorites',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.subdued.withOpacity(0.8),
                      fontStyle: FontStyle.italic,
                      fontSize: textScaler.scale(12),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            ...widget.favoriteItems!.map((itemId) {
              final item = widget.allItems.firstWhere(
                (e) => e.id == itemId,
                orElse: () => SelectableItem(
                  id: itemId,
                  label: itemId,
                  category: 'Other',
                ),
              );
              return _buildItemCard(item);
            }),
          const SizedBox(height: SpacingTokens.lg),
        ],

        // 🔄 Keep original "Common" section (always show when commonItems exist)
        if (widget.commonItems.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.all(SpacingTokens.md),
            child: Text(
              'Common ${widget.config.itemTypePlural.split(' ').map((word) => word[0].toUpperCase() + word.substring(1)).join(' ')}',
              style: theme.textTheme.titleMedium?.copyWith(
                fontSize: textScaler.scale(16),
                fontWeight: FontWeight.w600,
                color: colors.text,
              ),
            ),
          ),
          ...widget.commonItems.map((itemId) {
            final item = widget.allItems.firstWhere(
              (e) => e.id == itemId,
              orElse: () => SelectableItem(
                id: itemId,
                label: itemId,
                category: 'Other',
              ),
            );
            return _buildItemCard(item);
          }),
        ],

        const SizedBox(height: 100), // Space for bottom bar
      ],
    );
  }

  Widget _buildSearchTab() {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;
    final textScaler = MediaQuery.textScalerOf(context);
    final filtered = _getFilteredItems();

    return Column(
      children: [
        _buildSearchSection(),
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off,
                        size: textScaler.scale(48),
                        color: colors.subdued,
                      ),
                      const SizedBox(height: SpacingTokens.md),
                      Text(
                        query.isEmpty
                            ? 'Enter search terms above'
                            : widget.config.noItemsMessage,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontSize: textScaler.scale(16),
                          color: colors.subdued,
                        ),
                      ),
                      if (query.isNotEmpty) ...[
                        const SizedBox(height: SpacingTokens.xs),
                        Text(
                          'Try different keywords or check spelling',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: textScaler.scale(14),
                            color: colors.subdued.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ],
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.zero, // Remove default ListView padding
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    if (index == filtered.length - 1) {
                      // Add padding after last item for bottom bar
                      return Column(
                        children: [
                          _buildItemCard(filtered[index]),
                          const SizedBox(height: 100),
                        ],
                      );
                    }
                    return _buildItemCard(filtered[index]);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildSelectedTab() {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;
    final textScaler = MediaQuery.textScalerOf(context);

    return selected.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  widget.config.emptyStateIcon,
                  size: textScaler.scale(48),
                  color: colors.subdued,
                ),
                const SizedBox(height: SpacingTokens.md),
                Text(
                  widget.config.noSelectionMessage,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontSize: textScaler.scale(16),
                    color: colors.subdued,
                  ),
                ),
                const SizedBox(height: SpacingTokens.xs),
                Text(
                  widget.config.noSelectionSubMessage,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: textScaler.scale(14),
                    color: colors.subdued.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.only(top: SpacingTokens.md),
            itemCount: selected.length,
            itemBuilder: (context, index) {
              final itemId = selected[index];
              final item = widget.allItems.firstWhere(
                (e) => e.id == itemId,
                orElse: () => SelectableItem(
                  id: itemId,
                  label: itemId,
                  category: 'Other',
                ),
              );
              if (index == selected.length - 1) {
                // Add padding after last item for bottom bar
                return Column(
                  children: [
                    _buildItemCard(item),
                    const SizedBox(height: 100),
                  ],
                );
              }
              return _buildItemCard(item);
            },
          );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;
    final textScaler = MediaQuery.textScalerOf(context);
    final accentColor = widget.config.accentColor ?? colors.brandPrimary;

    return NurseScaffold(
      child: Scaffold(
        backgroundColor: colors.background,
        appBar: AppBar(
          title: Text(
            widget.config.title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontSize: textScaler.scale(20),
              fontWeight: FontWeight.w600,
              color: colors.onSurface,
            ),
          ),
          backgroundColor: colors.surface,
          iconTheme: IconThemeData(
            color: colors.onSurface,
            size: textScaler.scale(24),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight),
            child: Container(
              decoration: BoxDecoration(
                color: accentColor.withAlpha(20), // 0.08 * 255 ≈ 20
                border: Border(
                  bottom: BorderSide(
                    color: accentColor
                        .withAlpha(128), // 0.5 * 255 = 128 (more visible)
                    width: 1, // Match bottom bar thickness
                  ),
                ),
              ),
              child: TabBar(
                controller: _tabController,
                labelColor: Colors.white,
                unselectedLabelColor: colors.subdued,
                indicator: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorPadding: const EdgeInsets.symmetric(
                  horizontal: SpacingTokens.xs,
                  vertical: SpacingTokens.xs,
                ),
                dividerColor:
                    Colors.transparent, // 🆕 Remove default TabBar divider
                labelStyle: theme.textTheme.labelMedium?.copyWith(
                  fontSize: textScaler.scale(12),
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: theme.textTheme.labelMedium?.copyWith(
                  fontSize: textScaler.scale(12),
                  fontWeight: FontWeight.w500,
                ),
                tabs: [
                  Tab(
                    icon: Icon(
                      widget.config.tabRecentIcon,
                      size: textScaler.scale(18),
                    ),
                    text: 'Recent',
                  ),
                  Tab(
                    icon: Icon(
                      widget.config.tabSearchIcon,
                      size: textScaler.scale(18),
                    ),
                    text: 'Search',
                  ),
                  Tab(
                    icon: Icon(
                      widget.config.tabSelectedIcon,
                      size: textScaler.scale(18),
                    ),
                    text: 'Selected',
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: _done,
              child: Text(
                'Done',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontSize: textScaler.scale(16),
                  color: colors.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        body: Stack(
          children: [
            TabBarView(
              controller: _tabController,
              children: [
                _buildRecentTab(),
                _buildSearchTab(),
                _buildSelectedTab(),
              ],
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildBottomSelectionBar(),
            ),
          ],
        ),
      ),
    );
  }
}
