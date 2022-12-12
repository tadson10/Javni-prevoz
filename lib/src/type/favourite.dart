class Favourite {
  final String fromName;
  final int fromId;
  final String toName;
  final int toId;

  Favourite({required this.fromId, required this.fromName, required this.toId, required this.toName});

  @override
  String toString() {
    // TODO: implement toString
    return '${fromName} (${fromId}), ${toName} (${toId})';
  }

  Map toJson() => {
        'fromName': fromName,
        'fromId': fromId,
        'toName': toName,
        'toId': toId,
      };
  // static Station fromJson(Map<String, dynamic> json) => Station(
  //       JPOS_IJPP: json['JPOS_IJPP'],
  //       POS_NAZ: json['POS_NAZ'],
  //     );

  static Favourite fromJson(Map<String, dynamic> json) => Favourite(
        fromName: json['fromName'],
        fromId: json['fromId'],
        toName: json['toName'],
        toId: json['toId'],
      );
  // Station({
  //   required this.From,
  //   required this.To,
  // }) {
  //  // TODO: implement Station
  //  throw UnimplementedError();
  //  }

  // static Station fromJson(Map<String, dynamic> json) => Station(
  //       JPOS_IJPP: json['JPOS_IJPP'],
  //       to: json['POS_NAZ'],
  //     );
}
