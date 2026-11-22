import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../core/theme/severity.dart';
import '../../../core/utils/formatters.dart';
import '../../reminders/domain/reminder.dart';
import '../../reminders/presentation/widgets/reminder_type_ui.dart';
import '../domain/vehicle.dart';
import '../presentation/widgets/fuel_type_ui.dart';

class ReportScan {
  const ReportScan({this.date, required this.lights, this.worst});

  final DateTime? date;
  final List<String> lights;
  final Severity? worst;
}

class VehicleReport {
  const VehicleReport({
    required this.vehicle,
    required this.counts,
    required this.scans,
    required this.open,
    required this.done,
  });

  final Vehicle vehicle;
  final Map<Severity, int> counts;
  final List<ReportScan> scans;
  final List<Reminder> open;
  final List<Reminder> done;
}

const _ink = PdfColor.fromInt(0xFF1B1F24);
const _muted = PdfColor.fromInt(0xFF5F6670);
const _line = PdfColor.fromInt(0xFFD9DDE2);

// one pdf with a section per vehicle, plus the owner when given
Future<Uint8List> buildReportPdf({
  required String title,
  String? ownerName,
  String? ownerEmail,
  required List<VehicleReport> vehicles,
}) {
  final doc = pw.Document(title: title, author: 'SnapMyAuto');

  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(36),
      footer: (context) => pw.Align(
        alignment: pw.Alignment.centerRight,
        child: pw.Text(
          'SnapMyAuto - page ${context.pageNumber} of ${context.pagesCount}',
          style: const pw.TextStyle(fontSize: 9, color: _muted),
        ),
      ),
      build: (context) => [
        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: 22,
            fontWeight: pw.FontWeight.bold,
            color: _ink,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          'Made on ${formatDate(DateTime.now())}',
          style: const pw.TextStyle(fontSize: 10, color: _muted),
        ),
        if (ownerName != null || ownerEmail != null) ...[
          pw.SizedBox(height: 14),
          _heading('Owner'),
          _row('Name', ownerName ?? '-'),
          _row('Email', ownerEmail ?? '-'),
        ],
        if (vehicles.isEmpty) ...[
          pw.SizedBox(height: 14),
          pw.Text('No vehicles saved.'),
        ],
        for (final v in vehicles) ..._vehicleSection(v),
        pw.SizedBox(height: 18),
        pw.Text(
          'SnapMyAuto gives general advice only. It does not replace a mechanic.',
          style: const pw.TextStyle(fontSize: 9, color: _muted),
        ),
      ],
    ),
  );

  return doc.save();
}

List<pw.Widget> _vehicleSection(VehicleReport r) {
  final v = r.vehicle;
  final odometer = v.odometerKm;

  return [
    pw.SizedBox(height: 18),
    pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 6),
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: _line)),
      ),
      child: pw.Text(
        '${v.year} ${v.make} ${v.model}'
        '${v.nickname?.isNotEmpty == true ? ' (${v.nickname})' : ''}',
        style: pw.TextStyle(
          fontSize: 16,
          fontWeight: pw.FontWeight.bold,
          color: _ink,
        ),
      ),
    ),
    pw.SizedBox(height: 6),
    _row('Type', v.type.label),
    _row('Fuel', v.fuelType.label),
    _row('Transmission', v.transmission.label),
    _row('Plate', v.plate ?? 'Not set'),
    _row('Odometer', odometer == null ? 'Not set' : formatKm(odometer)),
    pw.SizedBox(height: 10),
    _heading('Warning lights found'),
    _row('Stop now', '${r.counts[Severity.stop] ?? 0}'),
    _row('Garage soon', '${r.counts[Severity.soon] ?? 0}'),
    _row('Info', '${r.counts[Severity.info] ?? 0}'),
    pw.SizedBox(height: 10),
    _heading('Scans'),
    if (r.scans.isEmpty)
      _note('No scans saved.')
    else
      _table(
        ['Date', 'Result', 'Lights'],
        [
          for (final s in r.scans)
            [
              s.date == null ? '-' : formatDate(s.date!),
              s.worst?.label ?? 'No lights',
              s.lights.isEmpty ? '-' : s.lights.join(', '),
            ],
        ],
      ),
    pw.SizedBox(height: 10),
    _heading('Open reminders'),
    if (r.open.isEmpty)
      _note('None.')
    else
      _table(
        ['Reminder', 'Type', 'Due'],
        [
          for (final m in r.open) [m.title, m.type.label, _due(m)],
        ],
      ),
    pw.SizedBox(height: 10),
    _heading('Service log'),
    if (r.done.isEmpty)
      _note('Nothing done yet.')
    else
      _table(
        ['Reminder', 'Type', 'Date'],
        [
          for (final m in r.done)
            [m.title, m.type.label, formatDate(m.dueDate)],
        ],
      ),
  ];
}

String _due(Reminder m) {
  final km = m.dueKm;
  final date = formatDate(m.dueDate);
  return km == null ? date : '$date or ${formatKm(km)}';
}

pw.Widget _heading(String text) => pw.Padding(
  padding: const pw.EdgeInsets.only(bottom: 4),
  child: pw.Text(
    text,
    style: pw.TextStyle(
      fontSize: 12,
      fontWeight: pw.FontWeight.bold,
      color: _ink,
    ),
  ),
);

pw.Widget _row(String label, String value) => pw.Padding(
  padding: const pw.EdgeInsets.symmetric(vertical: 1.5),
  child: pw.Row(
    children: [
      pw.SizedBox(
        width: 110,
        child: pw.Text(
          label,
          style: const pw.TextStyle(fontSize: 10, color: _muted),
        ),
      ),
      pw.Expanded(
        child: pw.Text(
          value,
          style: const pw.TextStyle(fontSize: 10, color: _ink),
        ),
      ),
    ],
  ),
);

pw.Widget _note(String text) =>
    pw.Text(text, style: const pw.TextStyle(fontSize: 10, color: _muted));

pw.Widget _table(List<String> headers, List<List<String>> rows) {
  return pw.TableHelper.fromTextArray(
    headers: headers,
    data: rows,
    // the scans table keeps date and result narrow, lights get the rest
    columnWidths: headers.last == 'Lights'
        ? const {
            0: pw.FixedColumnWidth(70),
            1: pw.FixedColumnWidth(70),
            2: pw.FlexColumnWidth(),
          }
        : null,
    border: const pw.TableBorder(
      horizontalInside: pw.BorderSide(color: _line, width: 0.5),
      bottom: pw.BorderSide(color: _line, width: 0.5),
    ),
    headerStyle: pw.TextStyle(
      fontSize: 10,
      fontWeight: pw.FontWeight.bold,
      color: _ink,
    ),
    cellStyle: const pw.TextStyle(fontSize: 10, color: _ink),
    headerDecoration: const pw.BoxDecoration(
      color: PdfColor.fromInt(0xFFF1F3F5),
    ),
    cellPadding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
  );
}
