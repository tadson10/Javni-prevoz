class DepartureStation {
  final int ROD_ZAP; 
  final String POS_NAZ; 
  final String ROD_IPRI; 
  final int ROD_POS;
  final String ROD_IODH; 
  final String ROD_STOP;
  final double ROD_LAT;
  final double ROD_LON; 

  const DepartureStation({
    required this.ROD_ZAP,
    required this.POS_NAZ,
    required this.ROD_IPRI,
    required this.ROD_POS,
    required this.ROD_IODH,
    required this.ROD_STOP,
    required this.ROD_LAT,
    required this.ROD_LON,
  });

  static DepartureStation DepartureStationEmpty() {
    return const DepartureStation(
        ROD_ZAP: -1,
        POS_NAZ: '',
        ROD_IPRI: '',
        ROD_POS: -1,
        ROD_IODH: '',
        ROD_STOP: '',
        ROD_LAT: -1,
        ROD_LON: -1);
  }

  static DepartureStation fromJson(Map<String, dynamic> json) => DepartureStation(
        ROD_ZAP: json['ROD_ZAP'],
        POS_NAZ: json['REG_POS_NAZISIF'],
        ROD_IPRI: json['ROD_IPRI'],
        ROD_POS: json['ROD_POS'],
        ROD_IODH: json['ROD_IODH'],
        ROD_STOP: json['ROD_STOP'],
        ROD_LAT: json['ROD_LAT'],
        ROD_LON: json['ROD_LON'],
      );
}
