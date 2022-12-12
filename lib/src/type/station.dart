class Station {
  final int JPOS_IJPP;
  final String POS_NAZ;

  const Station({
    required this.JPOS_IJPP,
    required this.POS_NAZ,
  });

  static Station fromJson(Map<String, dynamic> json) => Station(
        JPOS_IJPP: json['JPOS_IJPP'],
        POS_NAZ: json['POS_NAZ'],
      );

  Map toJson() => {
        'JPOS_IJPP': JPOS_IJPP,
        'POS_NAZ': POS_NAZ,
      };
}
