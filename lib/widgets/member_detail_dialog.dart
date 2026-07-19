import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/survey_provider.dart';
import '../models/survey_model.dart';
import 'form_helpers.dart';

class MemberDetailDialog extends StatefulWidget {
  final String memberId;
  const MemberDetailDialog({super.key, required this.memberId});

  @override
  State<MemberDetailDialog> createState() => _MemberDetailDialogState();
}

class _MemberDetailDialogState extends State<MemberDetailDialog> {
  final _formKey = GlobalKey<FormState>();
  late FamilyMemberModel _tempMember;
  late TextEditingController _dobController;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<SurveyProvider>(context, listen: false);
    final survey = provider.activeSurvey!;
    final member = survey.familyMembers.firstWhere((m) => m.id == widget.memberId);
    
    // Create a copy of the member so edits are transactional
    _tempMember = FamilyMemberModel.fromJson(member.toJson());
    _dobController = TextEditingController(text: _tempMember.tglLahir);
  }

  @override
  void dispose() {
    _dobController.dispose();
    super.dispose();
  }

  int _calculateAge(String? dob) {
    if (dob == null || dob.length < 6) return 99; // Default to adult if empty
    final parts = dob.split('/');
    if (parts.length < 3) return 99;
    final yearStr = parts[2];
    int year = int.tryParse(yearStr) ?? 0;
    if (year < 100) {
      // 2-digit year
      if (year > 26) {
        year += 1900;
      } else {
        year += 2000;
      }
    }
    const currentYear = 2026; // Census 2026
    return currentYear - year;
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime initialDate = DateTime.now();
    if (_tempMember.tglLahir != null && _tempMember.tglLahir!.isNotEmpty) {
      final parts = _tempMember.tglLahir!.split('/');
      if (parts.length == 3) {
        final day = int.tryParse(parts[0]) ?? 1;
        final month = int.tryParse(parts[1]) ?? 1;
        int year = int.tryParse(parts[2]) ?? 2000;
        if (year < 100) {
          year += (year > 26 ? 1900 : 2000);
        }
        initialDate = DateTime(year, month, day);
      }
    }
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      final dayStr = picked.day.toString().padLeft(2, '0');
      final monthStr = picked.month.toString().padLeft(2, '0');
      final yearStr = picked.year.toString();
      final formatted = '$dayStr/$monthStr/$yearStr';
      setState(() {
        _tempMember.tglLahir = formatted;
        _dobController.text = formatted;
      });
    }
  }

  void _saveData() {
    final provider = Provider.of<SurveyProvider>(context, listen: false);
    provider.updateFamilyMember(widget.memberId, (member) {
      // Copy fields back to provider member
      final jsonCopy = _tempMember.toJson();
      final updated = FamilyMemberModel.fromJson(jsonCopy);
      member.nama = updated.nama;
      member.nik = updated.nik;
      member.noHp = updated.noHp;
      member.keberadaan = updated.keberadaan;
      member.alamatDomisili = updated.alamatDomisili;
      member.provinsiDomisili = updated.provinsiDomisili;
      member.kabupatenDomisili = updated.kabupatenDomisili;
      member.negaraDomisili = updated.negaraDomisili;
      member.jenisKelamin = updated.jenisKelamin;
      member.tglLahir = updated.tglLahir;
      member.statusKawin = updated.statusKawin;
      member.hubunganKk = updated.hubunganKk;
      member.partisipasiSekolah = updated.partisipasiSekolah;
      member.ijazahTertinggi = updated.ijazahTertinggi;
      member.gaji = updated.gaji;
      member.tunjangan = updated.tunjangan;
      member.uangMakan = updated.uangMakan;
      member.honor = updated.honor;
      member.lembur = updated.lembur;
      member.pendapatanLain = updated.pendapatanLain;
      member.totalPendapatan = updated.totalPendapatan;
      member.pendapatanUsaha = updated.pendapatanUsaha;
      member.pendapatanPassive = updated.pendapatanPassive;
      member.profesi = updated.profesi;
      member.statusPekerjaan = updated.statusPekerjaan;
      
      // Disabilitas
      member.disabilitasFisik = updated.disabilitasFisik;
      member.disabilitasMental = updated.disabilitasMental;
      member.disabilitasIntelektual = updated.disabilitasIntelektual;
      member.disabilitasNetra = updated.disabilitasNetra;
      member.disabilitasRungu = updated.disabilitasRungu;
      member.disabilitasWicara = updated.disabilitasWicara;

      // Penyakit
      member.hipertensi = updated.hipertensi;
      member.rematik = updated.rematik;
      member.asma = updated.asma;
      member.jantung = updated.jantung;
      member.diabetes = updated.diabetes;
      member.tbc = updated.tbc;
      member.stroke = updated.stroke;
      member.kanker = updated.kanker;
      member.ginjal = updated.ginjal;
      member.hemofilia = updated.hemofilia;
      member.hiv = updated.hiv;
      member.kolesterol = updated.kolesterol;
      member.sirosis = updated.sirosis;
      member.talasemia = updated.talasemia;
      member.leukemia = updated.leukemia;
      member.alzheimer = updated.alzheimer;
      member.sakitLainnya = updated.sakitLainnya;

      member.rekeningDigital = updated.rekeningDigital;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final age = _calculateAge(_tempMember.tglLahir);

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          _saveData();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_tempMember.nama.isNotEmpty ? 'Ubah Rincian: ${_tempMember.nama}' : 'Tambah Rincian Anggota'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              _saveData();
              Navigator.pop(context);
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                _saveData();
                Navigator.pop(context);
              },
              child: const Text('SIMPAN', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Identitas Anggota Keluarga',
                style: theme.textTheme.titleMedium?.copyWith(color: theme.primaryColor, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // 25. Nama Anggota Keluarga
              _buildTextFormField(
                label: '25. Nama Anggota Keluarga *',
                value: _tempMember.nama,
                validator: (val) => val == null || val.trim().isEmpty ? 'Name is required' : null,
                onChanged: (val) => setState(() => _tempMember.nama = val),
              ),

              // 26.a NIK
              _buildTextFormField(
                label: '26. a. NIK (Nomor Induk Kependudukan) *',
                value: _tempMember.nik,
                keyboardType: TextInputType.number,
                maxLength: 16,
                validator: (val) => val != null && val.isNotEmpty && val.length != 16 ? 'NIK must be 16 digits' : null,
                onChanged: (val) => setState(() => _tempMember.nik = val),
              ),

              // 26.b Nomor HP
              (() {
                final displayValue = _tempMember.noHp != null && _tempMember.noHp!.startsWith('+62')
                    ? _tempMember.noHp!.substring(3)
                    : (_tempMember.noHp != null && _tempMember.noHp!.startsWith('0')
                        ? _tempMember.noHp!.substring(1)
                        : _tempMember.noHp ?? '');
                return _buildTextFormField(
                  label: '26. b. Nomor Telepon/HP',
                  value: displayValue,
                  prefixText: '+62 ',
                  keyboardType: TextInputType.number,
                  maxLength: 13,
                  validator: (val) {
                    if (val != null && val.isNotEmpty) {
                      if (val.length < 9) {
                        return 'Nomor HP minimal 9 digit (setelah +62)';
                      }
                      if (!RegExp(r'^[0-9]+$').hasMatch(val)) {
                        return 'Nomor HP harus berupa angka saja';
                      }
                    }
                    return null;
                  },
                  onChanged: (val) {
                    setState(() {
                      if (val.trim().isEmpty) {
                        _tempMember.noHp = null;
                      } else {
                        // strip any leading 0 if typed
                        String cleanVal = val.trim();
                        if (cleanVal.startsWith('0')) {
                          cleanVal = cleanVal.substring(1);
                        }
                        _tempMember.noHp = '+62$cleanVal';
                      }
                    });
                  },
                );
              }()),

              // 27.a Keberadaan
              _buildDropdownButtonFormField<String>(
                label: '27. a. Keberadaan anggota keluarga',
                value: _tempMember.keberadaan,
                items: const [
                  DropdownMenuItem(value: '1', child: Text('1. Tinggal di rumah/tempat tinggal ini')),
                  DropdownMenuItem(value: '2', child: Text('2. Meninggal')),
                  DropdownMenuItem(value: '3', child: Text('3. Pindah ke wilayah/daerah lain di Indonesia')),
                  DropdownMenuItem(value: '4', child: Text('4. Pindah ke luar negeri')),
                  DropdownMenuItem(value: '5', child: Text('5. Anggota keluarga baru')),
                  DropdownMenuItem(value: '6', child: Text('6. Sudah pisah KK')),
                  DropdownMenuItem(value: '7', child: Text('7. Tidak ditemukan/Tidak dikenal')),
                ],
                onChanged: (val) => setState(() => _tempMember.keberadaan = val),
              ),

              // 27.b Alamat Domisili
              _buildDropdownButtonFormField<String>(
                label: '27. b. Alamat Domisili',
                value: _tempMember.alamatDomisili,
                items: const [
                  DropdownMenuItem(value: '1', child: Text('1. Sesuai KK dan KTP')),
                  DropdownMenuItem(value: '2', child: Text('2. Hanya sesuai KK')),
                  DropdownMenuItem(value: '3', child: Text('3. Hanya sesuai KTP')),
                  DropdownMenuItem(value: '4', child: Text('4. Tidak sesuai KK dan KTP')),
                ],
                onChanged: (val) => setState(() => _tempMember.alamatDomisili = val),
              ),

              // 28DN Provinsi/Kabupaten Domisili (If Keberadaan == 3)
              if (_tempMember.keberadaan == '3') ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildTextFormField(
                        label: '28DN. a. Provinsi Domisili',
                        value: _tempMember.provinsiDomisili,
                        onChanged: (val) => setState(() => _tempMember.provinsiDomisili = val),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextFormField(
                        label: '28DN. b. Kabupaten/Kota Domisili',
                        value: _tempMember.kabupatenDomisili,
                        onChanged: (val) => setState(() => _tempMember.kabupatenDomisili = val),
                      ),
                    ),
                  ],
                ),
              ],

              // 28LN Negara Domisili (If Keberadaan == 4)
              if (_tempMember.keberadaan == '4') ...[
                _buildTextFormField(
                  label: '28LN. Negara Domisili',
                  value: _tempMember.negaraDomisili,
                  onChanged: (val) => setState(() => _tempMember.negaraDomisili = val),
                ),
              ],

              // 29 Jenis Kelamin
              _buildDropdownButtonFormField<String>(
                label: '29. Jenis Kelamin *',
                value: _tempMember.jenisKelamin,
                items: const [
                  DropdownMenuItem(value: '1', child: Text('1. Laki-laki')),
                  DropdownMenuItem(value: '2', child: Text('2. Perempuan')),
                ],
                onChanged: (val) => setState(() => _tempMember.jenisKelamin = val),
              ),

              // 30 Tanggal lahir
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const FormLabel('30. Tanggal lahir *'),
                  TextFormField(
                    controller: _dobController,
                    keyboardType: TextInputType.datetime,
                    decoration: getFormDecoration(
                      value: _tempMember.tglLahir,
                      hintText: 'DD/MM/YYYY (Contoh: 17/08/1945)',
                    ).copyWith(
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () => _selectDate(context),
                      ),
                    ),
                    validator: (val) => val == null || val.isEmpty ? 'Tanggal lahir wajib diisi' : null,
                    onChanged: (val) {
                      setState(() {
                        _tempMember.tglLahir = val;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              ),

              // 31 Status Perkawinan & 32 Hubungan KK
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildDropdownButtonFormField<String>(
                      label: '31. Status Kawin',
                      value: _tempMember.statusKawin,
                      items: const [
                        DropdownMenuItem(value: '1', child: Text('1. Belum Kawin')),
                        DropdownMenuItem(value: '2', child: Text('2. Kawin/Nikah')),
                        DropdownMenuItem(value: '3', child: Text('3. Cerai Hidup')),
                        DropdownMenuItem(value: '4', child: Text('4. Cerai Mati')),
                      ],
                      onChanged: (val) => setState(() => _tempMember.statusKawin = val),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDropdownButtonFormField<String>(
                      label: '32. Hubungan KK *',
                      value: _tempMember.hubunganKk,
                      items: const [
                        DropdownMenuItem(value: '1', child: Text('1. Kepala Keluarga')),
                        DropdownMenuItem(value: '2', child: Text('2. Istri/Suami')),
                        DropdownMenuItem(value: '3', child: Text('3. Anak')),
                        DropdownMenuItem(value: '4', child: Text('4. Menantu')),
                        DropdownMenuItem(value: '5', child: Text('5. Cucu')),
                        DropdownMenuItem(value: '6', child: Text('6. Orang Tua')),
                        DropdownMenuItem(value: '7', child: Text('7. Mertua')),
                        DropdownMenuItem(value: '8', child: Text('8. Famili')),
                        DropdownMenuItem(value: '9', child: Text('9. Lainnya')),
                      ],
                      onChanged: (val) => setState(() => _tempMember.hubunganKk = val),
                    ),
                  ),
                ],
              ),
              const Divider(height: 48),

              // Pendidikan (Conditional: Age >= 5 years)
              if (age >= 5) ...[
                Text(
                  'Pendidikan',
                  style: theme.textTheme.titleMedium?.copyWith(color: theme.primaryColor, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildDropdownButtonFormField<String>(
                  label: '33. Partisipasi Sekolah',
                  value: _tempMember.partisipasiSekolah,
                  items: const [
                    DropdownMenuItem(value: '0', child: Text('0. Tidak/Belum Pernah Sekolah')),
                    DropdownMenuItem(value: '1', child: Text('1. Masih Sekolah')),
                    DropdownMenuItem(value: '2', child: Text('2. Tidak Bersekolah Lagi')),
                  ],
                  onChanged: (val) => setState(() => _tempMember.partisipasiSekolah = val),
                ),
                _buildDropdownButtonFormField<String>(
                  label: '34. Ijazah/STTB Tertinggi',
                  value: _tempMember.ijazahTertinggi,
                  items: const [
                    DropdownMenuItem(value: '0', child: Text('0. Tidak punya ijazah SD')),
                    DropdownMenuItem(value: '1', child: Text('1. SD/sederajat')),
                    DropdownMenuItem(value: '2', child: Text('2. SMP/sederajat')),
                    DropdownMenuItem(value: '3', child: Text('3. SMA/sederajat')),
                    DropdownMenuItem(value: '4', child: Text('4. D1/D2/D3')),
                    DropdownMenuItem(value: '5', child: Text('5. D4/S1/Profesi')),
                    DropdownMenuItem(value: '6', child: Text('6. S2/S3')),
                  ],
                  onChanged: (val) => setState(() => _tempMember.ijazahTertinggi = val),
                ),
                const Divider(height: 48),
              ],

              // Pendapatan & Pekerjaan (Conditional: Age >= 10 years)
              if (age >= 10) ...[
                Text(
                  'Pekerjaan & Pendapatan Bulanan',
                  style: theme.textTheme.titleMedium?.copyWith(color: theme.primaryColor, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                
                // Income fields
                _buildIncomeField('35. a. Gaji Utama', _tempMember.gaji, (val) => setState(() => _tempMember.gaji = val)),
                _buildIncomeField('b. Tunjangan', _tempMember.tunjangan, (val) => setState(() => _tempMember.tunjangan = val)),
                _buildIncomeField('c. Uang Makan', _tempMember.uangMakan, (val) => setState(() => _tempMember.uangMakan = val)),
                _buildIncomeField('d. Honor', _tempMember.honor, (val) => setState(() => _tempMember.honor = val)),
                _buildIncomeField('e. Lembur', _tempMember.lembur, (val) => setState(() => _tempMember.lembur = val)),
                _buildIncomeField('f. Lainnya', _tempMember.pendapatanLain, (val) => setState(() => _tempMember.pendapatanLain = val)),
                
                // Total Income Autofill Display
                const FormLabel('Total Pendapatan Pekerjaan (Autofill)'),
                TextFormField(
                  decoration: getFormDecoration(
                    value: _calculateTotalIncome(),
                    isAutofill: true,
                    prefixText: 'Rp. ',
                  ),
                  readOnly: true,
                  controller: TextEditingController(text: _calculateTotalIncome()),
                ),
                const SizedBox(height: 16),

                _buildIncomeField('35. b. Pendapatan dari Usaha (Warung/Affiliate/etc.)', _tempMember.pendapatanUsaha, (val) => setState(() => _tempMember.pendapatanUsaha = val)),
                _buildIncomeField('35. c. Pendapatan Lain (Pensiunan/Passive/etc.)', _tempMember.pendapatanPassive, (val) => setState(() => _tempMember.pendapatanPassive = val)),

                // Profesi
                _buildTextFormField(
                  label: '36. Profesi Pekerjaan Utama',
                  value: _tempMember.profesi,
                  helperText: 'Jika tidak bekerja, tulis strip (-)',
                  onChanged: (val) => setState(() => _tempMember.profesi = val),
                ),

                // Status Kedudukan
                _buildDropdownButtonFormField<String>(
                  label: '37. Status Kedudukan Pekerjaan Utama',
                  value: _tempMember.statusPekerjaan,
                  items: const [
                    DropdownMenuItem(value: '1', child: Text('1. Berusaha sendiri')),
                    DropdownMenuItem(value: '2', child: Text('2. Berusaha dibantu buruh')),
                    DropdownMenuItem(value: '3', child: Text('3. Buruh/karyawan swasta')),
                    DropdownMenuItem(value: '4', child: Text('4. ASN/TNI/Polri/BUMN/pejabat')),
                    DropdownMenuItem(value: '5', child: Text('5. Pekerja bebas')),
                    DropdownMenuItem(value: '6', child: Text('6. Pekerja keluarga/tidak dibayar')),
                    DropdownMenuItem(value: '9', child: Text('9. Tidak tahu')),
                  ],
                  onChanged: (val) => setState(() => _tempMember.statusPekerjaan = val),
                ),
                const Divider(height: 48),
              ],

              // Disabilitas (38)
              Text(
                '38. Keterbatasan / Disabilitas',
                style: theme.textTheme.titleMedium?.copyWith(color: theme.primaryColor, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _buildDisabilityRadio('Disabilitas Fisik', _tempMember.disabilitasFisik, (val) => setState(() => _tempMember.disabilitasFisik = val)),
              _buildDisabilityRadio('Disabilitas Mental', _tempMember.disabilitasMental, (val) => setState(() => _tempMember.disabilitasMental = val)),
              _buildDisabilityRadio('Disabilitas Intelektual', _tempMember.disabilitasIntelektual, (val) => setState(() => _tempMember.disabilitasIntelektual = val)),
              _buildDisabilityRadio('Disabilitas Sensorik Netra', _tempMember.disabilitasNetra, (val) => setState(() => _tempMember.disabilitasNetra = val)),
              _buildDisabilityRadio('Disabilitas Sensorik Rungu', _tempMember.disabilitasRungu, (val) => setState(() => _tempMember.disabilitasRungu = val)),
              _buildDisabilityRadio('Disabilitas Sensorik Wicara', _tempMember.disabilitasWicara, (val) => setState(() => _tempMember.disabilitasWicara = val)),
              
              const Divider(height: 48),

              // Penyakit Kronis (39)
              Text(
                '39. Keluhan Kesehatan Kronis / Menahun',
                style: theme.textTheme.titleMedium?.copyWith(color: theme.primaryColor, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _buildDisabilityRadio('Hipertensi', _tempMember.hipertensi, (val) => setState(() => _tempMember.hipertensi = val)),
              _buildDisabilityRadio('Rematik', _tempMember.rematik, (val) => setState(() => _tempMember.rematik = val)),
              _buildDisabilityRadio('Asma', _tempMember.asma, (val) => setState(() => _tempMember.asma = val)),
              _buildDisabilityRadio('Masalah Jantung', _tempMember.jantung, (val) => setState(() => _tempMember.jantung = val)),
              _buildDisabilityRadio('Diabetes (Kencing Manis)', _tempMember.diabetes, (val) => setState(() => _tempMember.diabetes = val)),
              _buildDisabilityRadio('Tuberkulosis (TBC)', _tempMember.tbc, (val) => setState(() => _tempMember.tbc = val)),
              _buildDisabilityRadio('Stroke', _tempMember.stroke, (val) => setState(() => _tempMember.stroke = val)),
              _buildDisabilityRadio('Kanker / Tumor Ganas', _tempMember.kanker, (val) => setState(() => _tempMember.kanker = val)),
              _buildDisabilityRadio('Gagal Ginjal', _tempMember.ginjal, (val) => setState(() => _tempMember.ginjal = val)),
              _buildDisabilityRadio('Hemofilia', _tempMember.hemofilia, (val) => setState(() => _tempMember.hemofilia = val)),
              _buildDisabilityRadio('HIV/AIDS', _tempMember.hiv, (val) => setState(() => _tempMember.hiv = val)),
              _buildDisabilityRadio('Kolesterol', _tempMember.kolesterol, (val) => setState(() => _tempMember.kolesterol = val)),
              _buildDisabilityRadio('Sirosis Hati', _tempMember.sirosis, (val) => setState(() => _tempMember.sirosis = val)),
              _buildDisabilityRadio('Talasemia', _tempMember.talasemia, (val) => setState(() => _tempMember.talasemia = val)),
              _buildDisabilityRadio('Leukemia', _tempMember.leukemia, (val) => setState(() => _tempMember.leukemia = val)),
              _buildDisabilityRadio('Alzheimer', _tempMember.alzheimer, (val) => setState(() => _tempMember.alzheimer = val)),
              _buildDisabilityRadio('Lainnya', _tempMember.sakitLainnya, (val) => setState(() => _tempMember.sakitLainnya = val)),

              const Divider(height: 48),

              // Rekening Digital (40) (Conditional: Age >= 5 years)
              if (age >= 5) ...[
                Text(
                  '40. Kepemilikan Rekening / Dompet Digital',
                  style: theme.textTheme.titleMedium?.copyWith(color: theme.primaryColor, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _buildDropdownButtonFormField<String>(
                  label: 'Jenis Kepemilikan',
                  value: _tempMember.rekeningDigital,
                  items: const [
                    DropdownMenuItem(value: '1', child: Text('1. Ya untuk usaha')),
                    DropdownMenuItem(value: '2', child: Text('2. Ya untuk pribadi')),
                    DropdownMenuItem(value: '3', child: Text('3. Ya untuk usaha dan pribadi')),
                    DropdownMenuItem(value: '4', child: Text('4. Tidak ada')),
                    DropdownMenuItem(value: '9', child: Text('9. Tidak tahu')),
                  ],
                  onChanged: (val) => setState(() => _tempMember.rekeningDigital = val),
                ),
              ],
            ],
          ),
        ),
      ),
    ),
  );
}

  Widget _buildTextFormField({
    required String label,
    required String? value,
    required void Function(String) onChanged,
    TextInputType keyboardType = TextInputType.text,
    String? helperText,
    String? prefixText,
    String? suffixText,
    int? maxLength,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FormLabel(label, helperText: helperText),
        TextFormField(
          initialValue: value,
          keyboardType: keyboardType,
          maxLength: maxLength,
          decoration: getFormDecoration(
            value: value,
            prefixText: prefixText,
            suffixText: suffixText,
          ),
          validator: validator,
          onChanged: onChanged,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildDropdownButtonFormField<T>({
    required String label,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FormLabel(label),
        DropdownButtonFormField<T>(
          decoration: getFormDecoration(
            value: value?.toString(),
          ),
          isExpanded: true,
          initialValue: value,
          items: items,
          onChanged: onChanged,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildIncomeField(String label, String? initialValue, void Function(String) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FormLabel(label),
        TextFormField(
          initialValue: formatThousands(initialValue),
          keyboardType: TextInputType.number,
          inputFormatters: [
            ThousandsSeparatorInputFormatter(),
          ],
          decoration: getFormDecoration(
            value: initialValue,
            prefixText: 'Rp. ',
          ),
          onChanged: (val) {
            onChanged(val);
            setState(() {}); // refresh sum calculation display
          },
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  String _calculateTotalIncome() {
    final double g = double.tryParse((_tempMember.gaji ?? '0').replaceAll(',', '')) ?? 0;
    final double t = double.tryParse((_tempMember.tunjangan ?? '0').replaceAll(',', '')) ?? 0;
    final double u = double.tryParse((_tempMember.uangMakan ?? '0').replaceAll(',', '')) ?? 0;
    final double h = double.tryParse((_tempMember.honor ?? '0').replaceAll(',', '')) ?? 0;
    final double l = double.tryParse((_tempMember.lembur ?? '0').replaceAll(',', '')) ?? 0;
    final double o = double.tryParse((_tempMember.pendapatanLain ?? '0').replaceAll(',', '')) ?? 0;
    return formatThousands((g + t + u + h + l + o).toStringAsFixed(0));
  }

  Widget _buildDisabilityRadio(String label, String? currentValue, void Function(String) onChanged) {
    final effectiveValue = currentValue == '1' ? '1' : '2'; // Default empty values to '2' (Tidak)
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(width: 12),
          // Option 'Ya' (bullet on top, text below)
          GestureDetector(
            onTap: () => onChanged('1'),
            behavior: HitTestBehavior.opaque,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 24,
                  width: 24,
                  child: Radio<String>(
                    value: '1',
                    groupValue: effectiveValue,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    onChanged: (val) {
                      if (val != null) onChanged(val);
                    },
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Ya',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          // Option 'Tidak' (bullet on top, text below)
          GestureDetector(
            onTap: () => onChanged('2'),
            behavior: HitTestBehavior.opaque,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 24,
                  width: 24,
                  child: Radio<String>(
                    value: '2',
                    groupValue: effectiveValue,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    onChanged: (val) {
                      if (val != null) onChanged(val);
                    },
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Tidak',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8), // small margin at the right end
        ],
      ),
    );
  }
}
