import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'main.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'scan_creditcard.dart';
import 'menu.dart';

class AddNewCard extends StatefulWidget {
  const AddNewCard({Key? key}) : super(key: key);

  @override
  State<AddNewCard> createState() => AddNewCardPage();
}

class AddNewCardPage extends State<AddNewCard> {

  final _formKey = GlobalKey<FormState>();
  TextEditingController cardNumberController = TextEditingController();
  TextEditingController cardTypeController = TextEditingController();
  TextEditingController cardCVVController = TextEditingController();
  TextEditingController cardExpiryController = TextEditingController();
  TextEditingController cardCountryController = TextEditingController();

  late Box box_cards;
  late Box box_banned;

  CardType cardType = CardType.Invalid;

  void setScannedCardNumberType() {
    //GET THE 1ST 6 DIGITS
    String originalNumber = scannedCardNumber!; // Replace this with your 12-digit number
    String firstSixNumbers = originalNumber.substring(0, 6);
    CardType type = CardUtils.getCardTypeFrmNumber(firstSixNumbers);
    if (type != cardType) {
      setState(() {
        cardType = type;
        cardTypeController.text = cardTypeToString(type); // Update the text property
        //FORMAT THE CARD NUMBER
        String formattedNumber = originalNumber.replaceAllMapped(
          RegExp(r".{4}"),
              (match) => "${match.group(0)} ",
        );
        cardNumberController.text = formattedNumber.trimRight();
      });
    }
  }

  void getCardTypeFromNumber() {
    print('here');
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
    // TODO: implement initState
    cardNumberController.addListener(() {
      getCardTypeFromNumber();
    },);
    // Update the cardNumberController with scannedCardNumber if it's not null or empty
    if (scannedCardNumber != null && scannedCardNumber!.isNotEmpty) {
      setScannedCardNumberType();
    }
    super.initState();
    createOpenBox();
  }

  void createOpenBox()async{
    box_cards = await Hive.openBox('credit_cards');
  }

  Future<bool> validateCountry() async {

    //CHECK FOR COUNTRY IN BANNED LIST
    box_banned = await Hive.openBox('banned_countries');

    for (var key in box_banned.keys) {
      // Retrieve the value associated with the current key
      var value = box_banned.get(key);

      // Print the key-value pair
      print('$key: $value');

      if(value['country'] == cardCountryController.text.trim()) {
        print('the selected country is indeed banned');
        return true;
      }
    }

    return false;
  }

  Future<bool> saveData(BuildContext context) async {

    Future<bool> banned;
    box_cards = await Hive.openBox('credit_cards');

    //VALIDATE FOR BANNED COUNTRY
    bool isBanned = await validateCountry();

    if (isBanned) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Credit cards are banned from the country you selected.')));
      return false;
    }

