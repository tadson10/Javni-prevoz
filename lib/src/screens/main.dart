// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';
import 'package:javniPrevoz/src/screens/departure_list.dart';
import 'package:javniPrevoz/src/type/departure.dart';
import 'package:javniPrevoz/src/type/favourite.dart';
import 'package:javniPrevoz/src/widgets/ts_raw_autocomplete.dart';
import '../api/arriva_api.dart';
import '../widgets/ts_autocomplete.dart';
import 'package:javniPrevoz/src/type/station.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  runApp(MaterialApp(
    home: MyWidget(),
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    supportedLocales: const [
      Locale('sl', 'SI'),
      Locale('en', 'GB'),
    ],
  ));
}

class MyWidget extends StatefulWidget {
  const MyWidget({super.key});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  List<Station> _stations = <Station>[];
  Station _fromStation = Station(JPOS_IJPP: -1, POS_NAZ: '');
  Station _toStation = Station(JPOS_IJPP: -1, POS_NAZ: '');
  TextEditingController dateController = TextEditingController();
  List<Departure> _departures = <Departure>[];
  bool _isSwapped = false;
  final _formKey = GlobalKey<FormState>();
  final _fromFieldKey = GlobalKey<FormFieldState>();
  final _toFieldKey = GlobalKey<FormFieldState>();
  final _fromAutoKey = GlobalKey();
  final _toAutoKey = GlobalKey();
  List<Favourite> _favourites = <Favourite>[];
  final _stackKey = GlobalKey();
  double _swapBtnOffset = 48;

  TextEditingController _textEditingControllerFrom = TextEditingController();
  TextEditingController _textEditingControllerTo = TextEditingController();
  final FocusNode _focusNodeFrom = FocusNode();
  final FocusNode _focusNodeTo = FocusNode();

