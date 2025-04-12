import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRScannerPage extends StatefulWidget {
  final String trajetId;

  const QRScannerPage({super.key, required this.trajetId});

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  bool isProcessing = false;

  void handleScan(String raw) async {
    if (isProcessing) return;
    isProcessing = true;

    try {
      if (!raw.contains("user_id:") || !raw.contains("montant:")) {
        throw Exception("QR invalide");
      }

      // final parts = raw.split(',');
      // final userId = parts[0].split(':')[1];
      // final montant = int.parse(parts[1].split(':')[1]);
      final parts = raw.split(',');
      final userId = parts[0].split(':')[1].trim();
      final montantString = parts[1].split(':')[1].trim();
      double montantDouble = double.parse(montantString);
      int montant = montantDouble.round(); // ou .toInt()


      final userDoc = FirebaseFirestore.instance.collection('users').doc(userId);
      final userSnapshot = await userDoc.get();
      final currentSolde = userSnapshot.data()?['solde'] ?? 0;

      if (currentSolde < montant) {
        _showDialog("Solde insuffisant !");
        return;
      }

      // 🔁 Mettre à jour le solde
      await userDoc.update({
        'solde': FieldValue.increment(-montant),
      });

      // 🔁 Mettre à jour la réservation
      final reservationRef = FirebaseFirestore.instance
          .collection('trajet')
          .doc(widget.trajetId)
          .collection('reservations')
          .doc(userId);

      await reservationRef.update({
        'paye': 'oui',
        'solde': currentSolde - montant,
      });

      _showDialog("Paiement confirmé ✅");
    } catch (e) {
      _showDialog("QR invalide ou erreur : $e");
    }
  }

  void _showDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Résultat du scan"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Fermer scanner
            },
            child: const Text("OK"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Scanner le QR"),
        centerTitle: true,
      ),
   body: MobileScanner(
            controller: MobileScannerController(
          detectionSpeed:  DetectionSpeed.noDuplicates
        ),
  // allowDuplicates: false,
  onDetect: (BarcodeCapture capture) {
    final barcode = capture.barcodes.first;
    final raw = barcode.rawValue;

    if (raw != null) {
      handleScan(raw);
    }
  },
),
    );
  }
}
