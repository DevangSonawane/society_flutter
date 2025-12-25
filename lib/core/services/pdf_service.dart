import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

class PdfService {
  static Future<File> generateInvoice({
    required String residentName,
    required String flatNumber,
    required double amount,
    required String month,
    required int year,
    required String invoiceNumber,
  }) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('dd/MM/yyyy');
    
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'SCASA',
                        style: pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.purple,
                        ),
                      ),
                      pw.Text(
                        'Society Comprehensive Administrative Solution',
                        style: pw.TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'INVOICE',
                        style: pw.TextStyle(
                          fontSize: 20,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text('Invoice #: $invoiceNumber'),
                      pw.Text('Date: ${dateFormat.format(DateTime.now())}'),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 40),
              
              // Bill To
              pw.Text(
                'Bill To:',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text(residentName),
              pw.Text('Flat: $flatNumber'),
              pw.SizedBox(height: 30),
              
              // Invoice Details
              pw.Text(
                'Maintenance Payment Invoice',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 20),
              
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Description', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Amount', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Maintenance for $month $year'),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('₹${amount.toStringAsFixed(2)}'),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              
              // Total
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'Total Amount: ₹${amount.toStringAsFixed(2)}',
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              pw.Spacer(),
              
              // Footer
              pw.Divider(),
              pw.SizedBox(height: 10),
              pw.Text(
                'Thank you for your payment!',
                style: pw.TextStyle(fontSize: 12),
                textAlign: pw.TextAlign.center,
              ),
            ],
          );
        },
      ),
    );
    
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/invoice_$invoiceNumber.pdf');
    await file.writeAsBytes(await pdf.save());
    
    return file;
  }

  static Future<File> generateReceipt({
    required String residentName,
    required String flatNumber,
    required double amount,
    required String paymentDate,
    required String receiptNumber,
    required String paymentMode,
  }) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('dd/MM/yyyy');
    
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'SCASA',
                        style: pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.purple,
                        ),
                      ),
                      pw.Text(
                        'Society Comprehensive Administrative Solution',
                        style: pw.TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'RECEIPT',
                        style: pw.TextStyle(
                          fontSize: 20,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text('Receipt #: $receiptNumber'),
                      pw.Text('Date: ${dateFormat.format(DateTime.now())}'),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 40),
              
              // Paid By
              pw.Text(
                'Paid By:',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text(residentName),
              pw.Text('Flat: $flatNumber'),
              pw.SizedBox(height: 30),
              
              // Payment Details
              pw.Text(
                'Payment Receipt',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 20),
              
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Description', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Amount', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Maintenance Payment'),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('₹${amount.toStringAsFixed(2)}'),
                      ),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Payment Mode'),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(paymentMode),
                      ),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Payment Date'),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(paymentDate),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              
              // Total
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'Amount Received: ₹${amount.toStringAsFixed(2)}',
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              pw.Spacer(),
              
              // Footer
              pw.Divider(),
              pw.SizedBox(height: 10),
              pw.Text(
                'Thank you for your payment!',
                style: pw.TextStyle(fontSize: 12),
                textAlign: pw.TextAlign.center,
              ),
            ],
          );
        },
      ),
    );
    
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/receipt_$receiptNumber.pdf');
    await file.writeAsBytes(await pdf.save());
    
    return file;
  }
}

