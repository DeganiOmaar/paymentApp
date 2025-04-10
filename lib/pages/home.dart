import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:stripeapp/stripe_payment/payment_manager.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(onPressed: (){}, icon: Icon(Icons.qr_code))
        ],
      ),
      body: MobileScanner(
        onDetect: (capture) {},
      )
    );
  }
}