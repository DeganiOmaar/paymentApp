import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:stripeapp/profilePages/profilebutton.dart';
import 'package:stripeapp/profilePages/profiletextfield.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  Map userData = {};
  bool isLoading = true;

  getData() async {
    setState(() {
      isLoading = true;
    });
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();

      userData = snapshot.data()!;
    } catch (e) {
      print(e.toString());
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  DateTime startDate = DateTime.now();
  TextEditingController nomController = TextEditingController();
  TextEditingController prenomController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: LoadingAnimationWidget.discreteCircle(
                  size: 32,
                  color: const Color.fromARGB(255, 16, 16, 16),
                  secondRingColor: Colors.indigo,
                  thirdRingColor: Colors.pink.shade400),
            ),
          )
        : Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              centerTitle: true,
              leading: IconButton(
                onPressed: () {
                  Get.back();
                },
                icon: const Icon(LineAwesomeIcons.angle_left_solid),
              ),
              title: const Text(
                "Profile",
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 19),
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    SvgPicture.asset(
                      'assets/images/avatar.svg',
                      height: 100.0,
                      width: 100.0,
                      allowDrawingOutsideViewBox: true,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: [
                        Expanded(
                            child: ProfileTextField(
                          title: "Nom",
                          text: userData['nom'] == ""
                              ? "Entrer votre nom"
                              : userData['nom'].substring(0, 1).toUpperCase() +
                                  userData['nom'].substring(1),
                          controller: nomController,
                        )),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Expanded(
                            child: ProfileTextField(
                          title: "Prénom",
                          text: userData['prenom'] == ""
                              ? "Entrer votre prenom"
                              : userData['prenom'].substring(0, 1).toUpperCase() +
                                  userData['prenom'].substring(1),
                          controller: prenomController,
                        )),
                      ],
                    ),
                
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Expanded(
                            child: ProfileTextField(
                          title: "Email",
                          text: userData['email'] == ""
                              ? "Entrer votre email"
                              : userData['email'],
                          controller: emailController,
                        )),
                      ],
                    ),
                
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Expanded(
                            child: ProfileTextField(
                          title: "Télphone",
                          text: userData['phone'] == ""
                              ? "Entrer votre numéro de télphone"
                              : userData['phone'],
                          controller: phoneController,
                        )),
                      ],
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    //  const Spacer(),
                    Row(
                      children: [
                        Expanded(
                            child: ProfileButton(
                                onPressed: () async {
                                  await FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(FirebaseAuth.instance.currentUser!.uid)
                                      .update({
                                    "nom": nomController.text == ""
                                        ? userData['nom']
                                        : nomController.text,
                                    "prenom": prenomController.text == ""
                                        ? userData['prenom']
                                        : prenomController.text,
                                    "email": emailController.text == ""
                                        ? userData['email']
                                        : emailController.text,
                                    "phone": phoneController.text == ""
                                        ? userData['phone']
                                        : phoneController.text,
                                  });
                                  setState(() {});
                                  Get.back();
                                },
                                textButton: "Mettre à jour votre profil")),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}
