import 'dart:convert';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRService {
  /// Creates a QR scanner widget
  static Widget createScanner({
    required Function(String) onDetect,
    required MobileScannerController controller,
  }) {
    return MobileScanner(
      controller: controller,
      onDetect: (capture) {
        final List<Barcode> barcodes = capture.barcodes;
        if (barcodes.isNotEmpty && barcodes[0].rawValue != null) {
          onDetect(barcodes[0].rawValue!);
        }
      },
    );
  }

  /// Parses QR code data
  static Map<String, dynamic> parseQRData(String data) {
    try {
      // Try to parse as JSON
      final Map<String, dynamic> jsonData = json.decode(data);
      
      // Check if it has the required fields
      if (jsonData.containsKey('userId') && jsonData.containsKey('timestamp')) {
        return {
          'success': true,
          'userId': jsonData['userId'],
          'timestamp': jsonData['timestamp'],
        };
      }
      
      return {'success': false, 'error': 'Invalid QR code format'};
    } catch (e) {
      // If not valid JSON, check if it's a URL or other format
      if (data.startsWith('http') && data.contains('userId=')) {
        // Extract userId from URL
        final Uri uri = Uri.parse(data);
        final String? userId = uri.queryParameters['userId'];
        final String? timestamp = uri.queryParameters['timestamp'];
        
        if (userId != null && timestamp != null) {
          return {
            'success': true,
            'userId': userId,
            'timestamp': timestamp,
          };
        }
      }
      
      return {'success': false, 'error': 'Could not parse QR code'};
    }
  }

  /// Checks if QR code is still valid (not expired)
  static bool isQRCodeValid(String timestampStr) {
    try {
      final int timestamp = int.parse(timestampStr);
      final DateTime qrTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final DateTime now = DateTime.now();
      
      // QR code is valid for 5 minutes
      final Duration difference = now.difference(qrTime);
      return difference.inMinutes < 5;
    } catch (e) {
      return false;
    }
  }

  /// Generates QR code data for a user
  static String generateQRData(String userId) {
    final Map<String, dynamic> data = {
      'userId': userId,
      'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
    };
    
    return json.encode(data);
  }
  
  /// Generates a QR code widget
  static Widget generateQRCode(String data, {double size = 200}) {
    return QrImageView(
      data: data,
      version: QrVersions.auto,
      size: size,
      backgroundColor: Colors.white,
      padding: const EdgeInsets.all(10),
      errorStateBuilder: (context, error) {
        return Container(
          width: size,
          height: size,
          color: Colors.white,
          child: Center(
            child: Text(
              'Error generating QR code',
              style: TextStyle(
                color: Colors.red,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        );
      },
    );
  }
} 