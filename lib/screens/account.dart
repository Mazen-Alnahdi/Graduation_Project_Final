import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gp_v2/services/firestore.dart';

class Accounts extends StatefulWidget {
  final User? user;
  const Accounts({super.key, this.user});

  @override
  State<Accounts> createState() => _AccountsState();
}

class _AccountsState extends State<Accounts> {
  List<Map<String,dynamic>> _Carddocuments=[];
  final FireStoreService fireStoreService = FireStoreService();

  Future<void> _fetchCards(String email) async {
    List<Map<String,dynamic>> documents = await fireStoreService.getCardList(email);
    setState(() {
      _Carddocuments=documents;
    });
  }

  @override
  void initState() {
    super.initState();
    if(widget.user != null) {
      String? userEmail = widget.user!.email;
      if(userEmail != null) {
        _fetchCards(userEmail);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blue,
        toolbarHeight: 100,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // IconButton(
                //     icon: const Icon(Icons.person),
                //     onPressed: () {},
                //     color: Colors.white,),
                SizedBox(
                    width: MediaQuery.of(context).size.width*.5),
                IconButton(
                    icon: const Icon(Icons.notifications),
                    onPressed: () {},
                    color: Colors.white),
              ],
            ),
            Container(
              alignment: Alignment.centerLeft,
              child: const Text(
                'Account',
                style: TextStyle(fontSize: 50,color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10,),
              const Text("My Accounts",style: TextStyle(
                fontWeight: FontWeight.bold,
              ),),
              Column(

                children: [
                  accountCard(
                      text: "US Dollars UPA",
                      accNum: "Primary Account",
                      date: "Valid Till 10/22",
                      number: "\$ 12650"),
                  ..._Carddocuments.map((cardDocument) {
                    return accountCard(
                        text: cardDocument['Name'].toString(),
                        accNum: cardDocument['Number'].toString(),
                        date: "Valid Till "+
                        cardDocument['Expiration Month'].toString()+
                        "/"+
                        cardDocument['Expiration Year'].toString(),
                        number: "\$ "+cardDocument['Balance'].toString());
                  }).toList(),

                ],
              ),
              SizedBox(height: 10,),
              Text("Get a Card", style: TextStyle(
                fontWeight: FontWeight.bold,
              ),),
              Card(
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.zero)),
                    textStyle: MaterialStateProperty.all<TextStyle>(const TextStyle(color: Colors.black)),
                    foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
                    overlayColor: MaterialStateProperty.resolveWith<Color>(
                          (states) {
                        // Ensure button remains white when pressed
                        if (states.contains(MaterialState.pressed)) {
                          return Colors.white;
                        }
                        return Colors.white; // If not pressed, return null to use the default overlay color
                      },
                    ),                  ),
                  child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Physical",style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,

                                ),),
                                Text("For Stores, Cafes, and Internet",
                                  style: const TextStyle(color: Colors.grey,fontSize: 15),)
                              ]),
                        ),
                        
                      ]),
                onPressed: () {

                },
                ),
              ),
              Card(
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.zero)),
                    textStyle: MaterialStateProperty.all<TextStyle>(const TextStyle(color: Colors.black)),
                    foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
                    overlayColor: MaterialStateProperty.resolveWith<Color>(
                          (states) {
                        // Ensure button remains white when pressed
                        if (states.contains(MaterialState.pressed)) {
                          return Colors.white;
                        }
                        return Colors.white; // If not pressed, return null to use the default overlay color
                      },
                    ),
                  ),
                  child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Virtual",style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,

                                ),),
                                Text("For Google Pay, Apple Pay and Other Services",
                                  style: const TextStyle(color: Colors.grey,fontSize: 15),)
                              ]),
                        ),

                      ]),
                  onPressed: () {

                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class accountCard extends StatelessWidget {
  final String text;
  final String accNum;
  final String date;
  // final bool loss;
  String number;

  accountCard({
    super.key,
    required this.text,
    required this.accNum,
    required this.date,
    // required this.loss,
    required this.number});


  @override
  Widget build(BuildContext context) {
    String maskCreditCardNumber(String cardNumber) {
      // Extract last four digits
      String lastFourDigits = cardNumber.substring(cardNumber.length - 4);

      // Mask the rest of the digits
      String maskedNumber = cardNumber.replaceAll(RegExp(r'\d(?=\d{4})'), '*');

      // Concatenate the last four digits
      return maskedNumber.substring(0, maskedNumber.length - 4) + lastFourDigits;

    }


    return  Card(
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(text,style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),),
                    Text(maskCreditCardNumber(accNum),
                      style: const TextStyle(color: Colors.grey,fontSize: 15),)
                  ]),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(number,style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),),
                  Text(date, style: const TextStyle(color: Colors.grey,fontSize: 10),),
                ],),
            )
          ]),
    );
  }
}
