import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/utils/location_service.dart';
import '../domain/emergency_contact.dart';

// Opens the dialer and SMS app for an emergency.
class SosService {
  SosService(this._location);

  final LocationService _location;

  // Primary contact if one is set, otherwise the first one.
  EmergencyContact? primaryOf(List<EmergencyContact> contacts) {
    if (contacts.isEmpty) return null;
    return contacts.firstWhere(
      (c) => c.isPrimary,
      orElse: () => contacts.first,
    );
  }

  Future<bool> call(EmergencyContact contact) {
    return launchUrl(Uri(scheme: 'tel', path: _clean(contact.phone)));
  }

  // Opens the SMS app with all contacts and a map link filled in.
  // The user still has to press send.
  Future<bool> sendLocationSms(List<EmergencyContact> contacts) async {
    if (contacts.isEmpty) return false;

    LatLng? here;
    try {
      here = await _location.current();
    } catch (_) {
      // Still send the message even if we can't get the location.
      here = null;
    }

    final message = StringBuffer(
      'SOS from SnapMyAuto. I need help with my car.',
    );
    if (here != null) {
      message.write(
        ' My location: https://maps.google.com/?q='
        '${here.latitude},${here.longitude}',
      );
    }

    final numbers = contacts.map((c) => _clean(c.phone)).join(',');
    // query is built by hand so spaces become %20 and not "+".
    final uri = Uri.parse(
      'sms:$numbers?body=${Uri.encodeComponent(message.toString())}',
    );
    return launchUrl(uri);
  }

  String _clean(String phone) => phone.replaceAll(RegExp(r'[^0-9+]'), '');
}

final sosServiceProvider = Provider<SosService>(
  (ref) => SosService(ref.watch(locationServiceProvider)),
);
