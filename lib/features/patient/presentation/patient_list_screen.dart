import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';

import 'package:nurseos_v3/features/patient/presentation/widgets/patient_card.dart';
import 'package:nurseos_v3/features/profile/state/user_profile_controller.dart';
import 'package:nurseos_v3/shared/widgets/nurse_scaffold.dart';
import 'package:nurseos_v3/shared/widgets/animated_extended_fab.dart';
import 'package:nurseos_v3/core/theme/spacing.dart';
import 'package:nurseos_v3/core/theme/shape_tokens.dart';
import 'package:nurseos_v3/core/theme/animation_tokens.dart';

import '../../../shared/widgets/error/error_retry_tile.dart';
import '../../../shared/widgets/loading/patient_list_shimmer.dart';
import '../state/patient_providers.dart';
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
  late AnimationController _searchAnimationController;

  // Animations (only for search bar)
  late Animation<double> _searchHeightAnimation;

  // State
  bool _showSearchBar = true;
  String _searchQuery = '';

  // Constants (only for search bar)
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
    _searchAnimationController = AnimationController(
      duration: AnimationTokens.short, // 150ms from design tokens
      vsync: this,
    );
  }

  void _setupAnimations() {
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

    // Handle search bar state only (FAB handled by AnimatedExtendedFAB)
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
    _searchAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final patients = ref.watch(patientProvider);
    final userAsync = ref.watch(userProfileStreamProvider);

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
        floatingActionButton: AnimatedExtendedFAB(
          onPressed: _onAddPatientPressed,
          label: 'Add Patient',
          icon: Icons.add,
          scrollController: _scrollController,
          scrollThreshold: 100.0,
        ),
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
}
