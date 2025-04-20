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
      if (!raw.contains("user_id:") || !raw.contains("solde:")) {
        throw Exception("QR invalide");
      }

      final parts = raw.split(',');
      final userId = parts[0].split(':')[1].trim();

      // 🔁 Récupérer le montant du trajet
      final trajetSnapshot = await FirebaseFirestore.instance
          .collection('trajet')
          .doc(widget.trajetId)
          .get();

      if (!trajetSnapshot.exists) {
        _showDialog("Trajet introuvable.");
        return;
      }

      final montant = (trajetSnapshot.data()?['prix'] as num).toDouble();

      // 🔁 Récupérer utilisateur
      final userRef = FirebaseFirestore.instance.collection('users').doc(userId);
      final userSnapshot = await userRef.get();

      if (!userSnapshot.exists) {
        _showDialog("Utilisateur non trouvé.");
        return;
      }

      double currentSolde = (userSnapshot.data()?['solde'] ?? 0).toDouble();

      // 🔁 Échec paiement
      if (currentSolde < montant) {
        String notifId = const Uuid().v1();

        // ✅ Notification personnelle
        Map<String, dynamic> notifDataEchecUser = {
          'notification_id': notifId,
          'date': DateTime.now(),
          'titre': "Paiement échoué",
          'content': "Votre paiement a échoué. Solde insuffisant.",
        };

        // ✅ Notification globale
        Map<String, dynamic> notifDataEchecGlobal = {
          'notification_id': notifId,
          'date': DateTime.now(),
          'titre': "Paiement échoué",
          'content': "Un paiement a échoué à cause d’un solde insuffisant.",
        };

        // 🔁 Sauvegarde des notifications
        await userRef.collection("notification").doc(notifId).set(notifDataEchecUser);
        await FirebaseFirestore.instance
            .collection("notification")
            .doc(notifId)
            .set(notifDataEchecGlobal);

        _showDialog("Solde insuffisant !");
        return;
      }

      // ✅ Paiement accepté
      double newSolde = currentSolde - montant;

      await userRef.update({
        'solde': newSolde,
        'qr_data': "user_id:$userId,solde:$newSolde",
      });

      // ✅ Enregistrement transaction
      int lastNumber = userSnapshot.data()?['last_transaction_number'] ?? 0;
      int newNumber = lastNumber + 1;

      String transactionId = const Uuid().v1();
      await userRef.collection("transactions").doc(transactionId).set({
        'transaction_id': transactionId,
        'time': DateTime.now(),
        'titre': "Bonde sortante",
        'montant': -montant, // ✅ valeur numérique négative
        'numero_transaction': newNumber,
      });

      await userRef.update({'last_transaction_number': newNumber});

      // ✅ Notification succès
      String successNotifId = const Uuid().v1();

      // 🔁 Notification utilisateur
      Map<String, dynamic> notifDataSuccessUser = {
        'notification_id': successNotifId,
        'date': DateTime.now(),
        'titre': "Paiement confirmé",
        'content': "Votre paiement de $montant DT a été effectué avec succès.",
      };

      // 🔁 Notification globale
      Map<String, dynamic> notifDataSuccessGlobal = {
        'notification_id': successNotifId,
        'date': DateTime.now(),
        'titre': "Paiement confirmé",
        'content': "Un paiement de $montant DT a été effectué avec succès.",
      };

      // 🔁 Sauvegarde des notifications
      await userRef.collection("notification").doc(successNotifId).set(notifDataSuccessUser);
      await FirebaseFirestore.instance
          .collection("notification")
          .doc(successNotifId)
          .set(notifDataSuccessGlobal);

      _showDialog("✅ Paiement effectué\n💵 Bon de sortie : $montant DT");

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
              Navigator.of(context).pop(); // Fermer alert
              Navigator.of(context).pop(); // Fermer scanner
            },
            child: const Text("OK"),
          )
        ],
      ),
    );
    isProcessing = false;
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
