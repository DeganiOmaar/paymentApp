// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:stripeapp/trajetScreens/ajouter-trajet.dart';
import '../shared/colors.dart';

class TrajetList extends StatefulWidget {
  const TrajetList({super.key});

  @override
  State<TrajetList> createState() => _TrajetListState();
}

class _TrajetListState extends State<TrajetList> {
  TextEditingController pointdepartController = TextEditingController();
  TextEditingController destinationController = TextEditingController();
  TextEditingController prixController = TextEditingController();
  TextEditingController nombredePlaceController = TextEditingController();
  bool isLoading = false;
  Map userData = {};

  getData() async {
    setState(() {
      isLoading = true;
    });
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance
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
              thirdRingColor: Colors.pink.shade400,
            ),
          ),
        )
        : Scaffold(
          backgroundColor: Colors.white,
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            backgroundColor: Colors.white,
            centerTitle: true,
            title: const Text(
              "Liste des Trajets",
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 19),
            ),
            actions: [
              userData['role'] == 'admin'
                  ? IconButton(
                    icon: const Icon(
                      Icons.add_circle_outline,
                      color: mainColor,
                    ),
                    onPressed: () {
                      Get.to(() => const AjouterTrajet());
                    },
                  )
                  : SizedBox(),
            ],
          ),
          body: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('trajet').snapshots(),
            builder: (
              BuildContext context,
              AsyncSnapshot<QuerySnapshot> snapshot,
            ) {
              if (snapshot.hasError) {
                return const Text('Something went wrong');
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: LoadingAnimationWidget.discreteCircle(
                    size: 32,
                    color: const Color.fromARGB(255, 16, 16, 16),
                    secondRingColor: Colors.indigo,
                    thirdRingColor: Colors.pink.shade400,
                  ),
                );
              }

              return ListView(
                children:
                    snapshot.data!.docs.map((DocumentSnapshot document) {
                      Map<String, dynamic> data =
                          document.data()! as Map<String, dynamic>;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Column(
                          children: [
                            GestureDetector(
                           onTap: () async {
  final userId = userData['uid'];
  final trajetId = data['trajet_id'];

  // Vérifier si l'utilisateur a déjà réservé
  final reservationRef = FirebaseFirestore.instance
      .collection('trajet')
      .doc(trajetId)
      .collection('reservations')
      .doc(userId);

  final reservationSnapshot = await reservationRef.get();

  if (reservationSnapshot.exists) {
    // Déjà réservé ❌
    QuickAlert.show(
      context: context,
      type: QuickAlertType.error,
      title: 'Déjà réservé',
      text: 'Vous avez déjà réservé ce trajet.',
    );
  } else {
    // Réservation possible ✅
    await reservationRef.set({
      'user_id': userId,
      'nom': userData['nom'],
      'prenom': userData['prenom'],
      'montant': data['prix'],
      'paye': 'non',
    });

    QuickAlert.show(
      context: context,
      type: QuickAlertType.success,
      title: 'Succès',
      text: 'Vous avez réservé votre place.',
    );
  }
},

                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  side: const BorderSide(
                                    color: mainColor,
                                    width: 1.2,
                                  ),
                                ),
                                elevation: 5,
                                color: Colors.white,
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Row(
                                    children: [
                                      const Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Point de depart 📍",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Gap(10),
                                          Text(
                                            "Destination 📍",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Gap(10),
                                          Text(
                                            "De ⌚",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Gap(10),
                                          Text(
                                            "Jusqu' ⌚",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Gap(10),
                                          Text(
                                            "Prix 💵",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Gap(20),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              data['point_depart'],
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const Gap(10),
                                            Text(
                                              data['destination'],
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const Gap(10),
                                            Text(
                                              data['start_time'],
                                              style: const TextStyle(
                                                // fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const Gap(10),
                                            Text(
                                              data['end_time'],
                                              style: const TextStyle(
                                                // fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const Gap(10),
                                            Text(
                                              // "50 DT",
                                              "${data['prix']} DT",
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      userData['role'] == 'admin'
                                          ? Column(
                                            children: [
                                              IconButton(
                                                icon: const Icon(
                                                  LineAwesomeIcons
                                                      .trash_alt_solid,
                                                  color: Colors.red,
                                                ),
                                                onPressed: () {
                                                  FirebaseFirestore.instance
                                                      .collection('trajet')
                                                      .doc(data['trajet_id'])
                                                      .delete();
                                                },
                                              ),

                                              IconButton(
                                                onPressed: () {
                                                  showDialog(
                                                    context: context,
                                                    builder:
                                                        (
                                                          context,
                                                        ) => AlertDialog(
                                                          backgroundColor:
                                                              Colors.white,
                                                          actions: [
                                                            TextButton(
                                                              onPressed: () {
                                                                Navigator.of(
                                                                  context,
                                                                ).pop();
                                                              },
                                                              child: const Text(
                                                                "Retour",
                                                                style: TextStyle(
                                                                  color:
                                                                      Colors
                                                                          .red,
                                                                ),
                                                              ),
                                                            ),
                                                            TextButton(
                                                              onPressed: () async {
                                                                await FirebaseFirestore
                                                                    .instance
                                                                    .collection(
                                                                      'trajet',
                                                                    )
                                                                    .doc(
                                                                      data['trajet_id'],
                                                                    )
                                                                    .update({
                                                                      'point_depart':
                                                                          pointdepartController.text.isEmpty
                                                                              ? data['point_depart']
                                                                              : pointdepartController.text,
                                                                      'destination':
                                                                          destinationController.text.isEmpty
                                                                              ? data['destination']
                                                                              : destinationController.text,
                                                                      'nombre_places':
                                                                          nombredePlaceController.text.isEmpty
                                                                              ? data['nombre_places']
                                                                              : int.parse(
                                                                                nombredePlaceController.text,
                                                                              ),
                                                                      'prix':
                                                                          prixController.text.isEmpty
                                                                              ? data['prix']
                                                                              : double.parse(
                                                                                prixController.text,
                                                                              ),
                                                                    });
                                                                pointdepartController
                                                                    .clear();
                                                                destinationController
                                                                    .clear();
                                                                nombredePlaceController
                                                                    .clear();
                                                                prixController
                                                                    .clear();
                                                                if (!mounted)
                                                                  return;
                                                                Navigator.of(
                                                                  context,
                                                                ).pop();
                                                                setState(() {});
                                                              },
                                                              child: const Text(
                                                                "Modifier",
                                                                style: TextStyle(
                                                                  color:
                                                                      mainColor,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                          contentPadding:
                                                              const EdgeInsets.all(
                                                                20,
                                                              ),
                                                          content: SizedBox(
                                                            height: 390,
                                                            child: Column(
                                                              children: [
                                                                SizedBox(
                                                                  width:
                                                                      MediaQuery.of(
                                                                        context,
                                                                      ).size.width,
                                                                  height: 80,
                                                                  child: TextField(
                                                                    controller:
                                                                        pointdepartController,
                                                                    maxLines:
                                                                        null,
                                                                    expands:
                                                                        true,
                                                                    keyboardType:
                                                                        TextInputType
                                                                            .multiline,
                                                                    decoration: InputDecoration(
                                                                      hintText:
                                                                          data['point_depart'],
                                                                      hintStyle:
                                                                          const TextStyle(
                                                                            color:
                                                                                Colors.black87,
                                                                          ),
                                                                      enabledBorder: OutlineInputBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                              25,
                                                                            ),
                                                                        borderSide: const BorderSide(
                                                                          color: Color.fromARGB(
                                                                            255,
                                                                            220,
                                                                            220,
                                                                            220,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      border: OutlineInputBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                              25,
                                                                            ),
                                                                      ),
                                                                      focusedBorder: OutlineInputBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                              25,
                                                                            ),
                                                                        borderSide: const BorderSide(
                                                                          color: Color.fromARGB(
                                                                            255,
                                                                            220,
                                                                            220,
                                                                            220,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      contentPadding: const EdgeInsets.symmetric(
                                                                        horizontal:
                                                                            15,
                                                                        vertical:
                                                                            15,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                const Gap(20),
                                                                SizedBox(
                                                                  width:
                                                                      MediaQuery.of(
                                                                        context,
                                                                      ).size.width,
                                                                  height: 80,
                                                                  child: TextField(
                                                                    controller:
                                                                        destinationController,
                                                                    maxLines:
                                                                        null,
                                                                    expands:
                                                                        true,
                                                                    keyboardType:
                                                                        TextInputType
                                                                            .multiline,
                                                                    decoration: InputDecoration(
                                                                      hintText:
                                                                          data['destination'],
                                                                      hintStyle:
                                                                          const TextStyle(
                                                                            color:
                                                                                Colors.black87,
                                                                          ),
                                                                      enabledBorder: OutlineInputBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                              25,
                                                                            ),
                                                                        borderSide: const BorderSide(
                                                                          color: Color.fromARGB(
                                                                            255,
                                                                            220,
                                                                            220,
                                                                            220,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      border: OutlineInputBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                              25,
                                                                            ),
                                                                      ),
                                                                      focusedBorder: OutlineInputBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                              25,
                                                                            ),
                                                                        borderSide: const BorderSide(
                                                                          color: Color.fromARGB(
                                                                            255,
                                                                            220,
                                                                            220,
                                                                            220,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      contentPadding: const EdgeInsets.symmetric(
                                                                        horizontal:
                                                                            15,
                                                                        vertical:
                                                                            15,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                const Gap(20),
                                                                SizedBox(
                                                                  width:
                                                                      MediaQuery.of(
                                                                        context,
                                                                      ).size.width,
                                                                  height: 80,
                                                                  child: TextField(
                                                                    controller:
                                                                        nombredePlaceController,
                                                                    maxLines:
                                                                        null,
                                                                    expands:
                                                                        true,
                                                                    keyboardType:
                                                                        TextInputType
                                                                            .multiline,
                                                                    decoration: InputDecoration(
                                                                      hintText:
                                                                          data['nombre_places']
                                                                              .toString(),
                                                                      hintStyle:
                                                                          const TextStyle(
                                                                            color:
                                                                                Colors.black87,
                                                                          ),
                                                                      enabledBorder: OutlineInputBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                              25,
                                                                            ),
                                                                        borderSide: const BorderSide(
                                                                          color: Color.fromARGB(
                                                                            255,
                                                                            220,
                                                                            220,
                                                                            220,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      border: OutlineInputBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                              25,
                                                                            ),
                                                                      ),
                                                                      focusedBorder: OutlineInputBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                              25,
                                                                            ),
                                                                        borderSide: const BorderSide(
                                                                          color: Color.fromARGB(
                                                                            255,
                                                                            220,
                                                                            220,
                                                                            220,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      contentPadding: const EdgeInsets.symmetric(
                                                                        horizontal:
                                                                            15,
                                                                        vertical:
                                                                            15,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                const Gap(20),
                                                                SizedBox(
                                                                  width:
                                                                      MediaQuery.of(
                                                                        context,
                                                                      ).size.width,
                                                                  height: 80,
                                                                  child: TextField(
                                                                    controller:
                                                                        prixController,
                                                                    maxLines:
                                                                        null,
                                                                    expands:
                                                                        true,
                                                                    keyboardType:
                                                                        TextInputType
                                                                            .multiline,
                                                                    decoration: InputDecoration(
                                                                      hintText:
                                                                          data['prix']
                                                                              .toString(),
                                                                      hintStyle:
                                                                          const TextStyle(
                                                                            color:
                                                                                Colors.black87,
                                                                          ),
                                                                      enabledBorder: OutlineInputBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                              25,
                                                                            ),
                                                                        borderSide: const BorderSide(
                                                                          color: Color.fromARGB(
                                                                            255,
                                                                            220,
                                                                            220,
                                                                            220,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      border: OutlineInputBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                              25,
                                                                            ),
                                                                      ),
                                                                      focusedBorder: OutlineInputBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                              25,
                                                                            ),
                                                                        borderSide: const BorderSide(
                                                                          color: Color.fromARGB(
                                                                            255,
                                                                            220,
                                                                            220,
                                                                            220,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      contentPadding: const EdgeInsets.symmetric(
                                                                        horizontal:
                                                                            15,
                                                                        vertical:
                                                                            15,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                  );
                                                },
                                                icon: const Icon(
                                                  Icons.edit,
                                                  color: Color.fromARGB(
                                                    255,
                                                    55,
                                                    211,
                                                    61,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          )
                                          : SizedBox(),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
              );
            },
          ),
        );
  }

  Future<void> addMemeber(String trajetId, String montant) {
    return FirebaseFirestore.instance
        .collection('trajet')
        .doc(trajetId)
        .collection('reservations')
        .doc(userData['uid'])
        .set({
          'user_id': userData['uid'],
          'nom': userData['nom'],
          'prenom': userData['prenom'],
          'montant': int.parse(montant),
          'paye': 'non',
        })
        .then((value) => print("User Updated"))
        .catchError((error) => print("Failed to update user: $error"));
  }
}
