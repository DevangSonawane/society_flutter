import 'dart:io';
import 'package:path_provider/path_provider.dart';

class CsvService {
  static Future<File> exportResidentsToCsv(List<Map<String, dynamic>> residents) async {
    final buffer = StringBuffer();
    
    // Header
    buffer.writeln('Owner Name,Flat Number,Residency Type,Phone Number,Email,Status,Created Date,Number of Residents');
    
    // Data rows
    for (var resident in residents) {
      buffer.writeln([
        _escapeCsvField(resident['ownerName'] ?? ''),
        _escapeCsvField(resident['flatNumber'] ?? ''),
        _escapeCsvField(resident['typeString'] ?? ''),
        _escapeCsvField(resident['phoneNumber'] ?? ''),
        _escapeCsvField(resident['email'] ?? ''),
        _escapeCsvField(resident['status'] ?? ''),
        _escapeCsvField(resident['createdDate'] ?? ''),
        _escapeCsvField(resident['membersCount']?.toString() ?? '0'),
      ].join(','));
    }
    
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/residents_export_${DateTime.now().millisecondsSinceEpoch}.csv');
    await file.writeAsString(buffer.toString());
    
    return file;
  }

  static Future<File> exportPaymentsToCsv(List<Map<String, dynamic>> payments) async {
    final buffer = StringBuffer();
    
    // Header
    buffer.writeln('Resident Name,Flat Number,Amount,Month,Year,Status,Payment Date,Invoice Number');
    
    // Data rows
    for (var payment in payments) {
      buffer.writeln([
        _escapeCsvField(payment['residentName'] ?? ''),
        _escapeCsvField(payment['flatNumber'] ?? ''),
        _escapeCsvField(payment['amount']?.toString() ?? '0'),
        _escapeCsvField(payment['month'] ?? ''),
        _escapeCsvField(payment['year']?.toString() ?? ''),
        _escapeCsvField(payment['status'] ?? ''),
        _escapeCsvField(payment['paymentDate'] ?? ''),
        _escapeCsvField(payment['invoiceNumber'] ?? ''),
      ].join(','));
    }
    
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/payments_export_${DateTime.now().millisecondsSinceEpoch}.csv');
    await file.writeAsString(buffer.toString());
    
    return file;
  }

  static Future<File> exportComplaintsToCsv(List<Map<String, dynamic>> complaints) async {
    final buffer = StringBuffer();
    
    // Header
    buffer.writeln('Complainer Name,Phone,Email,Flat Number,Wing,Complaint Text,Status,Complaint Date,Created Date');
    
    // Data rows
    for (var complaint in complaints) {
      buffer.writeln([
        _escapeCsvField(complaint['complainerName'] ?? ''),
        _escapeCsvField(complaint['phoneNumber'] ?? ''),
        _escapeCsvField(complaint['email'] ?? ''),
        _escapeCsvField(complaint['flatNumber'] ?? ''),
        _escapeCsvField(complaint['wing'] ?? ''),
        _escapeCsvField(complaint['complaintText'] ?? ''),
        _escapeCsvField(complaint['status'] ?? ''),
        _escapeCsvField(complaint['complaintDate'] ?? ''),
        _escapeCsvField(complaint['createdDate'] ?? ''),
      ].join(','));
    }
    
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/complaints_export_${DateTime.now().millisecondsSinceEpoch}.csv');
    await file.writeAsString(buffer.toString());
    
    return file;
  }

  static String _escapeCsvField(String field) {
    if (field.contains(',') || field.contains('"') || field.contains('\n')) {
      return '"${field.replaceAll('"', '""')}"';
    }
    return field;
  }
}

