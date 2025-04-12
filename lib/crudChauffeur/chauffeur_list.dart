import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:stripeapp/crudChauffeur/addchauffeur.dart';

import '../shared/colors.dart';

class ChaffuerList extends StatefulWidget {
  const ChaffuerList({super.key});

  @override
  State<ChaffuerList> createState() => _ChaffuerListState();
}

class _ChaffuerListState extends State<ChaffuerList> {
    final Stream<QuerySnapshot> _usersStream = FirebaseFirestore.instance
      .collection('users')
      .where('role', isEqualTo: 'conducteur')
      .snapshots();



  @override
  Widget build(BuildContext context) {
    return Scaffold(
            appBar: AppBar(
              actions: [
                IconButton(
                  icon: const Icon(
                    CupertinoIcons.add_circled_solid,
                    color: mainColor,
                  ),
                  onPressed: () async {
                   Get.to(()=>const AddConducteur());
                  },
                )
              ],
              backgroundColor: Colors.white,
              elevation: 0,
              centerTitle: true,
              title: const Text(
                "Liste des Conducteurs",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
              ),
            ),
            backgroundColor: Colors.white,
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: StreamBuilder<QuerySnapshot>(
                stream: _usersStream,
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return const Center(child: Text('Erreur de chargement'));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final chauffeurs = snapshot.data!.docs;

                  return GridView.builder(
                    itemCount: chauffeurs.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // 🟩 2 colonnes
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.8,
                    ),
                    itemBuilder: (BuildContext context, int index) {
                      final data = chauffeurs[index].data()!
                          as Map<String, dynamic>;

                      return Card(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        elevation: 3,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                'assets/images/profilepic.svg',
                                height: 95.0,
                                width: 95.0,
                                allowDrawingOutsideViewBox: true,
                              ),
                              const Gap(10),
                              Text(
                                data['nom'] ?? '',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: blackColor,
                                ),
                              ),
                              const Gap(5),
                              Text(
                                data['prenom'] ?? '',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: secondaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          );
  }
}