import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';

import 'package:nurseos_v3/features/patient/models/patient_extensions.dart';
import 'package:nurseos_v3/features/patient/presentation/widgets/patient_card.dart';
import 'package:nurseos_v3/features/profile/state/user_profile_controller.dart';
import 'package:nurseos_v3/shared/widgets/nurse_scaffold.dart';
import 'package:nurseos_v3/core/theme/spacing.dart';
import 'package:nurseos_v3/core/theme/shape_tokens.dart';

import '../../../shared/widgets/error/error_retry_tile.dart';
import '../../../shared/widgets/loading/patient_list_shimmer.dart';
import '../state/patient_providers.dart';

class PatientListScreen extends ConsumerStatefulWidget {
  const PatientListScreen({super.key});

  @override
  ConsumerState<PatientListScreen> createState() => _PatientListScreenState();
}

class _PatientListScreenState extends ConsumerState<PatientListScreen>
    with TickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _fabAnimationController;
  late AnimationController _searchAnimationController;
  late Animation<double> _fabScaleAnimation;
  late Animation<double> _fabWidthAnimation;
  late Animation<double> _searchHeightAnimation;

  bool _showCompactFab = false;
  bool _showSearchBar = true;
  double _lastScrollOffset = 0;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _searchAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _fabScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.85,
    ).animate(CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.easeInOut,
    ));

    _fabWidthAnimation = Tween<double>(
      begin: 140.0,
      end: 56.0,
    ).animate(CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.easeInOut,
    ));

    _searchHeightAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0, // Collapse to zero height
    ).animate(CurvedAnimation(
      parent: _searchAnimationController,
      curve: Curves.easeInOut,
    ));

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final currentOffset = _scrollController.offset;
    final bool shouldShowCompact = currentOffset > 100;

    if (shouldShowCompact != _showCompactFab) {
      setState(() {
        _showCompactFab = shouldShowCompact;
      });

      if (_showCompactFab) {
        _fabAnimationController.forward();
      } else {
        _fabAnimationController.reverse();
      }
    }

    // Show search bar only when at the very top (offset <= 10 for small tolerance)
    final bool shouldShowSearchBar = currentOffset <= 10;

    if (shouldShowSearchBar != _showSearchBar) {
      setState(() {
        _showSearchBar = shouldShowSearchBar;
      });

      if (_showSearchBar) {
        _searchAnimationController.reverse();
      } else {
        _searchAnimationController.forward();
      }
    }

    _lastScrollOffset = currentOffset;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _fabAnimationController.dispose();
    _searchAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final patients = ref.watch(patientProvider);
    final userAsync = ref.watch(userProfileStreamProvider);

    final title = userAsync.when(
      data: (user) => "Nurse ${user.firstName}'s Patients",
      loading: () => 'Loading...',
      error: (_, __) => 'Assigned Patients',
    );

    return NurseScaffold(
      child: Scaffold(
        body: patients.when(
          loading: () => const KeyedSubtree(
            key: Key('patient_list_loading'),
            child: PatientListShimmer(),
          ),
          error: (err, _) => KeyedSubtree(
            key: const Key('patient_list_error'),
            child: ErrorRetryTile(
              message: 'Failed to load patients.',
              onRetry: () => ref.invalidate(patientProvider),
            ),
          ),
          data: (list) {
            final filteredList = _searchQuery.isEmpty
                ? list
                : list.where((patient) {
                    final query = _searchQuery.toLowerCase();
                    final fullName = '${patient.firstName} ${patient.lastName}'
                        .toLowerCase();
                    final mrn = patient.mrn?.toLowerCase() ?? '';
                    return fullName.contains(query) || mrn.contains(query);
                  }).toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  padding: const EdgeInsets.fromLTRB(SpacingTokens.md,
                      SpacingTokens.md, SpacingTokens.md, SpacingTokens.sm),
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                  ),
                ),
                SizeTransition(
                  sizeFactor: _searchHeightAnimation,
                  axisAlignment: -1.0, // Align to top during collapse
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(
                      SpacingTokens.md,
                      0,
                      SpacingTokens.md,
                      SpacingTokens.sm,
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search patients...',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(SpacingTokens.md),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: SpacingTokens.md,
                          vertical: SpacingTokens.sm,
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    key: const Key('patient_list'),
                    controller: _scrollController,
                    padding: EdgeInsets.fromLTRB(
                      SpacingTokens.md,
                      0,
                      SpacingTokens.md,
                      SpacingTokens.xxl * 2,
                    ),
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final patient = filteredList[index];

                      return Padding(
                        padding:
                            const EdgeInsets.only(bottom: SpacingTokens.sm),
                        child: Slidable(
                          key: ValueKey(patient.id),
                          endActionPane: ActionPane(
                            motion: const DrawerMotion(),
                            extentRatio: 0.4,
                            children: [
                              SlidableAction(
                                onPressed: (_) =>
                                    debugPrint('Edit ${patient.fullName}'),
                                backgroundColor: Colors.blue.shade600,
                                foregroundColor: Colors.white,
                                icon: Icons.edit,
                                label: 'Add Record',
                                borderRadius: ShapeTokens.cardRadius,
                              ),
                            ],
                          ),
                          child: InkWell(
                            borderRadius: ShapeTokens.cardRadius,
                            onTap: () =>
                                context.push('/patients/${patient.id}'),
                            child: PatientCard(patient: patient),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
        floatingActionButton: AnimatedBuilder(
          animation: _fabAnimationController,
          builder: (context, child) {
            return Transform.scale(
              scale: _fabScaleAnimation.value,
              child: SizedBox(
                width: _fabWidthAnimation.value,
                height: 56,
                child: _showCompactFab
                    ? FloatingActionButton(
                        onPressed: () => context.push('/patients/add'),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor:
                            Theme.of(context).colorScheme.onPrimary,
                        elevation: 2,
                        highlightElevation: 6,
                        shape: const CircleBorder(), // Perfect circle
                        child: const Icon(Icons.add, size: 24),
                      )
                    : FloatingActionButton.extended(
                        onPressed: () => context.push('/patients/add'),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor:
                            Theme.of(context).colorScheme.onPrimary,
                        elevation: 2,
                        highlightElevation: 6,
                        icon: const Icon(Icons.add, size: 24),
                        label: const Text(
                          'Add Patient',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
              ),
            );
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }
}
