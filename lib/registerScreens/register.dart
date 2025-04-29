import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:get/get.dart';
import 'package:quickalert/quickalert.dart';
import 'package:stripeapp/registerScreens/login.dart';
import 'package:stripeapp/registerScreens/registertextfield.dart';
import 'package:stripeapp/registerScreens/email_verification.dart';  // ← import ajouté
import 'package:stripeapp/screens.dart';
import '../../shared/colors.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  GlobalKey<FormState> formstate = GlobalKey<FormState>();
  bool isPasswordVisible = true;
  TextEditingController nomController = TextEditingController();
  TextEditingController prenomController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  bool isLoading = false;

  register() async {
    setState(() {
      isLoading = true;
    });
    try {
      // 1) création du compte
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // 2) envoi du mail de vérification
      await FirebaseAuth.instance.currentUser!.sendEmailVerification();

      // 3) stockage en Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .set({
        "nom": nomController.text.trim(),
        "prenom": prenomController.text.trim(),
        "email": emailController.text.trim(),
        "password": passwordController.text.trim(),
        "role": "client",
        "phone": '',
        "solde": 0,
        "last_transaction_number": 0,
        "uid": FirebaseAuth.instance.currentUser!.uid,
      });

      if (!mounted) return;

      // 4) redirection vers la page de vérification
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const EmailVerificationPage(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      // gestion des erreurs FirebaseAuth
      if (e.code == 'weak-password') {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Erreur…',
          text: 'Mot de passe trop faible !',
        );
      } else if (e.code == 'email-already-in-use') {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Erreur…',
          text: 'Cet utilisateur existe déjà !',
        );
      }
      setState(() => isLoading = false);
    } catch (e) {
      // erreur générique
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Oops…',
        text: 'Vérifiez votre e-mail ou votre mot de passe !',
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 15.0),
        child: Form(
          key: formstate,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Inscription",
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              const Text(
                "Rejoignez notre communauté en quelques étapes simples.",
                style: TextStyle(color: Colors.black),
              ),
              const SizedBox(height: 50),
              Row(
                children: [
                  Expanded(
                    child: RegistrationTextField(
                      icon: CupertinoIcons.person,
                      text: "  Nom",
                      controller: nomController,
                      validator: (value) =>
                          value!.isEmpty ? "Entrez un nom valide" : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: RegistrationTextField(
                      icon: CupertinoIcons.person,
                      text: "Prenom",
                      controller: prenomController,
                      validator: (value) =>
                          value!.isEmpty ? "Entrez un prenom valide" : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              RegistrationTextField(
                icon: CupertinoIcons.mail,
                text: "  Email",
                controller: emailController,
                validator: (email) => email!.contains(RegExp(
                        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+"))
                    ? null
                    : "Entrez un email valide",
              ),
              const SizedBox(height: 30),
              TextFormField(
                validator: (value) =>
                    value!.length < 6 ? "Entrer au moins 6 caractères" : null,
                obscureText: isPasswordVisible,
                controller: passwordController,
                decoration: InputDecoration(
                  suffixIcon: GestureDetector(
                    onTap: () {
                      setState(() {
                        isPasswordVisible = !isPasswordVisible;
                      });
                    },
                    child: Icon(
                      isPasswordVisible
                          ? CupertinoIcons.eye
                          : CupertinoIcons.eye_slash,
                      color: Colors.black,
                      size: 22,
                    ),
                  ),
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(top: 2.0, left: 3.0),
                    child: Icon(
                      CupertinoIcons.lock_rotation_open,
                      color: Colors.black,
                      size: 22,
                    ),
                  ),
                  hintText: "Mot de passe",
                  hintStyle: const TextStyle(color: Colors.black, fontSize: 16),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: const BorderSide(color: Colors.black),
                  ),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: const BorderSide(color: Colors.black),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
              const SizedBox(height: 30),
              TextFormField(
                validator: (value) =>
                    value!.length < 6 ? "Entrer au moins 6 caractères" : null,
                obscureText: isPasswordVisible,
                controller: confirmPasswordController,
                decoration: InputDecoration(
                  suffixIcon: GestureDetector(
                    onTap: () {
                      setState(() {
                        isPasswordVisible = !isPasswordVisible;
                      });
                    },
                    child: Icon(
                      isPasswordVisible
                          ? CupertinoIcons.eye
                          : CupertinoIcons.eye_slash,
                      color: Colors.black,
                      size: 22,
                    ),
                  ),
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(top: 2.0, left: 3.0),
                    child: Icon(
                      CupertinoIcons.lock_rotation_open,
                      color: Colors.black,
                      size: 22,
                    ),
                  ),
                  hintText: "Confirmer mot de passe",
                  hintStyle: const TextStyle(color: Colors.black, fontSize: 16),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: const BorderSide(color: Colors.black),
                  ),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: const BorderSide(color: Colors.black),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {},
                child: const Align(
                  alignment: Alignment.centerRight,
                  child: Text("Mot de passe oublié?",
                      style: TextStyle(color: Colors.black)),
                ),
              ),
              const SizedBox(height: 35),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (formstate.currentState!.validate()) {
                          await register();
                        } else {
                          QuickAlert.show(
                            context: context,
                            type: QuickAlertType.error,
                            title: 'Erreur',
                            text: 'Ajoutez vos informations',
                          );
                        }
                      },
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(mainColor),
                        padding: isLoading
                            ? MaterialStateProperty.all(
                                const EdgeInsets.all(10))
                            : MaterialStateProperty.all(
                                const EdgeInsets.all(13)),
                        shape:
                            MaterialStateProperty.all(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        )),
                      ),
                      child: isLoading
                          ? Center(
                              child:
                                  LoadingAnimationWidget.staggeredDotsWave(
                                color: Colors.white,
                                size: 32,
                              ),
                            )
                          : const Text(
                              "Enregistrer",
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Vous avez un compte?",
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.w700),
                  ),
                  TextButton(
                    onPressed: () {
                      Get.off(() => const LoginPage(),
                          transition: Transition.upToDown);
                    },
                    child: const Text(
                      "Se connecter",
                      style: TextStyle(
                          color: mainColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 17),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
