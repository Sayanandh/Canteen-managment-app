import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../constants/api_endpoints.dart';

class ConnectionTestScreen extends StatefulWidget {
  const ConnectionTestScreen({Key? key}) : super(key: key);

  @override
  State<ConnectionTestScreen> createState() => _ConnectionTestScreenState();
}

class _ConnectionTestScreenState extends State<ConnectionTestScreen> {
  bool _isTesting = false;
  Map<String, dynamic>? _result;
  String _currentUrl = ApiEndpoints.baseUrl;

  Future<void> _testConnection() async {
    setState(() {
      _isTesting = true;
      _result = null;
    });

    try {
      final result = await ApiService.testConnection();
      
      setState(() {
        _isTesting = false;
        _result = result;
      });
    } catch (e) {
      setState(() {
        _isTesting = false;
        _result = {
          'success': false,
          'message': 'Error testing connection: $e',
          'serverUrl': _currentUrl,
        };
      });
    }
  }

  void _showUrlDialog() {
    final controller = TextEditingController(text: _currentUrl);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Server URL'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Server URL',
            hintText: 'e.g., http://10.0.2.2:5000/api',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() => _currentUrl = controller.text);
              Navigator.pop(context);
              _testConnection();
            },
            child: const Text('Test'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connection Test'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isTesting ? null : _testConnection,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Current Server URL:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _currentUrl,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _isTesting ? null : _testConnection,
                          icon: _isTesting
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.refresh),
                          label: Text(_isTesting ? 'Testing...' : 'Test Connection'),
                        ),
                        TextButton.icon(
                          onPressed: _isTesting ? null : _showUrlDialog,
                          icon: const Icon(Icons.edit),
                          label: const Text('Change URL'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (_result != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _result!['success']
                      ? Colors.green.withAlpha(26)
                      : Colors.red.withAlpha(26),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _result!['success'] ? Icons.check_circle : Icons.error,
                          color: _result!['success'] ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _result!['success'] ? 'Connection Successful!' : 'Connection Failed',
                          style: TextStyle(
                            color: _result!['success'] ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(_result!['message']),
                    const SizedBox(height: 8),
                    Text(
                      'Server URL: ${_result!['serverUrl']}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    if (_result!['success'] && _result!['data'] != null) ...[
                      const SizedBox(height: 8),
                      const Divider(),
                      const SizedBox(height: 8),
                      const Text(
                        'System Information:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Database Status: ${_result!['data']['database']}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      Text(
                        'Server Time: ${_result!['data']['timestamp']}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      if (_result!['data']['system'] != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'CPU Usage: ${_result!['data']['system']['cpu_usage']}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        Text(
                          'Memory Usage: ${_result!['data']['system']['memory_usage']}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        Text(
                          'Available Memory: ${_result!['data']['system']['available_memory']}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Troubleshooting Tips:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text('1. Make sure your backend server is running'),
                    Text('2. Check if the server URL is correct for your environment:'),
                    Padding(
                      padding: EdgeInsets.only(left: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('• Android Emulator: http://10.0.2.2:5000/api'),
                          Text('• Physical Device: http://YOUR_IP:5000/api'),
                          Text('• Web: http://localhost:5000/api'),
                        ],
                      ),
                    ),
                    SizedBox(height: 8),
                    Text('3. Verify your device/emulator has internet access'),
                    Text('4. Check if any firewall is blocking the connection'),
                    Text('5. Ensure CORS is enabled on your backend'),
                    Text('6. Try restarting both frontend and backend servers'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 