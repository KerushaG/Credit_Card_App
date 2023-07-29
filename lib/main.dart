import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'registration.dart';
import 'menu.dart';

int? sessionId;

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
  late bool login_passed;
  late Box box_users;
  late Box box_session;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  Future<int?> getData() async {

    box_users = await Hive.openBox('users');

    int totalValues = box_users.length;

    // Print the total number of values
    print('Total number of values in the box: $totalValues');
    for (var key in box_users.keys) {
      // Retrieve the value associated with the current key
      var value = box_users.get(key);

      // Print the key-value pair
      print('$key: $value');

      if(value['username'] == usernameController.text.trim() && value['password'] == passwordController.text.trim()) {
        login_passed = true;
        //CREATE SESSION
        print(key);
        return key;
      }
    }
    login_passed = false;
    return null;
  }

  Future<int> createSession(int userKey) async {
    box_session = await Hive.openBox('sessions');
    DateTime now = DateTime.now();

    Map<String, dynamic> sessionValues = {
      'userKey': userKey,
      'dateTimeStarted': now.toString(),
      'dateTimeEnded': '',
    };

    int key = await box_session.add(sessionValues);
    await box_session.close();
    return key;
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
                      int? userKey = await getData(); // Get the userKey from getData()
                      if (login_passed && userKey != null) {
                        sessionId = await createSession(userKey); // Assign sessionId here
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => HomePage()),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Invalid Credentials'),
                          ),
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
    box_session.close();
    super.dispose();
  }
}
