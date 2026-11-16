import '../../../core/theme/severity.dart';
import '../../icon_library/presentation/widgets/light_visuals.dart';
import '../domain/triage_result.dart';

// plain text for the result page and for read aloud
class TriageAdvice {
  TriageAdvice._();

  static String summary(Severity severity) {
    if (severity == Severity.stop) {
      return 'Pull over safely and turn off the engine. '
          'Driving on could cause serious damage.';
    }
    if (severity == Severity.soon) {
      return 'You can drive carefully for now. Get it checked at a garage soon.';
    }
    if (severity == Severity.info) {
      return 'This light only gives information. Nothing to worry about.';
    }
    return 'Nothing serious found. Keep an eye on it.';
  }

  static List<String> steps(TriageResult result) {
    if (result.steps.isNotEmpty) return result.steps;

    // no light with its own steps, so use simple ones for the severity
    if (result.severity == Severity.stop) {
      return [
        'Pull over where it is safe and switch on hazard lights.',
        'Turn off the engine and do not restart it.',
        'Call a mechanic or a tow service.',
      ];
    }
    if (result.severity == Severity.soon) {
      return [
        'Drive gently and avoid long trips.',
        'Book a garage visit in the next few days.',
      ];
    }
    return ['Keep driving as normal.', 'Scan again if a light comes on.'];
  }

  static List<String> reasons(TriageResult result) {
    final reasons = <String>[];
    final seen = <Severity>{};

    for (final light in result.lights) {
      if (seen.add(light.severity)) {
        reasons.add(
          '${light.severity.lightColour} = '
          '${light.severity.label.toLowerCase()}',
        );
      }
    }
    for (final symptom in result.symptoms) {
      reasons.add(symptom.label);
    }
    return reasons;
  }

  static String speech(TriageResult result) {
    final buffer = StringBuffer();
    buffer.write('Result: ${result.severity.label}. ');
    buffer.write('${summary(result.severity)} ');

    final light = result.worstLight;
    if (light != null) {
      buffer.write('${light.name}. ${light.meaning} ');
    }

    buffer.write('Can I keep driving? ${result.canDrive.answer}. ');
    buffer.write('Do this now. ');
    for (final step in steps(result)) {
      buffer.write('$step ');
    }
    return buffer.toString().trim();
  }
}
