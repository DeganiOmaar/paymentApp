import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:stripeapp/shared/colors.dart';

class TransactionCard extends StatelessWidget {
  final String bondeType;
  final num montant;
  final String numeroTransactions;
  final String date;
  final String heure;

  const TransactionCard({
    super.key,
    required this.bondeType,
    required this.montant,
    required this.numeroTransactions,
    required this.date,
    required this.heure,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),
        side: BorderSide(color: mainColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  date,
                  style: TextStyle(color: Colors.deepOrange),
                ),
                const Gap(12),
                Text(
                  heure,
                  style: TextStyle(color: Colors.deepOrange),
                ),
              ],
            ),
            const Gap(12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text("Service", style: TextStyle(color: mainColor)),
                      Gap(10),
                      Text("Montant", style: TextStyle(color: mainColor)),
                      Gap(10),
                      Text("Numéro de paiement", style: TextStyle(color: mainColor)),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(bondeType),
                      const Gap(10),
                      Text(
                        "${montant > 0 ? '+ ' : ''}${montant.abs()} DT",
                        style: TextStyle(
                          color: montant < 0 ? Colors.red : Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Gap(10),
                      Text(numeroTransactions),
                    ],
                  ),
                ),
              ],
            ),
            const Gap(10),
          ],
        ),
      ),
    );
  }
}
