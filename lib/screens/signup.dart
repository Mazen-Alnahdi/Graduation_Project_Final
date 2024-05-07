import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gp_v2/services/firestore.dart';

import 'login.dart';

class SignUp extends StatefulWidget {
  SignUp({super.key});



  @override
  State<StatefulWidget> createState() {
    return SignupState();
  }
}

class textField extends StatelessWidget {

  const textField({super.key});

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: true,
      decoration: InputDecoration(
        hintText: "Enter your New Password",
        border: UnderlineInputBorder(),
        labelText: 'Create Password',

        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
    );
  }
}

class SignupState extends State<SignUp>{
  final _accNumtext = TextEditingController();
  final _nametext=TextEditingController();
  final _usernametext = TextEditingController();
  final _passwordtext = TextEditingController();
  final _confpasswordtext = TextEditingController();
  bool _validateacc = false;
  bool _validatename=false;
  bool _validatuser = false;
  bool _validatpass = false;
  bool _validatconfpass = false;
  String errorMessage="";


  @override
  void dispose() {
     _accNumtext.dispose();
     _nametext.dispose();
     _usernametext.dispose();
     _passwordtext.dispose();
     _confpasswordtext.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context)  {
    final FireStoreService fireStoreService= FireStoreService();
    return Scaffold(
      backgroundColor: Colors.lightBlue,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(

            mainAxisAlignment: MainAxisAlignment.start,
            children: [

              SizedBox(height: 200),
              SizedBox(
                width: 300,
                child: TextField(
                  controller: _accNumtext,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Enter Account Number',
                    hintText: "Enter your Existing Account Number",
                    errorText: _validateacc? 'Account Number cannot be empty' : null,
                    border: UnderlineInputBorder(),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                  ),
                ),
              ),
              SizedBox(
                width: 300,
                child: TextField(
                  controller: _usernametext,
                  decoration: InputDecoration(
                    labelText: 'Create Email',
                    hintText: "Enter your New Email",
                    errorText: _validatuser? 'Email cannot be empty' : null,
                    border: UnderlineInputBorder(),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                  ),
                ),
              ),
              SizedBox(
                width: 300,
                child: TextField(
                  controller: _nametext,
                  decoration: InputDecoration(
                    labelText: 'Enter Name',
                    hintText: "Enter your Existing Username",
                    errorText: _validatename? 'Name cannot be empty' : null,
                    border: UnderlineInputBorder(),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                  ),
                ),
              ),
              // SizedBox(height: 100),
              SizedBox(
                width: 300,
                child: TextField(
                  controller: _passwordtext,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Create Password',
                    hintText: "Enter your New Password",
                    errorText: _validatpass? 'Username cannot be empty' : null,
                    border: UnderlineInputBorder(),

                    floatingLabelBehavior: FloatingLabelBehavior.always,
                  ),
                ),
              ),
              SizedBox(
                width: 300,
                child: TextField(
                  controller: _confpasswordtext,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    hintText: "Reenter your New Password",
                    errorText: _validatconfpass? 'Username cannot be empty' : null,
                    border: UnderlineInputBorder(),

                    floatingLabelBehavior: FloatingLabelBehavior.always,
                  ),
                ),
              ),

              SizedBox(height: 80),
              Text(errorMessage),
              SizedBox(height: 20,),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [

                  ElevatedButton(
                  child: Text("Signup"),
                  onPressed: () async{

                    setState(() {
                      _accNumtext.text.isEmpty ? _validateacc = true : _validateacc = false;
                      _nametext.text.isEmpty ? _validatename = true : _validatename = false;
                      _usernametext.text.isEmpty ? _validatuser = true : _validatuser = false;
                      _passwordtext.text.isEmpty ? _validatpass = true : _validatpass = false;
                      _confpasswordtext.text.isEmpty ? _validatconfpass = true : _validatconfpass = false;
                    });
                    if(_validateacc==false ||
                        _validatename==false ||
                        _validatuser==false ||
                        _validatpass==false ||
                        _validatconfpass==false){

                      if (_passwordtext.text==_confpasswordtext.text) {
                        final register= await fireStoreService
                            .registerAndAddToFirestore(
                            email: _usernametext.text,
                            password: _passwordtext.text,
                            accNum: _accNumtext.text
                        );


                        // fireStoreService.addUser(_accNumtext.text,_usernametext.text, _passwordtext.text);
                        if (register=="Successfully Created") {
                          Navigator.pop(
                              context,
                              MaterialPageRoute(builder: (context) => SignUp())
                          );
                        } else {
                          setState(() {
                            errorMessage=register!;
                          });
                        }
                      }
                      else {
                        errorMessage="The password doesn't match";
                      }
                    }

                  },
                ),
              ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}


