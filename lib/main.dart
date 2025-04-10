import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:stripeapp/screens.dart';
import 'package:stripeapp/stripe_payment/stripe_keys.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'registerScreens/login.dart';

void main() async {
  Stripe.publishableKey = ApiKeys.pusblishableKey;
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home:
          FirebaseAuth.instance.currentUser == null
              ? const LoginPage()
              : const Screens(),
    );
  }
}