  void showError(BuildContext context, String error) {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Napaka'),
        content: new Text(error),
        actions: <Widget>[
          TextButton(
            onPressed: () => exit(0),
            child: const Text('Zapri'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, 'Poskusi znova');
              pridobiPostaje();
            },
            child: const Text('Poskusi znova'),
          ),
        ],
      ),
    );
  }

  void setStations(List<Station> stations) {
    setState(() {
      _stations = stations;
    });
  }

  void setFromStation(Station fromStation) {
    setState(() {
      _fromStation = fromStation;
    });
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _fromFieldKey.currentState!.validate();
    });
  }

  void setToStation(Station toStation) {
    setState(() {
      _toStation = toStation;
    });
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _toFieldKey.currentState!.validate();
    });
  }

  void setDepartures(List<Departure> departures) {
    setState(() {
      _departures = departures;
    });
  }

  void setIsSwapped(bool isSwapped) {
    setState(() {
      _isSwapped = isSwapped;
    });
  }

  void swapStations() {
    // Swap from and to station selected values
    var tmp_from = _fromStation;
    setFromStation(_toStation);
    setToStation(tmp_from);
    // Swap texts inside input fields
    _textEditingControllerFrom.text = _fromStation.POS_NAZ;
    _textEditingControllerTo.text = _toStation.POS_NAZ;
    // Save current stations to Shared preferences
    _saveCurrentStations();
  }

  Route _createRoute(fromStation, toStation) {
    String formattedDate = new DateFormat('d. MM. yyyy').parse(dateController.text).toString().split(' ')[0];

    return PageRouteBuilder(
      transitionDuration: Duration(milliseconds: 500),
      reverseTransitionDuration: Duration(milliseconds: 500),
      pageBuilder: (context, animation, secondaryAnimation) => DepartureList(
        fromToStations: [
          Station(JPOS_IJPP: fromStation.JPOS_IJPP, POS_NAZ: fromStation.POS_NAZ),
          Station(JPOS_IJPP: toStation.JPOS_IJPP, POS_NAZ: toStation.POS_NAZ)
        ],
        formattedDate: formattedDate,
        date: dateController.text,
      ),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.ease;

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  void searchBtnPress() {
    // Validate selected stations
    if (_formKey.currentState!.validate()) {
      // Add to favourites
      _addFavourites();
      // Hide keyboard
      FocusScope.of(context).requestFocus(new FocusNode());
      // Switch to departures screen
      goToDepListScreen(_fromStation, _toStation);
    }
  }

  // Show Departures list on favourite select
  void goToDepListScreen(fromStation, toStation) {
    FocusScope.of(context).requestFocus(new FocusNode());
    setCurrentStations(fromStation, toStation);
    _saveCurrentStations();
    Navigator.of(context).push(_createRoute(fromStation, toStation));
  }

  // Set currently selected stations
  void setCurrentStations(fromStation, toStation) {
    _textEditingControllerFrom.text = fromStation.POS_NAZ;
    _textEditingControllerTo.text = toStation.POS_NAZ;
    setFromStation(fromStation);
    setToStation(toStation);
  }

  void pridobiPostaje() {
    ArrivaApi.getStations('').then((value) {
      if (value.length == 0) {
        showError(context, 'Težava pri komunikaciji s strežniki. Prosimo, poskusite kasneje!');
      } else
        setStations(value);
    });
  }

  String removeSumniki(String text) {
    text = text.replaceAll('š', 's').replaceAll('č', 'c').replaceAll('ć', 'c').replaceAll('ž', 'z');
    return text;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print("WidgetsBinding");
      pridobiPostaje();
    });

    SchedulerBinding.instance.addPostFrameCallback((_) {
      calcSwapBtnOffset();
    });

    // Read from Shared Preferences
    _loadFavourites();
    _loadCurrentStations();

    // Get all stations on init
    setState(() {
      dateController.text = new DateFormat('d. MM. yyyy').format(DateTime.now());
    });
  }

  Iterable<Station> onSearch(String query) {
    if (query.length < 3) {
      return const Iterable<Station>.empty();
    }
    return _stations.where((Station option) {
      return removeSumniki(option.POS_NAZ.toLowerCase()).contains(removeSumniki(query.toLowerCase()));
    });
  }

  Iterable<Station> onFromSearchQuery(String query) {
    return onSearch(query);
  }

  Iterable<Station> onToSearchQuery(String query) {
    return onSearch(query);
  }

  void onFromItemSelected(Station selected) {
    setFromStation(selected);
    _saveCurrentStations();
  }

  void onToItemSelected(Station selected) {
    setToStation(selected);
    _saveCurrentStations();
  }

  Station getFromSelectedItem() {
    return _fromStation;
  }

  Station getToSelectedItem() {
    return _toStation;
  }

  void calcSwapBtnOffset() {
    final RenderBox renderBoxFrom = _fromFieldKey.currentContext?.findRenderObject() as RenderBox;
    final Size sizeFrom = renderBoxFrom.size;
    final Offset offsetFrom = renderBoxFrom.localToGlobal(Offset.zero);

    final RenderBox renderBoxTo = _toFieldKey.currentContext?.findRenderObject() as RenderBox;
    final Offset offsetTo = renderBoxTo.localToGlobal(Offset.zero);

    _swapBtnOffset =
        ((offsetTo.dy - offsetFrom.dy + sizeFrom.height / 2 + (offsetTo.dy - offsetFrom.dy - sizeFrom.height)) / 2)
            .roundToDouble(); // To_y - From_y + height/2 + razmik_med_inputoma/2
  }

  @override
  Widget build(BuildContext context) {
    print('build');
    var fromStationWidget = TsRawAutocomplete(
        autoKey: _fromAutoKey,
        formFieldKey: _fromFieldKey,
        textEditingControllerInput: _textEditingControllerFrom,
        icon: Icons.my_location,
        onSearchQuery: onFromSearchQuery,
        placeholder: 'Vstopna postaja',
        onItemSelected: onFromItemSelected,
        focusNodeAuto: _focusNodeFrom,
        selectedValue: _fromStation);

    var toStationWidget = TsRawAutocomplete(
        autoKey: _toAutoKey,
        formFieldKey: _toFieldKey,
        textEditingControllerInput: _textEditingControllerTo,
        icon: Icons.location_on,
        onSearchQuery: onToSearchQuery,
        placeholder: 'Izstopna postaja',
        onItemSelected: onToItemSelected,
        focusNodeAuto: _focusNodeTo,
        selectedValue: _toStation);

    return Form(
      key: _formKey,
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: PreferredSize(
              preferredSize: Size.fromHeight(50.0),
              child: AppBar(
                title: Text('Arriva'),
                centerTitle: true,
                backgroundColor: Colors.blueAccent,
              )),
          body: SingleChildScrollView(
            child: Stack(key: _stackKey, children: [
              Padding(
                padding: EdgeInsets.fromLTRB(15, 20, 15, 0),
                child: Column(children: <Widget>[
                  fromStationWidget,
                  SizedBox(
                    height: 10.0,
                  ),
                  toStationWidget,
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextField(
                      controller: dateController,
                      decoration: const InputDecoration(icon: Icon(Icons.calendar_today)),
                      readOnly: true,
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateFormat('d. MM. yyyy').parse(dateController.text),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                          locale: Locale('sl', 'GB'),
                        );
                        if (pickedDate != null) {
                          String formattedDate = DateFormat('d. MM. yyyy').format(pickedDate);
                          setState(() {
                            dateController.text = formattedDate;
                          });
                        } else {
                          print("Date is not selected");
                        }
                      },
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    height: 40,
                    width: 200,
                    child: ElevatedButton.icon(
                      style: ButtonStyle(
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                          backgroundColor: MaterialStateProperty.all<Color>(Colors.blueAccent)),
                      onPressed: () {
                        searchBtnPress();
                      },
                      icon: Icon(
                        Icons.search,
                        size: 24.0,
                      ),
                      label: Text('Prikaži'),
                    ),
                  ),
                  SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Zadnja iskanja',
                      style: TextStyle(fontSize: 20, color: Colors.grey[600]),
                    ),
                  ),
                  _favourites.isEmpty
                      ? Column(
                          children: [
                            SizedBox(
                              height: 100,
                            ),
                            Text('Prazen seznam')
                          ],
                        )
                      : Column(
                          children: [
                            SizedBox(
                              height: 10,
                            ),
                            for (var fav in _favourites) favouriteTemplate(fav),
                            SizedBox(height: 10),
                          ],
                        )
                ]),
              ),
              Positioned(
                top: _swapBtnOffset,
                left: MediaQuery.of(context).size.width * 0.71,
                child: FloatingActionButton(
                  heroTag: 'btnSwap',
                  child: Icon(Icons.swap_vert),
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    swapStations();
                  },
                  backgroundColor: Colors.blueAccent,
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  /* SHARED PREFERENCES */
  Future<void> _saveCurrentStations() async {
    print('SAVE');
    String stations = jsonEncode([_fromStation, _toStation]);
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('stations', stations);
  }

  Future<void> _loadCurrentStations() async {
    final prefs = await SharedPreferences.getInstance();
    // await prefs.clear();
    final List stationsList = json.decode(prefs.getString('stations') ?? '[]');
    print('LOAD');
    print(stationsList);
    setState(() {
      List lst = stationsList.map<Station>((json) => Station.fromJson(json)).toList();
      if (lst.length > 0) {
        setCurrentStations(lst[0], lst[1]);
      }
    });
  }

  Future<void> _addFavourites() async {
    Favourite newFav = Favourite(
        fromName: _fromStation.POS_NAZ,
        fromId: _fromStation.JPOS_IJPP,
        toName: _toStation.POS_NAZ,
        toId: _toStation.JPOS_IJPP);
    Favourite fav = _favourites.singleWhere((it) => it.fromId == newFav.fromId && it.toId == newFav.toId,
        orElse: () => Favourite(fromId: -1, fromName: '', toId: -1, toName: ''));
    if (fav.fromId == -1) {
      _favourites.insert(0, newFav);
      if (_favourites.length > 10) _favourites.removeLast();
      _saveFavourites();
    }
  }

  Future<void> _saveFavourites() async {
    String favouritesString = jsonEncode(_favourites);
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('favourites', favouritesString);
  }

  Future<void> _loadFavourites() async {
    final prefs = await SharedPreferences.getInstance();
    // await prefs.clear();
    final List favouritesList = json.decode(prefs.getString('favourites') ?? '[]');
    setState(() {
      _favourites = favouritesList.map<Favourite>((json) => Favourite.fromJson(json)).toList();
    });
  }

  // Favourite item template
  Widget favouriteTemplate(Favourite favourite) {
    print(favourite.toString());
    return Column(children: [
      Dismissible(
          // Each Dismissible must contain a Key. Keys allow Flutter to
          // uniquely identify widgets.
          key: Key('${favourite.fromName}${favourite.toName}'),
          direction: DismissDirection.endToStart,
          onDismissed: (direction) {
            setState(() {
              _favourites.removeWhere(
                  (element) => element.fromName == favourite.fromName && element.toName == favourite.toName);
            });
            _saveFavourites();

            // Then show a snackbar.
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Relacija odstranjena iz seznama!')));
          },
          background: Container(
              decoration: BoxDecoration(
                // borderRadius: BorderRadius.circular(10),
                color: Colors.red,
              ),
              child: Row(
                children: const [
                  SizedBox(
                    width: 270,
                  ),
                  Icon(
                    Icons.delete_forever,
                    size: 40,
                    color: Colors.white,
                  ),
                ],
              )),
          child: Card(
            shadowColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: Colors.blueAccent,
              ),
            ),
            // color: Colors.white,
            // margin: const EdgeInsets.fromLTRB(0.0, 16.0, 0.0, 0),
            child: InkWell(
              highlightColor: Colors.grey[300],
              borderRadius: BorderRadius.circular(20),
              onTapDown: (details) => {print('DOWN')},
              onTap: () => {
                goToDepListScreen(Station(JPOS_IJPP: favourite.fromId, POS_NAZ: favourite.fromName),
                    Station(JPOS_IJPP: favourite.toId, POS_NAZ: favourite.toName))
              },
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Row(children: <Widget>[
                      Icon(
                        Icons.my_location,
                        size: 15,
                        color: Colors.blueAccent,
                      ),
                      SizedBox(
                        width: 5.0,
                      ),
                      Text(
                        '${favourite.fromName}',
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.grey[800],
                        ),
                      ),
                    ]),
                    Row(
                      children: const [
                        Icon(
                          Icons.more_vert,
                          size: 15,
                          color: Colors.blueAccent,
                        ),
                      ],
                    ),
                    // ),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 15,
                          color: Colors.blueAccent,
                        ),
                        SizedBox(
                          width: 5.0,
                        ),
                        Text(
                          '${favourite.toName}',
                          style: TextStyle(
                            fontSize: 16.0,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          )),
    ]);
  }
}