    //CLEAN NUMBER
    String cleanCardNumber = CardUtils.getCleanedNumber(cardNumberController.text);
    //VALIDATE FOR EXISTING NUMBER
    for (var key in box_cards.keys) {
      // Retrieve the value associated with the current key
      var value = box_cards.get(key);

      // Print the key-value pair
      print('$key: $value');

      //CHECK FOR UNIQUE EMAIL AND PASSWORD
      if(value['number'] == cleanCardNumber) {
        print('found a duplicate');

        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('A credit card is already captured for the number you entered.')));
        return false;
      }
    }

    Map<String, dynamic> cardValues = {
      // Adding multiple values to a key using a List
      'session': sessionId,
      'number': cleanCardNumber,
      'type': cardTypeController.text.trim(),
      'cvv': cardCVVController.text.trim(),
      'expiry': cardExpiryController.text.trim(),
      'country': cardCountryController.text.trim()
    };

    box_cards.add(cardValues);
    await box_cards.close();
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('The credit card you captured has been successfully saved.')));
    return true;
  }

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
                child: Text( "Add Credit Card",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    // Customize the content text style if needed
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
                        readOnly: scannedCardNumber != null && scannedCardNumber!.isNotEmpty,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
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
                      padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
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
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                // Limit the input
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
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(5),
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
                            // Additional validation checks can be done here
                            return null; // Return null for valid input
                          },
                        );
                      },
                      onSelected: (Country selection) {
                        print('Selected: ${selection.name}');
                        cardCountryController.text = selection.name; // Set the selected country name in the controller
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
                            if (_formKey.currentState!.validate()) {
                              bool isSaved = await saveData(context);
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

  @override
  void dispose() {
    cardNumberController.dispose();
    cardTypeController.dispose();
    cardCVVController.dispose();
    cardExpiryController.dispose();
    cardCountryController.dispose();
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

  /// With the card number with Luhn Algorithm
  /// https://en.wikipedia.org/wiki/Luhn_algorithm
  static String? validateCardNum(String? input) {
    if (input == null || input.isEmpty) {
      return "This field is required";
    }
    input = getCleanedNumber(input);

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
      return null;
    }
    return "Card is invalid";
  }

  static String? validateCVV(String? value) {
    if (value == null || value.isEmpty) {
      return "This field is required";
    }
    if (value.length < 3 || value.length > 4) {
      return "CVV is invalid";
    }
    return null;
  }

  static String? validateDate(String? value) {
    if (value == null || value.isEmpty) {
      return "This field is required";
    }
    int year;
    int month;
    if (value.contains(RegExp(r'(/)'))) {
      var split = value.split(RegExp(r'(/)'));

      month = int.parse(split[0]);
      year = int.parse(split[1]);
    } else {

      month = int.parse(value.substring(0, (value.length)));
      year = -1; // Lets use an invalid year intentionally
    }
    if ((month < 1) || (month > 12)) {
      // A valid month is between 1 (January) and 12 (December)
      return 'Expiry month is invalid';
    }
    var fourDigitsYear = convertYearTo4Digits(year);
    if ((fourDigitsYear < 1) || (fourDigitsYear > 2099)) {
      // We are assuming a valid should be between 1 and 2099.
      // Note that, it's valid doesn't mean that it has not expired.
      return 'Expiry year is invalid';
    }
    if (!hasDateExpired(month, year)) {
      return "Card has expired";
    }
    return null;
  }

  /// Convert the two-digit year to four-digit year if necessary
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
    // It has not expired if both the year and date has not passed
    return !hasYearPassed(year) && !hasMonthPassed(year, month);
  }

  static List<int> getExpiryDate(String value) {
    var split = value.split(RegExp(r'(/)'));
    return [int.parse(split[0]), int.parse(split[1])];
  }

  static bool hasMonthPassed(int year, int month) {
    var now = DateTime.now();
    // The month has passed if:
    // 1. The year is in the past. In that case, we just assume that the month
    // has passed
    // 2. Card's month (plus another month) is more than current month.
    return hasYearPassed(year) ||
        convertYearTo4Digits(year) == now.year && (month < now.month + 1);
  }
  
  static bool hasYearPassed(int year) {
    int fourDigitsYear = convertYearTo4Digits(year);
    var now = DateTime.now();
    // The year has passed if the year we are currently is more than card's
    // year
    return fourDigitsYear < now.year;
  }
}

class Country {

  const Country({
    required this.name
  });

  final String name;

  @override
  String toString() {
    return '$name()';
  }
}

