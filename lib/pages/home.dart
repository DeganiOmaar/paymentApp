import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:gap/gap.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:stripeapp/stripe_payment/payment_manager.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String?qrData;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(onPressed: (){}, icon: Icon(Icons.notifications))
        ],
      ),
      // body: MobileScanner(
      //   controller: MobileScannerController(
      //     detectionSpeed:  DetectionSpeed.noDuplicates
      //   ),
      //   onDetect: (capture) {},
      // )

      body: Padding(padding: 
      EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
            onSubmitted: (value) {
              setState(() {
                qrData = value;
              });
            },
          ), 
          Gap(20), 
          if(qrData != null) PrettyQrView.data(data: qrData!)
        ],
      ),
      ),
    );
  }
}