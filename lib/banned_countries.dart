import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

//ADD COUNT OF ITEMS
//ADD ARE YOU SURE YOU WANNA DELETE IT

// Home Page
class BannedCountries extends StatefulWidget {
  const BannedCountries({Key? key}) : super(key: key);

  @override
  State<BannedCountries> createState() => _BannedCountriesState();
}

class _BannedCountriesState extends State<BannedCountries> {
  List<Map<String, dynamic>> _items = [];

  late Box box_countries;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    createOpenBox();
  }

  void createOpenBox() async {
    box_countries = await Hive.openBox('banned_countries');
    //await box_countries.clear();
    _refreshItems();
  }


  // Get all items from the database
  void _refreshItems() {
    final data = box_countries.keys.map((key) {
      final value = box_countries.get(key);
      return {"key": key, "country": value["country"]};
    }).toList();

    setState(() {
      _items = data.reversed.toList();
      // we use "reversed" to sort items in order from the latest to the oldest
    });
  }

  // Create new item
  Future<void> _createItem(Map<String, dynamic> newItem) async {
    await box_countries.add(newItem);
    _refreshItems(); // update the UI
  }

  // Retrieve a single item from the database by using its key
  // Our app won't use this function but I put it here for your reference
  Map<String, dynamic> _readItem(int key) {
    final item = box_countries.get(key);
    return item;
  }

  // Update a single item
  Future<void> _updateItem(int itemKey, Map<String, dynamic> item) async {
    await box_countries.put(itemKey, item);
    _refreshItems(); // Update the UI
  }

  // Delete a single item
  Future<void> _deleteItem(int itemKey) async {
    await box_countries.delete(itemKey);
    _refreshItems(); // update the UI

    // Display a snackbar
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('The country has been deleted')));
  }

  // TextFields' controllers
  final TextEditingController countryController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();

  // This function will be triggered when the floating button is pressed
  // It will also be triggered when you want to update an item
  void _showForm(BuildContext ctx, int? itemKey) async {
    // itemKey == null -> create new item
    // itemKey != null -> update an existing item

    if (itemKey != null) {
      final existingItem =
      _items.firstWhere((element) => element['key'] == itemKey);
      countryController.text = existingItem['country'];
    }

    showModalBottomSheet(
        context: ctx,
        elevation: 5,
        isScrollControlled: true,
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
                    controller: countryController,
                    decoration: const InputDecoration(hintText: 'Country'),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      // Save new item
                      if (itemKey == null) {
                        _createItem({
                          "country": countryController.text,
                        });
                      }

                      // update an existing item
                      if (itemKey != null) {
                        _updateItem(itemKey, {
                          'country': countryController.text.trim(),
                        });
                      }

                      // Clear the text fields
                      countryController.text = '';

                      Navigator.of(context).pop(); // Close the bottom sheet
                    },
                    child: Text(itemKey == null ? 'Create New' : 'Update'),
                  ),
                  const SizedBox(
                    height: 15,
                  )
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
            padding: const EdgeInsets.fromLTRB(0, 25, 10, 30),
            child: Text(
              'Banned Countries',
              style: TextStyle(
                color: Colors.black,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                // Customize the content text style if needed
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
                    title: Text(currentItem['country']),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Edit button
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () =>
                              _showForm(context, currentItem['key']),
                        ),
                        // Delete button
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _deleteItem(currentItem['key']),
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
        onPressed: () => _showForm(context, null),
        child: const Icon(Icons.add),
      ),
    );
  }
}