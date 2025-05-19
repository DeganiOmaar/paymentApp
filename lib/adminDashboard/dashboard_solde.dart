// lib/pages/financial_stats_page.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class FinancialStatsPage extends StatefulWidget {
  const FinancialStatsPage({Key? key}) : super(key: key);

  @override
  _FinancialStatsPageState createState() => _FinancialStatsPageState();
}

class _FinancialStatsPageState extends State<FinancialStatsPage> {
  bool _isLoading = true;
  double _totalPositiveTransactions = 0.0;
  double _totalBalances = 0.0;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchFinancials();
  }

  Future<void> _fetchFinancials() async {
    try {
      final usersColl = FirebaseFirestore.instance.collection('users');

      // 1) Somme des montants positifs dans transactions des clients
      final clientsSnap = await usersColl
          .where('role', isEqualTo: 'client')
          .get();

      double sumTx = 0.0;
      for (final userDoc in clientsSnap.docs) {
        final txSnap = await usersColl
            .doc(userDoc.id)
            .collection('transactions')
            .where('montant', isGreaterThanOrEqualTo: 0)
            .get();

        sumTx += txSnap.docs.fold<double>(
          0.0,
          (total, doc) {
            final m = doc.data()['montant'];
            return total + (m is num ? m.toDouble() : 0.0);
          },
        );
      }

      // 2) Somme des soldes de tous les utilisateurs
      final allUsersSnap = await usersColl.get();
      final sumSolde = allUsersSnap.docs.fold<double>(
        0.0,
        (total, doc) {
          final s = doc.data()['solde'];
          return total + (s is num ? s.toDouble() : 0.0);
        },
      );

      setState(() {
        _totalPositiveTransactions = sumTx;
        _totalBalances = sumSolde;
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
    // Couleurs
    const txColor    = Color(0xFF42A5F5); // bleu
    const soldeColor = Color(0xFFFFA726); // orange

    // Pourcentages
    final double total = _totalPositiveTransactions + _totalBalances;
    final double pctTx    = total > 0.0 ? _totalPositiveTransactions / total * 100.0 : 0.0;
    final double pctSolde = total > 0.0 ? _totalBalances / total * 100.0 : 0.0;

    return Scaffold(
      appBar: AppBar(
        // title: const Text('Statistiques Financières'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : (_errorMessage != null
                ? Center(child: Text(_errorMessage!))
                : Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Text(
                          'Solde Ajouter et Transactions',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),

                        // Légende
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _LegendItem(
                              color: txColor,
                              label: 'Transactions',
                              percent: pctTx,
                            ),
                            _LegendItem(
                              color: soldeColor,
                              label: 'Soldes',
                              percent: pctSolde,
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // PieChart
                        Expanded(
                          child: PieChart(
                            PieChartData(
                              sectionsSpace: 4,
                              centerSpaceRadius: 40,
                              sections: [
                                PieChartSectionData(
                                  value: _totalPositiveTransactions,
                                  title: _totalPositiveTransactions
                                      .toStringAsFixed(0),
                                  radius: 80,
                                  color: txColor,
                                  titleStyle: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                                PieChartSectionData(
                                  value: _totalBalances,
                                  title: _totalBalances.toStringAsFixed(0),
                                  radius: 80,
                                  color: soldeColor,
                                  titleStyle: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
      ),
    );
  }
}

// Widget légende : carré + label + pourcentage
class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final double percent;

  const _LegendItem({
    required this.color,
    required this.label,
    required this.percent,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 16, height: 16, color: color),
        const SizedBox(width: 8),
        Text('$label: ${percent.toStringAsFixed(1)}%'),
      ],
    );
  }
}
