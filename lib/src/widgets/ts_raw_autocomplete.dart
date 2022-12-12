import 'package:flutter/material.dart';

class TsRawAutocomplete extends StatelessWidget {
  final TextEditingController textEditingControllerInput;
  final FocusNode _focusNode = FocusNode();
  final GlobalKey _autocompleteKey = GlobalKey();
  final IconData icon;

  final List<String> _options = <String>[
    'aardvark',
    'bobcat',
    'chameleon',
  ];

  TsRawAutocomplete({Key? key, required this.textEditingControllerInput, required this.icon})
      : super(key: key);

  void clear() {
    textEditingControllerInput.clear();
  }

  @override
  Widget build(BuildContext context) {
    return RawAutocomplete<String>(
      focusNode: _focusNode,
      onSelected: (option) {
        print(textEditingControllerInput);
      },
      textEditingController: textEditingControllerInput,
      fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
        return TextField(
          decoration: InputDecoration(
            icon: Icon(icon),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            hintText: 'From',
            isDense: true,
          ),
          controller: controller,
          focusNode: focusNode,
          onEditingComplete: onEditingComplete,
        );
      },
      // fieldViewBuilder: (BuildContext context, TextEditingController textEditingController,
      //     FocusNode focusNode, VoidCallback onFieldSubmitted) {
      //   return TextFormField(
      //     controller: textEditingController,
      //     focusNode: focusNode,
      //     onFieldSubmitted: (String value) {
      //       onFieldSubmitted();
      //     },
      //   );
      // },
      optionsBuilder: (TextEditingValue textEditingValue) {
        // return _options.where((String option) {
        //   return option.contains(textEditingValue.text.toLowerCase());
        // });
        if (textEditingValue.text.length < 3) {
          return const Iterable<String>.empty();
        }
        return _options.where((String option) {
          return option.contains(textEditingValue.text.toLowerCase());
          // removeSumniki(option.POS_NAZ.toLowerCase())
          //     .contains(removeSumniki(query.toLowerCase()));
        });
      },
      optionsViewBuilder: (BuildContext context, AutocompleteOnSelected<String> onSelected,
          Iterable<String> options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4.0,
            child: SizedBox(
              height: 200.0,
              child: ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: options.length,
                itemBuilder: (BuildContext context, int index) {
                  final String option = options.elementAt(index);
                  return GestureDetector(
                    onTap: () {
                      onSelected(option);
                    },
                    child: ListTile(
                      title: Text(option),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
    // return RawAutocomplete<String>(
    //   key: _autocompleteKey,
    //   focusNode: _focusNode,
    //   textEditingController: _textEditingController,
    //   optionsBuilder: (TextEditingValue textEditingValue) {
    //     return _options.where((String option) {
    //       return option.contains(textEditingValue.text.toLowerCase());
    //     }).toList();
    //   },
    //   optionsViewBuilder: (BuildContext context, AutocompleteOnSelected<String> onSelected,
    //       Iterable<String> options) {
    //     return Material(
    //       elevation: 4.0,
    //       child: ListView(
    //         children: options
    //             .map((String option) => GestureDetector(
    //                   onTap: () {
    //                     onSelected(option);
    //                   },
    //                   child: ListTile(
    //                     title: Text(option),
    //                   ),
    //                 ))
    //             .toList(),
    //       ),
    //     );
    //   },
    // );
  }
}
