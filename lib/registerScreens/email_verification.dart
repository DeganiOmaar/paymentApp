import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:quickalert/quickalert.dart';
import '../../shared/colors.dart';
import '../screens.dart';
import 'login.dart';

class EmailVerificationPage extends StatefulWidget {
  const EmailVerificationPage({super.key});

  @override
  State<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  bool isChecking = false;
  bool isResending = false;

  Future<void> _checkVerified() async {
    setState(() => isChecking=true);
    await FirebaseAuth.instance.currentUser?.reload();
    if (FirebaseAuth.instance.currentUser?.emailVerified==true) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.success,
        title: 'Succès',
        text: 'Email vérifié !',
      );
      await Future.delayed(const Duration(seconds: 1));
      Get.off(() => const Screens());
    } else {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.warning,
        title: 'En attente',
        text: 'Email non vérifié.',
      );
    }
    setState(()=>isChecking=false);
  }

  Future<void> _resendEmail() async {
    setState(() => isResending=true);
    await FirebaseAuth.instance.currentUser?.sendEmailVerification();
    QuickAlert.show(
      context: context,
      type: QuickAlertType.info,
      title: 'Envoyé',
      text: 'Email de vérification renvoyé.',
    );
    setState(()=>isResending=false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text('Vérification Email', style: TextStyle(fontSize:21, fontWeight: FontWeight.bold)),
            const SizedBox(height:5),
            const Text(
              "Un e-mail de confirmation vous\u2019a été envoyé.\nVeuillez vérifier votre boîte mail.",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height:50),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isChecking? null: _checkVerified,
                style: ElevatedButton.styleFrom(
                  backgroundColor: mainColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  padding: const EdgeInsets.symmetric(vertical:14),
                ),
                child: isChecking
                    ? LoadingAnimationWidget.staggeredDotsWave(color: Colors.white, size:32)
                    : const Text('J\u2019ai confirmé', style: TextStyle(fontSize:16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
            const SizedBox(height:20),
            TextButton(
              onPressed: isResending? null: _resendEmail,
              child: isResending
                  ? LoadingAnimationWidget.staggeredDotsWave(color: mainColor, size:24)
                  : const Text('Renvoyer l\'e-mail', style: TextStyle(color: mainColor, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height:30),
            TextButton(
              onPressed: () => Get.off(() => const LoginPage()),
              child: const Text('Retour à la connexion', style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }
}
