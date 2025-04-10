
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:stripeapp/pages/home.dart';
import 'package:stripeapp/transactionsPages/transactions.dart';
import 'package:stripeapp/shared/colors.dart';
import 'profilePages/profile.dart';
import 'trajetScreens/trajetlist.dart';

class Screens extends StatefulWidget {
  const Screens({super.key});

  @override
  State<Screens> createState() => _ScreensState();
}

class _ScreensState extends State<Screens> {
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
  final PageController _pageController = PageController();

  int currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return 
    isLoading
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
        : 
    Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 25, right: 25, top: 4, bottom: 4),
        child: GNav(
          backgroundColor: Colors.white,
          gap: 10,
          color: Colors.grey,
          activeColor: mainColor,
          curve: Curves.decelerate,
          padding: const EdgeInsets.only(bottom: 10, left: 6, right: 6, top: 2),
          onTabChange: (index) {
            _pageController.jumpToPage(index);
            setState(() {
              currentPage = index;
            });
          },
          tabs:  [
            const GButton(
              icon: LineAwesomeIcons.home_solid,
              text: 'Home',
            ),
            const GButton(
              icon: Icons.attach_money_outlined,
              text: 'Transactions',
            ),
          const GButton(
              icon: Icons.wallet_outlined,
              text: 'Payments',
            ),
            const GButton(
              icon: CupertinoIcons.person_alt_circle,
              text: 'Profile',
            ),
          ],
        ),
      ),
      body: PageView(
        onPageChanged: (index) {},
        physics: const NeverScrollableScrollPhysics(),
        controller: _pageController,
        children:  [
          const TrajetList(),
          const Transactions(),
          const  HomeScreen(),
          const Profile(),
        ],
      ),
    );
  }
}
