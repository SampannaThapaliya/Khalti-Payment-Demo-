import 'dart:async';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:knocadoor/helpers/common.dart';
import 'package:knocadoor/helpers/roundedborder.dart';
import 'package:knocadoor/screens/home.dart';
import '../screens/delivery_address.dart';

import 'package:flutter/material.dart';
import 'package:flutter_khalti/flutter_khalti.dart';
import 'package:knocadoor/models/order.dart';
import 'package:knocadoor/services/payment.dart';
import 'package:http/http.dart' as http;

PaymentServices _paymentServices = PaymentServices();
OrderModel orderModel;

// ignore: must_be_immutable
class Pay extends StatefulWidget {
  //Pay({Key key}) : super(key: key);
  var id;
  var name;
  dynamic totalPrice;

  Pay({Key key, this.id, this.name, this.totalPrice}) : super(key: key);

  @override
  _PayState createState() => _PayState();
}

class _PayState extends State<Pay> {
  final _key = GlobalKey<ScaffoldState>();
  @override
  void initstate() {
    super.initState();
  }


// Server Side Verification
  void verify(Map<dynamic, dynamic> z) async {
    //Map<String, dynamic> user = convert.jsonDecode(z);
    String tkn = z['token'];
    var amnt = z['amount'].toString();

    try {
      var last = Uri.parse('https://khalti.com/api/v2/payment/verify/');
      var ssv = await http.post(last, body: {
        'token': tkn,
        'amount': amnt
      }, headers: {
        'Authorization': 'Key test_secret_key_e34309fdd6434402958c7919d99c2d74'  // Your Secret Key 
      });

      print("Response status : ${ssv.statusCode}");
      print("Content : ${ssv.body}");
    } catch (e) {
      print("Something went wrong");
    }
  }

  _khaltipay() async {
    FlutterKhalti _flutterKhalti = FlutterKhalti.configure(
      publicKey: "test_public_key_71df426f55c64e1fa025efc8af0cdd10",
      urlSchemeIOS: "KhaltiPayFlutterExampleScheme",
      paymentPreferences: [
        KhaltiPaymentPreference.KHALTI,
      ],
    );
    void showToast() {
      Fluttertoast.showToast(
          msg: 'your payment is succesful',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.yellow);
    }

    // double.parse(widget.total);
    KhaltiProduct product = KhaltiProduct(
        id: widget.id.toString(),
        name: widget.name.toString(),
        amount: double.parse(widget.totalPrice.toString()));

    _flutterKhalti.startPayment(
      product: product,
      onSuccess: (data) {
        Map<dynamic, dynamic> s = data;
        //dynamic z = jsonEncode(data); //convert map to json value
        //dynamic a = JsonEncoder(z); //convert json to string

        verify(s);

        Timer(Duration(seconds: 3), () {
          showToast();
        });
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => DeliveryAddress()));
      },
      onFaliure: (error) {
        print("sorru");
      },
    );
  }

  Future _hello() async {
    _paymentServices.createPayment(
        userid: widget.id.toString(),
        name: "Your Total bill is",
        amount: double.parse(widget.totalPrice.toString()),
        status: true);

    widget.id = "";
    widget.name = "";
    widget.totalPrice = 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Text(
              "Choose your payment gateway",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24.0,
              ),
            ),
            const SizedBox(height: 50.0),
            Row(
              children: <Widget>[
                Expanded(
                  child: RoundedContainer(
                    margin: const EdgeInsets.symmetric(
                      vertical: 15.0,
                      horizontal: 15.0,
                    ),
                    child: Column(
                      children: <Widget>[
                        Text(
                          "Knoca Door Grocery",
                          style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 30),
                        ),
                        const SizedBox(height: 5.0),
                        Text(
                          "Thankyou for Choosing us",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12.0,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 60.0),
            RoundedContainer(
              margin: const EdgeInsets.all(8.0),
              padding: const EdgeInsets.all(8.0),
              child: ListTile(
                  leading: Icon(
                    Icons.money_rounded,
                    color: Colors.indigo,
                  ),
                  title: Text("Cash on Delivery"),
                  trailing: Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        backgroundColor: Colors.blueAccent,
                        behavior: SnackBarBehavior.floating,
                        content: Text(
                          "Your order has been placed and cash will be taken on delivery.",
                          style: TextStyle(
                            fontSize: 17,
                          ),
                        )));

                    _hello();
                  }),
            ),
            RoundedContainer(
              margin: const EdgeInsets.all(8.0),
              padding: const EdgeInsets.all(8.0),
              child: ListTile(
                leading: Icon(
                  Icons.credit_card_rounded,
                  color: Colors.indigo,
                ),
                onTap: () {
                  _khaltipay();
                  _hello();
                },
                title: Text("Khalti"),
                trailing: Icon(Icons.arrow_forward_ios),
              ),
            ),
            const SizedBox(height: 100.0),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                vertical: 16.0,
                horizontal: 32.0,
              ),
              child: RaisedButton(
                elevation: 0,
                padding: const EdgeInsets.all(24.0),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)),
                child: Text("Continue"),
                color: Colors.indigo,
                textColor: Colors.white,
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => HomePage()));
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
