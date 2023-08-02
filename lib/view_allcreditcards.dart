import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'add_creditcard.dart';

class ViewCreditCardsAll extends StatefulWidget {
  const ViewCreditCardsAll({Key? key}) : super(key: key);

  @override
  State<ViewCreditCardsAll> createState() => _ViewCreditCardsAllState();
}

class _ViewCreditCardsAllState extends State<ViewCreditCardsAll> {

  //DECLARE VARIABLES
  late int totalCards;
  late Box box_cards;
  List<Map<String, dynamic>> map_cards = [];

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

  void openBox() async {
    box_cards = await Hive.openBox('credit_cards');
    loadList();
  }

  void loadList() {

    //DECLARE VARIABLES
    String formattedNumber;
    String originalNumber;

    final data = box_cards.keys.map((key) {
      //DATA FROM BOX CAST TO A MAP WITH ALL KEY VALUE PAIRS
      final value = box_cards.get(key);
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
    }).whereType<Map<String, dynamic>>().toList();

    //UPDATE THE WIDGET WITH THE LIST
    setState(() {
      map_cards = data.reversed.toList();
      //SHOW ORDER FROM NEWEST ADDITIONS
    });
  }

  int getTotalCards() {
    return map_cards.length;
  }

  //DELETE CARD
  Future<void> deleteCard(int itemKey) async {
    try{
      await box_cards.delete(itemKey);

      //REFRESH LIST
      loadList();

      //DISPLAY USER MESSAGE
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
  void displayCardDetails(BuildContext ctx, int? itemKey) async {

    //VALIDATE FOR SELECTED CARD
    if (itemKey != null) {
      final existingItem =
      map_cards.firstWhere((element) => element['key'] == itemKey);
      cardNumberController.text = existingItem['number'];
      cardTypeController.text = existingItem['type'];
      cardCVVController.text = existingItem['cvv'];
      cardExpiryController.text = existingItem['expiry'];
      cardCountryController.text = existingItem['country'];
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(30, 25, 30, 30),
            child: Align(
              alignment: Alignment.center,
              child: Text(
                '${getTotalCards()} Captured Credit Cards',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  // Customize the content text style if needed
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
              // the list of items
              itemCount: map_cards.length,
              itemBuilder: (_, index) {
                final currentItem = map_cards[index];
                return Card(
                  color: Colors.blue.shade50,
                  margin: const EdgeInsets.all(10),
                  elevation: 3,
                  child: ListTile(
                    title: Text(currentItem['number']),
                    subtitle: Text(currentItem['type']),

                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        //EDIT BUTTON
                        IconButton(
                          icon: const Icon(Icons.visibility),
                          onPressed: () =>
                              displayCardDetails(context, currentItem['key']),
                        ),
                        //DELETE BUTTON
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _showDeleteConfirmationDialog(currentItem['key']),
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
      //ADD BUTTON
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddNewCard(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
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
                //CLOSE THE DIALOG
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
                //CLOSE THE DIALOG
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