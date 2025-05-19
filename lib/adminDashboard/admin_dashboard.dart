import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardAdminUserStaticPage extends StatefulWidget {
  const DashboardAdminUserStaticPage({Key? key}) : super(key: key);

  @override
  _DashboardAdminUserStaticPageState createState() =>
      _DashboardAdminUserStaticPageState();
}

class _DashboardAdminUserStaticPageState
    extends State<DashboardAdminUserStaticPage> {
  late Future<Map<String, int>> _statsFuture;

  @override
  void initState() {
    super.initState();
    _statsFuture = _fetchStats();
  }

  /// Récupère le nombre total, clients et conducteurs
  Future<Map<String, int>> _fetchStats() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('users').get();
    final total = snapshot.docs.length;
    final clients = snapshot.docs
        .where((d) => (d.data()['role'] as String) == 'client')
        .length;
    final conducteurs = snapshot.docs
        .where((d) => (d.data()['role'] as String) == 'conducteur')
        .length;
    return {
      'total': total,
      'clients': clients,
      'conducteurs': conducteurs,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title: const Text('Dashboard Admin - Utilisateurs'),
        centerTitle: true,
      ),
      body: FutureBuilder<Map<String, int>>(
        future: _statsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erreur : ${snapshot.error}'));
          }

          final stats = snapshot.data!;
          // Valeur maximale et pas de graduation entiers
          final int maxCount = [
            stats['total']!,
            stats['clients']!,
            stats['conducteurs']!
          ].reduce((a, b) => a > b ? a : b);
          final int step = (maxCount / 5).ceil();
          final double maxY = (step * 5).toDouble();

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Text(
                  'Statistiques Utilisateurs',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: maxY,
                      barTouchData: BarTouchData(enabled: true),
                      titlesData: FlTitlesData(
                        show: true,
                        // Axe de gauche (graduations entières)
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: step.toDouble(),
                            getTitlesWidget: (value, meta) =>
                                Text(value.toInt().toString()),
                          ),
                        ),
                        // Axe du bas (labels des catégories)
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              switch (value.toInt()) {
                                case 0:
                                  return const Text('Total');
                                case 1:
                                  return const Text('Clients');
                                case 2:
                                  return const Text('Conducteurs');
                                default:
                                  return const Text('');
                              }
                            },
                          ),
                        ),
                        // Masquer haut & droite
                        topTitles:   AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      gridData:   FlGridData(show: true),
                      borderData: FlBorderData(show: false),
                      barGroups: [
                        BarChartGroupData(
                          x: 0,
                          barRods: [
                            BarChartRodData(
                              toY: stats['total']!.toDouble(),
                              width: 30,
                              color: Colors.blueAccent,
                            ),
                          ],
                        ),
                        BarChartGroupData(
                          x: 1,
                          barRods: [
                            BarChartRodData(
                              toY: stats['clients']!.toDouble(),
                              width: 30,
                              color: Colors.greenAccent,
                            ),
                          ],
                        ),
                        BarChartGroupData(
                          x: 2,
                          barRods: [
                            BarChartRodData(
                              toY: stats['conducteurs']!.toDouble(),
                              width: 30,
                              color: Colors.orangeAccent,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
