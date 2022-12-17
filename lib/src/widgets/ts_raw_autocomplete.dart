import 'package:flutter/material.dart';
import 'package:javniPrevoz/src/type/station.dart';

typedef Iterable<Station> StringCallback(String query);
typedef void StationCallback(Station station);

class TsRawAutocomplete extends StatelessWidget {
  final TextEditingController textEditingControllerInput;
  final FocusNode focusNodeAuto;
  final GlobalKey _autocompleteKey = GlobalKey();
  final IconData icon;
  final StringCallback onSearchQuery;
  final String placeholder;
  final StationCallback onItemSelected;
  final Key autoKey;
  final GlobalKey formFieldKey;
  final Station selectedValue;

  final List<String> _options = <String>[
    'aardvark',
    'bobcat',
    'chameleon',
  ];

  TsRawAutocomplete({
    required this.autoKey,
    required this.formFieldKey,
    required this.textEditingControllerInput,
    required this.icon,
    required this.onSearchQuery,
    required this.placeholder,
    required this.onItemSelected,
    required this.focusNodeAuto,
    required this.selectedValue,
  });

  void clear() {
    textEditingControllerInput.clear();
  }

  @override
  Widget build(BuildContext context) {
    return RawAutocomplete<Station>(
      key: autoKey,
      focusNode: focusNodeAuto,
      // initialValue: TextEditingValue(),
      onSelected: onItemSelected,
      textEditingController: textEditingControllerInput,
      displayStringForOption: (option) => option.POS_NAZ,
      fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
        print('BLA');
        print(focusNode);
        return TextFormField(
          key: formFieldKey,
          validator: (value) {
            if (controller.text == "" || controller.text != selectedValue.POS_NAZ) {
              print('${placeholder}: ${controller.text}, ${selectedValue.POS_NAZ}');
              return 'Izberite veljavno postajo!';
            }
            ;
          },
          decoration: InputDecoration(
            icon: Icon(
              icon,
              size: 20,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            hintText: placeholder,
            isDense: true,
          ),
          controller: controller,
          focusNode: focusNode,
          onEditingComplete: onEditingComplete,
        );
        // TextField(
        //   key: formFieldKey,
        //   decoration: InputDecoration(
        //     icon: Icon(icon),
        //     border: OutlineInputBorder(
        //       borderRadius: BorderRadius.circular(30),
        //     ),
        //     hintText: placeholder,
        //     isDense: true,
        //   ),
        //   controller: controller,
        //   focusNode: focusNode,
        //   onEditingComplete: onEditingComplete,
        // );
      },
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.length < 3 || selectedValue.POS_NAZ == textEditingValue.text) {
          return const Iterable<Station>.empty();
        }
        return onSearchQuery(textEditingValue.text);
      },
      optionsViewBuilder: (BuildContext context, AutocompleteOnSelected<Station> onSelected, Iterable<Station> options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4.0,
            child: Container(
              constraints: BoxConstraints(
                maxHeight: 200,
              ),
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.all(8.0),
                itemCount: options.length,
                itemBuilder: (BuildContext context, int index) {
                  final Station option = options.elementAt(index);
                  return GestureDetector(
                    onTap: () {
                      onSelected(option);
                    },
                    child: ListTile(
                      title: Text(option.POS_NAZ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
