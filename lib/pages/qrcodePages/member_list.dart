import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:stripeapp/pages/qrcodePages/qr_scanner_page.dart';
import 'package:stripeapp/shared/colors.dart';

class MembersList extends StatefulWidget {
  final String trajetId;
  const MembersList({super.key, required this.trajetId});

  @override
  State<MembersList> createState() => _MembersListState();
}

class _MembersListState extends State<MembersList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "Personnes Reservés",
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 19),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.qr_code,
              color: mainColor,
            ),
            onPressed: () {
                Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => QRScannerPage(trajetId: widget.trajetId),
    ),
  );  
            },
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('trajet')
                .doc(widget.trajetId)
                .collection("reservations")
                .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
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
                    child: Card(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                        side: BorderSide(color: mainColor),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12.0,
                          vertical: 5.0,
                        ),
                        child: Column(
                          children: [
                            Gap(12),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Nom",
                                        style: TextStyle(color: mainColor),
                                      ),
                                      Gap(10),
                                      Text(
                                        "Prenom",
                                        style: TextStyle(color: mainColor),
                                      ),
                                      Gap(10),
                                      Text(
                                        "Payé",
                                        style: TextStyle(color: mainColor),
                                      ),
                                       Gap(10),
                                      Text(
                                        "Monatnt",
                                        style: TextStyle(color: mainColor),
                                      ),
                                       Gap(10),
                                      Text(
                                        "Solde Client",
                                        style: TextStyle(color: mainColor),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(data['nom']),
                                      Gap(10),
                                      Text(data['prenom']),
                                      Gap(10),
                                      data['paye'] == "oui"
                                          ? Text("✅")
                                          : Text("❌"),
                                      Gap(10),
                                      Text(data['montant']),
                                      Gap(10),
                                      Text(data['solde'].toString()),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Gap(10),
                          ],
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
