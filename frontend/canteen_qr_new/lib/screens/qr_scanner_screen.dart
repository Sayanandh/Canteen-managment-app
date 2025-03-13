import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../constants/app_constants.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({Key? key}) : super(key: key);

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final MobileScannerController _controller = MobileScannerController();
  bool _hasScanned = false;
  bool _isProcessing = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onQRCodeDetected(BarcodeCapture capture) {
    if (_hasScanned || _isProcessing) return;
    
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final String? data = barcodes.first.rawValue;
    if (data == null) return;

    setState(() {
      _hasScanned = true;
      _isProcessing = true;
    });

    // Process the QR code data
    try {
      final userId = int.parse(data);
      _showResultDialog(
        'Valid QR Code',
        'User ID: $userId\nScanned successfully!',
        Icons.check_circle,
        AppColors.success,
      );
    } catch (e) {
      _showResultDialog(
        'Invalid QR Code',
        'The scanned QR code is not valid for this system.',
        Icons.error,
        AppColors.error,
      );
    }
  }

  void _showResultDialog(String title, String message, IconData icon, Color color) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _hasScanned = false;
                _isProcessing = false;
              });
            },
            child: const Text('Scan Again'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Scan QR Code',
          style: AppTextStyles.heading3.copyWith(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primary,
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // QR Scanner
                MobileScanner(
                  controller: _controller,
                  onDetect: _onQRCodeDetected,
                ),
                
                // Overlay
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.primary,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  width: 250,
                  height: 250,
                ),
                
                // Instructions
                Positioned(
                  bottom: 30,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.symmetric(horizontal: 40),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha((0.6 * 255).round()),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Position the QR code within the frame to scan',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Controls
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  onPressed: () => _controller.toggleTorch(),
                  icon: const Icon(Icons.flash_on),
                  color: AppColors.primary,
                  tooltip: 'Toggle Flash',
                ),
                IconButton(
                  onPressed: () => _controller.switchCamera(),
                  icon: const Icon(Icons.flip_camera_ios),
                  color: AppColors.primary,
                  tooltip: 'Switch Camera',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 