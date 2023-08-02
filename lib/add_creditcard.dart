import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'main.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'scan_creditcard.dart';
import 'menu.dart';
import 'countries.dart';

class AddNewCard extends StatefulWidget {
  const AddNewCard({Key? key}) : super(key: key);

  @override
  State<AddNewCard> createState() => AddNewCardPage();
}

class AddNewCardPage extends State<AddNewCard> {

  //DECLARE VARIABLES
  final _formKey = GlobalKey<FormState>();
  late Box box_cards;
  late Box box_banned;
  CardType cardType = CardType.Invalid;

  //DECLARE USER INPUT OBJECTS
  TextEditingController cardNumberController = TextEditingController();
  TextEditingController cardTypeController = TextEditingController();
  TextEditingController cardCVVController = TextEditingController();
  TextEditingController cardExpiryController = TextEditingController();
  TextEditingController cardCountryController = TextEditingController();

  //INITIAL SETUP OF THE WIDGET
  @override
  void initState() {
    // TODO: implement initState
    //INFER CARD TYPE
    cardNumberController.addListener(() {
      getCardTypeFromScannedNumber();
    },);
    //CHECK IF THE GLOBAL SCANNED CARD NUMBER HAS A VALUE AND SET UP PAGE
    if (scannedCardNumber != null && scannedCardNumber!.isNotEmpty) {
      setScannedCardNumberType();
    }
    super.initState();
  }

  //FUNCTIONS FOR THE WIDGET
  void setScannedCardNumberType() {
    //GET THE 1ST 6 DIGITS
    String originalNumber = scannedCardNumber!;
    String firstSixNumbers = originalNumber.substring(0, 6);
    CardType type = CardUtils.getCardTypeFromNumber(firstSixNumbers);
    //GET CARD TYPE
    if (type != cardType) {
      setState(() {
        cardType = type;
        cardTypeController.text = cardTypeToString(type);
        //FORMAT THE CARD NUMBER FOR DISPLAY
        String formattedNumber = originalNumber.replaceAllMapped(
          RegExp(r".{4}"),
              (match) => "${match.group(0)} ",
        );
        cardNumberController.text = formattedNumber.trimRight();
      });
    }
  }

  void getCardTypeFromScannedNumber() {
    if (cardNumberController.text.length <= 6) {
      String cardNum = CardUtils.getCleanedNumber(cardNumberController.text);
      CardType type = CardUtils.getCardTypeFromNumber(cardNum);
      if (type != cardType) {
        setState(() {
          cardType = type;
          cardTypeController.text = cardTypeToString(type);
        });
      }
    }
  }

  //CASTS CARD TYPE ENUM TO STRING
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

  Future<bool> saveCard(BuildContext context) async {

    //DECLARE VARIABLES
    String? errorMessage = "";
    String expiryDate = "";
    Future<bool> banned;

    //OPEN BOX THAT STORES CREDIT CARDS
    box_cards = await Hive.openBox('credit_cards');

    //VALIDATE FOR BANNED COUNTRY
    bool isBanned = await validateCountry();

    //EXIT IF BANNED
    if (isBanned) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Credit cards are banned from the country you selected.')));
      return false;
    }

    //CLEAN NUMBER
    String cleanCardNumber = CardUtils.getCleanedNumber(cardNumberController.text);

