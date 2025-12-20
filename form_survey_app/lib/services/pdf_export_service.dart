import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../models/survey_model.dart';

class PdfExportService {
  static Future<void> exportToPdf({
    required SurveyData data,
    required BuildContext context,
  }) async {
    try {
      final pdf = pw.Document();
      
      // Tambahkan font
      final font = await PdfGoogleFonts.nunitoSansRegular();
      final fontBold = await PdfGoogleFonts.nunitoSansBold();
      
      // Header dengan logo
      final header = pw.Row(
        children: [
          pw.Container(
            width: 50,
            height: 50,
            decoration: const pw.BoxDecoration(
              color: PdfColors.blue,
              shape: pw.BoxShape.circle,
            ),
            child: pw.Center(
              child: pw.Text(
                'S',
                style: pw.TextStyle(
                  color: PdfColors.white,
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
          ),
          pw.SizedBox(width: 20),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Laporan Survey',
                style: pw.TextStyle(
                  fontSize: 24,
                  font: fontBold,
                  color: PdfColors.blue,
                ),
              ),
              pw.Text(
                'Tanggal: ${DateFormat('dd MMMM yyyy').format(DateTime.now())}',
                style: pw.TextStyle(
                  fontSize: 12,
                  font: font,
                  color: PdfColors.grey,
                ),
              ),
            ],
          ),
        ],
      );
      
      // Halaman PDF
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                header,
                pw.SizedBox(height: 30),
                
                // Data Responden
                _buildSectionTitle('Data Responden', fontBold),
                pw.SizedBox(height: 10),
                _buildInfoRow('Nama Lengkap', data.nama, font, fontBold),
                _buildInfoRow('Umur', '${data.umur} tahun', font, fontBold),
                _buildInfoRow('Pekerjaan', data.pekerjaan, font, fontBold),
                
                pw.SizedBox(height: 20),
                
                // Hasil Survey
                _buildSectionTitle('Hasil Survey', fontBold),
                pw.SizedBox(height: 10),
                _buildInfoRow('Hobi', data.hobi.join(', '), font, fontBold),
                _buildInfoRow('Tingkat Kepuasan', data.tingkatKepuasan, font, fontBold),
                
                pw.SizedBox(height: 20),
                
                // Feedback
                _buildSectionTitle('Feedback', fontBold),
                pw.SizedBox(height: 10),
                pw.Container(
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey300),
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Text(
                    data.feedback,
                    style: pw.TextStyle(
                      font: font,
                      fontSize: 12,
                    ),
                  ),
                ),
                
                pw.Spacer(),
                
                // Footer
                pw.Divider(),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Halaman 1/1',
                      style: pw.TextStyle(
                        font: font,
                        fontSize: 10,
                        color: PdfColors.grey,
                      ),
                    ),
                    pw.Text(
                      'Survey App © 2024',
                      style: pw.TextStyle(
                        font: font,
                        fontSize: 10,
                        color: PdfColors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      );
      
      // Tampilkan dialog pilihan
      final action = await showDialog<PdfAction>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Export PDF'),
          content: const Text('Pilih aksi yang diinginkan:'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, PdfAction.preview),
              child: const Text('Preview'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, PdfAction.print),
              child: const Text('Print'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, PdfAction.share),
              child: const Text('Share'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
          ],
        ),
      );
      
      if (action == PdfAction.preview) {
        await Printing.layoutPdf(
          onLayout: (format) => pdf.save(),
        );
      } else if (action == PdfAction.print) {
        await Printing.sharePdf(
          bytes: await pdf.save(),
          filename: 'survey_report_${DateTime.now().millisecondsSinceEpoch}.pdf',
        );
      } else if (action == PdfAction.share) {
        await Printing.sharePdf(
          bytes: await pdf.save(),
          filename: 'survey_report.pdf',
        );
      }
      
    } catch (e) {
      print('Error exporting PDF: $e');
      rethrow;
    }
  }
  
  static pw.Widget _buildSectionTitle(String title, pw.Font font) {
    return pw.Container(
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          left: pw.BorderSide(
            color: PdfColors.blue,
            width: 4,
          ),
        ),
      ),
      padding: const pw.EdgeInsets.only(left: 12),
      child: pw.Text(
        title,
        style: pw.TextStyle(
          fontSize: 18,
          font: font,
          color: PdfColors.blue,
        ),
      ),
    );
  }
  
  static pw.Row _buildInfoRow(String label, String value, pw.Font font, pw.Font fontBold) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: 120,
          child: pw.Text(
            '$label:',
            style: pw.TextStyle(
              font: fontBold,
              fontSize: 12,
            ),
          ),
        ),
        pw.SizedBox(width: 10),
        pw.Expanded(
          child: pw.Text(
            value,
            style: pw.TextStyle(
              font: font,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}

enum PdfAction { preview, print, share }