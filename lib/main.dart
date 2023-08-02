import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'registration.dart';
import 'menu.dart';

//DECLARE GLOBAL VARIABLES
int sessionId = 0;
String userName = '';

//APP STARTS HERE
void main() async{
  await Hive.initFlutter();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  static const String _title = 'Submit Credit Cards';

  //TOP PAGE UI STYLING
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

  //DECLARE VARIABLES
  final _formKey = GlobalKey<FormState>();
  late String login_passed;
  late Box box_users;
  late Box box_session;

  //DECLARE USER INPUT OBJECTS
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  //INITIAL SETUP OF THE WIDGET
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  //FUNCTIONS FOR THE WIDGET
  Future<String?> validateUser() async {
    try
    {
      //OPEN BOX THAT STORES USER INFO
      box_users = await Hive.openBox('users');

      //VALIDATE USER EXISTS
      for (var key in box_users.keys) {
        //LOOP THROUGH BOX AND GET KEY VALUE PAIRS
        var value = box_users.get(key);

        if(value['username'] == usernameController.text.trim() && value['password'] == passwordController.text.trim()) {
          login_passed = "true";
          //SAVE USERNAME
          userName = value['username'];
          //RETURN ON USER KEY
          return key.toString();
        }
      }
      login_passed = "Invalid User Credentials.";
      return null;
    }
    catch (e)
    {
      login_passed = "There is an error in validating your user credentials: $e";
      return null;
    }
  }

  Future<int> createSession(String userKey) async {
    try {
      //OPEN BOX THAT STORES SESSIONS FOR USERS WHO LOG IN
      box_session = await Hive.openBox('sessions');

      //await box_session.clear();

      DateTime now = DateTime.now();

      //ADD USER ID AND DATETIME STAMP
      Map<String, dynamic> sessionValues = {
        'userKey': userKey,
        'dateTimeStarted': now.toString(),
      };

      //SAVE KEY
      int key = await box_session.add(sessionValues);

      await box_session.close();

      return key;

    } catch (e) {
      return -1; // Return a default value or throw an appropriate error
    }
  }

  //MAIN UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Credit Card Submissions'),
      ),
      body: SingleChildScrollView( // STOP OVERFLOW
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 20, 10, 0),
                  child: Align(
                    alignment: Alignment.center,
                    child: Text('User Login',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
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
                        String? userKey = await validateUser();
                        if (login_passed == "true" && userKey != null  && userKey != "-1") {
                          sessionId = await createSession(userKey); // SAVE SESSION ID
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => HomePage()),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(login_passed),
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
      ),
    );
  }

  //DISPOSE ALL OBJECTS
  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    box_users.close();
    box_session.close();
    super.dispose();
  }
}
