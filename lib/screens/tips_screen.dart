import 'package:flutter/material.dart';
import '../models/tip_model.dart';
import '../services/tips_service.dart';

class TipsScreen extends StatefulWidget {
  const TipsScreen({super.key});

  @override
  State<TipsScreen> createState() => _TipsScreenState();
}

class _TipsScreenState extends State<TipsScreen> {
  final TipsService _tipsService = TipsService();
  late Future<List<Tip>> _tipsFuture;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadTips();
  }

  Future<void> _loadTips() async {
    setState(() {
      _isLoading = true;
      _tipsFuture = _tipsService.fetchTips();
    });
  }

  Future<void> _refreshTips() async {
    setState(() {
      _tipsFuture = _tipsService.fetchTips();
    });
  }

  // Get icon based on tip content
  IconData _getTipIcon(String tipText) {
    final tipLower = tipText.toLowerCase();
    
    if (tipLower.contains('car') || tipLower.contains('vehicle') || tipLower.contains('driving')) {
      return Icons.directions_car;
    } else if (tipLower.contains('walk') || tipLower.contains('walking')) {
      return Icons.directions_walk;
    } else if (tipLower.contains('bike') || tipLower.contains('cycling') || tipLower.contains('bicycle')) {
      return Icons.directions_bike;
    } else if (tipLower.contains('bus') || tipLower.contains('public transport')) {
      return Icons.directions_bus;
    } else if (tipLower.contains('train') || tipLower.contains('rail')) {
      return Icons.train;
    } else if (tipLower.contains('plane') || tipLower.contains('flight')) {
      return Icons.flight;
    } else {
      return Icons.eco;
    }
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFFF5F9F6);
    const cardColor = Colors.white;
    const textColor = Color(0xFF2E7D32);
    
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Eco Tips'),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _refreshTips,
            tooltip: 'Refresh Tips',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshTips,
        color: const Color(0xFF4CAF50),
        child: FutureBuilder<List<Tip>>(
          future: _tipsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF4CAF50),
                ),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 60,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load tips',
                      style: TextStyle(
                        fontSize: 18,
                        color: textColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      snapshot.error.toString(),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _refreshTips,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Try Again'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: Color(0xFF4CAF50),
                      size: 60,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No tips available',
                      style: TextStyle(
                        fontSize: 18,
                        color: textColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _refreshTips,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Refresh'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
            
            // Display tips
            final tips = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: tips.length,
              itemBuilder: (context, index) {
                final tip = tips[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    color: cardColor,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF4CAF50).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  _getTipIcon(tip.text),
                                  color: const Color(0xFF4CAF50),
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      tip.text,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Color(0xFF2E7D32),
                                        height: 1.5,
                                      ),
                                    ),
                                    if (tip.author != null && tip.author!.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 8),
                                        child: Text(
                                          '- ${tip.author}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontStyle: FontStyle.italic,
                                            color: Colors.grey[700],
                                          ),
                                          textAlign: TextAlign.right,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
