import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:crypto/crypto.dart';
import 'package:javniPrevoz/src/type/departure.dart';
import 'package:javniPrevoz/src/type/station.dart';

class ArrivaApi {
  static Future<List<Station>> getStations(String query) async {
    try {
      DateTime date = new DateTime.now();
      var formatter = new DateFormat('yyyyMMddHHmmss');
      String timestamp = formatter.format(date);
      String token = md5.convert(utf8.encode('R300_VozniRed_2015' + timestamp)).toString();

      final url = Uri.parse(
          'https://prometws.alpetour.si/WS_ArrivaSLO_TimeTable_DepartureStations.aspx?JSON=1&SearchType=2&cTOKEN=${token}&cTIMESTAMP=${timestamp}&POS_NAZ=${query}');

      final response = await http.get(url).timeout(
        const Duration(seconds: 2),
        onTimeout: () {
          throw TimeoutException('The connection has timed out, please try again!');
        },
      );

      if (response.statusCode == 200) {
        final List stations = json.decode(response.body)[0]['DepartureStations'];
        return stations.map<Station>((json) => Station.fromJson(json)).toList();
      } else {
        throw Exception();
      }
    } on TimeoutException catch (e) {
      print(e);
      return [];
    }
  }

  static Future<dynamic> getDepartures(int fromStationId, int toStationId, String selectedDate) async {
    try {
      DateTime date = new DateTime.now();
      var formatter = new DateFormat('yyyyMMddHHmmss');
      String timestamp = formatter.format(date);
      String token = md5.convert(utf8.encode('R300_VozniRed_2015' + timestamp)).toString();
      print(date);
      final url = Uri.parse(
          'https://prometws.alpetour.si/WS_ArrivaSLO_TimeTable_TimeTableDepartures.aspx?JSON=1&SearchType=2&cTOKEN=${token}&cTIMESTAMP=${timestamp}&JPOS_IJPPZ=${fromStationId}&JPOS_IJPPK=${toStationId}&VZVK_DAT=${selectedDate}');
      final response = await http.get(url).timeout(
        const Duration(seconds: 3),
        onTimeout: () {
          throw TimeoutException('The connection has timed out, please try again!');
        },
      );

      if (response.statusCode == 200) {
        final List departures = json.decode(response.body)[0]['Departures'];
        print(departures);
        return departures.map<Departure>((json) => Departure.fromJson(json)).toList();
      } else {
        throw Exception();
      }
    } on TimeoutException catch (e) {
      print('BLA TIMEOUT');
      print(e);
      return 'Timeout';
    }
  }
}
