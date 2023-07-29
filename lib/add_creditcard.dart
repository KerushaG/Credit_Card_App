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

  }

  @override
  void dispose() {
    cardNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text("Credit Card Submissions")),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ListView(
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
                    Autocomplete<Country>(
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        return countryOptions
                            .where((Country continent) => continent.name.toLowerCase()
                            .startsWith(textEditingValue.text.toLowerCase())
                        )
                            .toList();
                      },
                      displayStringForOption: (Country option) => option.name,
                      fieldViewBuilder: (
                          BuildContext context,
                          TextEditingController countryController,
                          FocusNode fieldFocusNode,
                          VoidCallback onFieldSubmitted
                          ) {
                        return TextField(
                          controller: countryController,
                          decoration: const InputDecoration(hintText: "Issuing Country"),
                          focusNode: fieldFocusNode,
                        );
                      },
                      onSelected: (Country selection) {
                        print('Selected: ${selection.name}');
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




