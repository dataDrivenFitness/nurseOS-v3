// 📁 lib/features/schedule/shift_pool/services/patient_analysis_service.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nurseos_v3/features/patient/data/abstract_patient_repository.dart';
import 'package:nurseos_v3/features/patient/models/patient_model.dart';
import 'package:nurseos_v3/features/patient/models/patient_risk.dart';
import 'package:nurseos_v3/features/patient/data/patient_repository_provider.dart';

/// Service for analyzing patient loads and generating intelligent descriptions
///
/// ✅ Uses existing Patient model and risk assessment logic
/// ✅ Follows shift-centric architecture patterns
/// ✅ Provides caching for performance optimization
class PatientAnalysisService {
  final PatientRepository patientRepository;

  // Simple in-memory cache for patient data
  final Map<String, Patient> _patientCache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  static const Duration _cacheExpiry = Duration(minutes: 10);

  PatientAnalysisService(this.patientRepository);

  /// Generate intelligent patient load description from patient IDs
  ///
  /// Examples:
  /// - "4 patients: 3 high acuity, 2 fall risk, 1 isolation"
  /// - "2 patients: 1 high acuity, 1 fall risk"
  /// - "5 patients: 4 high acuity, 3 isolation"
  /// - "1 patient: high acuity"
  /// - "3 patients assigned" (fallback)
  Future<String> generatePatientLoadDescription(List<String> patientIds) async {
    if (patientIds.isEmpty) {
      return 'No patients assigned';
    }

    try {
      // Get patient data with caching
      final patients = await _getPatientsWithCache(patientIds);

      if (patients.isEmpty) {
        return _getFallbackDescription(patientIds.length);
      }

      // Analyze patient characteristics
      final analysis = _analyzePatients(patients);

      // Generate description based on analysis
      return _buildDescription(patientIds.length, analysis);
    } catch (e) {
      // Fallback on error
      return _getFallbackDescription(patientIds.length);
    }
  }

  /// Get patients with caching for performance
  Future<List<Patient>> _getPatientsWithCache(List<String> patientIds) async {
    final patients = <Patient>[];
    final uncachedIds = <String>[];
    final now = DateTime.now();

    // Check cache first
    for (final id in patientIds) {
      final cachedPatient = _patientCache[id];
      final cacheTime = _cacheTimestamps[id];

      if (cachedPatient != null &&
          cacheTime != null &&
          now.difference(cacheTime) < _cacheExpiry) {
        patients.add(cachedPatient);
      } else {
        uncachedIds.add(id);
      }
    }

    // Fetch uncached patients
    if (uncachedIds.isNotEmpty) {
      try {
        final freshPatients =
            await patientRepository.getPatientsByIds(uncachedIds);

        // Update cache
        for (final patient in freshPatients) {
          _patientCache[patient.id] = patient;
          _cacheTimestamps[patient.id] = now;
        }

        patients.addAll(freshPatients);
      } catch (e) {
        // Continue with cached patients only
      }
    }

    return patients;
  }

  /// Analyze patient characteristics for description generation
  PatientAnalysis _analyzePatients(List<Patient> patients) {
    int highRiskCount = 0;
    int mediumRiskCount = 0;
    int fallRiskCount = 0;
    int isolationCount = 0;

    for (final patient in patients) {
      // Use existing risk resolution logic
      final riskLevel = resolveRiskLevel(patient);

      switch (riskLevel) {
        case RiskLevel.high:
          highRiskCount++;
          break;
        case RiskLevel.medium:
          mediumRiskCount++;
          break;
        case RiskLevel.low:
        case RiskLevel.unknown:
          // Don't count low/unknown in descriptions
          break;
      }

      // Count clinical flags
      if (patient.isFallRisk == true) fallRiskCount++;
      if (patient.isIsolation == true) isolationCount++;
    }

    return PatientAnalysis(
      highRiskCount: highRiskCount,
      mediumRiskCount: mediumRiskCount,
      fallRiskCount: fallRiskCount,
      isolationCount: isolationCount,
    );
  }

  /// Build human-readable description from analysis
  String _buildDescription(int totalCount, PatientAnalysis analysis) {
    final characteristics = <String>[];

    // Add high acuity patients (high + medium risk)
    final acuityCount = analysis.highRiskCount + analysis.mediumRiskCount;
    if (acuityCount > 0) {
      characteristics.add('$acuityCount high acuity');
    }

    // Add fall risk patients
    if (analysis.fallRiskCount > 0) {
      characteristics.add('${analysis.fallRiskCount} fall risk');
    }

    // Add isolation patients
    if (analysis.isolationCount > 0) {
      characteristics.add('${analysis.isolationCount} isolation');
    }

    // Build final description
    final patientText = totalCount == 1 ? 'patient' : 'patients';

    if (characteristics.isEmpty) {
      return '$totalCount $patientText assigned';
    }

    if (totalCount == 1) {
      return '1 patient: ${characteristics.join(', ')}';
    }

    return '$totalCount $patientText: ${characteristics.join(', ')}';
  }

  /// Fallback description when patient data unavailable
  String _getFallbackDescription(int count) {
    final patientText = count == 1 ? 'patient' : 'patients';
    return '$count $patientText assigned';
  }

  /// Clear expired cache entries
  void _cleanupCache() {
    final now = DateTime.now();
    final expiredKeys = _cacheTimestamps.entries
        .where((entry) => now.difference(entry.value) >= _cacheExpiry)
        .map((entry) => entry.key)
        .toList();

    for (final key in expiredKeys) {
      _patientCache.remove(key);
      _cacheTimestamps.remove(key);
    }
  }

  /// Clear all cached data
  void clearCache() {
    _patientCache.clear();
    _cacheTimestamps.clear();
  }

  /// Get cache statistics for debugging
  Map<String, dynamic> getCacheStats() {
    _cleanupCache();
    return {
      'cachedPatients': _patientCache.length,
      'oldestEntry': _cacheTimestamps.values.isEmpty
          ? null
          : _cacheTimestamps.values.reduce((a, b) => a.isBefore(b) ? a : b),
      'newestEntry': _cacheTimestamps.values.isEmpty
          ? null
          : _cacheTimestamps.values.reduce((a, b) => a.isAfter(b) ? a : b),
    };
  }
}

/// Analysis results for patient characteristics
class PatientAnalysis {
  final int highRiskCount;
  final int mediumRiskCount;
  final int fallRiskCount;
  final int isolationCount;

  const PatientAnalysis({
    required this.highRiskCount,
    required this.mediumRiskCount,
    required this.fallRiskCount,
    required this.isolationCount,
  });
}

/// Riverpod provider for PatientAnalysisService
final patientAnalysisServiceProvider = Provider<PatientAnalysisService?>((ref) {
  final patientRepository = ref.watch(patientRepositoryProvider);

  if (patientRepository == null) {
    return null;
  }

  return PatientAnalysisService(patientRepository);
});
