import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:uuid/uuid.dart';

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

    final parts = raw.split(',');
    final userId = parts[0].split(':')[1].trim();
    final montantString = parts[1].split(':')[1].trim();
    final montant = double.parse(montantString).round();

    final userDoc = FirebaseFirestore.instance.collection('users').doc(userId);
    final userSnapshot = await userDoc.get();

    if (!userSnapshot.exists) {
      _showDialog("Utilisateur non trouvé.");
      return;
    }

    final currentSolde = userSnapshot.data()?['solde'] ?? 0;

    if (currentSolde < montant) {
      _showDialog("Solde insuffisant !");
      String newNotificationsId = const Uuid().v1();
      await userDoc.collection("notification").doc(newNotificationsId).set({
      'notification_id': newNotificationsId,
      'date': DateTime.now(),
      'titre': "Paiement non effectué",
      'content': "Votre solde est insuffisant pour payer ce trajet",
    });
      return;
    }

    // 🔁 Mise à jour du solde de l'utilisateur
    await userDoc.update({
      'solde': FieldValue.increment(-montant),
      'qr_data': FieldValue.delete(), // ✅ Suppression du champ qr_data
    });

    // 🔁 Mise à jour de la réservation
    final reservationRef = FirebaseFirestore.instance
        .collection('trajet')
        .doc(widget.trajetId)
        .collection('reservations')
        .doc(userId);

    await reservationRef.update({
      'paye': 'oui',
      'solde': currentSolde - montant,
    });

    // 🔁 Gestion du numero_transaction
    final userData = userSnapshot.data()!;
    int lastNumber = userData['last_transaction_number'] ?? 0;
    int newNumber = lastNumber + 1;

    String newTransactionsId = const Uuid().v1();
    await userDoc.collection("transactions").doc(newTransactionsId).set({
      'transaction_id': newTransactionsId,
      'time': DateTime.now(),
      'titre': "Bonde sortante",
      'montant': "$montant \$",
      'numero_transaction': newNumber,
    });

    String newNotificationsId = const Uuid().v1();
    await userDoc.collection("notification").doc(newNotificationsId).set({
      'notification_id': newNotificationsId,
      'date': DateTime.now(),
      'titre': "Paiement confirmé",
      'content': "Votre paiement a bien été bien effectué",
    });


    await userDoc.update({'last_transaction_number': newNumber});

    _showDialog("Paiement confirmé ✅");
  } catch (e) {
    _showDialog("Erreur lors du scan : $e");
  }
}



  Future<void> _showDialog(String message) async {
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Résultat du scan"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Fermer l'alerte
              Navigator.of(context).pop(); // Fermer le scanner
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
          detectionSpeed: DetectionSpeed.noDuplicates,
        ),
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
