import 'dart:convert';
import 'package:uuid/uuid.dart';

class SurveyModel {
  String id;
  String userId;
  DateTime? createdAt;
  DateTime? updatedAt;

  // BLOK I: KETERANGAN IDENTITAS KELUARGA
  String? namaKk;
  String? nikKk;
  String? noKk;
  int? jmlAnggotaKk;
  int? jmlAnggotaPendataan;
  String? provinsi;
  String? kabupatenKota;
  String? kecamatan;
  String? desaKelurahan;
  String? klasifikasiDesa; // 1=Perkotaan, 2=Perdesaan
  String? kodePos;
  String? kodeSls;
  String? namaSls;
  String? alamat;
  String? namaJalan;
  String? noRumah;
  double? latitude;
  double? longitude;
  String? alamatSesuaiKk; // 1=Ya, 2=Tidak

  // BLOK II: KETERANGAN PERUMAHAN
  int? jmlKeluargaTinggal;
  String? noKkLain; // comma-separated NIK/KK values
  String? jenisBangunan;
  String? namaNoLantai;
  String? statusKepemilikan;
  String? buktiKepemilikan;
  String? sewaPerkiraan;
  int? luasLantai;
  String? bahanLantai;
  String? kondisiLantai;
  String? bahanDinding;
  String? kondisiDinding;
  String? bahanAtap;
  String? kondisiAtap;
  String? fasilitasBab;
  String? jenisKloset;
  String? pembuanganTinja;
  String? sumberAirMinum;
  String? sumberPenerangan;
  int? meteranPlnCount;
  String? dayaMeteran1;
  String? dayaMeteran2;
  String? idPelanggan1;
  String? idPelanggan2;
  String? pengeluaranListrik;
  String? pengeluaranInternet;
  String? fotoDepanUrl;
  String? fotoTamuUrl;
  String? fotoMandiUrl;

  // BLOK III: KETERANGAN KEPEMILIKAN ASET
  int? gas3kg;
  int? gas5kgPlus;
  int? kulkas;
  int? ac;
  double? emas;
  int? komputer;
  int? motor;
  String? motorNilai;
  int? mobil;
  String? mobilNilai;
  int? tanahLain;
  String? tanahLainNilai;
  int? rumahLain;
  String? rumahLainNilai;

  // BLOK IV: KETERANGAN ANGGOTA KELUARGA
  List<FamilyMemberModel> familyMembers;

  SurveyModel({
    required this.id,
    required this.userId,
    this.createdAt,
    this.updatedAt,
    this.namaKk,
    this.nikKk,
    this.noKk,
    this.jmlAnggotaKk,
    this.jmlAnggotaPendataan,
    this.provinsi,
    this.kabupatenKota,
    this.kecamatan,
    this.desaKelurahan,
    this.klasifikasiDesa,
    this.kodePos,
    this.kodeSls,
    this.namaSls,
    this.alamat,
    this.namaJalan,
    this.noRumah,
    this.latitude,
    this.longitude,
    this.alamatSesuaiKk,
    this.jmlKeluargaTinggal,
    this.noKkLain,
    this.jenisBangunan,
    this.namaNoLantai,
    this.statusKepemilikan,
    this.buktiKepemilikan,
    this.sewaPerkiraan,
    this.luasLantai,
    this.bahanLantai,
    this.kondisiLantai,
    this.bahanDinding,
    this.kondisiDinding,
    this.bahanAtap,
    this.kondisiAtap,
    this.fasilitasBab,
    this.jenisKloset,
    this.pembuanganTinja,
    this.sumberAirMinum,
    this.sumberPenerangan,
    this.meteranPlnCount = 1,
    this.dayaMeteran1,
    this.dayaMeteran2,
    this.idPelanggan1,
    this.idPelanggan2,
    this.pengeluaranListrik,
    this.pengeluaranInternet,
    this.fotoDepanUrl,
    this.fotoTamuUrl,
    this.fotoMandiUrl,
    this.gas3kg = 0,
    this.gas5kgPlus = 0,
    this.kulkas = 0,
    this.ac = 0,
    this.emas = 0.0,
    this.komputer = 0,
    this.motor = 0,
    this.motorNilai,
    this.mobil = 0,
    this.mobilNilai,
    this.tanahLain = 0,
    this.tanahLainNilai,
    this.rumahLain = 0,
    this.rumahLainNilai,
    List<FamilyMemberModel>? familyMembers,
  }) : this.familyMembers = familyMembers ?? [];

