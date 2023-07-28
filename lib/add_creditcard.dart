import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:country_provider2/country_provider2.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AddNewCard extends StatefulWidget {
  const AddNewCard({Key? key}) : super(key: key);

  @override
  State<AddNewCard> createState() => AddNewCardPage();
}

class AddNewCardPage extends State<AddNewCard> {
  TextEditingController cardNumberController = TextEditingController();
  TextEditingController cardTypeController = TextEditingController();
  TextEditingController cardCVVController = TextEditingController();
  TextEditingController cardExpiryController = TextEditingController();
  TextEditingController cardCountryController = TextEditingController();

  CardType cardType = CardType.Invalid;
  List<String> _kOptions = [];

  void getCardTypeFrmNum() {
    if (cardNumberController.text.length <= 6) {
      String cardNum = CardUtils.getCleanedNumber(cardNumberController.text);
      CardType type = CardUtils.getCardTypeFrmNumber(cardNum);
      if (type != cardType) {
        setState(() {
          cardType = type;
          cardTypeController.text = cardTypeToString(type); // Update the text property
        });
      }
    }
  }

  // Utility method to convert CardType enum to String
  String cardTypeToString(CardType type) {
    switch (type) {
      case CardType.Master:
        return 'Mastercard';
      case CardType.Visa:
        return 'Visa';
      case CardType.Verve:
        return 'Verve';
      case CardType.AmericanExpress:
        return 'American Express';
      case CardType.Discover:
        return 'Discover';
      case CardType.DinersClub:
        return 'Diners Club';
      case CardType.Jcb:
        return 'JCB';
      case CardType.Others:
      default:
        return 'Unknown';
    }
  }


  @override
  void initState() {
    // Other code...
    _fetchCountryNames().then((countryNames) {
      setState(() {
        _kOptions = countryNames;
      });
    }).catchError((error) {
      print('Error fetching country names: $error');
      // Provide a default list of country names in case of an error
      setState(() {
        _kOptions = ['Country 1', 'Country 2', 'Country 3']; // Add more countries if needed
      });
    });
    // Other code...
  }



  @override
  void dispose() {
    cardNumberController.dispose();
    super.dispose();
  }

  /*static const List<String> _kOptions = <String>[
    'aardvark',
    'bobcat',
    'chameleon',
  ];*/

  Future<List<String>> _fetchCountryNames() async {
    List<String> countryNames = [];
    CountryProvider countryProvider = CountryProvider();
    try {
      List<Country>? countries = await countryProvider.getCountriesByName('');
      if (countries != null) {
        for (var country in countries) {
          countryNames.add(country.name ?? ''); // Provide a default value if null
        }
      }
    } catch (error) {
      print('Error fetching country names: $error');
    }
    return countryNames;
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text("Credit Card Submissions")),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 25, 10, 0),
                child: Text(
                  'Add New Card',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    // Customize the content text style if needed
                  ),
                ),
              ),
              Form(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 35, 10, 0),
                      child: TextFormField(
                        controller: cardNumberController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(19),
                          CardNumberInputFormatter(),
                        ],
                        decoration: InputDecoration(
                          labelText: "Card Number",
                          border: OutlineInputBorder(),
                          //suffix: CardUtils.getCardTypeDescription(cardType),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                      child: TextFormField(
                        controller: cardTypeController,
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: 'Card Type',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: cardCVVController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                // Limit the input
                                LengthLimitingTextInputFormatter(4),
                              ],
                              decoration: const InputDecoration(hintText: "CVV"),
                            ),
                          ),
                          SizedBox(width: 10), // Add some spacing between the CVV and Expiry fields
                          Expanded(
                            child: TextFormField(
                              controller: cardExpiryController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(5),
                              ],
                              decoration: const InputDecoration(hintText: "MM/YY"),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                      child: TextField(
                        controller: cardCountryController,
                        decoration: const InputDecoration(
                          labelText: 'Issuing Country',
                          border: OutlineInputBorder(),
                        ),
                        // Disable text field editing
                        enabled: true,
                        // Show the autocomplete suggestions as a dropdown menu
                        // when the user taps the text field
                        onTap: () {
                          showAutocomplete(context);
                        },
                      ),
                    ),
                    SizedBox(height: 20), // Add some spacing between the fields and buttons
                    Center(
                      child: Container(
                        width: 350,
                        height: 45,
                        child: ElevatedButton(
                          onPressed: () {
                            // Handle the form submission here
                          },
                          child: const Text('Submit'),
                        ),
                      ),
                    ),
                    SizedBox(height: 10), // Add some spacing between the buttons
                    Center(
                      child: Container(
                        width: 350,
                        height: 45,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('Cancel'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showAutocomplete(BuildContext context) async {
    final selectedCountry = await showSearch<String>(
      context: context,
      delegate: _CountrySearchDelegate(_kOptions),
    );

    if (selectedCountry != null) {
      setState(() {
        cardCountryController.text = selectedCountry;
      });
    }
  }



}

//ALLOW SPACES WHEN USER ENTERS CARD NO
class CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text;
    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }
    var buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      var nonZeroIndex = i + 1;
      if (nonZeroIndex % 4 == 0 && nonZeroIndex != text.length) {
        buffer.write('  '); // Add double spaces.
      }
    }
    var string = buffer.toString();
    return newValue.copyWith(
        text: string,
        selection: TextSelection.collapsed(offset: string.length));
  }
}

