import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:crypto/crypto.dart';
import 'package:javniPrevoz/src/type/departure.dart';
import 'package:javniPrevoz/src/type/departureStation.dart';
import 'package:javniPrevoz/src/type/station.dart';

class ArrivaApi {
  static Future<List<Station>> getStations(String query) async {
    try {
      DateTime date = new DateTime.now();
      var formatter = new DateFormat('yyyyMMddHHmmss');
      String timestamp = formatter.format(date);
      String token = md5.convert(utf8.encode('R300_VozniRed_2015' + timestamp)).toString();
      
      final queryParameters = {
        'cTOKEN': token,
        'cTIMESTAMP': timestamp,
        'POS_NAZ': query,
        'JSON': '1',
        'SearchType': '2',
      };
      var url = Uri.https('prometws.alpetour.si', '/WS_ArrivaSLO_TimeTable_DepartureStations.aspx', queryParameters);

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
    } catch (e) {
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

      final queryParameters = {
        'cTOKEN': token,
        'cTIMESTAMP': timestamp,
        'JPOS_IJPPZ': fromStationId.toString(),
        'JPOS_IJPPK': toStationId.toString(),
        'VZVK_DAT': selectedDate,
        'JSON': '1',
        'SearchType': '2',
      };
      var url = Uri.https('prometws.alpetour.si', '/WS_ArrivaSLO_TimeTable_TimeTableDepartures.aspx', queryParameters);

      final response = await http.get(url).timeout(
        const Duration(seconds: 3),
        onTimeout: () {
          throw TimeoutException('The connection has timed out, please try again!');
        },
      );

      if (response.statusCode == 200) {
        final List departures = json.decode(response.body)[0]['Departures'];
        return departures.map<Departure>((json) => Departure.fromJson(json)).toList();
      } else {
        throw Exception();
      }
    } catch (e) {
      print(e);
      return 'Timeout';
    }
  }

  static Future<dynamic> getDepartureStations(Departure departure) async {
    try {
      DateTime date = new DateTime.now();
      var formatter = new DateFormat('yyyyMMddHHmmss');
      String timestamp = formatter.format(date);
      String token = md5.convert(utf8.encode('R300_VozniRed_2015' + timestamp)).toString();
      
      final queryParameters = {
        'cTOKEN': token,
        'cTIMESTAMP': timestamp,
        'SPOD_SIF': departure.SPOD_SIF.toString(),
        'REG_ISIF': departure.REG_ISIF,
        'VVLN_ZL': departure.VVLN_ZL.toString(),
        'ROD_ZAPZ': departure.ROD_ZAPZ.toString(),
        'ROD_ZAPK': departure.ROD_ZAPK.toString(),
        'OVR_SIF': departure.OVR_SIF,
        'JSON': '1',
        'SearchType': '2',
      };
      var url = Uri.https(
          'prometws.alpetour.si', '/WS_ArrivaSLO_TimeTable_TimeTableDepartureStationList.aspx', queryParameters);
      final response = await http.get(url).timeout(
        const Duration(seconds: 3),
        onTimeout: () {
          throw TimeoutException('The connection has timed out, please try again!');
        },
      );

      if (response.statusCode == 200) {
        final List departureStationsList = json.decode(response.body)[0]['DepartureStationList'];
        return departureStationsList.map<DepartureStation>((json) => DepartureStation.fromJson(json)).toList();
      } else {
        throw Exception();
      }
    } catch (e) {
      print(e);
      return 'Timeout';
    }
  }
}
