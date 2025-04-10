// ignore_for_file: deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:quickalert/quickalert.dart';
import 'package:stripeapp/shared/colors.dart';
import 'package:stripeapp/shared/customtextfield.dart';
import 'package:uuid/uuid.dart';
import '../shared/snackbar.dart';

class AjouterTrajet extends StatefulWidget {
  const AjouterTrajet({super.key});

  @override
  State<AjouterTrajet> createState() => _AjouterTrajetState();
}

class _AjouterTrajetState extends State<AjouterTrajet> {
  GlobalKey<FormState> formstate = GlobalKey<FormState>();
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  TextEditingController pointdepartController = TextEditingController();
  TextEditingController destinationController = TextEditingController();
  TextEditingController nombredePlaceController = TextEditingController();
  TextEditingController prixController = TextEditingController();
  bool isLoading = false;
  Map userData = {};

  ajouterTrajet() async {
    setState(() {
      isLoading = true;
    });
    try {
      CollectionReference trajet = FirebaseFirestore.instance.collection(
        'trajet',
      );
      String newTrajetId = const Uuid().v1();
      trajet.doc(newTrajetId).set({
        'trajet_id': newTrajetId,
        'start_time':
            "${startTime!.hour.toString().padLeft(2, '0')}:${startTime!.minute.toString().padLeft(2, '0')}",
        'end_time':
            "${endTime!.hour.toString().padLeft(2, '0')}:${endTime!.minute.toString().padLeft(2, '0')}",
        'point_depart': pointdepartController.text,
        'destination': destinationController.text,
        'nombre_places': int.parse(nombredePlaceController.text),
        'prix': double.parse(prixController.text),
        'disponible' : 'oui',
      });
    } catch (err) {
      if (!mounted) return;
      showSnackBar(context, "Erreur :  $err ");
    }
    setState(() {
      isLoading = false;
    });
  }

  afficherAlert() {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.success,
      text: 'Trajet ajouté avec succès !',
      onConfirmBtnTap: () {
        setState(() {
          pointdepartController.clear();
          destinationController.clear();
          nombredePlaceController.clear();
          prixController.clear();
          startTime = null;
          endTime = null;
        });
        Navigator.of(context).pop();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          "Ajouter un Trajet",
          style: TextStyle(
            fontSize: 17,
            color: blackColor,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Form(
          key: formstate,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Gap(30),
              const Text(
                "Heure de départ",
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () async {
                  TimeOfDay? picked = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (picked != null) {
                    setState(() {
                      startTime = picked;
                    });
                  }
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  height: 48,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 0.75),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 12.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        startTime != null
                            ? "${startTime!.hour.toString().padLeft(2, '0')}:${startTime!.minute.toString().padLeft(2, '0')}"
                            : "",
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ),
              ),

              const Gap(10),
              const Text(
                "Heure de fin",
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () async {
                  TimeOfDay? picked = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (picked != null) {
                    setState(() {
                      endTime = picked;
                    });
                  }
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  height: 48,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 0.75),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 12.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        endTime != null
                            ? "${endTime!.hour.toString().padLeft(2, '0')}:${endTime!.minute.toString().padLeft(2, '0')}"
                            : "",
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ),
              ),

              const Gap(10),
              AddAvisTField(
                title: 'Point de départ',
                text: '',
                controller: pointdepartController,
                validator: (value) {
                  return value!.isEmpty ? "Ne peut être vide" : null;
                },
              ),
              const Gap(10),
              AddAvisTField(
                title: 'Destination',
                text: '',
                controller: destinationController,
                validator: (value) {
                  return value!.isEmpty ? "Ne peut être vide" : null;
                },
              ),
              const Gap(10),
              AddAvisTField(
                textInputType: TextInputType.number,
                title: 'Nombre de places',
                text: '',
                controller: nombredePlaceController,
                validator: (value) {
                  return value!.isEmpty ? "Ne peut être vide" : null;
                },
              ),
              const Gap(10),
              AddAvisTField(
                textInputType: TextInputType.number,
                title: 'Prix',
                text: '',
                controller: prixController,
                validator: (value) {
                  return value!.isEmpty ? "Ne peut être vide" : null;
                },
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (formstate.currentState!.validate()) {
                          await ajouterTrajet();
                          afficherAlert();
                        } else {
                          QuickAlert.show(
                            context: context,
                            type: QuickAlertType.error,
                            title: 'Erreur',
                            text: 'Ajouter les informations nécessaires',
                          );
                        }
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(mainColor),
                        padding:
                            isLoading
                                ? MaterialStateProperty.all(
                                  const EdgeInsets.all(9),
                                )
                                : MaterialStateProperty.all(
                                  const EdgeInsets.all(12),
                                ),
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                      child:
                          isLoading
                              ? Center(
                                child: LoadingAnimationWidget.staggeredDotsWave(
                                  color: whiteColor,
                                  size: 32,
                                ),
                              )
                              : const Text(
                                "Ajouter un Trajet",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: whiteColor,
                                ),
                              ),
                    ),
                  ),
                ],
              ),
              const Gap(30),
            ],
          ),
        ),
      ),
    );
  }
}
