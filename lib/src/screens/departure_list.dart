// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:flutter/material.dart';
import 'package:javniPrevoz/src/api/arriva_api.dart';
import 'package:javniPrevoz/src/type/departure.dart';
import 'package:javniPrevoz/src/type/station.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class DepartureList extends StatefulWidget {
  DepartureList({Key? key, required this.fromToStations, required this.date, required this.formattedDate}) : super(key: key);

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

  void initState() {
    super.initState();
    print('initState');
    () async {
      await Future.delayed(Duration.zero);
      context.loaderOverlay.show();
    }();

    Future<List<Departure>> result = ArrivaApi.getDepartures(widget.fromToStations[0].JPOS_IJPP, widget.fromToStations[1].JPOS_IJPP, widget.formattedDate);
    result.then((value) {
      setState(() {
        departures = value;
        isLoaded = true;
      });
      // Call after frame was built
      WidgetsBinding.instance.addPostFrameCallback((_) {
        scrollToItem(true);
      });
      context.loaderOverlay.hide();
    });
  }

  // Switch stations and get departures
  void switchStations(BuildContext context) {
    context.loaderOverlay.show();
    setState(() {
      isLoaded = false;
      isSwitched = !isSwitched;
    });

    int fromStation = isSwitched ? widget.fromToStations[1].JPOS_IJPP : widget.fromToStations[0].JPOS_IJPP;
    int toStation = isSwitched ? widget.fromToStations[0].JPOS_IJPP : widget.fromToStations[1].JPOS_IJPP;

    Future<List<Departure>> result = ArrivaApi.getDepartures(fromStation, toStation, widget.formattedDate);
    result.then((value) {
      setState(() {
        departures = value;
        isLoaded = true;
      });
      scrollToItem(false);
      context.loaderOverlay.hide();
    });
  }

  double timeToDouble(TimeOfDay myTime) => myTime.hour + myTime.minute / 60.0;

  Future scrollToItem(bool isOnInit) async {
    DateTime now = DateTime.now();
    String nowString = '${now.day}. ${now.month}. ${now.year}';
    // DateTime date = DateTime(now.year, now.month, now.day);
    if (nowString == widget.date) {
      TimeOfDay curTime = TimeOfDay.now();
      double curTimeD = timeToDouble(curTime);
      for (int i = 0; i < departures.length; i++) {
        Departure dep = departures[i];
        TimeOfDay depTime = TimeOfDay(hour: int.parse(dep.ROD_IODH.split(":")[0]), minute: int.parse(dep.ROD_IODH.split(":")[1]));
        double depTimeD = timeToDouble(depTime);
        if (depTimeD >= curTimeD) {
          itemController.scrollTo(index: i, duration: Duration(milliseconds: 500));
          break;
        }
      }
    } else if (!isOnInit) {
      itemController.scrollTo(index: 0, duration: Duration(milliseconds: 500));
    }
  }

  void getNextDepIndex() {
    DateTime now = DateTime.now();
    String nowString = '${now.day}. ${now.month}. ${now.year}';
    if (nowString == widget.date) {
      TimeOfDay curTime = TimeOfDay.now();
      double curTimeD = timeToDouble(curTime);
      for (int i = 0; i < departures.length; i++) {
        Departure dep = departures[i];
        TimeOfDay depTime = TimeOfDay(hour: int.parse(dep.ROD_IODH.split(":")[0]), minute: int.parse(dep.ROD_IODH.split(":")[1]));
        double depTimeD = timeToDouble(depTime);
        if (depTimeD >= curTimeD) {
          nextDepIndex = i;
          break;
        }
      }
    }
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
                  '${widget.fromToStations[0].POS_NAZ}',
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
                    '${widget.fromToStations[1].POS_NAZ}',
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
        ));
  }

  @override
  Widget build(BuildContext context) {
    print('build');
    getNextDepIndex();
    return Scaffold(
      appBar: AppBar(
          title: Column(children: [
            FittedBox(
              fit: BoxFit.fitWidth,
              child: Row(children: [
                Text(
                  '${isSwitched ? widget.fromToStations[1].POS_NAZ : widget.fromToStations[0].POS_NAZ} ',
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
                  ' ${isSwitched ? widget.fromToStations[0].POS_NAZ : widget.fromToStations[1].POS_NAZ}',
                  overflow: TextOverflow.clip,
                ),
              ]),
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
        overlayOpacity: 0.6,
        useDefaultLoading: false,
        duration: const Duration(milliseconds: 250),
        reverseDuration: const Duration(milliseconds: 250),
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
                itemBuilder: (context, index) {
                  final item = departures[index];
                  return departureTemplate(item, index);
                }),
      ),
    );
  }
}
