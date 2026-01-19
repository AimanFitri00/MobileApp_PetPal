import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/booking.dart';

class PdfService {
  Future<Uint8List> buildPetReport({
    required String petName,
    required List<String> sections,
  }) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'PetPal Report',
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 12),
            pw.Text('Pet Name: $petName'),
            pw.Divider(),
            ...sections.map(
              (section) => pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 8),
                child: pw.Text(section),
              ),
            ),
          ],
        ),
      ),
    );
    return pdf.save();
  }

  Future<Uint8List> buildVetReport({
    required String clinicName,
    required Map<String, dynamic> stats,
  }) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Clinic Activity Report',
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 12),
            pw.Text('Clinic: $clinicName'),
            pw.Divider(),
            pw.Text('Total Appointments: ${stats['totalAppointments']}'),
            pw.Text('Completed: ${stats['completed']}'),
            pw.Text('Upcoming: ${stats['upcoming']}'),
            pw.Text('Pending: ${stats['pending']}'),
            pw.Text('Unique Pets Treated: ${stats['uniquePets']}'),
          ],
        ),
      ),
    );
    return pdf.save();
  }

  Future<Uint8List> buildVetReportDetailed({
    required String clinicName,
    required String periodLabel,
    required Map<String, dynamic> stats,
    required List<Booking> bookings,
  }) async {
    final pdf = pw.Document();

    pw.Widget statRow(String label, String value) => pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(label, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Text(value),
          ],
        );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (_) => [
          pw.Text(
            'Clinic Activity Report',
            style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 6),
          pw.Text('Clinic: $clinicName'),
          pw.Text('Period: $periodLabel'),
          pw.SizedBox(height: 12),
          pw.Divider(),
          pw.SizedBox(height: 8),
          statRow('Total Appointments', '${stats['totalAppointments'] ?? 0}'),
          statRow('Completed', '${stats['completed'] ?? 0}'),
          statRow('Upcoming (Accepted)', '${stats['upcoming'] ?? 0}'),
          statRow('Pending', '${stats['pending'] ?? 0}'),
          statRow('Rejected', '${stats['rejected'] ?? 0}'),
          statRow('Unique Pets Treated', '${stats['uniquePets'] ?? 0}'),
          pw.SizedBox(height: 16),
          pw.Text('Bookings', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          ...bookings.map(
            (b) => pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 8),
              padding: const pw.EdgeInsets.all(8),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300),
                borderRadius: pw.BorderRadius.circular(6),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        b.petName,
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                      pw.Text(b.status.name.toUpperCase()),
                    ],
                  ),
                  pw.Text('Date: ${b.date.toLocal()}'),
                  if (b.time != null) pw.Text('Time: ${b.time}'),
                  pw.Text('Owner: ${b.ownerName ?? 'Unknown'} (${b.ownerEmail ?? '-'})'),
                  pw.Text('Pet: ${b.petName} | ${b.petSpecies ?? '-'} / ${b.petBreed ?? '-'}'),
                  if (b.notes != null && b.notes!.isNotEmpty) pw.Text('Notes: ${b.notes}'),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    return pdf.save();
  }

  Future<Uint8List> buildSitterReport({
    required String sitterName,
    required Map<String, dynamic> stats,
  }) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Sitter Work Summary',
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 12),
            pw.Text('Sitter: $sitterName'),
            pw.Divider(),
            pw.Text('Total Jobs: ${stats['totalJobs']}'),
            pw.Text('Completed: ${stats['completed']}'),
            pw.Text('Pending: ${stats['pending']}'),
            pw.Text('Completion Rate: ${stats['completionRate'].toStringAsFixed(1)}%'),
          ],
        ),
      ),
    );
    return pdf.save();
  }

  Future<Uint8List> buildPetReportDetailed({
    required String petName,
    required String periodLabel,
    required Map<String, dynamic> stats,
    required List<Booking> bookings,
  }) async {
    final pdf = pw.Document();

    pw.Widget statRow(String label, String value) => pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(label, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Text(value),
          ],
        );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (_) => [
          pw.Text(
            'Pet Health Report',
            style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 6),
          pw.Text('Pet: $petName'),
          pw.Text('Period: $periodLabel'),
          pw.SizedBox(height: 12),
          pw.Divider(),
          pw.SizedBox(height: 8),
          statRow('Total Appointments', '${stats['totalAppointments'] ?? 0}'),
          statRow('Completed', '${stats['completed'] ?? 0}'),
          statRow('Upcoming', '${stats['upcoming'] ?? 0}'),
          statRow('Pending', '${stats['pending'] ?? 0}'),
          statRow('Unique Vets Seen', '${stats['uniqueVets'] ?? 0}'),
          pw.SizedBox(height: 16),
          pw.Text('Bookings', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          ...bookings.map(
            (b) => pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 8),
              padding: const pw.EdgeInsets.all(8),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300),
                borderRadius: pw.BorderRadius.circular(6),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(b.petName, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text(b.status.name.toUpperCase()),
                    ],
                  ),
                  pw.Text('Date: ${b.date.toLocal()}'),
                  if (b.time != null) pw.Text('Time: ${b.time}'),
                  pw.Text('Provider ID: ${b.providerId ?? '-'}'),
                  if (b.notes != null && b.notes!.isNotEmpty) pw.Text('Notes: ${b.notes}'),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    return pdf.save();
  }
}
