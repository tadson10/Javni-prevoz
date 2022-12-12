import 'package:flutter/material.dart';
import 'package:javniPrevoz/src/api/arriva_api.dart';
import 'package:javniPrevoz/src/type/station.dart';

// Step 1: Define a Callback.
typedef void StationCallback(Station station);
typedef Iterable<Station> StringCallback(String query);
typedef Station StationSelected();

class TsAutocomplete extends StatefulWidget {
  final StationCallback onItemSelected;
  final StringCallback onSearchQuery;
  final StationSelected getStationSelected;
  final IconData icon;
  final String placeholder;
  final GlobalKey formFieldKey;
  final Key autoKey;

  TsAutocomplete({
    required this.autoKey,
    required this.onItemSelected,
    required this.onSearchQuery,
    required this.icon,
    required this.placeholder,
    required this.formFieldKey,
    required this.getStationSelected,
  });

  static String _displayStringForOption(Station option) => '${option.POS_NAZ}';

  @override
  State<TsAutocomplete> createState() => _TsAutocompleteState();
}

class _TsAutocompleteState extends State<TsAutocomplete> {
  @override
  Widget build(BuildContext context) {
    return Autocomplete<Station>(
      key: widget.autoKey,
      displayStringForOption: TsAutocomplete._displayStringForOption,
      optionsBuilder: (TextEditingValue textEditingValue) {
        return widget.onSearchQuery(textEditingValue.text);
      },
      onSelected: (Station selection) {
        debugPrint('You just selected $selection');
        widget.onItemSelected(selection);
      },
      fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
        return TextFormField(
          key: widget.formFieldKey,
          validator: (value) {
            if (controller.text == "" || controller.text != widget.getStationSelected().POS_NAZ) {
              print('${widget.placeholder}: ${controller.text}, ${widget.getStationSelected().POS_NAZ}');
              return 'Izberite veljavno postajo!';
            }
            ;
          },
          decoration: InputDecoration(
            icon: Icon(
              widget.icon,
              size: 20,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            hintText: widget.placeholder,
            isDense: true,
          ),
          controller: controller,
          focusNode: focusNode,
          onEditingComplete: onEditingComplete,
        );
      },
    );
  }
}
