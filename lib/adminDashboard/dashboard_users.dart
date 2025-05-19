// lib/pages/admin_stats_page.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class AdminStatsPage extends StatefulWidget {
  const AdminStatsPage({Key? key}) : super(key: key);

  @override
  _AdminStatsPageState createState() => _AdminStatsPageState();
}

class _AdminStatsPageState extends State<AdminStatsPage> {
  bool _isLoading = true;
  int _clientsCount = 0;
  int _driversCount = 0;
  int _usersCount = 0;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    try {
      final usersRef = FirebaseFirestore.instance.collection('users');
      final clientsSnap = await usersRef.where('role', isEqualTo: 'client').get();
      final driversSnap = await usersRef.where('role', isEqualTo: 'conducteur').get();
      final usersSnap = await usersRef.get();

      setState(() {
        _clientsCount = clientsSnap.size;
        _driversCount = driversSnap.size;
        _usersCount = usersSnap.size;
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
    // Palette dynamique
    const Color usersColor    = Color(0xFF9C27B0); // violet
    const Color clientsColor  = Color(0xFF03A9F4); // turquoise
    const Color driversColor  = Color(0xFFE91E63); // corail

    // Calcul des pourcentages
    final double total     = (_clientsCount + _driversCount + _usersCount).toDouble();
    final double pctClients = total > 0 ? _clientsCount / total * 100 : 0;
    final double pctDrivers = total > 0 ? _driversCount / total * 100 : 0;
    final double pctUsers   = total > 0 ? _usersCount / total * 100 : 0;

    final maxY = [
      _clientsCount,
      _driversCount,
      _usersCount,
    ].reduce((a, b) => a > b ? a : b).toDouble();

    return Scaffold(
      appBar: AppBar(
        // title: const Text('Dashboard Admin'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: const Text(
                          'Vue d’ensemble',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // BarChart : clients / conducteurs / total utilisateurs
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              const Text(
                                'Comparatif Clients / Conducteurs / Utilisateurs',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 12),
                              AspectRatio(
                                aspectRatio: 1.7,
                                child: BarChart(
                                  BarChartData(
                                    alignment: BarChartAlignment.spaceAround,
                                    maxY: maxY,
                                    barTouchData: BarTouchData(enabled: false),
                                    titlesData: FlTitlesData(
                                      leftTitles: AxisTitles(
                                        sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                                      ),
                                      bottomTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          getTitlesWidget: (value, meta) {
                                            switch (value.toInt()) {
                                              case 0:
                                                return const Text('Clients');
                                              case 1:
                                                return const Text('Conducteurs');
                                              case 2:
                                                return const Text('Utilisateurs');
                                              default:
                                                return const Text('');
                                            }
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
                                          borderRadius: BorderRadius.circular(4),
                                        )
                                      ]),
                                      BarChartGroupData(x: 1, barRods: [
                                        BarChartRodData(
                                          toY: _driversCount.toDouble(),
                                          width: 20,
                                          color: driversColor,
                                          borderRadius: BorderRadius.circular(4),
                                        )
                                      ]),
                                      BarChartGroupData(x: 2, barRods: [
                                        BarChartRodData(
                                          toY: _usersCount.toDouble(),
                                          width: 20,
                                          color: usersColor,
                                          borderRadius: BorderRadius.circular(4),
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

                      // PieChart avec légende en carrés + pourcentages
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              const Text(
                                'Répartition Clients / Conducteurs / Utilisateurs',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 12),

                              // Légende colorée avec pourcentages
                              Column(
                                children: [
                                  _LegendItem(color: usersColor,   label: 'Utilisateurs', percent: pctUsers),
                                  _LegendItem(color: clientsColor, label: 'Clients',      percent: pctClients),
                                  _LegendItem(color: driversColor, label: 'Conducteurs',  percent: pctDrivers),
                                ],
                              ),

                              const SizedBox(height: 16),

                              // Le cercle
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
                                          color: Colors.white,
                                        ),
                                        color: usersColor,
                                      ),
                                      PieChartSectionData(
                                        value: _clientsCount.toDouble(),
                                        title: '$_clientsCount',
                                        radius: 60,
                                        titleStyle: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                        color: clientsColor,
                                      ),
                                      PieChartSectionData(
                                        value: _driversCount.toDouble(),
                                        title: '$_driversCount',
                                        radius: 60,
                                        titleStyle: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
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
                    ],
                  ),
                ),
    );
  }
}

// Widget pour la légende
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 16, height: 16,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
          ),
          const SizedBox(width: 8),
          Text('$label: ${percent.toStringAsFixed(1)}%'),
        ],
      ),
    );
  }
}
