import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gp_v2/services/PicovoiceSetup.dart';
import 'package:gp_v2/services/firestore.dart';
import 'package:provider/provider.dart';
import 'package:rhino_flutter/rhino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class History extends StatefulWidget {
  final User? user;
  const History({super.key, this.user});

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  List<Map<String, dynamic>> _transactions = [];
  final FireStoreService fireStoreService = FireStoreService();
  bool _showDebitTransactions = false;
  double _loss=0;
  double _income = 0;
  late PicovoiceSetup picovoiceSetup;



  Future<void> _fetchTransactions(String email) async {
    List<String> cardIDs = await fireStoreService.getCardID(email);
    List<Map<String, dynamic>> transactions = [];
    _loss=0;
    _income=0;


    for (int i = 0; i < cardIDs.length; i++) {
      List<Map<String, dynamic>> fetchedTransactions =
      await fireStoreService.getTransactionList(cardIDs[i]);

      for (var transaction in fetchedTransactions) {
        if (transaction['Type'] == 'Debit') {
          _income += transaction['Amount'];
        } else {
          _loss += transaction['Amount'];
        }


        if (!_showDebitTransactions) {
          // Filter out only the documents where type is 'Debit'
          if (transaction['Type'] == 'Debit') {
            transactions.add(transaction);

          }
        } else {
          // Filter out only the documents where type is 'Credit'
          if (transaction['Type'] == 'Credit') {
            transactions.add(transaction);
          }
        }
      }
    }
    setState(() {
      _transactions = transactions;

    });
  }

  void changeTransactions(){
    setState(() {

      _showDebitTransactions = !_showDebitTransactions;
      // Refetch transactions based on the updated state
      if (widget.user != null) {
        String? userEmail = widget.user!.email;
        if (userEmail != null) {
          _fetchTransactions(userEmail);
        }
      }
    });

  }



  @override
  void initState() {
    super.initState();


    if(widget.user != null) {
      String? userEmail = widget.user!.email;
      if(userEmail != null) {
        _fetchTransactions(userEmail);
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
                SizedBox(width: MediaQuery.of(context).size.width*.5),
                IconButton(icon: const Icon(Icons.notifications),onPressed: () {
                },color: Colors.white),
              ],
            ),
            Container(
              alignment: Alignment.centerLeft,
              child: const Text(
                'History',
                style: TextStyle(fontSize: 50,color: Colors.white,fontWeight: FontWeight.bold),
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
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    alignment: Alignment.centerLeft,
                    margin: const EdgeInsetsDirectional.only(start: 5),
                    child: const Text("Current Month",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        )),
                  ),
                  SizedBox(width: MediaQuery.of(context).size.width*.65,),
                ],
              ),
              // SizedBox(height: 2,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Card(
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Income",
                                      style: TextStyle(color: Colors.grey,fontSize: 15),),
                                    Text("\$ "+_income.toString(),style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),),
                                  ]),
                            ),
                            Icon(Icons.arrow_outward,color: Colors.white,)

                          ]),
                    ),
                  ),
                  Expanded(
                    child: Card(
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Spent",
                                      style: TextStyle(color: Colors.grey,fontSize: 15),),
                                    Text("\$ "+_loss.toString(),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,

                                    ),),
                                  ]),
                            ),

                          ]),
                    ),
                  ),
                ],


              ),
              const SizedBox(height: 5,),

              const SizedBox(height: 15,),
              Container(
                alignment: Alignment.centerLeft,
                margin: const EdgeInsetsDirectional.only(start: 5),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        "Recent Transactions",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                        icon: Icon(Icons.tune),
                        onPressed: changeTransactions ,)
                  ],
                ),

              ),
              Column(
                children: [
                  ..._transactions.map((transDocuments) {
                    return Card(
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(transDocuments['Type'].toString(),
                                      style: const TextStyle(
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
                ],
              ),
              


            ],
          ),
        ),
      ),
    );
  }
}
