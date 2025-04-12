import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRCodePage extends StatelessWidget {
  final String userId;
  final String montant;

  const QRCodePage({
    super.key,
    required this.userId,
    required this.montant,
  });

  @override
  Widget build(BuildContext context) {
    String qrData = "user_id:$userId,montant:$montant";

    return Scaffold(
      appBar: AppBar(
        title: const Text("Votre QR Code"),
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Text(userId),
          Text(montant),
          Center(
        child: QrImageView(
          data: qrData,
          version: QrVersions.auto,
          size: 250,
        ),
      ),
        ],
      )
    );
  }
}
