import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SignUp extends StatefulWidget {
  //const SignUp({super.key, required this.title});
  const SignUp({Key? key}) : super(key: key);
  //final String title;
  @override
  State<SignUp> createState() => SignUpPage();
}

class SignUpPage extends State<SignUp> {

  final _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  late bool uniqueUser;

  late Box box_users;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    createOpenBox();
  }

  void createOpenBox()async{
    box_users = await Hive.openBox('users');
  }

  Future<bool> saveData() async {

    box_users = await Hive.openBox('users');

    //VALIDATE FOR EXISTING USER
    for (var key in box_users.keys) {
      // Retrieve the value associated with the current key
      var value = box_users.get(key);

      // Print the key-value pair
      print('$key: $value');

      //CHECK FOR UNIQUE EMAIL AND PASSWORD
      if(value['email'] == emailController.text.trim()) {
        print('found a duplicate');
        return false;
      }
    }

    Map<String, dynamic> signupValues = {
    // Adding multiple values to a key using a List
    'username': usernameController.text.trim(),
    'email': emailController.text.trim(),
    'password': passwordController.text.trim()
    };

    box_users.add(signupValues);
    await box_users.close();
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Credit Card Submissions'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView( // Wrap with SingleChildScrollView
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
                    // Customize the content text style if needed
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
                      if (_formKey.currentState!.validate()) {
                        bool isSaved = await saveData();
                        if (isSaved) {
                          Navigator.pop(context);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('A user already exists for the e-mail address you entered.'),
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
                  width: 350, // Set your desired width here
                  height: 70,
                  padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                  child: ElevatedButton(
                    onPressed: () {
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

}