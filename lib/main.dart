import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'registration.dart';
import 'menu.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async{
  await Hive.initFlutter();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  static const String _title = 'Submit Credit Cards';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Submit Credit Cards',
      debugShowCheckedModeBanner: false,
      theme: new ThemeData(scaffoldBackgroundColor: Colors.grey.shade50),
      home: const Login(title: 'Submit Credit Cards'),
      );
  }
}

class Login extends StatefulWidget {
  const Login({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  State<Login> createState() => LoginPage();
}

class LoginPage extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  late bool login_passed = false;
  late Box box_users;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  getData() async {

    box_users = await Hive.openBox('users');

    // Print the keys that match the search value REMOVE TRAILING SPACES
    if (box_users.containsKey(usernameController.value.text) && box_users.containsKey(passwordController.value.text)) {
      print('Value found!');
      login_passed = true;
    }
    else {
      // The value does not exist in the box
      print('Value not found!');
      login_passed = false;
    }
    return;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Credit Card Submissions'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding (
               padding: const EdgeInsets.fromLTRB(10, 25, 10, 0),
                child: Text('User Login', style: TextStyle(
                  color: Colors.black,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  // Customize the content text style if needed
                ),),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 50, 10, 0),
                child: TextFormField(
                  controller: usernameController,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(), labelText: "Username"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your Username';
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                child: TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(), labelText: "Password"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your Password';
                    }
                    return null;
                  },
                ),
              ),
              Center (
                child: Container (
                  width: 350,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      await getData();
                      if (login_passed) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => HomePage()),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Invalid Credentials')),
                        );
                      }
                    },
                    child: const Text('Login'),
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SignUp(),
                        ),
                      );
                    },
                    child: const Text('Sign Up'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    box_users.close();
    super.dispose();
  }

}