  factory SurveyModel.createNew(String userId) {
    return SurveyModel(
      id: const Uuid().v4(),
      userId: userId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  factory SurveyModel.fromJson(Map<String, dynamic> json) {
    var membersList = json['familyMembers'] as List? ?? [];
    List<FamilyMemberModel> members = membersList
        .map((m) => FamilyMemberModel.fromJson(Map<String, dynamic>.from(m)))
        .toList();

    return SurveyModel(
      id: json['id'] as String,
      userId: json['userId'] ?? '',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      namaKk: json['namaKk'] as String?,
      nikKk: json['nikKk'] as String?,
      noKk: json['noKk'] as String?,
      jmlAnggotaKk: json['jmlAnggotaKk'] as int?,
      jmlAnggotaPendataan: json['jmlAnggotaPendataan'] as int?,
      provinsi: json['provinsi'] as String?,
      kabupatenKota: json['kabupatenKota'] as String?,
      kecamatan: json['kecamatan'] as String?,
      desaKelurahan: json['desaKelurahan'] as String?,
      klasifikasiDesa: json['klasifikasiDesa'] as String?,
      kodePos: json['kodePos'] as String?,
      kodeSls: json['kodeSls'] as String?,
      namaSls: json['namaSls'] as String?,
      alamat: json['alamat'] as String?,
      namaJalan: json['namaJalan'] as String?,
      noRumah: json['noRumah'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      alamatSesuaiKk: json['alamatSesuaiKk'] as String?,
      jmlKeluargaTinggal: json['jmlKeluargaTinggal'] as int?,
      noKkLain: json['noKkLain'] as String?,
      jenisBangunan: json['jenisBangunan'] as String?,
      namaNoLantai: json['namaNoLantai'] as String?,
      statusKepemilikan: json['statusKepemilikan'] as String?,
      buktiKepemilikan: json['buktiKepemilikan'] as String?,
      sewaPerkiraan: json['sewaPerkiraan'] as String?,
      luasLantai: json['luasLantai'] as int?,
      bahanLantai: json['bahanLantai'] as String?,
      kondisiLantai: json['kondisiLantai'] as String?,
      bahanDinding: json['bahanDinding'] as String?,
      kondisiDinding: json['kondisiDinding'] as String?,
      bahanAtap: json['bahanAtap'] as String?,
      kondisiAtap: json['kondisiAtap'] as String?,
      fasilitasBab: json['fasilitasBab'] as String?,
      jenisKloset: json['jenisKloset'] as String?,
      pembuanganTinja: json['pembuanganTinja'] as String?,
      sumberAirMinum: json['sumberAirMinum'] as String?,
      sumberPenerangan: json['sumberPenerangan'] as String?,
      meteranPlnCount: json['meteranPlnCount'] as int? ?? 1,
      dayaMeteran1: json['dayaMeteran1'] as String?,
      dayaMeteran2: json['dayaMeteran2'] as String?,
      idPelanggan1: json['idPelanggan1'] as String?,
      idPelanggan2: json['idPelanggan2'] as String?,
      pengeluaranListrik: json['pengeluaranListrik'] as String?,
      pengeluaranInternet: json['pengeluaranInternet'] as String?,
      fotoDepanUrl: json['fotoDepanUrl'] as String?,
      fotoTamuUrl: json['fotoTamuUrl'] as String?,
      fotoMandiUrl: json['fotoMandiUrl'] as String?,
      gas3kg: json['gas3kg'] as int? ?? 0,
      gas5kgPlus: json['gas5kgPlus'] as int? ?? 0,
      kulkas: json['kulkas'] as int? ?? 0,
      ac: json['ac'] as int? ?? 0,
      emas: (json['emas'] as num?)?.toDouble() ?? 0.0,
      komputer: json['komputer'] as int? ?? 0,
      motor: json['motor'] as int? ?? 0,
      motorNilai: json['motorNilai'] as String?,
      mobil: json['mobil'] as int? ?? 0,
      mobilNilai: json['mobilNilai'] as String?,
      tanahLain: json['tanahLain'] as int? ?? 0,
      tanahLainNilai: json['tanahLainNilai'] as String?,
      rumahLain: json['rumahLain'] as int? ?? 0,
      rumahLainNilai: json['rumahLainNilai'] as String?,
      familyMembers: members,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'namaKk': namaKk,
      'nikKk': nikKk,
      'noKk': noKk,
      'jmlAnggotaKk': jmlAnggotaKk,
      'jmlAnggotaPendataan': jmlAnggotaPendataan,
      'provinsi': provinsi,
      'kabupatenKota': kabupatenKota,
      'kecamatan': kecamatan,
      'desaKelurahan': desaKelurahan,
      'klasifikasiDesa': klasifikasiDesa,
      'kodePos': kodePos,
      'kodeSls': kodeSls,
      'namaSls': namaSls,
      'alamat': alamat,
      'namaJalan': namaJalan,
      'noRumah': noRumah,
      'latitude': latitude,
      'longitude': longitude,
      'alamatSesuaiKk': alamatSesuaiKk,
      'jmlKeluargaTinggal': jmlKeluargaTinggal,
      'noKkLain': noKkLain,
      'jenisBangunan': jenisBangunan,
      'namaNoLantai': namaNoLantai,
      'statusKepemilikan': statusKepemilikan,
      'buktiKepemilikan': buktiKepemilikan,
      'sewaPerkiraan': sewaPerkiraan,
      'luasLantai': luasLantai,
      'bahanLantai': bahanLantai,
      'kondisiLantai': kondisiLantai,
      'bahanDinding': bahanDinding,
      'kondisiDinding': kondisiDinding,
      'bahanAtap': bahanAtap,
      'kondisiAtap': kondisiAtap,
      'fasilitasBab': fasilitasBab,
      'jenisKloset': jenisKloset,
      'pembuanganTinja': pembuanganTinja,
      'sumberAirMinum': sumberAirMinum,
      'sumberPenerangan': sumberPenerangan,
      'meteranPlnCount': meteranPlnCount,
      'dayaMeteran1': dayaMeteran1,
      'dayaMeteran2': dayaMeteran2,
      'idPelanggan1': idPelanggan1,
      'idPelanggan2': idPelanggan2,
      'pengeluaranListrik': pengeluaranListrik,
      'pengeluaranInternet': pengeluaranInternet,
      'fotoDepanUrl': fotoDepanUrl,
      'fotoTamuUrl': fotoTamuUrl,
      'fotoMandiUrl': fotoMandiUrl,
      'gas3kg': gas3kg,
      'gas5kgPlus': gas5kgPlus,
      'kulkas': kulkas,
      'ac': ac,
      'emas': emas,
      'komputer': komputer,
      'motor': motor,
      'motorNilai': motorNilai,
      'mobil': mobil,
      'mobilNilai': mobilNilai,
      'tanahLain': tanahLain,
      'tanahLainNilai': tanahLainNilai,
      'rumahLain': rumahLain,
      'rumahLainNilai': rumahLainNilai,
      'familyMembers': familyMembers.map((m) => m.toJson()).toList(),
    };
  }
}

class FamilyMemberModel {
  String id;
  String surveyId;
  int noUrut;
  String nama;
  String? nik;
  String? noHp;
  String? keberadaan; // 1 to 7
  String? alamatDomisili; // 1 to 4
  String? provinsiDomisili;
  String? kabupatenDomisili;
  String? negaraDomisili;
  String? jenisKelamin; // 1=Laki-laki, 2=Perempuan
  String? tglLahir; // DD/MM/YY
  String? statusKawin; // 1=Belum, 2=Kawin, 3=Cerai Hidup, 4=Cerai Mati
  String? hubunganKk; // 1 to 9
  String? partisipasiSekolah; // 0=Tidak/Belum, 1=Masih, 2=Tidak Lagi
  String? ijazahTertinggi; // 0 to 6
  String? gaji;
  String? tunjangan;
  String? uangMakan;
  String? honor;
  String? lembur;
  String? pendapatanLain;
  String? totalPendapatan;
  String? pendapatanUsaha;
  String? pendapatanPassive;
  String? profesi;
  String? statusPekerjaan; // 1 to 9

  // Disabilitas (1=Ya, 2=Tidak)
  String? disabilitasFisik;
  String? disabilitasMental;
  String? disabilitasIntelektual;
  String? disabilitasNetra;
  String? disabilitasRungu;
  String? disabilitasWicara;

  // Penyakit Kronis (1=Ya, 2=Tidak)
  String? hipertensi;
  String? rematik;
  String? asma;
  String? jantung;
  String? diabetes;
  String? tbc;
  String? stroke;
  String? kanker;
  String? ginjal;
  String? hemofilia;
  String? hiv;
  String? kolesterol;
  String? sirosis;
  String? talasemia;
  String? leukemia;
  String? alzheimer;
  String? sakitLainnya;

  String? rekeningDigital; // 1 to 9

  FamilyMemberModel({
    required this.id,
    required this.surveyId,
    required this.noUrut,
    required this.nama,
    this.nik,
    this.noHp,
    this.keberadaan = '1',
    this.alamatDomisili = '1',
    this.provinsiDomisili,
    this.kabupatenDomisili,
    this.negaraDomisili,
    this.jenisKelamin = '1',
    this.tglLahir,
    this.statusKawin = '1',
    this.hubunganKk = '3',
    this.partisipasiSekolah = '1',
    this.ijazahTertinggi = '3',
    this.gaji = '0',
    this.tunjangan = '0',
    this.uangMakan = '0',
    this.honor = '0',
    this.lembur = '0',
    this.pendapatanLain = '0',
    this.totalPendapatan = '0',
    this.pendapatanUsaha = '0',
    this.pendapatanPassive = '0',
    this.profesi,
    this.statusPekerjaan = '3',
    this.disabilitasFisik = '2',
    this.disabilitasMental = '2',
    this.disabilitasIntelektual = '2',
    this.disabilitasNetra = '2',
    this.disabilitasRungu = '2',
    this.disabilitasWicara = '2',
    this.hipertensi = '2',
    this.rematik = '2',
    this.asma = '2',
    this.jantung = '2',
    this.diabetes = '2',
    this.tbc = '2',
    this.stroke = '2',
    this.kanker = '2',
    this.ginjal = '2',
    this.hemofilia = '2',
    this.hiv = '2',
    this.kolesterol = '2',
    this.sirosis = '2',
    this.talasemia = '2',
    this.leukemia = '2',
    this.alzheimer = '2',
    this.sakitLainnya = '2',
    this.rekeningDigital = '4',
  });

  factory FamilyMemberModel.createNew(String surveyId, int noUrut) {
    return FamilyMemberModel(
      id: const Uuid().v4(),
      surveyId: surveyId,
      noUrut: noUrut,
      nama: '',
    );
  }

  factory FamilyMemberModel.fromJson(Map<String, dynamic> json) {
    return FamilyMemberModel(
      id: json['id'] as String,
      surveyId: json['surveyId'] as String,
      noUrut: json['noUrut'] as int,
      nama: json['nama'] as String,
      nik: json['nik'] as String?,
      noHp: json['noHp'] as String?,
      keberadaan: json['keberadaan'] as String?,
      alamatDomisili: json['alamatDomisili'] as String?,
      provinsiDomisili: json['provinsiDomisili'] as String?,
      kabupatenDomisili: json['kabupatenDomisili'] as String?,
      negaraDomisili: json['negaraDomisili'] as String?,
      jenisKelamin: json['jenisKelamin'] as String?,
      tglLahir: json['tglLahir'] as String?,
      statusKawin: json['statusKawin'] as String?,
      hubunganKk: json['hubunganKk'] as String?,
      partisipasiSekolah: json['partisipasiSekolah'] as String?,
      ijazahTertinggi: json['ijazahTertinggi'] as String?,
      gaji: json['gaji'] as String?,
      tunjangan: json['tunjangan'] as String?,
      uangMakan: json['uangMakan'] as String?,
      honor: json['honor'] as String?,
      lembur: json['lembur'] as String?,
      pendapatanLain: json['pendapatanLain'] as String?,
      totalPendapatan: json['totalPendapatan'] as String?,
      pendapatanUsaha: json['pendapatanUsaha'] as String?,
      pendapatanPassive: json['pendapatanPassive'] as String?,
      profesi: json['profesi'] as String?,
      statusPekerjaan: json['statusPekerjaan'] as String?,
      disabilitasFisik: json['disabilitasFisik'] as String?,
      disabilitasMental: json['disabilitasMental'] as String?,
      disabilitasIntelektual: json['disabilitasIntelektual'] as String?,
      disabilitasNetra: json['disabilitasNetra'] as String?,
      disabilitasRungu: json['disabilitasRungu'] as String?,
      disabilitasWicara: json['disabilitasWicara'] as String?,
      hipertensi: json['hipertensi'] as String?,
      rematik: json['rematik'] as String?,
      asma: json['asma'] as String?,
      jantung: json['jantung'] as String?,
      diabetes: json['diabetes'] as String?,
      tbc: json['tbc'] as String?,
      stroke: json['stroke'] as String?,
      kanker: json['kanker'] as String?,
      ginjal: json['ginjal'] as String?,
      hemofilia: json['hemofilia'] as String?,
      hiv: json['hiv'] as String?,
      kolesterol: json['kolesterol'] as String?,
      sirosis: json['sirosis'] as String?,
      talasemia: json['talasemia'] as String?,
      leukemia: json['leukemia'] as String?,
      alzheimer: json['alzheimer'] as String?,
      sakitLainnya: json['sakitLainnya'] as String?,
      rekeningDigital: json['rekeningDigital'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'surveyId': surveyId,
      'noUrut': noUrut,
      'nama': nama,
      'nik': nik,
      'noHp': noHp,
      'keberadaan': keberadaan,
      'alamatDomisili': alamatDomisili,
      'provinsiDomisili': provinsiDomisili,
      'kabupatenDomisili': kabupatenDomisili,
      'negaraDomisili': negaraDomisili,
      'jenisKelamin': jenisKelamin,
      'tglLahir': tglLahir,
      'statusKawin': statusKawin,
      'hubunganKk': hubunganKk,
      'partisipasiSekolah': partisipasiSekolah,
      'ijazahTertinggi': ijazahTertinggi,
      'gaji': gaji,
      'tunjangan': tunjangan,
      'uangMakan': uangMakan,
      'honor': honor,
      'lembur': lembur,
      'pendapatanLain': pendapatanLain,
      'totalPendapatan': totalPendapatan,
      'pendapatanUsaha': pendapatanUsaha,
      'pendapatanPassive': pendapatanPassive,
      'profesi': profesi,
      'statusPekerjaan': statusPekerjaan,
      'disabilitasFisik': disabilitasFisik,
      'disabilitasMental': disabilitasMental,
      'disabilitasIntelektual': disabilitasIntelektual,
      'disabilitasNetra': disabilitasNetra,
      'disabilitasRungu': disabilitasRungu,
      'disabilitasWicara': disabilitasWicara,
      'hipertensi': hipertensi,
      'rematik': rematik,
      'asma': asma,
      'jantung': jantung,
      'diabetes': diabetes,
      'tbc': tbc,
      'stroke': stroke,
      'kanker': kanker,
      'ginjal': ginjal,
      'hemofilia': hemofilia,
      'hiv': hiv,
      'kolesterol': kolesterol,
      'sirosis': sirosis,
      'talasemia': talasemia,
      'leukemia': leukemia,
      'alzheimer': alzheimer,
      'sakitLainnya': sakitLainnya,
      'rekeningDigital': rekeningDigital,
    };
  }
}
