import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gp_v2/screens/profile.dart';
import 'package:gp_v2/services/firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';



class Home extends StatefulWidget {

  final User? user;
  const Home({super.key,this.user});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Map<String,dynamic>> _Carddocuments=[];
  List<Map<String,dynamic>> _Transdocuments=[];
  final FireStoreService fireStoreService = FireStoreService();

  Future<void> _fetchCards(String email) async {
    List<Map<String,dynamic>> documents = await fireStoreService.getCardList(email);
    setState(() {
      _Carddocuments=documents;
    });
  }

  Future<void> _fetchTransaction(String email) async {
    List<String> CardID=await fireStoreService.getCardID(email);

    List<Map<String, dynamic>> documents = []; // Initialize the list outside the loop

    for (int i = 0; i < CardID.length; i++) {
      List<Map<String, dynamic>> fetchedDocuments = await fireStoreService.getTransactionList(CardID[i]);
      documents.addAll(fetchedDocuments); // Use addAll to add all fetched documents
    }


    setState(() {
      _Transdocuments = documents; // Update the state with the accumulated documents
    });
  }

  @override
  void initState() {
    super.initState();
    if(widget.user != null) {
      String? userEmail = widget.user!.email;
      if(userEmail != null) {
        _fetchCards(userEmail);
        _fetchTransaction(userEmail);
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final FireStoreService fireStoreService= FireStoreService();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          toolbarHeight: 100,
          backgroundColor: Colors.black54,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(icon: Icon(Icons.person),onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>  profilePage(user: widget.user,))
                    );
                  },color: Colors.white,),
                  SizedBox(width: MediaQuery.of(context).size.width*.45),
                  IconButton(icon: Icon(Icons.notifications),onPressed: () {},color: Colors.white,),
                ],
              ),
              Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Mobile Bank',
                  style: TextStyle(fontSize: 50,color: Colors.white),
                ),
              ),
            ],
          ),
        ),
        body: SingleChildScrollView(
          child: SafeArea(
              child:Column(
                children: [
                  // SizedBox(height: 2,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      //TODO: Fix the width issue of the Row below the AppBar
                      SizedBox(width: 5,),
                      const Text("My Accounts",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      )),
                      SizedBox(width: MediaQuery.of(context).size.width*.55,),
                      IconButton(onPressed: () {}, icon: Icon(Icons.add_circle)),
                    ],
                  ),
                  // SizedBox(height: 2,),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Wrap(
                            spacing: 10, // Adjust the spacing between cards
                            runSpacing: 10, // Adjust the spacing between rows
                            children: [
                              CardWidget(icon: Icons.account_balance_rounded, title: '12650', content: "Primary Account"),
                              ..._Carddocuments.map((cardDocument) {
                                return Card(
                                  color: Colors.black45,
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 70, top: 10, bottom: 10, left: 10),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Icon(Icons.account_balance_rounded, color: Colors.white),
                                        SizedBox(height: 16),
                                        Text("\$ "+cardDocument['Balance'].toString(),
                                          style: TextStyle(
                                            fontSize: 30,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        Text("Current Balance",
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: Colors.white,
                                          ),
                                        ),
                                        SizedBox(height: 32),
                                        Text(cardDocument['Type'].toString(),
                                            style: TextStyle(
                                              color: Colors.white,
                                            )),
                                        Text("US DOLLAR",
                                          style: TextStyle(color: Colors.white),)
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ],
                          ),
                        )

                      ],
                    ),
                  ),
                  const SizedBox(height: 5,),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          child: Expanded(
                            child: ElevatedButton(
                              onPressed: () {  },
                              style: ButtonStyle(),
                              child: Padding(

                                padding: EdgeInsets.only(left: 20,right: 20,bottom: 5,top: 5),
                                child: Column(
                                  children: [
                                    Icon(Icons.credit_card),
                                    Text("Send Money")
                                  ],
                                ),),
                            ),
                          ),
                        ),
                        SizedBox(width: 20,),
                        Container(
                          child: Expanded(
                            child: ElevatedButton(
                              onPressed: () {  },
                              child: Padding(
                                padding: EdgeInsets.only(left: 20,right: 20,bottom: 5,top: 5),
                                child: Column(
                                  children: [
                                    Icon(Icons.qr_code_scanner),
                                    Text("Scan QR")
                                  ],
                                ),),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15,),
                  Container(
                    alignment: Alignment.centerLeft,
                    margin: EdgeInsetsDirectional.only(start: 5),
                    child: Text(
                        "Recent Transactions",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                    ),
                  ),
                  Column(
                    children: [
                  ..._Transdocuments.map((transDocuments) {
                    return Card(
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(transDocuments['Type'].toString(), style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),),
                                    Text(transDocuments['Account'].toString(),
                                      style: const TextStyle(
                                          color: Colors.grey, fontSize: 15),)
                                  ]),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(transDocuments['Date'].toString(), style: const TextStyle(
                                      color: Colors.grey),),
                                  Text("\$ "+transDocuments['Amount'].toString(),
                                    style: TextStyle(color: transDocuments['Type'].toString() == 'Debit' ? Colors.green : Colors.red),
                                  )
                                ],),
                            )
                          ]),
                    );
                  }).toList(),

                      /*
                      CardTrans(
                          text: "Transfer",
                          accNum: "8923",
                          date: "May 1 11:00AM",
                          loss: false,
                          number: "42.15"),
                      */
                    ],
                  ),




                ],
              ),
          ),
        ),
      )
    );
  }
}

class CardWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;

  const CardWidget({super.key, required this.title, required this.content, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.black45,
      // margin: EdgeInsets.all(20),
      child: Padding(
        padding: const EdgeInsets.only(right: 70,top: 10,bottom: 10,left: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon,color: Colors.white),
            SizedBox(height: 16,),
            Text(
              "\$ $title",

              style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                color: Colors.white,

              ),
            ),
            Text("Current Balance",
            style: TextStyle(
              fontSize: 15,
              color: Colors.white,
            ),
            ),
            SizedBox(height: 32),
            Text(content,
            style: TextStyle(
              color: Colors.white,
            )),
            Text("US DOLLAR UPA",
            style: TextStyle(color: Colors.white),)
          ],
        ),
      ),
    );
  }
}

class CardTrans extends StatelessWidget {
  final String text;
  final String accNum;
  final String date;
  final bool loss;
  String number;
  CardTrans({super.key,required this.text, required this.accNum, required this.date, required this.loss, required this.number});



  @override
  Widget build(BuildContext context) {
    if(loss==false) {
      number="+ $number";
    } else {
      number="- $number";
    }

    Color clr=(loss==false) ? Colors.green : Colors.red;

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
            Text(accNum,
              style: const TextStyle(color: Colors.grey,fontSize: 15),)
          ]),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
            Text(date, style: const TextStyle(color: Colors.grey),),
            Text(number,style: TextStyle(color: clr),
            )
          ],),
        )
      ]),
    );
  }
}


