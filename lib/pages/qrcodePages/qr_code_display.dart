import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:stripeapp/notificationsPages/notifications.dart';
import 'package:stripeapp/shared/colors.dart';

class QRCodeDisplayPage extends StatefulWidget {
  const QRCodeDisplayPage({super.key});

  @override
  State<QRCodeDisplayPage> createState() => _QRCodeDisplayPageState();
}

class _QRCodeDisplayPageState extends State<QRCodeDisplayPage> {
  String? uid;
  double? solde;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final uidUser = user.uid;
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(uidUser).get();

    if (doc.exists && doc.data() != null) {
      setState(() {
        uid = uidUser;
        solde = doc['solde'] != null ? doc['solde'].toDouble() : 0.0;
        isLoading = false;
      });
    } else {
      setState(() {
        uid = uidUser;
        solde = 0.0;
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

    String qrContent = "user_id:$uid,solde:$solde";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("Votre QR Code"),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Get.to(() => Notifications());
            },
            icon: Icon(Icons.notifications_active_outlined, color: mainColor),
          ),
        ],
      ),
      body: Center(child: QrImageView(data: qrContent, size: 250)),
    );
  }
}
