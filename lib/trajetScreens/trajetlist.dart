// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:stripeapp/pages/qrcodePages/qr_scanner_page.dart';
import 'package:stripeapp/trajetScreens/ajouter-trajet.dart';
import '../shared/colors.dart';

class TrajetList extends StatefulWidget {
  const TrajetList({super.key});

  @override
  State<TrajetList> createState() => _TrajetListState();
}

class _TrajetListState extends State<TrajetList> {
  bool isLoading = false;
  Map userData = {};

  final TextEditingController pointdepartController = TextEditingController();
  final TextEditingController destinationController = TextEditingController();
  final TextEditingController prixController = TextEditingController();

  getData() async {
    setState(() {
      isLoading = true;
    });
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
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
            appBar: AppBar(
              backgroundColor: Colors.white,
              centerTitle: true,
              title: const Text(
                "Liste des Trajets",
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 19),
              ),
              actions: [
                if (userData['role'] == 'admin')
                  IconButton(
                    icon: const Icon(
                      Icons.add_circle_outline,
                      color: mainColor,
                    ),
                    onPressed: () {
                      Get.to(() => const AjouterTrajet());
                    },
                  ),
              ],
            ),
            body: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('trajet').snapshots(),
              builder: (
                BuildContext context,
                AsyncSnapshot<QuerySnapshot> snapshot,
              ) {
                if (snapshot.hasError) {
                  return const Text('Erreur de chargement.');
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
                  children: snapshot.data!.docs.map((DocumentSnapshot document) {
                    Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6),
                      child: GestureDetector(
                        onTap: () {
                          if (userData['role'] == 'conducteur') {
                            Get.to(() => QRScannerPage(trajetId: data['trajet_id']));
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
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("Point de départ 📍: ${data['point_depart']}"),
                                      const SizedBox(height: 6),
                                      Text("Destination 📍: ${data['destination']}"),
                                      const SizedBox(height: 6),
                                      Text("Heure de départ ⌚: ${data['start_time']}"),
                                      const SizedBox(height: 6),
                                      Text("Heure d'arrivée ⌚: ${data['end_time']}"),
                                      const SizedBox(height: 6),
                                      Text("Prix 💵: ${data['prix']} DT"),
                                      const SizedBox(height: 8),
                                    ],
                                  ),
                                ),
                                if (userData['role'] == 'admin')
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.edit,
                                          color: Colors.green,
                                        ),
                                        onPressed: () {
                                          pointdepartController.clear();
                                          destinationController.clear();
                                          prixController.clear();

                                          showDialog(
                                            context: context,
                                            builder: (_) => AlertDialog(
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              backgroundColor: Colors.white,
                                              title: const Text(
                                                "Modifier le trajet",
                                                style: TextStyle(fontWeight: FontWeight.bold),
                                                textAlign: TextAlign.center,
                                              ),
                                              content: SingleChildScrollView(
                                                child: Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    const SizedBox(height: 10),
                                                    TextField(
                                                      controller: pointdepartController,
                                                      decoration: InputDecoration(
                                                        labelText: 'Point de départ',
                                                        hintText: data['point_depart'],
                                                        border: OutlineInputBorder(
                                                            borderRadius: BorderRadius.circular(12)),
                                                        filled: true,
                                                        fillColor: Colors.grey[100],
                                                      ),
                                                    ),
                                                    const SizedBox(height: 15),
                                                    TextField(
                                                      controller: destinationController,
                                                      decoration: InputDecoration(
                                                        labelText: 'Destination',
                                                        hintText: data['destination'],
                                                        border: OutlineInputBorder(
                                                            borderRadius: BorderRadius.circular(12)),
                                                        filled: true,
                                                        fillColor: Colors.grey[100],
                                                      ),
                                                    ),
                                                    const SizedBox(height: 15),
                                                    TextField(
                                                      controller: prixController,
                                                      keyboardType: TextInputType.number,
                                                      decoration: InputDecoration(
                                                        labelText: 'Prix',
                                                        hintText: data['prix'].toString(),
                                                        border: OutlineInputBorder(
                                                            borderRadius: BorderRadius.circular(12)),
                                                        filled: true,
                                                        fillColor: Colors.grey[100],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              actionsAlignment: MainAxisAlignment.spaceBetween,
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.pop(context),
                                                  child: const Text(
                                                    "Annuler",
                                                    style: TextStyle(color: Colors.red),
                                                  ),
                                                ),
                                                ElevatedButton(
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: mainColor,
                                                    shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(10)),
                                                  ),
                                                  onPressed: () async {
                                                    await FirebaseFirestore.instance
                                                        .collection('trajet')
                                                        .doc(data['trajet_id'])
                                                        .update({
                                                      'point_depart':
                                                          pointdepartController.text.isEmpty
                                                              ? data['point_depart']
                                                              : pointdepartController.text,
                                                      'destination':
                                                          destinationController.text.isEmpty
                                                              ? data['destination']
                                                              : destinationController.text,
                                                      'prix': prixController.text.isEmpty
                                                          ? data['prix']
                                                          : double.parse(prixController.text),
                                                    });
                                                    Navigator.pop(context);
                                                  },
                                                  child: const Text("Modifier" , style: TextStyle(color: Colors.white),),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          LineAwesomeIcons.trash_alt_solid,
                                          color: Colors.red,
                                        ),
                                        onPressed: () async {
                                          await FirebaseFirestore.instance
                                              .collection('trajet')
                                              .doc(data['trajet_id'])
                                              .delete();
                                        },
                                      ),
                                    ],
                                  )
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          );
  }
}
