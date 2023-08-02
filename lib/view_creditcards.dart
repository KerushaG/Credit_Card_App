import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'main.dart';
import 'add_creditcard.dart';
import 'view_allcreditcards.dart';

class ViewCreditCards extends StatefulWidget {
  const ViewCreditCards({Key? key}) : super(key: key);

  @override
  State<ViewCreditCards> createState() => _ViewCreditCardsState();
}

class _ViewCreditCardsState extends State<ViewCreditCards> {

  //DECLARE VARIABLES
  List<Map<String, dynamic>> map_cards = [];
  late int totalCards;
  late Box box_cards;

  //DECLARE USER INPUT OBJECTS
  final TextEditingController cardNumberController = TextEditingController();
  final TextEditingController cardTypeController = TextEditingController();
  final TextEditingController cardCVVController = TextEditingController();
  final TextEditingController cardExpiryController = TextEditingController();
  final TextEditingController cardCountryController = TextEditingController();

  //INITIAL SETUP OF THE WIDGET
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    openBox();
  }

  //FUNCTIONS FOR THE WIDGET
  void openBox() async {
    box_cards = await Hive.openBox('credit_cards');
    //box_cards.clear();
    loadList();
  }

  void loadList() {
   try{
     //DECLARE VARIABLES
     String formattedNumber;
     String originalNumber;

     //GET SESSION ID
     final sessionValue = sessionId;

     final data = box_cards.keys.map((key) {
       //DATA FROM BOX CAST TO A MAP WITH ALL KEY VALUE PAIRS
       final value = box_cards.get(key);
       //FILTER FOR CURRENT SESSION
       if (value["session"] == sessionValue) {
         //SAVE CARD NUMBER
         originalNumber = value["number"];

         //FORMAT CARD NUMBER
         formattedNumber = originalNumber.replaceAllMapped(
           RegExp(r".{4}"),
               (match) => "${match.group(0)} ",
         ).trim();

         return {
           "key": key,
           "number": formattedNumber,
           "type": value["type"],
           "cvv": value["cvv"],
           "expiry": value["expiry"],
           "country": value["country"],
         };
       } else {
         return null;
       }
     }).whereType<Map<String, dynamic>>().toList();

     //UPDATE THE WIDGET WITH THE LIST
     setState(() {
       //SHOW ORDER FROM NEWEST ADDITIONS
       map_cards = data.reversed.toList();
     });
   }catch (e)
   {
     //DISPLAY USER MESSAGE
     if (!mounted) return;
     ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text('Error in getting list.')));
   }
  }

  int getTotalCards() {
    return map_cards.length;
  }

  //DELETE CARD
  Future<void> deleteCard(int cardKey) async {
    try{
      await box_cards.delete(cardKey);
      //REFRESH LIST
      loadList();

      //DISPLAY MESSAGE TO USER
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('The credit card has been deleted')));
    }catch (e)
    {
      //DISPLAY USER MESSAGE
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error in deleting card.')));
    }
  }

  //SETS POP UP FOR VIEWING CARD INFO
  void displayCardDetails(BuildContext ctx, int? cardKey) async {

    //VALIDATE FOR SELECTED CARD
    if (cardKey != null) {
      final existingCard =
      map_cards.firstWhere((element) => element['key'] == cardKey);
      cardNumberController.text = existingCard['number'];
      cardTypeController.text = existingCard['type'];
      cardCVVController.text = existingCard['cvv'];
      cardExpiryController.text = existingCard['expiry'];
      cardCountryController.text = existingCard['country'];
    }
    //ALL FIELDS ARE SET TO READ ONLY
    showModalBottomSheet(
        context: ctx,
        elevation: 5,
        isScrollControlled: false,
        builder: (_) =>
            Container(
              padding: EdgeInsets.only(
                  bottom: MediaQuery
                      .of(ctx)
                      .viewInsets
                      .bottom,
                  top: 15,
                  left: 15,
                  right: 15),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TextField(
                    readOnly: true,
                    controller: cardNumberController,
                    decoration: const InputDecoration(labelText: 'Card Number'),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    readOnly: true,
                    controller: cardTypeController,
                    decoration: const InputDecoration(labelText: 'Card Type'),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    readOnly: true,
                    controller: cardCVVController,
                    decoration: const InputDecoration(labelText: 'Card CVV Number'),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    readOnly: true,
                    controller: cardExpiryController,
                    decoration: const InputDecoration(labelText: 'Card Expiry Date'),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    readOnly: true,
                    controller: cardCountryController,
                    decoration: const InputDecoration(labelText: 'Issuing Country'),
                  ),
                ],
              ),
            ));
  }

  //MAIN UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Credit Card Submissions'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(30, 25, 30, 30),
            child: Align(
              alignment: Alignment.center,
              child: Text(
                '${getTotalCards()} Captured Credit Cards for Current Session ($sessionId)',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Expanded(
            //VALIDATE FOR DATA
            child: map_cards.isEmpty
                ? Center(
              child: Text(
                'No Data',
                style: TextStyle(fontSize: 30),
              ),
            )
            //DISPLAY LIST
                : ListView.builder(
              itemCount: map_cards.length,
              itemBuilder: (_, index) {
                final currentCard = map_cards[index];
                return Card(
                  color: Colors.blue.shade50,
                  margin: const EdgeInsets.all(10),
                  elevation: 3,
                  child: ListTile(
                    title: Text(currentCard['number']),
                    subtitle: Text(currentCard['type']),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.visibility),
                          onPressed: () => displayCardDetails(context, currentCard['key']),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _showDeleteConfirmationDialog(currentCard['key']),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      //DISPLAY ADD BUTTON
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddNewCard(),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
      //DISPLAY VIEW ALL BUTTON
      persistentFooterButtons: [
        Container(
          width: 350,
          height: 60,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ViewCreditCardsAll(),
                ),
              );
            },
            child: Text('View All'),
          ),
        ),
      ],
    );
  }

  //ASK USER FOR CONFIRMATION WHEN DELETING
  void _showDeleteConfirmationDialog(int cardKey) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Card"),
          content: const Text("Are you sure you want to delete this card?"),
          actions: [
            TextButton(
              onPressed: () {
                //CLOSE DIALOG
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  //DELETE CARD
                  deleteCard(cardKey);
                });
                //CLOSE DIALOG
                Navigator.of(context).pop();
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  //DISPOSE ALL OBJECTS
  @override
  void dispose() {
    cardNumberController.dispose();
    cardCVVController.dispose();
    cardCountryController.dispose();
    cardExpiryController.dispose();
    cardTypeController.dispose();
    box_cards.close(); // Close the Hive box when the widget is disposed
    super.dispose();
  }
}