    //VALIDATE FOR EXISTING NUMBER
    for (var key in box_cards.keys) {

      //LOOP THROUGH BOX AND GET KEY VALUE PAIRS
      var value = box_cards.get(key);

      //CHECK FOR EXISTING NUMBER
      if(value['number'] == cleanCardNumber) {
        //EXIT
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('A credit card is already captured for the number you entered.')));
        return false;
      }

      //VALIDATE CARD NUMBER
      if(CardUtils.validateCardNumber(cleanCardNumber) != "") {
        //EXIT
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('The credit card number you provided is invalid.')));
        return false;
      }

      //VALIDATE EXPIRY DATE
      expiryDate = cardExpiryController.text;
      errorMessage = CardUtils.validateDate(expiryDate);
      if (errorMessage != null) {
        //EXIT
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage)));
        return false;
      }
    }

    //SAVE CREDIT CARD
    Map<String, dynamic> cardValues = {
      'session': sessionId,
      'number': cleanCardNumber,
      'type': cardTypeController.text.trim(),
      'cvv': cardCVVController.text.trim(),
      'expiry': cardExpiryController.text.trim(),
      'country': cardCountryController.text.trim()
    };

    box_cards.add(cardValues);
    await box_cards.close();

    //SUCCESSFUL SAVE
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('The credit card you captured has been successfully saved.')));
    return true;
  }

  //CHECK FOR COUNTRY IN BANNED LIST
  Future<bool> validateCountry() async {

    //OPEN BOX THAT STORES BANNED COUNTRIES
    box_banned = await Hive.openBox('banned_countries');

    //VALIDATE COUNTRY IN BANNED COUNTRIES
    for (var key in box_banned.keys) {
      //LOOP THROUGH BOX AND GET KEY VALUE PAIRS
      var value = box_banned.get(key);

      if(value['country'] == cardCountryController.text.trim()) {
        //BANNED
        return true;
      }
    }
    //UNBANNED
    return false;
  }

  //MAIN UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text("Credit Card Submissions"), automaticallyImplyLeading: false,),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 25, 10, 0),
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    "Add Credit Card",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 35, 10, 0),
                      child: TextFormField(
                        controller: cardNumberController,
                        //IF THE NUMBER WAS SCANNED IN, LOCK TEXTBOX
                        readOnly: scannedCardNumber != null && scannedCardNumber!.isNotEmpty,
                        keyboardType: TextInputType.number,
                        inputFormatters: [ //FORMAT USER'S INPUT
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(19),
                          CardNumberInputFormatter(),
                        ],
                        decoration: InputDecoration(
                          labelText: "Card Number",
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a Card Number';
                          }
                          return null;
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 15, 10, 0),
                      child: TextFormField(
                        controller: cardTypeController,
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: 'Card Type',
                          border: OutlineInputBorder(),
                        ),validator: (value) {
                        if (value == null || value.isEmpty || value == 'Other') {
                          return 'Please enter a valid Credit Card Number';
                        }
                        return null;
                      },
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
                              inputFormatters: [ //FOMAT USERS INPUT
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(4),
                              ],
                              decoration: const InputDecoration(hintText: "CVV"),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a CVV Number';
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(width: 10), // Add some spacing between the CVV and Expiry fields
                          Expanded(
                            child: TextFormField(
                              controller: cardExpiryController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [ //FORMAT USERS INPUT
                                LengthLimitingTextInputFormatter(5),
                                ExpiryDateInputFormatter(),
                              ],
                              decoration: const InputDecoration(hintText: "MM/YY"),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a Card Expiry Date';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    //AUTOCOMPLETE TEXT SEARCH FOR A COUNTRY
                    Autocomplete<Country>(
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        return countryOptions
                            .where((Country country) => country.name.toLowerCase()
                            .startsWith(textEditingValue.text.toLowerCase())
                        )
                            .toList();
                      },
                      displayStringForOption: (Country option) => option.name,
                      fieldViewBuilder: (
                          BuildContext context,
                          TextEditingController cardCountryController,
                          FocusNode fieldFocusNode,
                          VoidCallback onFieldSubmitted
                          ) {
                        return TextFormField(
                          controller: cardCountryController,
                          decoration: const InputDecoration(hintText: "Issuing Country"),
                          focusNode: fieldFocusNode,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please provide an issuing country.';
                            }
                            return null; // Return null for valid input
                          },
                        );
                      },
                      onSelected: (Country selection) {
                        cardCountryController.text = selection.name;
                      },
                      optionsViewBuilder: (
                          BuildContext context,
                          AutocompleteOnSelected<Country> onSelected,
                          Iterable<Country> options
                          ) {
                        return Align(
                          alignment: Alignment.topLeft,
                          child: Material(
                            child: Container(
                              width: 300,
                              color: Colors.grey.shade100,
                              child: ListView.builder(
                                padding: EdgeInsets.all(10.0),
                                itemCount: options.length,
                                itemBuilder: (BuildContext context, int index) {
                                  final Country option = options.elementAt(index);
                                  return GestureDetector(
                                    onTap: () {
                                      onSelected(option);
                                    },
                                    child: ListTile(
                                      title: Text(option.name, style: const TextStyle(color: Colors.black)),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 35), // Add some spacing between the fields and buttons
                    Center(
                      child: Container(
                        width: 350,
                        height: 45,
                        child: ElevatedButton(
                          onPressed: () async {
                            //DO VALIDATIONS
                            if (_formKey.currentState!.validate()) {
                              bool isSaved = await saveCard(context);
                              if (isSaved) {
                                scannedCardNumber = "";
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => HomePage(),
                                  ),
                                );
                              }
                            }
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
                            scannedCardNumber = "";
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HomePage(),
                              ),
                            );
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

  //DISPOSE ALL OBJECTS
  @override
  void dispose() {
    cardNumberController.dispose();
    cardTypeController.dispose();
    cardCVVController.dispose();
    cardExpiryController.dispose();
    cardCountryController.dispose();
    cardNumberController.removeListener;
    box_cards.close();
    scannedCardNumber = null;
    super.dispose();
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

//ADD FORWARD SLASH WHEN USER ENTERS DATE
class ExpiryDateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {

    final input = newValue.text;
    final length = input.length;

    if (length == 3 && !input.contains('/')) {
      // ADD A SLASH AFTER THE FIRST 2 DIGITS
      final formattedValue = '${input.substring(0, 2)}/${input.substring(2)}';
      return TextEditingValue(
        text: formattedValue,
        selection: TextSelection.collapsed(offset: formattedValue.length),
      );
    }

    return newValue;
  }
}


//LIST OF CARD TYPES
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

//METHODS TO VALIDATE USER INPUT
class CardUtils {

  static CardType getCardTypeFromNumber(String input) {
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

  static String validateCardNumber(String input) {

    if (input.length < 8) {
      return "Card is invalid";
    }
    int sum = 0;
    int length = input.length;
    for (var i = 0; i < length; i++) {
      // get digits in reverse order
      int digit = int.parse(input[length - i - 1]);
      // every 2nd number multiply with 2
      if (i % 2 == 1) {
        digit *= 2;
      }
      sum += digit > 9 ? (digit - 9) : digit;
    }
    if (sum % 10 == 0) {
      return "";
    }
    return "Card is invalid";
  }

  static String? validateDate(String value) {
    int year;
    int month;
    if (value.contains(RegExp(r'(/)'))) {
      var split = value.split(RegExp(r'(/)'));

      month = int.parse(split[0]);
      year = int.parse(split[1]);
    } else {
      month = int.parse(value.substring(0, (value.length)));
      year = -1;
    }
    if ((month < 1) || (month > 12)) {
      return 'Expiry month is invalid';
    }
    var fourDigitsYear = convertYearTo4Digits(year);
    if ((fourDigitsYear < 1) || (fourDigitsYear > 2099)) {
      return 'Expiry year is invalid';
    }
    if (!hasDateExpired(month, year)) {
      return "Card has expired";
    }
    return null; // Return an empty string for valid dates
  }

  static int convertYearTo4Digits(int year) {
    if (year < 100 && year >= 0) {
      var now = DateTime.now();
      String currentYear = now.year.toString();
      String prefix = currentYear.substring(0, currentYear.length - 2);
      year = int.parse('$prefix${year.toString().padLeft(2, '0')}');
    }
    return year;
  }

  static bool hasDateExpired(int month, int year) {
    return isNotExpired(year, month);
  }

  static bool isNotExpired(int year, int month) {
    return !hasYearPassed(year) && !hasMonthPassed(year, month);
  }

  static bool hasMonthPassed(int year, int month) {
    var now = DateTime.now();
    return hasYearPassed(year) ||
        convertYearTo4Digits(year) == now.year && (month < now.month + 1);
  }

  static bool hasYearPassed(int year) {
    int fourDigitsYear = convertYearTo4Digits(year);
    var now = DateTime.now();
    return fourDigitsYear < now.year;
  }
}






