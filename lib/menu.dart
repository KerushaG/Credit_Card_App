import 'package:flutter/material.dart';
import 'banned_countries.dart';
import 'add_creditcard.dart';
import 'main.dart';
import 'view_creditcards.dart';
import 'scan_creditcard.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  //MAIN UI - ALL APP OPTIONS
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Credit Card Submissions'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView( //STOP OVERFLOW
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 50, 10, 30),
              child: Column(
                children: [
                  Text(
                    'Menu Options',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10), // Add some space between the lines
                  Text(
                    'Session: $sessionId for $userName',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            Center(
              child: Container(
                width: 350,
                height: 70,
                padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddNewCard(),
                      ),
                    );
                  },
                  child: const Text("Add Card"),
                ),
              ),
            ),
            Center(
              child: Container(
                width: 350,
                height: 80,
                padding: const EdgeInsets.fromLTRB(0, 30, 0, 0),
                child: ElevatedButton(
                  onPressed: () { Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Scanning(),
                    ),
                  );},
                  child: const Text("Scan Card"),
                ),
              ),
            ),
            Center(
              child: Container(
                width: 350,
                height: 80,
                padding: const EdgeInsets.fromLTRB(0, 30, 0, 0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BannedCountries(),
                      ),
                    );
                  },
                  child: const Text("Maintain Banned Countries"),
                ),
              ),
            ),
            Center(
              child: Container(
                width: 350,
                height: 80,
                padding: const EdgeInsets.fromLTRB(0, 30, 0, 0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ViewCreditCards(),
                    ),
                  );},
                  child: const Text("View Credit Card Submissions"),
                ),
              ),
            ),
            Center(
              child: Container(
                width: 350,
                height: 80,
                padding: const EdgeInsets.fromLTRB(0, 30, 0, 0),
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MyApp()),
                    );
                  },
                  child: const Text("Logout"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
