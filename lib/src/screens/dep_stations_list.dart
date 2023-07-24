import 'dart:ffi';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:javniPrevoz/src/type/departure.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:timelines/timelines.dart';
import '../api/arriva_api.dart';
import '../type/departureStation.dart';

class DepartureStationsList extends StatefulWidget {
  DepartureStationsList(
      {Key? key, required this.departure, required this.fromStation, required this.toStation, required this.date})
      : super(key: key);

  final Departure departure;
  final String fromStation;
  final String toStation;
  final String date;

  @override
  State<DepartureStationsList> createState() => _DepartureStationsListState();
}

class _DepartureStationsListState extends State<DepartureStationsList> {
  List<DepartureStation> departureStations = [];
  int fromIndex = 0;
  int toIndex = 0;

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
              getDepartureStationsList(widget.departure);
            },
            child: const Text('Poskusi znova'),
          ),
        ],
      ),
    );
  }

  void getDepartureStationsList(Departure departure) {
    Future<dynamic> result = ArrivaApi.getDepartureStations(departure);

    result.then((value) {
      print(value);
      if (value is String) {
        showError(context, 'Težava pri komunikaciji s strežniki.');
      } else {
        setState(() {
          departureStations = value;
          getFromToIndex();
        });
        context.loaderOverlay.hide();
      }
    });
  }

  void getFromToIndex() {
    fromIndex = departureStations.indexWhere((element) => element.POS_NAZ == widget.fromStation);
    toIndex = departureStations.indexWhere((element) => element.POS_NAZ == widget.toStation);
  }

  bool checkIfStartOrEnd(int index) {
    return index == fromIndex || index == toIndex;
  }

  bool checkIfBetween(int index) {
    return index >= fromIndex && index <= toIndex;
  }

  void initState() {
    super.initState();
    print('initState');
    print(widget.departure.toString());
    () async {
      await Future.delayed(Duration.zero);
      context.loaderOverlay.show();
    }();
    getDepartureStationsList(widget.departure);
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
                      '${widget.fromStation} - ',
                    ),
                    // SizedBox(
                    //   height: 30,
                    //   width: 30,
                    //   child: FloatingActionButton(
                    //     heroTag: 'btnSwapH',
                    //     mini: true,
                    //     child: Icon(Icons.swap_horiz),
                    //     onPressed: () {
                    //       switchStations(context);
                    //     },
                    //     backgroundColor: Colors.blue,
                    //   ),
                    // ),
                    Text(
                      '${widget.toStation} ',
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
          child:
              // Timeline.tileBuilder(
              //   builder: TimelineTileBuilder.fromStyle(
              //     contentsAlign: ContentsAlign.reverse,
              //     contentsBuilder: (context, index) => Padding(
              //       padding: const EdgeInsets.all(24.0),
              //       child: Text('Timeline Event $index'),
              //     ),
              //     itemCount: 10,
              //   ),

              // ),

              Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: const BorderSide(
                      color: Colors.blueAccent,
                    ),
                  ),
                  margin: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0),
                  child: Padding(
                      padding: const EdgeInsets.only(bottom: 12.0, top: 12.0),
                      child: ListView(padding: const EdgeInsets.only(right: 0.0), children: [
                        FixedTimeline.tileBuilder(
                          theme: TimelineTheme.of(context).copyWith(
                            nodePosition: 0.05,
                          ),
                          builder: TimelineTileBuilder.connectedFromStyle(
                            firstConnectorStyle: ConnectorStyle.transparent,
                            lastConnectorStyle: ConnectorStyle.transparent,
                            contentsAlign: ContentsAlign.basic,
                            // oppositeContentsBuilder: (context, index) => Padding(
                            //   padding: const EdgeInsets.all(10.0),
                            //   child: Text(
                            //       departureStations[index].ROD_IODH != ""
                            //           ? departureStations[index].ROD_IODH
                            //           : departureStations[index].ROD_IPRI,
                            //       style: TextStyle(
                            //           fontWeight: checkIfBetween(index) ? FontWeight.bold : FontWeight.normal,
                            //           fontSize: checkIfStartOrEnd(index) ? 18 : 13)),
                            // ),
                            contentsBuilder: (context, index) => Row(children: [
                              SizedBox(
                                width: 200,
                                child:
                                    Padding(
                                  padding: const EdgeInsets.only(top: 10.0, bottom: 10.0, left: 40.0),
                                  child: Text(departureStations[index].POS_NAZ,
                                      style: TextStyle(
                                          fontWeight: checkIfBetween(index) ? FontWeight.bold : FontWeight.normal,
                                          fontSize: checkIfStartOrEnd(index) ? 18 : 13)),
                                ),
                              ),
                              SizedBox(width: 60),
                              Text(
                                  departureStations[index].ROD_IODH != ""
                                      ? departureStations[index].ROD_IODH
                                      : departureStations[index].ROD_IPRI,
                                  style: TextStyle(
                                      fontWeight: checkIfBetween(index) ? FontWeight.bold : FontWeight.normal,
                                      fontSize: checkIfStartOrEnd(index) ? 18 : 13)),
                            ]),
                            connectorStyleBuilder: (context, index) => ConnectorStyle.solidLine,
                            indicatorStyleBuilder: (context, index) =>
                                checkIfBetween(index) ? IndicatorStyle.dot : IndicatorStyle.outlined  ,
                            itemCount: departureStations.length,
                          ),
                        ),
                      ]))

                  // ListView(
                  //     padding: EdgeInsets.all(16.0),
                  //     children: [
                  //       TimelineTile(
                  //         alignment: TimelineAlign.manual,
                  //         lineXY: 0.1,
                  //         isFirst: true,//  index == 0,
                  //         // isLast: index == departureStations.length - 1,
                  //         // indicatorStyle: const IndicatorStyle(
                  //         //   width: 15,
                  //         //   height: 15,
                  //         //   color: Colors.blueAccent,
                  //         //   // indicator: Icon(Icons.abc),//(number: '${index + 1}'),
                  //         //   drawGap: true,
                  //         // ),
                  //         beforeLineStyle: const LineStyle(
                  //           color: Colors.blueAccent,
                  //           thickness: 2,
                  //         ),
                  //         startChild: const _Child(
                  //           text: "Don't Panic!",
                  //           font: 'Bungee',
                  //           key: Key('1'),
                  //         ),
                  //       ),

                  //     ],
                  //   ),
                  ////////////////////////////////////////////////////////////////////
                  // ListView(
                  //   padding: EdgeInsets.all(16.0),
                  //   children: [
                  //     Row(
                  //       children: [
                  //         Column(
                  //           children: [
                  //             for (int x = 0; x <= departureStations.length - 1; x++) ...[
                  //               Text(departureStations[x].ROD_IPRI != ""
                  //                   ? departureStations[x].ROD_IPRI
                  //                   : departureStations[x].ROD_IODH),
                  //               SizedBox(
                  //                 width: 5,
                  //                 height: 20,
                  //               ),
                  //             ],
                  //           ],
                  //         ),
                  //         SizedBox(width: 10),
                  //         Column(
                  //           children: [
                  //             for (int x = 0; x <= departureStations.length - 1; x++) ...[
                  //               SizedBox(
                  //                 width: 10,
                  //                 child: const Icon(
                  //                   Icons.circle,
                  //                   size: 10.0,
                  //                 ),
                  //               ),
                  //               // Text(departureStations[x].ROD_IPRI != ""
                  //               //     ? departureStations[x].ROD_IPRI
                  //               //     : departureStations[x].ROD_IODH),
                  //               Container(
                  //                 color: Colors.black,
                  //                 width: 5,
                  //                 height: 20,
                  //               ),
                  //             ],
                  //           ],
                  //         ),
                  //         SizedBox(width: 10),
                  //         Column(
                  //           children: [
                  //             for (int x = 0; x <= departureStations.length - 1; x++) ...[
                  //               Text(departureStations[x].POS_NAZ),
                  //               SizedBox(
                  //                 width: 5,
                  //                 height: 20,
                  //               ),
                  //             ],
                  //           ],
                  //         ),
                  //       ],
                  //     )
                  // ],
                  // )
