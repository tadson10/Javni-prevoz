class Departure {
  final String OVR_SIF; //  - sifra
  final String REG_ISIF; // nek id postaje
  final int ROD_CAS; // čas potovanja
  final String ROD_IODH; // čas odhoda
  final String ROD_IPRI; // čas prihoda
  final int ROD_KM; // razdalja
  final String ROD_OPO;
  final String ROD_PER; // peron
  final int ROD_ZAPK; // končna postaja
  final int ROD_ZAPZ; // zacetna postaja
  final String RPR_NAZ; // naziv podjetja
  final String RPR_SIF; // id podjetja
  final int SPOD_SIF; // id sifra
  final int VVLN_ZL;
  final double VZCL_CEN; // cena

  const Departure({
    required this.OVR_SIF,
    required this.REG_ISIF,
    required this.ROD_CAS,
    required this.ROD_IODH,
    required this.ROD_IPRI,
    required this.ROD_KM,
    required this.ROD_OPO,
    required this.ROD_PER,
    required this.ROD_ZAPK,
    required this.ROD_ZAPZ,
    required this.RPR_NAZ,
    required this.RPR_SIF,
    required this.SPOD_SIF,
    required this.VVLN_ZL,
    required this.VZCL_CEN,
  });

  static Departure DepartureEmpty() {
    return const Departure(
        OVR_SIF: '',
        REG_ISIF: '',
        ROD_CAS: 0,
        ROD_IODH: '',
        ROD_IPRI: '',
        ROD_KM: 0,
        ROD_OPO: '',
        ROD_PER: '',
        ROD_ZAPK: 0,
        ROD_ZAPZ: 0,
        RPR_NAZ: '',
        RPR_SIF: '',
        SPOD_SIF: 0,
        VVLN_ZL: 0,
        VZCL_CEN: 0);
  }

  static Departure fromJson(Map<String, dynamic> json) => Departure(
        OVR_SIF: json['OVR_SIF'],
        REG_ISIF: json['REG_ISIF'],
        ROD_CAS: json['ROD_CAS'],
        ROD_IODH: json['ROD_IODH'],
        ROD_IPRI: json['ROD_IPRI'],
        ROD_KM: json['ROD_KM'],
        ROD_OPO: json['ROD_OPO'],
        ROD_PER: json['ROD_PER'],
        ROD_ZAPK: json['ROD_ZAPK'],
        ROD_ZAPZ: json['ROD_ZAPZ'],
        RPR_NAZ: json['RPR_NAZ'],
        RPR_SIF: json['RPR_SIF'],
        SPOD_SIF: json['SPOD_SIF'],
        VVLN_ZL: json['VVLN_ZL'],
        VZCL_CEN: json['VZCL_CEN'],
      );
}
