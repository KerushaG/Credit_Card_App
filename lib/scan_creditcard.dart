import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ml_card_scanner/ml_card_scanner.dart';
import 'add_creditcard.dart';

//DECLARE GLOBAL VARIABLE
String? scannedCardNumber = "";

class Scanning extends StatefulWidget {
  const Scanning({Key? key}) : super(key: key);

  @override
  State<Scanning> createState() => _ScanningState();
}

class _ScanningState extends State<Scanning> {

  //DECLARE VARIABLES
  CardInfo? _cardInfo;
  String cardNumber = "";
  bool showCamera = true;

  //DECLARE USER INPUT OBJECTS
  final ScannerWidgetController _controller = ScannerWidgetController();

  //INITIAL SETUP OF THE WIDGET
  @override
  void initState() {
    //CHECK FOR SCANNED CARD NUMBER, SAVE AND DISENABLE CAMERA
    _controller
      ..setCardListener((value) {
        setState(() {
          _cardInfo = value;
          if (_cardInfo != null) {

            //SPLIT THE CARD INFO IN LINES
            List<String> lines = _cardInfo!.toString().split('\n');

            //GET THE CARD NUMBER LINE
            cardNumber = 'Card ' + lines[1];

            //SAVE SCANNED CARD NUMBER ONLY
            if (lines[1].isNotEmpty) {
              RegExp regex = RegExp(r'\d+');
              Iterable<Match> matches = regex.allMatches(lines[1]);
              scannedCardNumber = matches.map((match) => match.group(0)).join();
              setState(() {
                //DISENABLE CAMERA
                showCamera = false;

              });
            } else {
              scannedCardNumber = "";
            }
          }
        });
      })
      ..setErrorListener((exception) {
        if (kDebugMode) {
          print('Error: ${exception.message}');
        }
      });
    super.initState();
  }

  //FUNCTIONS FOR THE WIDGET

  //CLEAR SCANNED CARD NUMBER AND ENABLE CAMERA
  void _resetScan() {
    _cardInfo = null;
    scannedCardNumber = "";
    setState(() {
      showCamera = true;
    });
  }

  //MAIN UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Credit Card Submissions'),
        automaticallyImplyLeading: false, //HIDE BACK BUTTON
      ),
      body: Center(
        child: Column(
          children: [
            if (showCamera) //SHOW CAMERA BASED ON BOOL
              Expanded(
                child: ScannerWidget(
                  controller: _controller,
                  overlayOrientation: CardOrientation.landscape,
                ),
              ),
            Container(
              width: MediaQuery.of(context).size.width,
              color: Colors.white,
              child: Column(
                children: [
                  const SizedBox(
                    height: 45,
                  ),
                  Text(
                    cardNumber.isNotEmpty ? cardNumber : 'No Card Details',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    width: 350,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddNewCard(),
                          ),
                        );
                      },
                      child: Text('Submit'),
                    ),
                  ),
                  SizedBox(
                    width: 350,
                    child: ElevatedButton(
                      onPressed: () {
                        //CLEAR AND ENABLE CAMERA
                        _resetScan();
                      },
                      child: Text('Try Again'),
                    ),
                  ),
                  SizedBox(
                    width: 350,
                    child: ElevatedButton(
                      onPressed: () {
                        scannedCardNumber = "";
                        Navigator.pop(context);
                      },
                      child: Text('Cancel'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  //DISPOSE ALL OBJECTS
  @override
  void dispose() {
    _controller.dispose();
    _cardInfo = null;
    super.dispose();
  }
}