////////////////////////////////////////////////////////////////////

                  // ScrollablePositionedList.builder(
                  //     padding: const EdgeInsets.all(16.0),
                  //     itemCount: departureStations.length,
                  //     itemBuilder: (context, index) {
                  //       final item = departureStations[index];
                  //       print(item.POS_NAZ);

                  //       var icon;
                  //       if (index == 0) {
                  //         icon = const Icon(
                  //           Icons.my_location,
                  //           size: 20.0,
                  //         );
                  //       }
                  //       if (index == departureStations.length - 1) {
                  //         icon = const Icon(
                  //           Icons.location_on,
                  //           size: 20.0,
                  //         );
                  //       }
                  //       if (index != 0 && index != departureStations.length - 1) {
                  //         icon = const Icon(
                  //           Icons.circle,
                  //           size: 10.0,
                  //         );
                  //       }
                  //       if (index == 0) {
                  //         return Row(children: [
                  //           Column(
                  //             children: [
                  //               for (int x = 1; x <= 50; x++) ...[
                  //                 Container(child: Text("$x")),
                  //               ],
                  //             ],
                  //           ),
                  //           Column(
                  //             children: [
                  //               for (int x = 1; x <= 50; x++) ...[
                  //                 Container(child: Text("$x")),
                  //               ],
                  //             ],
                  //           )
                  //         ]);
                  //       }
                  //       return SizedBox.shrink();

                  //       // return Row(
                  //       //   children: [
                  //       //     SizedBox(
                  //       //       width: 50,
                  //       //       child: Column(
                  //       //         children: [Text(item.ROD_IPRI != "" ? item.ROD_IPRI : item.ROD_IODH)],
                  //       //       ),
                  //       //     ),
                  //       //     const SizedBox(width: 10),
                  //       //     Row(
                  //       //       children: [
                  //       //         SizedBox(
                  //       //           width: 50,
                  //       //           child: icon,
                  //       //         ),
                  //       //         const SizedBox(width: 10),
                  //       //         Text(item.POS_NAZ),
                  //       //         const SizedBox(height: 50),
                  //       //       ],
                  //       //     )
                  //       //   ],
                  //       // );
                  //     }),
                  ),
        ));
  }
}

class _Child extends StatelessWidget {
  const _Child({
    required Key key,
    required this.text,
    this.font = 'Shrikhand',
  }) : super(key: key);

  final String text;
  final String font;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      color: Colors.amberAccent,
      constraints: const BoxConstraints(minHeight: 20, minWidth: 200),
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          // style: GoogleFonts.getFont(
          //   font,
          //   color: Colors.deepOrange,
          //   fontSize: 26,
          // ),
        ),
      ),
    );
  }
}
