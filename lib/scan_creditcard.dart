import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ml_card_scanner/ml_card_scanner.dart';

class Scanning extends StatefulWidget {
  const Scanning({Key? key}) : super(key: key);

  @override
  State<Scanning> createState() => _ScanningState();
}

class _ScanningState extends State<Scanning> {
  CardInfo? _cardInfo;
  final ScannerWidgetController _controller = ScannerWidgetController();
  String cardNumber = "";

  @override
  void initState() {
    _controller
      ..setCardListener((value) {
        setState(() {
          _cardInfo = value;
          // Split the text into lines
          List<String> lines = _cardInfo.toString().split('\n');

          // Get the second line (index 1) and third line (index 2) from the list
          cardNumber = 'Card ' + lines[1];
          //_cardInfo = cardNumber as CardInfo?;

        });
      })
      ..setErrorListener((exception) {
        if (kDebugMode) {
          print('Error: ${exception.message}');
        }
      });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Credit Card Submissions'),
      ),
      body: Center(
        child: Column(
          children: [
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

                  Text(cardNumber.isNotEmpty ? cardNumber : 'No Card Details',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 22,
                    fontWeight: FontWeight.bold, // Adjust the font weight as needed// Adjust the text color as needed
                    // You can add more text styles here if needed, such as fontFamily, letterSpacing, etc.
                  ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    width: 350, // Add your desired width here
                    child: ElevatedButton(
                      onPressed: () {
                        // Handle submit button press here
                        // You can add your logic to submit the card details
                      },
                      child: Text('Submit'),
                    ),
                  ),
                  SizedBox(
                    width: 350, // Add your desired width here
                    child: ElevatedButton(
                      onPressed: () {
                        // Handle cancel button press here
                        // You can add your logic to cancel the submission
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


}
