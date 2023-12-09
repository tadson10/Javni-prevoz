// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:io';

import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:flutter/material.dart';
import 'package:vozniRed/src/api/arriva_api.dart';
import 'package:vozniRed/src/type/departure.dart';
import 'package:vozniRed/src/type/station.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:intl/intl.dart';
import 'dep_stations_list.dart';
import 'main.dart' as mainScreen;

class DepartureList extends StatefulWidget {
  DepartureList({Key? key, required this.fromToStations, required this.date, required this.formattedDate})
      : super(key: key);

  final List<Station> fromToStations;
  final String date;
  final String formattedDate;

  @override
  State<DepartureList> createState() => _DepartureListState();
}

class _DepartureListState extends State<DepartureList> {
  bool isLoaded = false;
  bool isSwitched = false;
  List<Departure> departures = [];
  final itemController = ItemScrollController();
  int nextDepIndex = 0;

  void showError(BuildContext context, String error) {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Napaka'),
        content: new Text(error),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              context.loaderOverlay.hide();
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Nazaj'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, 'Poskusi znova');
              getDepartures(
                  widget.fromToStations[0].JPOS_IJPP, widget.fromToStations[1].JPOS_IJPP, widget.formattedDate);
            },
            child: const Text('Poskusi znova'),
          ),
        ],
      ),
    );
  }

  void getDepartures(fromStation, toStation, date) {
    Future<dynamic> result = ArrivaApi.getDepartures(fromStation, toStation, date);

    result.then((value) {
      if (value is String) {
        showError(context, 'Težava pri komunikaciji s strežniki.');
      } else {
        departures = value;
        isLoaded = true;
        if (departures.length > 0) {
          setState(() {
            getNextDepIndex();
          });
        }
        context.loaderOverlay.hide();
      }
    });
  }

  // Show Departures list on favourite select
  void goToDepStationsListScreen(Departure departure) {
    FocusScope.of(context).requestFocus(new FocusNode());
    Navigator.of(context).push(_createRoute(departure));
  }

  Route _createRoute(Departure departure) {
    return PageRouteBuilder(
      transitionDuration: Duration(milliseconds: 500),
      reverseTransitionDuration: Duration(milliseconds: 500),
      pageBuilder: (context, animation, secondaryAnimation) => DepartureStationsList(
        departure: departure,
        fromStation: getFromStation().POS_NAZ,
        toStation: getToStation().POS_NAZ,
        date: widget.date,
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

  void initState() {
    super.initState();
    print('initState');
    () async {
      await Future.delayed(Duration.zero);
      context.loaderOverlay.show();
    }();
    getDepartures(widget.fromToStations[0].JPOS_IJPP, widget.fromToStations[1].JPOS_IJPP, widget.formattedDate);
  }

  Station getFromStation() {
    return isSwitched ? widget.fromToStations[1] : widget.fromToStations[0];
  }

  Station getToStation() {
    return isSwitched ? widget.fromToStations[0] : widget.fromToStations[1];
  }

  // Switch stations and get departures
  void switchStations(BuildContext context) {
    context.loaderOverlay.show();
    isLoaded = false;
    isSwitched = !isSwitched;

    int fromStation = getFromStation().JPOS_IJPP;
    int toStation = getToStation().JPOS_IJPP;

    // Get list of departures between the stations for the selected date
    getDepartures(fromStation, toStation, widget.formattedDate);
  }

  double timeToDouble(TimeOfDay myTime) => myTime.hour + myTime.minute / 60.0;

  // Function finds the next departure based on current time
  void getNextDepIndex() {
    String nowString = new DateFormat('d. MM. yyyy').format(DateTime.now()); //'${now.day}. ${now.month}. ${now.year}';
    if (nowString == widget.date) {
      TimeOfDay curTime = TimeOfDay.now();
      double curTimeD = timeToDouble(curTime);
      bool exists = false;
      for (int i = 0; i < departures.length; i++) {
        Departure dep = departures[i];
        TimeOfDay depTime =
            TimeOfDay(hour: int.parse(dep.ROD_IODH.split(":")[0]), minute: int.parse(dep.ROD_IODH.split(":")[1]));
        double depTimeD = timeToDouble(depTime);
        if (depTimeD >= curTimeD) { 
          nextDepIndex = i;
          exists = true;
          break;
        }
      }
      if (!exists) nextDepIndex = departures.length;
    } else {
        nextDepIndex = 0;
    }

    // Scroll to the next departure
    WidgetsBinding.instance.addPostFrameCallback((_) {
      itemController.jumpTo(index: nextDepIndex);
    });
  }

// Creates departure Card
  Widget departureTemplate(departure, index) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: Colors.blueAccent,
        ),
      ),
      color: index < nextDepIndex ? Colors.grey[200] : Colors.white,
      margin: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
      child: InkWell(
        highlightColor: Colors.grey[300],
        borderRadius: BorderRadius.circular(20),
        onTap: () => {goToDepStationsListScreen(departures[index])},
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(children: <Widget>[
                Icon(
                  Icons.my_location,
                  size: 15,
                  color: index < nextDepIndex ? Colors.grey[600] : Colors.blueAccent,
                ),
                SizedBox(
                  width: 5.0,
                ),
                Text(
                  departure.ROD_IODH,
                  style: TextStyle(fontSize: 18.0, color: Colors.grey[800], fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  width: 10.0,
                ),
                Text(
                  '${getFromStation().POS_NAZ}',
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.grey[800],
                  ),
                ),
              ]),
              Row(
                children: [
                  Icon(
                    Icons.more_vert,
                    size: 15,
                    color: index < nextDepIndex ? Colors.grey[600] : Colors.blueAccent,
                  ),
                ],
              ),
              // ),
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 15,
                    color: index < nextDepIndex ? Colors.grey[600] : Colors.blueAccent,
                  ),
                  SizedBox(
                    width: 5.0,
                  ),
                  Text(
                    departure.ROD_IPRI,
                    style: TextStyle(fontSize: 18.0, color: Colors.grey[800], fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    width: 10.0,
                  ),
                  Text(
                    '${getToStation().POS_NAZ}',
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
              Divider(color: Colors.black),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Trajanje: \n${departure.ROD_CAS} min',
                    style: TextStyle(
                      fontSize: 14.0,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(width: 20.0),
                  Text(
                    'Cena: \n${departure.VZCL_CEN} €',
                    style: TextStyle(
                      fontSize: 14.0,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(width: 20.0),
                  Text(
                    'Razdalja: \n${departure.VZCL_CEN} km',
                    style: TextStyle(
                      fontSize: 14.0,
                      color: Colors.grey[600],
                    ),
                  ),
                  if (departure.ROD_PER.length > 0) ...[
                    SizedBox(width: 20.0),
                    Text(
                      'Peron: \n${departure.ROD_PER}',
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Colors.grey[600],
                      ),
                    ),
                  ]
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Column(children: [
            Align(
              alignment: Alignment.centerLeft,
              child: FittedBox(
                fit: BoxFit.fitWidth,
                child: Row(children: [
                  Text(
                    '${getFromStation().POS_NAZ} ',
                  ),
                  SizedBox(
                    height: 30,
                    width: 30,
                    child: FloatingActionButton(
                      heroTag: 'btnSwapH',
                      mini: true,
                      child: Icon(Icons.swap_horiz),
                      onPressed: () {
                        switchStations(context);
                      },
                      backgroundColor: Colors.blue,
                    ),
                  ),
                  Text(
                    ' ${getToStation().POS_NAZ}',
                    overflow: TextOverflow.clip,
                  ),
                ]),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${widget.date}',
                style: TextStyle(
                  fontSize: 14.0,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
            ),
          ]),
          backgroundColor: Colors.blueAccent),
      body: LoaderOverlay(
        overlayOpacity: 1,
        useDefaultLoading: false,
        duration: const Duration(milliseconds: 100),
        reverseDuration: const Duration(milliseconds: 300),
        overlayWidget: Center(
          child: LoadingAnimationWidget.fourRotatingDots(
            color: Colors.white,
            size: 80,
          ),
        ),
        child: departures.isEmpty
            ? Center(
                child: Text(
                'Med izbranima postajama ni najdenih povezav.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20),
              ))
            : ScrollablePositionedList.builder(
                padding: EdgeInsets.only(bottom: 16.0),
                itemScrollController: itemController,
                itemCount: departures.length,
                initialScrollIndex: nextDepIndex,
                itemBuilder: (context, index) {
                  final item = departures[index];
                  return departureTemplate(item, index);
                }),
      ),
    );
  }
}
