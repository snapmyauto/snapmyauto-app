import 'package:flutter/widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../domain/vehicle.dart';

extension FuelTypeUi on FuelType {
  String get label => switch (this) {
    FuelType.petrol => 'Petrol',
    FuelType.diesel => 'Diesel',
    FuelType.hybrid => 'Hybrid',
    FuelType.electric => 'Electric',
  };

  IconData get icon => switch (this) {
    FuelType.petrol => LucideIcons.fuel,
    FuelType.diesel => LucideIcons.droplets,
    FuelType.hybrid => LucideIcons.leaf,
    FuelType.electric => LucideIcons.zap,
  };
}
