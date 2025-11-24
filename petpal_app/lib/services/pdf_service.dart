import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

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
}
