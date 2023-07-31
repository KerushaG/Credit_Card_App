import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'main.dart';
import 'add_creditcard.dart';
//ADD COUNT OF ITEMS
//ADD ARE YOU SURE YOU WANNA DELETE IT

// Home Page
class ViewCreditCards extends StatefulWidget {
  const ViewCreditCards({Key? key}) : super(key: key);

  @override
  State<ViewCreditCards> createState() => _ViewCreditCardsState();
}

class _ViewCreditCardsState extends State<ViewCreditCards> {
  List<Map<String, dynamic>> _items = [];
  // TextFields' controllers
  final TextEditingController cardNumberController = TextEditingController();
  final TextEditingController cardTypeController = TextEditingController();
  final TextEditingController cardCVVController = TextEditingController();
  final TextEditingController cardExpiryController = TextEditingController();
  final TextEditingController cardCountryController = TextEditingController();
  late int totalCards;
  late Box box_cards;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    openBox();
  }

  void openBox() async {
    box_cards = await Hive.openBox('credit_cards');
    //
    _refreshItems();
  }

  // Get all items from the database
  void _refreshItems() {
    final sessionValue = sessionId; // Replace this with the session value you want to filter by
    final data = box_cards.keys.map((key) {
      final value = box_cards.get(key);
      if (value["session"] == sessionValue) { // Filter by the specific session value
        return {
          "key": key,
          "number": value["number"],
          "type": value["type"],
          "cvv": value["cvv"],
          "expiry": value["expiry"],
          "country": value["country"],
        };
      } else {
        return null; // Return null for items that don't match the specific session value
      }
    }).whereType<Map<String, dynamic>>().toList(); // Remove null items from the list

    setState(() {
      _items = data.reversed.toList();
      // we use "reversed" to sort items in order from the latest to the oldest
    });
  }

  int getTotalCards() {
    return _items.length;
  }

  // Delete a single item
  Future<void> _deleteItem(int itemKey) async {
    await box_cards.delete(itemKey);
    _refreshItems(); // update the UI

    // Display a snackbar
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('The credit card has been deleted')));
  }

  // This function will be triggered when the floating button is pressed
  // It will also be triggered when you want to update an item
  void _showForm(BuildContext ctx, int? itemKey) async {

    if (itemKey != null) {
      final existingItem =
      _items.firstWhere((element) => element['key'] == itemKey);
      cardNumberController.text = existingItem['number'];
      cardTypeController.text = existingItem['type'];
      cardCVVController.text = existingItem['cvv'];
      cardExpiryController.text = existingItem['expiry'];
      cardCountryController.text = existingItem['country'];
    }

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
                '${getTotalCards()} Captured Credit Cards for Current Session ($sessionId)',
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
            child: _items.isEmpty
                ? Center(
              child: Text(
                'No Data',
                style: TextStyle(fontSize: 30),
              ),
            )
                : ListView.builder(
              // the list of items
              itemCount: _items.length,
              itemBuilder: (_, index) {
                final currentItem = _items[index];
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
                        // Edit button
                        IconButton(
                          icon: const Icon(Icons.visibility),
                          onPressed: () =>
                              _showForm(context, currentItem['key']),
                        ),
                        // Delete button
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
      // Add new item button
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

  void _showDeleteConfirmationDialog(int itemKey) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Item"),
          content: const Text("Are you sure you want to delete this item?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                // Perform the delete operation inside the setState callback
                setState(() {
                  _deleteItem(itemKey); // Delete the item
                });
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }


}