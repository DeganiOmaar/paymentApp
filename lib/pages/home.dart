import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:stripeapp/stripe_payment/payment_manager.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: ElevatedButton(
              onPressed: ()=>PaymentManager.makePayment(40, "USD"), 
              child: Text("Pay 40 dollar"),
              ),
          )
        ],
      ),
    );
  }
}