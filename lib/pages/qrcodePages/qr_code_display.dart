import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRCodeDisplayPage extends StatefulWidget {
  const QRCodeDisplayPage({super.key});

  @override
  State<QRCodeDisplayPage> createState() => _QRCodeDisplayPageState();
}

class _QRCodeDisplayPageState extends State<QRCodeDisplayPage> {
  String? qrData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadQRData();
  }

  Future<void> loadQRData() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    if (doc.exists && doc.data()!.containsKey('qr_data')) {
      setState(() {
        qrData = doc['qr_data'];
        isLoading = false;
      });
    } else {
      setState(() {
        qrData = null;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("Votre QR Code"),
        centerTitle: true,
      ),
      body: Center(
        child:
            qrData != null
                ? QrImageView(data: qrData!, size: 250)
                : const Text(
                  "Vous n’avez réservé aucun trajet.",
                  style: TextStyle(fontSize: 18),
                ),
      ),
    );
  }
}