const List<Country> countryOptions = <Country>[
  Country(name: 'Algeria'),
  Country(name: 'Angola'),
  Country(name: 'Benin'),
  Country(name: 'Botswana'),
  Country(name: 'Burkina Faso'),
  Country(name: 'Burundi'),
  Country(name: 'Cabo Verde'),
  Country(name: 'Cameroon'),
  Country(name: 'Central African Republic'),
  Country(name: 'Chad'),
  Country(name: 'Comoros'),
  Country(name: 'Congo (Brazzaville)'),
  Country(name: 'Congo (Kinshasa)'),
  Country(name: 'Cote d\'Ivoire\''),
  Country(name: 'Djibouti'),
  Country(name: 'Egypt'),
  Country(name: 'Equatorial Guinea'),
  Country(name: 'Eritrea'),
  Country(name: 'Eswatini (formerly Swaziland)'),
  Country(name: 'Ethiopia'),
  Country(name: 'Gabon'),
  Country(name: 'Gambia'),
  Country(name: 'Ghana'),
  Country(name: 'Guinea'),
  Country(name: 'Guinea-Bissau'),
  Country(name: 'Kenya'),
  Country(name: 'Lesotho'),
  Country(name: 'Liberia'),
  Country(name: 'Libya'),
  Country(name: 'Madagascar'),
  Country(name: 'Malawi'),
  Country(name: 'Mali'),
  Country(name: 'Mauritania'),
  Country(name: 'Mauritius'),
  Country(name: 'Morocco'),
  Country(name: 'Mozambique'),
  Country(name: 'Namibia'),
  Country(name: 'Niger'),
  Country(name: 'Nigeria'),
  Country(name: 'Rwanda'),
  Country(name: 'Sao Tome and Principe'),
  Country(name: 'Senegal'),
  Country(name: 'Seychelles'),
  Country(name: 'Sierra Leone'),
  Country(name: 'Somalia'),
  Country(name: 'South Africa'),
  Country(name: 'South Sudan'),
  Country(name: 'Sudan'),
  Country(name: 'Tanzania'),
  Country(name: 'Togo'),
  Country(name: 'Tunisia'),
  Country(name: 'Uganda'),
  Country(name: 'Zambia'),
  Country(name: 'Zimbabwe'),
  Country(name: 'Afghanistan'),
  Country(name: 'Armenia'),
  Country(name: 'Azerbaijan'),
  Country(name: 'Bahrain'),
  Country(name: 'Bangladesh'),
  Country(name: 'Bhutan'),
  Country(name: 'Brunei'),
  Country(name: 'Cambodia'),
  Country(name: 'China'),
  Country(name: 'Cyprus'),
  Country(name: 'Georgia'),
  Country(name: 'India'),
  Country(name: 'Indonesia'),
  Country(name: 'Iran'),
  Country(name: 'Iraq'),
  Country(name: 'Israel'),
  Country(name: 'Japan'),
  Country(name: 'Jordan'),
  Country(name: 'Kazakhstan'),
  Country(name: 'North Korea'),
  Country(name: 'South Korea'),
  Country(name: 'Kuwait'),
  Country(name: 'Kyrgyzstan'),
  Country(name: 'Laos'),
  Country(name: 'Lebanon'),
  Country(name: 'Malaysia'),
  Country(name: 'Maldives'),
  Country(name: 'Mongolia'),
  Country(name: 'Myanmar (Burma)'),
  Country(name: 'Nepal'),
  Country(name: 'Oman'),
  Country(name: 'Pakistan'),
  Country(name: 'Palestine'),
  Country(name: 'Philippines'),
  Country(name: 'Qatar'),
  Country(name: 'Saudi Arabia'),
  Country(name: 'Singapore'),
  Country(name: 'Sri Lanka'),
  Country(name: 'Syria'),
  Country(name: 'Tajikistan'),
  Country(name: 'Thailand'),
  Country(name: 'Timor-Leste'),
  Country(name: 'Turkey'),
  Country(name: 'Turkmenistan'),
  Country(name: 'United Arab Emirates (UAE)'),
  Country(name: 'Uzbekistan'),
  Country(name: 'Vietnam'),
  Country(name: 'Yemen'),
  Country(name: 'Albania'),
  Country(name: 'Andorra'),
  Country(name: 'Austria'),
  Country(name: 'Belarus'),
  Country(name: 'Belgium'),
  Country(name: 'Bosnia and Herzegovina'),
  Country(name: 'Bulgaria'),
  Country(name: 'Croatia'),
  Country(name: 'Cyprus'),
  Country(name: 'Czech Republic'),
  Country(name: 'Denmark'),
  Country(name: 'Estonia'),
  Country(name: 'Finland'),
  Country(name: 'France'),
  Country(name: 'Germany'),
  Country(name: 'Greece'),
  Country(name: 'Hungary'),
  Country(name: 'Iceland'),
  Country(name: 'Ireland'),
  Country(name: 'Italy'),
  Country(name: 'Kosovo'),
  Country(name: 'Latvia'),
  Country(name: 'Liechtenstein'),
  Country(name: 'Lithuania'),
  Country(name: 'Luxembourg'),
  Country(name: 'Malta'),
  Country(name: 'Moldova'),
  Country(name: 'Monaco'),
  Country(name: 'Montenegro'),
  Country(name: 'Netherlands'),
  Country(name: 'North Macedonia'),
  Country(name: 'Norway'),
  Country(name: 'Poland'),
  Country(name: 'Portugal'),
  Country(name: 'Romania'),
  Country(name: 'Russia'),
  Country(name: 'San Marino'),
  Country(name: 'Serbia'),
  Country(name: 'Slovakia'),
  Country(name: 'Slovenia'),
  Country(name: 'Spain'),
  Country(name: 'Sweden'),
  Country(name: 'Switzerland'),
  Country(name: 'Ukraine'),
  Country(name: 'United Kingdom (UK)'),
  Country(name: 'Mexico'),
  Country(name: 'Canada'),
  Country(name: 'United States of America (USA)'),
  Country(name: 'Australia'),
  Country(name: 'Fiji'),
  Country(name: 'Kiribati'),
  Country(name: 'Marshall Islands'),
  Country(name: 'Micronesia'),
  Country(name: 'Nauru'),
  Country(name: 'New Zealand'),
  Country(name: 'Palau'),
  Country(name: 'Papua New Guinea'),
  Country(name: 'Samoa'),
  Country(name: 'Solomon Islands'),
  Country(name: 'Tonga'),
  Country(name: 'Tuvalu'),
  Country(name: 'Vanuatu'),
  Country(name: 'Argentina'),
  Country(name: 'Bolivia'),
  Country(name: 'Brazil'),
  Country(name: 'Chile'),
  Country(name: 'Colombia'),
  Country(name: 'Ecuador'),
  Country(name: 'Guyana'),
  Country(name: 'Paraguay'),
  Country(name: 'Peru'),
  Country(name: 'Suriname'),
  Country(name: 'Uruguay'),
  Country(name: 'Venezuela'),
];




