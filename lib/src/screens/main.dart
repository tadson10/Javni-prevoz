// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';
import 'package:javniPrevoz/src/screens/departure_list.dart';
import 'package:javniPrevoz/src/type/departure.dart';
import 'package:javniPrevoz/src/type/favourite.dart';
import '../api/arriva_api.dart';
import '../widgets/ts_autocomplete.dart';
import 'package:javniPrevoz/src/type/station.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

void main() {
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
      var tmp = _fromStation;
      _fromStation = _toStation;
      _toStation = tmp;
    });
  }

  Route _createRoute(fromStation, toStation) {
    String formattedDate = new DateFormat('d. MM. yyyy').parse(dateController.text).toString().split(' ')[0];

    return PageRouteBuilder(
      transitionDuration: Duration(milliseconds: 500),
      reverseTransitionDuration: Duration(milliseconds: 500),
      pageBuilder: (context, animation, secondaryAnimation) => DepartureList(
        fromToStations: [Station(JPOS_IJPP: fromStation.JPOS_IJPP, POS_NAZ: fromStation.POS_NAZ), Station(JPOS_IJPP: toStation.JPOS_IJPP, POS_NAZ: toStation.POS_NAZ)],
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
    if (_formKey.currentState!.validate()) {
      _addFavourites();
      FocusScope.of(context).requestFocus(new FocusNode());
      goToDepListScreen(_fromStation, _toStation);
    }
  }

  void goToDepListScreen(fromStation, toStation) {
    Navigator.of(context).push(_createRoute(fromStation, toStation));
  }

  @override
  void initState() {
    super.initState();
    _loadFavourites();
    // Get all stations on init
    setState(() {
      ArrivaApi.getStations('').then((value) {
        setStations(value);
      });
      dateController.text = new DateFormat('d. MM. yyyy').format(DateTime.now());
    });
  }

  String removeSumniki(String text) {
    text = text.replaceAll('š', 's').replaceAll('č', 'c').replaceAll('ć', 'c').replaceAll('ž', 'z');
    return text;
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
  }

  void onToItemSelected(Station selected) {
    setToStation(selected);
  }

  Station getFromSelectedItem() {
    return _fromStation;
  }

  Station getToSelectedItem() {
    return _toStation;
  }

  @override
  Widget build(BuildContext context) {
    print('build');
    var fromStationWidget = TsAutocomplete(
      formFieldKey: _fromFieldKey,
      onSearchQuery: _isSwapped ? onToSearchQuery : onFromSearchQuery,
      onItemSelected: _isSwapped ? onToItemSelected : onFromItemSelected,
      icon: _isSwapped ? Icons.location_on : Icons.my_location,
      placeholder: _isSwapped ? 'Izstopna postaja' : 'Vstopna postaja',
      getStationSelected: _isSwapped ? getToSelectedItem : getFromSelectedItem,
      autoKey: _fromAutoKey,
    );

    var toStationWidget = TsAutocomplete(
      formFieldKey: _toFieldKey,
      onSearchQuery: _isSwapped ? onFromSearchQuery : onToSearchQuery,
      onItemSelected: _isSwapped ? onFromItemSelected : onToItemSelected,
      icon: _isSwapped ? Icons.my_location : Icons.location_on,
      placeholder: _isSwapped ? 'Vstopna postaja' : 'Izstopna postaja',
      getStationSelected: _isSwapped ? getFromSelectedItem : getToSelectedItem,
      autoKey: _toAutoKey,
    );

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
            child: Stack(children: [
              Padding(
                // padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                padding: EdgeInsets.fromLTRB(15, 20, 15, 0),
                child: Column(children: <Widget>[
                  _isSwapped ? toStationWidget : fromStationWidget,
                  SizedBox(
                    height: 10.0,
                  ),
                  _isSwapped ? fromStationWidget : toStationWidget,
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        SizedBox(
                          width: 325,
                          // height: 100,
                          child: TextField(
                            controller: dateController,
                            decoration: const InputDecoration(icon: Icon(Icons.calendar_today)),
                            readOnly: true,
                            onTap: () async {
                              DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateFormat('d. MM. yyyy').parse(dateController.text),
                                firstDate: DateTime(2020),
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
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    height: 40,
                    width: 200,
                    child: ElevatedButton.icon(
                      style: ButtonStyle(shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)))),
                      onPressed: () {
                        searchBtnPress();
                      },
                      icon: Icon(
                        // <-- Icon
                        Icons.search,
                        size: 24.0,
                      ),
                      label: Text('Prikaži'), // <-- Text
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
                top: 45,
                left: 260,
                child: FloatingActionButton(
                  heroTag: 'btnSwap',
                  child: Icon(Icons.swap_vert),
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    setIsSwapped(!_isSwapped);
                  },
                  backgroundColor: Colors.blueAccent,
                ),
              ),
            ]),
          ),
        ),
      ),
    )
        // ],
        ;

    // Stack(children: <Widget>[
    //   Form(
    //     key: _formKey,
    //     child: GestureDetector(
    //       onTap: () {
    //         FocusScope.of(context).requestFocus(new FocusNode());
    //       },
    //       child: Scaffold(
    //         resizeToAvoidBottomInset: false,
    //         appBar: PreferredSize(
    //             preferredSize: Size.fromHeight(50.0),
    //             child: AppBar(
    //               title: Text('Arriva'),
    //               centerTitle: true,
    //               backgroundColor: Colors.blueAccent,
    //             )),
    //         body: Padding(
    //           // padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
    //           padding: EdgeInsets.fromLTRB(15, 20, 15, 0),
    //           child:
    //               // Center(
    //               //   child:
    //               //   SingleChildScrollView(
    //               // child:
    //               ListView(
    //             children: <Widget>[
    //               _isSwapped ? toStationWidget : fromStationWidget,
    //               SizedBox(
    //                 height: 10.0,
    //               ),
    //               _isSwapped ? fromStationWidget : toStationWidget,
    //               // Text('${_fromStation.POS_NAZ}, ${_toStation.POS_NAZ}'),
    //               // Text('${_favourites.length}'),
    //               Align(
    //                 alignment: Alignment.centerLeft,
    //                 child:
    //                     // SizedBox(
    //                     //   width: 150,
    //                     //   height: 100,
    //                     //   child:
    //                     Row(
    //                   children: [
    //                     SizedBox(
    //                       width: 325,
    //                       // height: 100,
    //                       child: TextField(
    //                         controller: dateController,
    //                         decoration: const InputDecoration(icon: Icon(Icons.calendar_today)),
    //                         readOnly: true,
    //                         onTap: () async {
    //                           DateTime? pickedDate = await showDatePicker(
    //                             context: context,
    //                             initialDate: DateFormat('d. MM. yyyy').parse(dateController.text),
    //                             firstDate: DateTime(2020),
    //                             lastDate: DateTime(2100),
    //                             locale: Locale('sl', 'GB'),
    //                           );
    //                           if (pickedDate != null) {
    //                             String formattedDate = DateFormat('d. MM. yyyy').format(pickedDate);
    //                             setState(() {
    //                               dateController.text = formattedDate;
    //                             });
    //                           } else {
    //                             print("Date is not selected");
    //                           }
    //                         },
    //                       ),
    //                     ),
    //                     // SizedBox(
    //                     //   height: 50,
    //                     //   width: 50,
    //                     //   child: FloatingActionButton(
    //                     //     heroTag: 'btnSearch',
    //                     //     child: Icon(Icons.search),
    //                     //     onPressed: searchBtnPress,
    //                     //     backgroundColor: Colors.blueAccent,
    //                     //   ),
    //                     // ),
    //                   ],
    //                 ),
    //                 // ),
    //               ),
    //               SizedBox(
    //                 height: 10,
    //               ),
    //               SizedBox(
    //                 height: 40,
    //                 width: 200,
    //                 child: ElevatedButton.icon(
    //                   style: ButtonStyle(shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)))),
    //                   onPressed: () {
    //                     searchBtnPress();
    //                   },
    //                   icon: Icon(
    //                     // <-- Icon
    //                     Icons.search,
    //                     size: 24.0,
    //                   ),
    //                   label: Text('Prikaži'), // <-- Text
    //                 ),
    //               ),
    //               SizedBox(height: 20),
    //               // Divider(color: Colors.black),
    //               Align(
    //                 alignment: Alignment.centerLeft,
    //                 child: Text(
    //                   'Zadnja iskanja',
    //                   style: TextStyle(fontSize: 20, color: Colors.grey[600]),
    //                 ),
    //               ),
    //               _favourites.isEmpty
    //                   ? Column(
    //                       children: [
    //                         SizedBox(
    //                           height: 100,
    //                         ),
    //                         Text('Prazen seznam')
    //                       ],
    //                     )
    //                   : Column(
    //                       children: [
    //                         SizedBox(
    //                           height: 10,
    //                         ),
    //                         for (var fav in _favourites) favouriteTemplate(fav),
    //                       ],
    //                     )

    //               // Container(
    //               //     margin: EdgeInsets.only(top: 20),
    //               //     decoration: BoxDecoration(
    //               //       border: Border(
    //               //         top: BorderSide(color: Colors.blueGrey),
    //               //         bottom: BorderSide(color: Colors.blueGrey),
    //               //       ),
    //               //       // borderRadius: BorderRadius.circular(20),
    //               //     ),
    //               //     child: SizedBox(
    //               //       height: 270,
    //               //       child: ListView.builder(
    //               //           padding: EdgeInsets.all(0),
    //               //           itemCount: _favourites.length,
    //               //           itemBuilder: (context, index) {
    //               //             final item = _favourites[index];
    //               //             return favouriteTemplate(item, index);
    //               //           }),
    //               //     ),
    //               //   ),
    //             ],
    //           ),
    //           // ),
    //         ),
    //       ),
    //     ),
    //   ),
    //   Positioned(
    //     top: 120,
    //     left: 260,
    //     child: FloatingActionButton(
    //       heroTag: 'btnSwap',
    //       child: Icon(Icons.swap_vert),
    //       onPressed: () {
    //         FocusScope.of(context).unfocus();
    //         setIsSwapped(!_isSwapped);
    //       },
    //       backgroundColor: Colors.blueAccent,
    //     ),
    //   ),
    // ]);
  }

  Future<void> _addFavourites() async {
    Favourite newFav = Favourite(fromName: _fromStation.POS_NAZ, fromId: _fromStation.JPOS_IJPP, toName: _toStation.POS_NAZ, toId: _toStation.JPOS_IJPP);
    Favourite fav = _favourites.singleWhere((it) => it.fromId == newFav.fromId && it.toId == newFav.toId, orElse: () => Favourite(fromId: -1, fromName: '', toId: -1, toName: ''));
    if (fav.fromId == -1) {
      setState(() {
        _favourites.add(newFav);
      });
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

  List<Widget> listFavouriteTemplate(List<Favourite> listFavourite) {
    List<Widget> result = [];
    for (int i = 0; i < listFavourite.length; i++) {
      result.add(favouriteTemplate(listFavourite[i]));
    }
    return result;
  }

  Widget favouriteTemplate(Favourite favourite) {
    print(favourite.toString());
    return Column(children: [
      // if (index == 0)
      //   SizedBox(
      //     height: 5,
      //   ),
      Dismissible(
          // Each Dismissible must contain a Key. Keys allow Flutter to
          // uniquely identify widgets.
          key: Key('${favourite.fromName}${favourite.toName}'),
          // Provide a function that tells the app
          // what to do after an item has been swiped away.
          direction: DismissDirection.endToStart,
          onDismissed: (direction) {
            // Remove the item from the data source.
            setState(() {
              _favourites.removeWhere((element) => element.fromName == favourite.fromName && element.toName == favourite.toName);
            });
            _saveFavourites();

            // Then show a snackbar.
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(' dismissed')));
          },
          background: Container(
              decoration: BoxDecoration(
                // borderRadius: BorderRadius.circular(10),
                color: Colors.red,
              ),
              child: Row(
                children: const [
                  // Padding(
                  //   padding: EdgeInsets.only(right: 200),
                  //   child:
                  SizedBox(
                    width: 270,
                  ),
                  Icon(
                    Icons.delete_forever,
                    size: 40,
                    color: Colors.white,
                  ),
                  // ),
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
              onTap: () => {goToDepListScreen(Station(JPOS_IJPP: favourite.fromId, POS_NAZ: favourite.fromName), Station(JPOS_IJPP: favourite.toId, POS_NAZ: favourite.toName))},
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
      // SizedBox(
      //   height: 5,
      // )
    ]);
  }
}
