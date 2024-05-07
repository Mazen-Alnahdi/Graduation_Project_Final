

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

String notFound = "No Account found";

class FireStoreService {

  //Retrieves List of Card Data from Account having that Email
  Future<List<Map<String,dynamic>>> getCardList(String email) async {

    List<Map<String, dynamic>> cardsData=[];
    List<dynamic> cardIDList=[];

    //Get Collection
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .where('email',isEqualTo: email)
        .limit(1).get();
    
    if (userDoc.docs.isNotEmpty) {
      //getting card's ID list for collection cards
      final userData = userDoc.docs.first.data();
      cardIDList = List<dynamic>.from(userData['cards'] ?? []);

      for (String id in cardIDList){
        final cardSnapshot=await FirebaseFirestore.instance
            .collection('cards')
            .doc(id)
            .get();

        if (cardSnapshot.exists) {
          // Ensure the data is added only if the document exists
          cardsData.add(cardSnapshot.data() as Map<String, dynamic>);
        }
      }
    }

    return cardsData;

  }

  Future<List<Map<String, dynamic>>> getUserData(String email) async {
    List<Map<String, dynamic>> userData = [];

    final userDocs = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    // Check if any document exists with the given email
    if (userDocs.docs.isNotEmpty) {
      // Get the first document
      final userDoc = userDocs.docs.first;
      // Convert the document data to a Map and add it to the userData list
      userData.add(userDoc.data() as Map<String, dynamic>);
    }

    return userData;
  }

  //Retrieves List of Transaction from Card ID
  Future<List<Map<String, dynamic>>> getTransactionList(String cardID) async {
    try {
      final cardQuery = await FirebaseFirestore.instance
          .collection('cards')
          .doc(cardID)
          .get();

      // Check if the card document exists and has a 'transactions' field
      if (cardQuery.exists) {
        final List<dynamic> transIDs = cardQuery.data()?['transactions'] ?? [];

        List<Map<String, dynamic>> transData = [];

        // Iterate through each transaction ID
        for (String transID in transIDs) {
          final transSnapshot = await FirebaseFirestore.instance
              .collection('transaction')
              .doc(transID)
              .get();
          // Check if the transaction document exists
          if (transSnapshot.exists) {
            transData.add(transSnapshot.data() as Map<String, dynamic>);
          }
        }

        return transData;
      } else {
        // If the card document doesn't exist or doesn't have a 'transactions' field
        return [];
      }
    } catch (e) {
      print("Error in getTransactionList: $e");
      rethrow;
    }
  }


  Future<String> changePassword({
    String? email,
    required String currentPassword,
    required String newPassword,
  }) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    try {
      if (email == null) {
        // Handle the case where email is null
        return "Email is null";
      }

      // Sign in the user with their email and current password
      AuthCredential credential = EmailAuthProvider.credential(email: email, password: currentPassword);
      await auth.currentUser!.reauthenticateWithCredential(credential);

      // Change the user's password
      await auth.currentUser!.updatePassword(newPassword);
    } catch (e) {
      return "Error changing password: $e";
    }
    return "Success";
  }


  //Register by checking Account Number if exist and if email already made in the account
  //else then add the new email and password to authenticator and to the document
  Future<String?> registerAndAddToFirestore({
    required String email,
    required String password,
    required String accNum,
  }) async {
    try {
      String userID = "";
      //Retrieve User ID
      String accNumID = await getAccNumID(accNum);
      if (accNumID == notFound) {
        return notFound;
      } else {
        userID = await getUserID(accNumID);
      }

      FirebaseAuth auth = FirebaseAuth.instance;
      User? user;
      UserCredential userCredential =
      await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      user = userCredential.user;

      // Add user to Firestore
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      DocumentReference userDocRef = firestore.collection('users').doc(userID);
      await userDocRef.set({
        'email': email,
        // 'uid': user?.uid,
        // Add any other user information you want to store
      }, SetOptions(merge: true));

    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {

        return "The password provided is too weak.";
      } else if (e.code == 'email-already-in-use') {

        return "The account already exists for that email.";
      } else if (e.code == 'invalid-email') {

        return "The email address is badly formatted.";
      }
    } catch (e) {

      return e.toString();
    }
    return "Successfully Created";
  }


  //Func that returns Doc ID using Account Number
  Future<String> getAccNumID(String AccNumb) async {
    int Acc=int.parse(AccNumb);
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('cards')
          .where('Account Number', isEqualTo: Acc)
          .limit(1).get();
      if (querySnapshot.docs.isNotEmpty) {
        // Assuming you want the path of the first document that matches the query

        return querySnapshot.docs.first.id;
      } else {
        return notFound;
        throw Exception('No document found with the given account number');
      }
    } catch (error) {
      print("Error in Func getAccNumID: $error");
      rethrow;
    }
  }

  //Func that returns Doc ID using cardID in the array
  Future<String> getUserID(String cardID) async {
    try{
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('cards',arrayContains: cardID)
          .get();
      for(var doc in querySnapshot.docs) {
        return doc.id;
      }
    } catch (e){
      print("Error in Func getAccNumData: $e");
      rethrow;
    }
    return "";
  }
  //Taken into consideration that each account has to have at least one card...

  Future<List<String>> getCardID(String email) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where("email", isEqualTo: email)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        // Extracting the "cards" field from the document
        final List<dynamic> cards = querySnapshot.docs.first.data()['cards'];

        // Converting the list of dynamic to a list of strings
        final List<String> cardIDs = cards.map((card) => card.toString()).toList();

        return cardIDs;
      }
    } catch (e) {
      print("Error in Func getCardID List: $e");
      rethrow;
    }

    return [];
  }



}
