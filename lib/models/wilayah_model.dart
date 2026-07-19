class WilayahModel {
  final String idSubsls;
  final String kdProv;
  final String kdKab;
  final String kdKec;
  final String kdDesa;
  final String kdSls;
  final String namaProv;
  final String namaKab;
  final String namaKec;
  final String namaDesa;
  final String namaSls;
  final String kdPos;

  WilayahModel({
    required this.idSubsls,
    required this.kdProv,
    required this.kdKab,
    required this.kdKec,
    required this.kdDesa,
    required this.kdSls,
    required this.namaProv,
    required this.namaKab,
    required this.namaKec,
    required this.namaDesa,
    required this.namaSls,
    required this.kdPos,
  });

  factory WilayahModel.fromJson(Map<String, dynamic> json) {
    return WilayahModel(
      idSubsls: json['idSubsls'] ?? '',
      kdProv: json['kdProv'] ?? '',
      kdKab: json['kdKab'] ?? '',
      kdKec: json['kdKec'] ?? '',
      kdDesa: json['kdDesa'] ?? '',
      kdSls: json['kdSls'] ?? '',
      namaProv: json['namaProv'] ?? '',
      namaKab: json['namaKab'] ?? '',
      namaKec: json['namaKec'] ?? '',
      namaDesa: json['namaDesa'] ?? '',
      namaSls: json['namaSls'] ?? '',
      kdPos: json['kdPos'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idSubsls': idSubsls,
      'kdProv': kdProv,
      'kdKab': kdKab,
      'kdKec': kdKec,
      'kdDesa': kdDesa,
      'kdSls': kdSls,
      'namaProv': namaProv,
      'namaKab': namaKab,
      'namaKec': namaKec,
      'namaDesa': namaDesa,
      'namaSls': namaSls,
      'kdPos': kdPos,
    };
  }
}
