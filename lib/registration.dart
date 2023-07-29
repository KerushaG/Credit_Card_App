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

  late Box box_users;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    createOpenBox();
  }

  void createOpenBox()async{

    box_users = await Hive.openBox('users');
    //await box_users.clear();
    getData();

  }

  void saveData()async {

    box_users = await Hive.openBox('users');
    //box_users.add([usernameController.text, emailController.text, passwordController.text]);
    //box_users.put(emailController.value.text,emailController.value.text);
    //box_users.put(c, passwordController.value.text);
    Map<String, dynamic> signupValues = {
    // Adding multiple values to a key using a List
    'username': usernameController.text.trim(),
    'email': emailController.text.trim(),
    'password': passwordController.text.trim()
    };

    box_users.add(signupValues);

    await box_users.close();
  }

  void getData()async {
    int totalValues = box_users.length;

    // Print the total number of values
    print('Total number of values in the box: $totalValues');
    for (var key in box_users.keys) {
      // Retrieve the value associated with the current key
      var value = box_users.get(key);

      // Print the key-value pair
      print('$key: $value');

      if(value['username'] == 'fdg' && value['password'] == 'bbb') {
        print('almost there!!');
        print(value['username']); // Output: 10
        print(value['email']); // Output: 20
        print(value['password']); // Output: 30
        break;
      }
      else{ print('sorry kiddo, but dont give up we almost there, trust me!!');}
    }
    //WHEN YOU DON'T KNOW THE KEY, SEARCH BY VALUE
    /* var keys = box_users.keys.toList();
    var foundKeys = <String>[];
    for (var key in keys) {
      var value = box_users.get(key);
      if (value == '123') {
        foundKeys.add(key);
      }
    }*/

    // Print the keys that match the search value
    //print('Keys with matching value: $foundKeys');
    /*if (box_users.containsKey('viri') && box_users.containsKey('vg')) {
      // The value exists in the box
      print('THERE IS A MATCH');
    } else {
      // The value does not exist in the box
      print('Value not found!');
    }
    if(box_users.get('usernameController')!=null) {
      emailController.text = box_users.get('usernameController');
      setState(() {
      });
    }
    if(box_users.get('emailController')!=null){
      passwordController.text = box_users.get('emailController');
      setState(() {
      });
    }
    if(box_users.get('passwordController')!=null){
      passwordController.text = box_users.get('passwordController');
      setState(() {
      });
    }*/
    await box_users.close();
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
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        saveData();
                        Navigator.pop(context);
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