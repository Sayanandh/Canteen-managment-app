import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../services/api_service.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRCodeScreen extends StatefulWidget {
  const QRCodeScreen({Key? key}) : super(key: key);

  @override
  State<QRCodeScreen> createState() => _QRCodeScreenState();
}

class _QRCodeScreenState extends State<QRCodeScreen> {
  String? _qrCode;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchQRCode();
    // Set up periodic refresh every 5 minutes
    Future.delayed(const Duration(seconds: 1), () {
      _startPeriodicRefresh();
    });
  }

  void _startPeriodicRefresh() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(minutes: 5));
      if (!mounted) return false;
      await _fetchQRCode();
      return true;
    });
  }

  Future<void> _fetchQRCode() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final appState = Provider.of<AppState>(context, listen: false);
      final user = appState.currentUser;
      
      if (user == null) {
        setState(() {
          _error = 'User not found';
          _isLoading = false;
        });
        return;
      }

      final response = await ApiService.getUserQRCode(user.id.toString());
      
      if (mounted) {
        setState(() {
          if (response['success']) {
            _qrCode = response['qrCode'];
            _error = null;
          } else {
            _error = response['message'] ?? 'Failed to load QR code';
            _qrCode = null;
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load QR code';
          _qrCode = null;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final user = appState.currentUser;
    
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('My QR Code'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchQRCode,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (user != null) ...[
              CircleAvatar(
                radius: 40,
                backgroundColor: Theme.of(context).primaryColor,
                child: Text(
                  user.fullName[0].toUpperCase(),
                  style: const TextStyle(
                    fontSize: 32,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                user.fullName,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                user.email,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  user.role.toUpperCase(),
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
            
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Text(
                      'Scan this QR code to verify your meal',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    if (_isLoading)
                      const SizedBox(
                        height: 250,
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (_error != null)
                      SizedBox(
                        height: 250,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 48,
                                color: Theme.of(context).colorScheme.error,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _error!,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.error,
                                  fontSize: 16,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      )
                    else if (_qrCode == null)
                      const SizedBox(
                        height: 250,
                        child: Center(
                          child: Text(
                            'No QR code available',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: QrImageView(
                          data: _qrCode!,
                          version: QrVersions.auto,
                          size: 250,
                          backgroundColor: Colors.white,
                        ),
                      ),
                    const SizedBox(height: 24),
                    Text(
                      'QR code refreshes automatically every 5 minutes for security',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _fetchQRCode,
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh QR Code'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 