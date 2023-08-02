import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'countries.dart';

class BannedCountries extends StatefulWidget {
  const BannedCountries({Key? key}) : super(key: key);

  @override
  State<BannedCountries> createState() => _BannedCountriesState();
}

class _BannedCountriesState extends State<BannedCountries> {
  // DECLARE VARIABLES
  List<Map<String, dynamic>> map_cards = [];
  late int totalCountries;
  late Box box_banned;
  String selectedCountryName = '';

  // DECLARE USER INPUT OBJECTS
  final TextEditingController countryController = TextEditingController();

  // INITIAL SETUP OF THE WIDGET
  @override
  void initState() {
    super.initState();
    openBox();
  }

  void openBox() async {
    box_banned = await Hive.openBox('banned_countries');
    loadList();
  }

  void loadList() {
    final data = box_banned.keys.map((key) {
      final value = box_banned.get(key);
      return {"key": key, "country": value["country"]};
    }).toList();

    data.sort((a, b) => a["country"].compareTo(b["country"]));

    setState(() {
      map_cards = data.toList();
    });
  }

  int getTotalCountries() {
    return map_cards.length;
  }

  // ADD COUNTRY
  Future<void> createCountry(Map<String, dynamic> newCountry) async {
    try {
      await box_banned.add(newCountry);
      loadList();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('The country has been created.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error in adding card.')),
      );
    }
  }

  // EDIT COUNTRY
  Future<void> editCountry(int countryKey, Map<String, dynamic> selectedCountry) async {
    try {
      await box_banned.put(countryKey, selectedCountry);
      loadList();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('The country has been edited.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error in editing card.')),
      );
    }
  }

  // DELETE COUNTRY
  Future<void> deleteCountry(int countryKey) async {
    try {
      await box_banned.delete(countryKey);
      loadList();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('The country has been deleted')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error in deleting card.')),
      );
    }
  }

  // SETS POP UP FOR VIEWING CARD INFO
  void displayCountryMaintenance(BuildContext ctx, int? countryKey) async {
    if (countryKey != null) {
      final existingItem =
      map_cards.firstWhere((element) => element['key'] == countryKey);
      countryController.text = existingItem['country']; // Update the text in the controller
    } else {
      countryController.text = ''; // Clear the text in the controller for adding a new country
    }

    showModalBottomSheet(
      context: ctx,
      elevation: 5,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: 15,
          right: 15,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const SizedBox(height: 40),
            TextField(
              controller: countryController,
              decoration: const InputDecoration(hintText: 'Country'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                // ADD NEW COUNTRY
                if (countryKey == null) {
                  createCountry({
                    "country": countryController.text, // Use the countryController text here
                  });
                }
                // EDIT COUNTRY
                if (countryKey != null) {
                  editCountry(countryKey, {
                    'country': countryController.text.trim(), // Use the countryController text here
                  });
                }

                // CLOSE DIALOG
                Navigator.of(context).pop();
              },
              // VALIDATE AND NAME BUTTON
              child: Text(countryKey == null ? 'Create New' : 'Update'),
            ),
            const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }

  // MAIN UI
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
              'Banned Countries (${getTotalCountries()})',
              style: TextStyle(
                color: Colors.black,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            // VALIDATE FOR DATA
            child: map_cards.isEmpty
                ? Center(
              child: Text(
                'No Data',
                style: TextStyle(fontSize: 30),
              ),
            )
            // DISPLAY LIST
                : ListView.builder(
              itemCount: map_cards.length,
              itemBuilder: (_, index) {
                final currentItem = map_cards[index];
                return Card(
                  color: Colors.blue.shade50,
                  margin: const EdgeInsets.all(10),
                  elevation: 3,
                  child: ListTile(
                    title: Text(currentItem['country']),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // EDIT BUTTON
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () =>
                              displayCountryMaintenance(context, currentItem['key']),
                        ),
                        // DELETE BUTTON
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
      // ADD NEW BUTTON
      floatingActionButton: FloatingActionButton(
        onPressed: () => displayCountryMaintenance(context, null),
        child: const Icon(Icons.add),
      ),
    );
  }

  // ASK USER FOR CONFIRMATION WHEN DELETING
  void _showDeleteConfirmationDialog(int countryKey) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Country"),
          content: const Text("Are you sure you want to delete this country?"),
          actions: [
            TextButton(
              onPressed: () {
                // CLOSE DIALOG
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  // DELETE COUNTRY
                  deleteCountry(countryKey);
                });
                // CLOSE DIALOG
                Navigator.of(context).pop();
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  // DISPOSE ALL OBJECTS
  @override
  void dispose() {
    countryController.dispose();
    super.dispose();
  }
}
