import '../../../core/theme/severity.dart';

enum Symptom {
  smoke('Smoke from the engine', Severity.stop),
  burningSmell('Burning smell', Severity.stop),
  steam('Steam from the bonnet', Severity.stop),
  flashingLight('A warning light is flashing', Severity.stop),
  weakBrakes('Brakes feel soft or weak', Severity.stop),
  hotGauge('Temperature gauge high', Severity.stop),
  strangeNoise('Strange noise', Severity.soon),
  shaking('Shaking or rough running', Severity.soon),
  lossOfPower('Loss of power', Severity.soon),
  leak('Fluid leaking under the car', Severity.soon);

  const Symptom(this.label, this.severity);

  final String label;
  final Severity severity;
}
