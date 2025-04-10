import 'package:dio/dio.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:stripeapp/stripe_payment/stripe_keys.dart';

abstract class PaymentManager{

static Future<void> makePayment(int amount, String currency) async {
  try {
    String clientSecret = await _getClientSecret((amount * 100).toString(), currency);
    await _initializePaymentSheet(clientSecret);
    await Stripe.instance.presentPaymentSheet();
  } on StripeException catch (e) {
    if (e.error.code == FailureCode.Canceled) {
      print("Paiement annulé par l'utilisateur");
    } else {
      throw Exception("Erreur Stripe : ${e.error.localizedMessage}");
    }
  } catch (error) {
    throw Exception("Autre erreur : ${error.toString()}");
  }
}


  static Future<void>_initializePaymentSheet(String clientSecret)async{
    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: clientSecret,
        merchantDisplayName: "Basel",
      ),
    );
  }

  static Future<String> _getClientSecret(String amount,String currency)async{
    Dio dio=Dio();
    var response= await dio.post(
      'https://api.stripe.com/v1/payment_intents',
      options: Options(
        headers: {
          'Authorization': 'Bearer ${ApiKeys.secretKey}',
          'Content-Type': 'application/x-www-form-urlencoded'
        },
      ),
      data: {
        'amount': amount,
        'currency': currency,
      },
    );
    return response.data["client_secret"];
  }

}