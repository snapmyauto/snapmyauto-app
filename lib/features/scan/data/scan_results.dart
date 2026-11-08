import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../icon_library/data/warning_light_repository.dart';
import '../../triage/domain/triage_result.dart';
import 'scan_repository.dart';

// triage result of a saved scan, worked out again from the light library
// so old scans pick up any changes to the light data
final scanResultProvider = Provider.family<TriageResult?, String>((
  ref,
  scanId,
) {
  final library = ref.watch(warningLightsProvider).value;
  final scans = ref.watch(scansProvider).value;
  if (library == null || scans == null) return null;
  for (final scan in scans) {
    if (scan.id == scanId) {
      return TriageResult.fromLabels(scan.lights.map((l) => l.label), library);
    }
  }
  return null;
});
