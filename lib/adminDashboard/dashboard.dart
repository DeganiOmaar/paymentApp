// lib/pages/dashboard_page.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool _isLoading = true;
  String? _errorMessage;

  // Transaction stats
  int _txCount = 0;
  int _successCount = 0;
  int _failureCount = 0;

  // User stats
  int _clientsCount = 0;
  int _driversCount = 0;
  int _usersCount = 0;

  // Financial stats
  double _totalPositiveTransactions = 0.0;
  double _totalBalances = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchAllStats();
  }

  Future<void> _fetchAllStats() async {
    try {
      // Transactions
      final txSnap = await FirebaseFirestore.instance
          .collectionGroup('transactions')
          .get();
      final notifRef = FirebaseFirestore.instance.collection('notification');
      final successSnap = await notifRef
          .where('titre', isEqualTo: 'Paiement confirmé')
          .get();
      final failureSnap = await notifRef
          .where('titre', isEqualTo: 'Paiement échoué')
          .get();

      // Users
      final usersRef = FirebaseFirestore.instance.collection('users');
      final clientsSnap =
          await usersRef.where('role', isEqualTo: 'client').get();
      final driversSnap =
          await usersRef.where('role', isEqualTo: 'conducteur').get();
      final usersSnap = await usersRef.get();

      // Financials: somme des montants ≥ 0 pour chaque client
      double sumTx = 0.0;
      for (final doc in clientsSnap.docs) {
        final txs = await usersRef
            .doc(doc.id)
            .collection('transactions')
            .where('montant', isGreaterThanOrEqualTo: 0)
            .get();
        sumTx += txs.docs.fold<double>(
          0.0,
          (prev, tx) => prev + ((tx.data()['montant'] ?? 0) as num).toDouble(),
        );
      }
      // Somme des soldes de tous les utilisateurs
      final sumSolde = usersSnap.docs.fold<double>(
        0.0,
        (prev, doc) => prev + ((doc.data()['solde'] ?? 0) as num).toDouble(),
      );

      setState(() {
        _txCount = txSnap.size;
        _successCount = successSnap.size;
        _failureCount = failureSnap.size;
        _clientsCount = clientsSnap.size;
        _driversCount = driversSnap.size;
        _usersCount = usersSnap.size;
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
    const txColor = Colors.blue;
    const successColor = Colors.green;
    const failureColor = Colors.red;
    const usersColor = Color(0xFF9C27B0);
    const clientsColor = Color(0xFF03A9F4);
    const driversColor = Color(0xFFE91E63);
    const soldeColor = Color(0xFFFFA726);

    // Calcul des pourcentages en double
    final double totalUsers =
        (_clientsCount + _driversCount + _usersCount).toDouble();
    final double pctClients = totalUsers > 0
        ? _clientsCount / totalUsers * 100
        : 0.0;
    final double pctDrivers = totalUsers > 0
        ? _driversCount / totalUsers * 100
        : 0.0;
    final double pctUsers = totalUsers > 0
        ? _usersCount / totalUsers * 100
        : 0.0;

    final double totalFinancial =
        _totalPositiveTransactions + _totalBalances;
    final double pctTx = totalFinancial > 0
        ? _totalPositiveTransactions / totalFinancial * 100
        : 0.0;
    final double pctSolde = totalFinancial > 0
        ? _totalBalances / totalFinancial * 100
        : 0.0;

    // Valeur max pour les barres
    final double maxY = [
      _txCount,
      _successCount,
      _failureCount,
      _clientsCount,
      _driversCount,
      _usersCount,
    ].reduce((a, b) => a > b ? a : b).toDouble();

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Dashboard',
                  style:
                      TextStyle(fontWeight: FontWeight.w700, fontSize: 19),),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
                ? Center(child: Text(_errorMessage!))
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // --- Transactions ---
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                const Text(
                                  'Transactions',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 12),
                                AspectRatio(
                                  aspectRatio: 1.7,
                                  child: BarChart(
                                    BarChartData(
                                      alignment: BarChartAlignment.spaceAround,
                                      maxY: maxY,
                                      barTouchData:
                                          BarTouchData(enabled: false),
                                      titlesData: FlTitlesData(
                                        leftTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            reservedSize: 40,
                                          ),
                                        ),
                                        bottomTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            getTitlesWidget: (value, meta) {
                                              switch (value.toInt()) {
                                                case 0:
                                                  return const Text(
                                                      'Transactions');
                                                case 1:
                                                  return const Text(
                                                      'Confirmés');
                                                case 2:
                                                  return const Text(
                                                      'Échoués');
                                              }
                                              return const Text('');
                                            },
                                            reservedSize: 30,
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
                                            width: 20,
                                            color: txColor,
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          )
                                        ]),
                                        BarChartGroupData(x: 1, barRods: [
                                          BarChartRodData(
                                            toY: _successCount.toDouble(),
                                            width: 20,
                                            color: successColor,
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          )
                                        ]),
                                        BarChartGroupData(x: 2, barRods: [
                                          BarChartRodData(
                                            toY: _failureCount.toDouble(),
                                            width: 20,
                                            color: failureColor,
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          )
                                        ]),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // --- Utilisateurs ---
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                const Text(
                                  'Vue d’ensemble Utilisateurs',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 12),
                                AspectRatio(
                                  aspectRatio: 1.7,
                                  child: BarChart(
                                    BarChartData(
                                      alignment: BarChartAlignment.spaceAround,
                                      maxY: maxY,
                                      barTouchData:
                                          BarTouchData(enabled: false),
                                      titlesData: FlTitlesData(
                                        leftTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            reservedSize: 40,
                                          ),
                                        ),
                                        bottomTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            getTitlesWidget: (value, meta) {
                                              switch (value.toInt()) {
                                                case 0:
                                                  return const Text('Clients');
                                                case 1:
                                                  return const Text(
                                                      'Conducteurs');
                                                case 2:
                                                  return const Text(
                                                      'Utilisateurs');
                                              }
                                              return const Text('');
                                            },
                                            reservedSize: 30,
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
                                            toY: _clientsCount.toDouble(),
                                            width: 20,
                                            color: clientsColor,
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          )
                                        ]),
                                        BarChartGroupData(x: 1, barRods: [
                                          BarChartRodData(
                                            toY: _driversCount.toDouble(),
                                            width: 20,
                                            color: driversColor,
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          )
                                        ]),
                                        BarChartGroupData(x: 2, barRods: [
                                          BarChartRodData(
                                            toY: _usersCount.toDouble(),
                                            width: 20,
                                            color: usersColor,
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          )
                                        ]),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                AspectRatio(
                                  aspectRatio: 1.3,
                                  child: PieChart(
                                    PieChartData(
                                      sectionsSpace: 4,
                                      centerSpaceRadius: 40,
                                      sections: [
                                        PieChartSectionData(
                                          value: _usersCount.toDouble(),
                                          title: '$_usersCount',
                                          radius: 60,
                                          titleStyle: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white),
                                          color: usersColor,
                                        ),
                                        PieChartSectionData(
                                          value: _clientsCount.toDouble(),
                                          title: '$_clientsCount',
                                          radius: 60,
                                          titleStyle: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white),
                                          color: clientsColor,
                                        ),
                                        PieChartSectionData(
                                          value: _driversCount.toDouble(),
                                          title: '$_driversCount',
                                          radius: 60,
                                          titleStyle: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white),
                                          color: driversColor,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // --- Financier ---
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                const Text(
                                  'Statistiques Financières',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
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
                                const SizedBox(height: 16),
                                AspectRatio(
                                  aspectRatio: 1.3,
                                  child: PieChart(
                                    PieChartData(
                                      sectionsSpace: 4,
                                      centerSpaceRadius: 40,
                                      sections: [
                                        PieChartSectionData(
                                          value: _totalPositiveTransactions,
                                          title: _totalPositiveTransactions
                                              .toStringAsFixed(0),
                                          radius: 60,
                                          titleStyle: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white),
                                          color: txColor,
                                        ),
                                        PieChartSectionData(
                                          value: _totalBalances,
                                          title: _totalBalances
                                              .toStringAsFixed(0),
                                          radius: 60,
                                          titleStyle: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white),
                                          color: soldeColor,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }
}

// Widget légende
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
