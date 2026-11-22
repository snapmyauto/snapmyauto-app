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

  // The SOS text with a map link, or without one if location fails.
  Future<String> locationMessage() async {
    LatLng? here;
    try {
      here = await _location.current();
    } catch (_) {
      here = null;
    }
    return messageFor(here);
  }

  String messageFor(LatLng? here) {
    final message = StringBuffer(
      'SOS from SnapMyAuto. I need help with my car.',
    );
    if (here != null) {
      message.write(
        ' My location: https://maps.google.com/?q='
        '${here.latitude},${here.longitude}',
      );
    }
    return message.toString();
  }

  // Opens the SMS app with all contacts and the message filled in.
  // The user still has to press send.
  Future<bool> sendSms(List<EmergencyContact> contacts, String message) {
    if (contacts.isEmpty) return Future.value(false);

    final numbers = contacts.map((c) => _clean(c.phone)).join(',');
    // query is built by hand so spaces become %20 and not "+".
    final uri = Uri.parse('sms:$numbers?body=${Uri.encodeComponent(message)}');
    return launchUrl(uri);
  }

  String _clean(String phone) => phone.replaceAll(RegExp(r'[^0-9+]'), '');
}

final sosServiceProvider = Provider<SosService>(
  (ref) => SosService(ref.watch(locationServiceProvider)),
);
