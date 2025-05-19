// lib/pages/transaction_stats_page.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class TransactionStatsPage extends StatefulWidget {
  const TransactionStatsPage({Key? key}) : super(key: key);

  @override
  _TransactionStatsPageState createState() => _TransactionStatsPageState();
}

class _TransactionStatsPageState extends State<TransactionStatsPage> {
  bool _isLoading = true;
  int _txCount = 0;
  int _successCount = 0;
  int _failureCount = 0;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    try {
      // Total des transactions
      final txSnap = await FirebaseFirestore.instance
          .collectionGroup('transactions')
          .get();

      // Notifications
      final notifRef = FirebaseFirestore.instance.collection('notification');
      final successSnap = await notifRef
          .where('titre', isEqualTo: 'Paiement confirmé')
          .get();
      final failureSnap = await notifRef
          .where('titre', isEqualTo: 'Paiement échoué')
          .get();

      setState(() {
        _txCount = txSnap.size;
        _successCount = successSnap.size;
        _failureCount = failureSnap.size;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur de chargement : $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const txColor      = Colors.blue;
    const successColor = Colors.green;
    const failureColor = Colors.red;

    final maxY = [
      _txCount,
      _successCount,
      _failureCount,
    ].reduce((a, b) => a > b ? a : b).toDouble();

    return Scaffold(
      appBar: AppBar(
        // title: const Text('Statistiques Transactions'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
                ? Center(child: Text(_errorMessage!))
                : Column(
                    children: [
                      const SizedBox(height: 16),
                      const Text(
                        'Transactions',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: BarChart(
                            BarChartData(
                              alignment: BarChartAlignment.spaceAround,
                              maxY: maxY,
                              barTouchData: BarTouchData(enabled: false),
                              titlesData: FlTitlesData(
                                // Ordonnées : uniquement entiers
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    interval: 1,
                                    reservedSize: 40,
                                    getTitlesWidget: (value, meta) {
                                      // n'affiche que si c'est un entier
                                      if (value % 1 == 0) {
                                        return Text(
                                          value.toInt().toString(),
                                          style: TextStyle(color: Colors.black),
                                        );
                                      }
                                      return const SizedBox.shrink();
                                    },
                                  ),
                                ),
                                // Abscisses : labels fixes
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) {
                                      switch (value.toInt()) {
                                        case 0:
                                          return const Text('Transactions');
                                        case 1:
                                          return const Text('Confirmés');
                                        case 2:
                                          return const Text('Échoués');
                                        default:
                                          return const Text('');
                                      }
                                    },
                                    reservedSize: 40,
                                  ),
                                ),
                                topTitles: AxisTitles(),
                                rightTitles: AxisTitles(),
                              ),
                              gridData: FlGridData(show: true),
                              borderData: FlBorderData(show: false),
                              barGroups: [
                                BarChartGroupData(x: 0, barRods: [
                                  BarChartRodData(
                                    toY: _txCount.toDouble(),
                                    width: 24,
                                    color: txColor,
                                    borderRadius: BorderRadius.circular(6),
                                  )
                                ]),
                                BarChartGroupData(x: 1, barRods: [
                                  BarChartRodData(
                                    toY: _successCount.toDouble(),
                                    width: 24,
                                    color: successColor,
                                    borderRadius: BorderRadius.circular(6),
                                  )
                                ]),
                                BarChartGroupData(x: 2, barRods: [
                                  BarChartRodData(
                                    toY: _failureCount.toDouble(),
                                    width: 24,
                                    color: failureColor,
                                    borderRadius: BorderRadius.circular(6),
                                  )
                                ]),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
      ),
    );
  }
}
