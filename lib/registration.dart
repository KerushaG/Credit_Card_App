import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SignUp extends StatefulWidget {

  const SignUp({Key? key}) : super(key: key);

  @override
  State<SignUp> createState() => SignUpPage();
}

class SignUpPage extends State<SignUp> {

  //DECLARE VARIABLES
  final _formKey = GlobalKey<FormState>();
  late bool uniqueUser;
  late Box box_users;

  //DECLARE USER INPUT OBJECTS
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController usernameController = TextEditingController();

  //INITIAL SETUP OF THE WIDGET
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  //FUNCTIONS FOR THE WIDGET
  Future<String> saveNewUser() async {
    try {
      //OPEN BOX THAT STORES USER INFO
      box_users = await Hive.openBox('users');

      //VALIDATE FOR EXISTING USER
      for (var key in box_users.keys) {
        //LOOP THROUGH BOX AND GET KEY VALUE PAIRS
        var value = box_users.get(key);

        //CHECK FOR UNIQUE EMAIL
        if (value['email'] == emailController.text.trim()) {
          //EXIT AND DO NOT SAVE
          await box_users.close();
          return "A user already exists for the e-mail address you entered.";
        }
      }

      //SAVE USER DATA FOR ONE KEY
      Map<String, dynamic> signupValues = {
        'username': usernameController.text.trim(),
        'email': emailController.text.trim(),
        'password': passwordController.text.trim(),
      };

      await box_users.add(signupValues);
      await box_users.close();

      //SAVE SUCCESSFUL
      return "true";
    }
    catch (e)
    {
      return "Error saving new user: $e";
    }
  }

  //MAIN UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Credit Card Submissions'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView( // STOP OVERFLOW
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 25, 10, 0),
                child: Text(
                  'Sign Up',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 35, 10, 0),
                child: TextFormField(
                  controller: usernameController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Username",
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your Username';
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                child: TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "E-mail Address",
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your E-mail Address';
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                child: TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Password",
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your Password';
                    }
                    return null;
                  },
                ),
              ),
              Center(
                child: Container(
                  width: 350,
                  height: 70,
                  padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                  child: ElevatedButton(
                    onPressed: () async {
                      //VALIDATIONS
                      if (_formKey.currentState!.validate()) {
                        String isSaved = await saveNewUser();
                        if (isSaved == "true") {
                          //IF PASSED GO TO LOGIN
                          Navigator.pop(context);
                        } else {
                          //ELSE INFORM USER ON FAILED VALIDATION
                          ScaffoldMessenger.of(context).showSnackBar(
                             SnackBar(
                              content: Text(isSaved),
                            ),
                          );
                        }
                      }
                    },
                    child: const Text('Submit'),
                  ),
                ),
              ),
              Center(
                child: Container(
                  width: 350,
                  height: 70,
                  padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                  child: ElevatedButton(
                    onPressed: () {
                      //RETURN TO LOGIN
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //DISPOSE ALL OBJECTS
  @override
  void dispose() {
    emailController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}