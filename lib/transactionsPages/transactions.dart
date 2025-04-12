import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:stripeapp/shared/colors.dart';
import 'package:stripeapp/stripe_payment/payment_manager.dart';
import 'package:stripeapp/transactionsPages/transactionscard.dart';
import 'package:uuid/uuid.dart';

class Transactions extends StatefulWidget {
  const Transactions({super.key});

  @override
  State<Transactions> createState() => _TransactionsState();
}

class _TransactionsState extends State<Transactions> {
  TextEditingController amountController = TextEditingController();
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
            appBar: AppBar(
              backgroundColor: Colors.white,
              centerTitle: true,
              title: const Text(
                "Liste des Transactions",
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 19),
              ),
              leading: IconButton(
                onPressed: showPaymentDialog,
                icon: Icon(LineAwesomeIcons.paypal, color: mainColor),
              ),
              actions: [
                Text(
                  "${userData['solde']} \$",
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 20),
              ],
            ),
            backgroundColor: Colors.white,
            body: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .doc(userData['uid'])
                          .collection("transactions")
                          .orderBy('numero_transaction', descending: true)
                          .snapshots(),
                      builder: (
                        BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot,
                      ) {
                        if (snapshot.hasError) {
                          return const Text('Something went wrong');
                        }

                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
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
                          children: snapshot.data!.docs.map((
                            DocumentSnapshot document,
                          ) {
                            Map<String, dynamic> data =
                                document.data()! as Map<String, dynamic>;
                            return TransactionCard(
                              date: DateFormat('dd/MM/yyyy')
                                  .format(data['time'].toDate()),
                              heure: DateFormat('HH:mm')
                                  .format(data['time'].toDate()),
                              bondeType: data['titre'],
                              montant: data['montant'],
                              numeroTransactions:
                                  data['numero_transaction'].toString(),
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
  }

  void showPaymentDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Entrer le montant"),
          content: TextField(
            controller: amountController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: "Montant en USD",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Annuler"),
            ),
            ElevatedButton(
              onPressed: () async {
                final text = amountController.text.trim();
                if (text.isNotEmpty && int.tryParse(text) != null) {
                  final amount = int.parse(text);
                  Navigator.of(context).pop();
                  try {
                    await PaymentManager.makePayment(amount, "USD");
                    await updateSolde(amount);
                    await enregistrerTransaction(amount);
                    amountController.clear();
                    await getData(); // 🔄 Refresh UI
                  } catch (e) {
                    print("Erreur paiement ou enregistrement : $e");
                  }
                } else {
                  print("Erreur de saisie montant.");
                }
              },
              child: const Text("Payer"),
            ),
          ],
        );
      },
    );
  }

  Future<void> updateSolde(int montant) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final userRef = FirebaseFirestore.instance.collection('users').doc(uid);

    await userRef.update({'solde': FieldValue.increment(montant)});

    // 🔁 Mettre à jour dans réservations
    final snapshot = await userRef.get();
    final solde = snapshot.data()?['solde'] ?? 0;
    await mettreAJourSoldeDansReservations(uid, solde);
  }

  Future<void> enregistrerTransaction(int amount) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final userRef = FirebaseFirestore.instance.collection('users').doc(uid);
    try {
      final userSnapshot = await userRef.get();
      final userData = userSnapshot.data()!;
      int lastNumber = userData['last_transaction_number'] ?? 0;

      int newNumber = lastNumber + 1;
      String newTransactionsId = const Uuid().v1();

      await userRef.collection('transactions').doc(newTransactionsId).set({
        'transaction_id': newTransactionsId,
        'time': DateTime.now(),
        'titre': "Bonde entrante",
        'montant': "$amount \$",
        'numero_transaction': newNumber,
      });

      await userRef.update({'last_transaction_number': newNumber});
    } catch (e) {
      print("Erreur enregistrement transaction : $e");
    }
  }

  /// 🔄 Mise à jour des réservations après ajout solde
  Future<void> mettreAJourSoldeDansReservations(String userId, int nouveauSolde) async {
    final trajetsSnapshot = await FirebaseFirestore.instance.collection('trajet').get();

    for (var trajet in trajetsSnapshot.docs) {
      final reservationRef = FirebaseFirestore.instance
          .collection('trajet')
          .doc(trajet.id)
          .collection('reservations')
          .doc(userId);

      final reservationSnap = await reservationRef.get();

      if (reservationSnap.exists) {
        await reservationRef.update({'solde': nouveauSolde});
      }
    }
  }
}