enum CardType {
  Master,
  Visa,
  Verve,
  Discover,
  AmericanExpress,
  DinersClub,
  Jcb,
  Others,
  Invalid
}

class CardUtils {

  static CardType getCardTypeFrmNumber(String input) {
    CardType cardType;
    if (input.startsWith(RegExp(
        r'((5[1-5])|(222[1-9]|22[3-9][0-9]|2[3-6][0-9]{2}|27[01][0-9]|2720))'))) {
      cardType = CardType.Master;
    } else if (input.startsWith(RegExp(r'[4]'))) {
      cardType = CardType.Visa;
    } else if (input.startsWith(RegExp(r'((506(0|1))|(507(8|9))|(6500))'))) {
      cardType = CardType.Verve;
    } else if (input.startsWith(RegExp(r'((34)|(37))'))) {
      cardType = CardType.AmericanExpress;
    } else if (input.startsWith(RegExp(r'((6[45])|(6011))'))) {
      cardType = CardType.Discover;
    } else if (input.startsWith(RegExp(r'((30[0-5])|(3[89])|(36)|(3095))'))) {
      cardType = CardType.DinersClub;
    } else if (input.startsWith(RegExp(r'(352[89]|35[3-8][0-9])'))) {
      cardType = CardType.Jcb;
    } else if (input.length <= 8) {
      cardType = CardType.Others;
    } else {
      cardType = CardType.Invalid;
    }
    return cardType;
  }

  static String getCleanedNumber(String text) {
    RegExp regExp = RegExp(r"[^0-9]");
    return text.replaceAll(regExp, '');
  }

   String getCardTypeDescription(CardType cardType) {
    String creditcardtyperesult = "";
    switch (cardType) {
      case CardType.Master:
        creditcardtyperesult = 'Master Card';
        break;
      case CardType.Visa:
        creditcardtyperesult = 'Visa Card';
        break;
      case CardType.Verve:
        creditcardtyperesult = 'Verve';
        break;
      case CardType.AmericanExpress:
        creditcardtyperesult = 'American Express';
        break;
      case CardType.Discover:
        creditcardtyperesult = 'Discover';
        break;
      case CardType.DinersClub:
        creditcardtyperesult = 'Dinners Club';
        break;
      case CardType.Jcb:
        creditcardtyperesult = 'JCB';
        break;
      case CardType.Others:
        creditcardtyperesult = 'Other';
        break;
      default:
        creditcardtyperesult = 'Unknown';
        break;
    }

    return creditcardtyperesult;
  }
}

class _CountrySearchDelegate extends SearchDelegate<String> {
  final List<String> countryNames;

  _CountrySearchDelegate(this.countryNames);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: Icon(Icons.clear),
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, '');
      },
      icon: Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults(query);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults(query);
  }

  Widget _buildSearchResults(String query) {
    final List<String> matches = countryNames
        .where((countryName) => countryName
        .toLowerCase()
        .contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: matches.length,
      itemBuilder: (context, index) {
        final countryName = matches[index];
        return ListTile(
          title: Text(countryName),
          onTap: () {
            close(context, countryName);
          },
        );
      },
    );
  }
}




