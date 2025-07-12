import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';

import 'package:nurseos_v3/features/patient/presentation/widgets/patient_card.dart';
import 'package:nurseos_v3/features/profile/state/user_profile_controller.dart';
import 'package:nurseos_v3/shared/widgets/nurse_scaffold.dart';
import 'package:nurseos_v3/core/theme/spacing.dart';
import 'package:nurseos_v3/core/theme/shape_tokens.dart';
import 'package:nurseos_v3/core/theme/animation_tokens.dart';

import '../../../shared/widgets/error/error_retry_tile.dart';
import '../../../shared/widgets/loading/patient_list_shimmer.dart';
import '../state/patient_providers.dart';
import '../../agency/state/agency_context_provider.dart';
import '../../auth/state/auth_controller.dart';

class PatientListScreen extends ConsumerStatefulWidget {
  const PatientListScreen({super.key});

  @override
  ConsumerState<PatientListScreen> createState() => _PatientListScreenState();
}

class _PatientListScreenState extends ConsumerState<PatientListScreen>
    with TickerProviderStateMixin {
  // Controllers
  late ScrollController _scrollController;
  late AnimationController _fabAnimationController;
  late AnimationController _searchAnimationController;

  // Animations
  late Animation<double> _fabScaleAnimation;
  late Animation<double> _fabWidthAnimation;
  late Animation<double> _fabTextOpacityAnimation;
  late Animation<double> _searchHeightAnimation;

  // State
  bool _showCompactFab = false;
  bool _showSearchBar = true;
  String _searchQuery = '';

  // Constants
  static const double _fabExtendedWidth = 170.0; // Increased from 160.0
  static const double _fabCompactWidth = 56.0;
  static const double _scrollThreshold = 100.0;
  static const double _searchThreshold = 10.0;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _setupAnimations();
    _scrollController.addListener(_onScroll);
  }

  void _initializeControllers() {
    _scrollController = ScrollController();
    _fabAnimationController = AnimationController(
      duration: AnimationTokens.medium, // 300ms from design tokens
      vsync: this,
    );
    _searchAnimationController = AnimationController(
      duration: AnimationTokens.short, // 150ms from design tokens
      vsync: this,
    );
  }

  void _setupAnimations() {
    // FAB scale animation (subtle scale down when compact)
    _fabScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.easeOutCubic,
    ));

    // FAB width animation
    _fabWidthAnimation = Tween<double>(
      begin: _fabExtendedWidth,
      end: _fabCompactWidth,
    ).animate(CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.easeOutCubic,
    ));

    // FAB text opacity - fades out early in the animation
    _fabTextOpacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _fabAnimationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeInCubic),
    ));

    // Search bar height animation
    _searchHeightAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _searchAnimationController,
      curve: Curves.easeOutCubic,
    ));
  }

  void _onScroll() {
    final currentOffset = _scrollController.offset;

    // Handle FAB state
    final bool shouldShowCompact = currentOffset > _scrollThreshold;
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

    // Handle search bar state
    final bool shouldShowSearchBar = currentOffset <= _searchThreshold;
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
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value;
    });
  }

  void _onAddPatientPressed() {
    context.push('/patients/add');
  }

  void _onPatientTapped(String patientId) {
    context.push('/patients/$patientId');
  }

  void _onPatientActionPressed(String patientName) {
    debugPrint('Edit $patientName');
    // TODO: Implement patient action
  }

  List<dynamic> _getFilteredPatients(List<dynamic> patients) {
    if (_searchQuery.isEmpty) return patients;

    final query = _searchQuery.toLowerCase();
    return patients.where((patient) {
      final fullName = '${patient.firstName} ${patient.lastName}'.toLowerCase();
      final mrn = patient.mrn?.toLowerCase() ?? '';
      return fullName.contains(query) || mrn.contains(query);
    }).toList();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _fabAnimationController.dispose();
    _searchAnimationController.dispose();
    super.dispose();
  }

  void _fixUserAgency() async {
    try {
      final user = ref.read(authControllerProvider).value;
      if (user != null && user.activeAgencyId == null) {
        print('🔧 Fixing user agency - setting activeAgencyId to rising-phoenix');
        await ref.read(agencyContextNotifierProvider.notifier).setInitialAgency('rising-phoenix');
        print('✅ User agency fixed');
      }
    } catch (e) {
      print('❌ Failed to fix user agency: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final patients = ref.watch(patientProvider);
    final userAsync = ref.watch(userProfileStreamProvider);

    // Auto-fix user agency if needed
    final user = ref.watch(authControllerProvider).value;
    if (user != null && user.activeAgencyId == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _fixUserAgency());
    }

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
          data: (list) => _buildPatientList(context, list, userAsync),
        ),
        floatingActionButton: _buildAnimatedFAB(),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }

  Widget _buildPatientList(
      BuildContext context, List<dynamic> patients, AsyncValue userAsync) {
    final filteredPatients = _getFilteredPatients(patients);
    final title = _buildTitle(userAsync);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context, title),
        _buildSearchBar(),
        _buildPatientListView(filteredPatients),
      ],
    );
  }

  String _buildTitle(AsyncValue userAsync) {
    return userAsync.when(
      data: (user) => "Nurse ${user.firstName}'s Patients",
      loading: () => 'Loading...',
      error: (_, __) => 'Assigned Patients',
    );
  }

  Widget _buildHeader(BuildContext context, String title) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: const EdgeInsets.fromLTRB(
        SpacingTokens.md,
        SpacingTokens.md,
        SpacingTokens.md,
        SpacingTokens.sm,
      ),
      child: Text(
        title,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return SizeTransition(
      sizeFactor: _searchHeightAnimation,
      axisAlignment: -1.0,
      child: Container(
        margin: const EdgeInsets.fromLTRB(
          SpacingTokens.md,
          0,
          SpacingTokens.md,
          SpacingTokens.sm,
        ),
        child: TextField(
          onChanged: _onSearchChanged,
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
        ),
      ),
    );
  }

  Widget _buildPatientListView(List<dynamic> patients) {
    return Expanded(
      child: ListView.builder(
        key: const Key('patient_list'),
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(
          SpacingTokens.md,
          0,
          SpacingTokens.md,
          SpacingTokens.xxl * 2,
        ),
        itemCount: patients.length,
        itemBuilder: (context, index) => _buildPatientListItem(patients[index]),
      ),
    );
  }

  Widget _buildPatientListItem(dynamic patient) {
    return Padding(
      padding: const EdgeInsets.only(bottom: SpacingTokens.sm),
      child: Slidable(
        key: ValueKey(patient.id),
        endActionPane: ActionPane(
          motion: const DrawerMotion(),
          extentRatio: 0.4,
          children: [
            SlidableAction(
              onPressed: (_) => _onPatientActionPressed(patient.fullName),
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
          onTap: () => _onPatientTapped(patient.id),
          child: PatientCard(patient: patient),
        ),
      ),
    );
  }

  Widget _buildAnimatedFAB() {
    return AnimatedBuilder(
      animation: Listenable.merge([_fabAnimationController]),
      builder: (context, child) {
        return Transform.scale(
          scale: _fabScaleAnimation.value,
          child: SizedBox(
            width: _fabWidthAnimation.value,
            height: 56,
            child: FloatingActionButton(
              onPressed: _onAddPatientPressed,
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              elevation: 2,
              highlightElevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              child: _buildFABContent(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFABContent() {
    // Calculate current width progress (0.0 to 1.0)
    final widthProgress = (_fabWidthAnimation.value - _fabCompactWidth) /
        (_fabExtendedWidth - _fabCompactWidth);

    // Only show text when there's actually enough room (65%+ width)
    final showText = widthProgress > 0.65 && _fabWidthAnimation.value > 115;

    return ClipRect(
      child: Padding(
        // ✅ Conservative padding to prevent overflow
        padding: EdgeInsets.symmetric(
          horizontal: showText ? 18 : 16, // Reduced from 20 to 18
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add, size: 24),
            // ✅ Only add spacing and text when we have sufficient width
            if (showText) ...[
              const SizedBox(width: 12),
              // ✅ Flexible text to prevent overflow
              Flexible(
                child: AnimatedOpacity(
                  opacity: _fabTextOpacityAnimation.value,
                  duration: AnimationTokens.short,
                  child: const Text(
                    'Add Patient',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
