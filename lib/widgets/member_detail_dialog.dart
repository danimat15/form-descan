import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/survey_provider.dart';
import '../models/survey_model.dart';

class MemberDetailDialog extends StatefulWidget {
  final String memberId;
  const MemberDetailDialog({super.key, required this.memberId});

  @override
  State<MemberDetailDialog> createState() => _MemberDetailDialogState();
}

class _MemberDetailDialogState extends State<MemberDetailDialog> {
  final _formKey = GlobalKey<FormState>();
  late FamilyMemberModel _tempMember;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<SurveyProvider>(context, listen: false);
    final survey = provider.activeSurvey!;
    final member = survey.familyMembers.firstWhere((m) => m.id == widget.memberId);
    
    // Create a copy of the member so edits are transactional
    _tempMember = FamilyMemberModel.fromJson(member.toJson());
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final age = _calculateAge(_tempMember.tglLahir);

    return Scaffold(
      appBar: AppBar(
        title: Text(_tempMember.nama.isNotEmpty ? 'Edit: ${_tempMember.nama}' : 'Add Member Details'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
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
                Navigator.pop(context);
              }
            },
            child: const Text('SAVE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
              TextFormField(
                initialValue: _tempMember.nama,
                decoration: const InputDecoration(labelText: '25. Nama Anggota Keluarga'),
                validator: (val) => val == null || val.trim().isEmpty ? 'Name is required' : null,
                onChanged: (val) => setState(() => _tempMember.nama = val),
              ),
              const SizedBox(height: 16),

              // 26.a NIK
              TextFormField(
                initialValue: _tempMember.nik,
                keyboardType: TextInputType.number,
                maxLength: 16,
                decoration: const InputDecoration(labelText: '26. a. NIK (Nomor Induk Kependudukan)', counterText: ''),
                validator: (val) => val != null && val.isNotEmpty && val.length != 16 ? 'NIK must be 16 digits' : null,
                onChanged: (val) => setState(() => _tempMember.nik = val),
              ),
              const SizedBox(height: 16),

              // 26.b Nomor HP
              TextFormField(
                initialValue: _tempMember.noHp,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: '26. b. Nomor Telepon/HP'),
                onChanged: (val) => setState(() => _tempMember.noHp = val),
              ),
              const SizedBox(height: 16),

              // 27.a Keberadaan
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: '27. a. Keberadaan anggota keluarga'),
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
              const SizedBox(height: 16),

              // 27.b Alamat Domisili
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: '27. b. Alamat Domisili'),
                value: _tempMember.alamatDomisili,
                items: const [
                  DropdownMenuItem(value: '1', child: Text('1. Sesuai KK dan KTP')),
                  DropdownMenuItem(value: '2', child: Text('2. Hanya sesuai KK')),
                  DropdownMenuItem(value: '3', child: Text('3. Hanya sesuai KTP')),
                  DropdownMenuItem(value: '4', child: Text('4. Tidak sesuai KK dan KTP')),
                ],
                onChanged: (val) => setState(() => _tempMember.alamatDomisili = val),
              ),
              const SizedBox(height: 16),

              // 28DN Provinsi/Kabupaten Domisili (If Keberadaan == 3)
              if (_tempMember.keberadaan == '3') ...[
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: _tempMember.provinsiDomisili,
                        decoration: const InputDecoration(labelText: '28DN. a. Provinsi Domisili'),
                        onChanged: (val) => setState(() => _tempMember.provinsiDomisili = val),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        initialValue: _tempMember.kabupatenDomisili,
                        decoration: const InputDecoration(labelText: '28DN. b. Kabupaten/Kota Domisili'),
                        onChanged: (val) => setState(() => _tempMember.kabupatenDomisili = val),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],

              // 28LN Negara Domisili (If Keberadaan == 4)
              if (_tempMember.keberadaan == '4') ...[
                TextFormField(
                  initialValue: _tempMember.negaraDomisili,
                  decoration: const InputDecoration(labelText: '28LN. Negara Domisili'),
                  onChanged: (val) => setState(() => _tempMember.negaraDomisili = val),
                ),
                const SizedBox(height: 16),
              ],

              // 29 Jenis Kelamin & 30 Tanggal Lahir
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: '29. Jenis Kelamin'),
                      value: _tempMember.jenisKelamin,
                      items: const [
                        DropdownMenuItem(value: '1', child: Text('1. Laki-laki')),
                        DropdownMenuItem(value: '2', child: Text('2. Perempuan')),
                      ],
                      onChanged: (val) => setState(() => _tempMember.jenisKelamin = val),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      initialValue: _tempMember.tglLahir,
                      keyboardType: TextInputType.datetime,
                      decoration: const InputDecoration(
                        labelText: '30. Tanggal lahir',
                        hintText: 'DD/MM/YY',
                      ),
                      validator: (val) => val == null || val.isEmpty ? 'DOB is required' : null,
                      onChanged: (val) {
                        setState(() {
                          _tempMember.tglLahir = val;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 31 Status Perkawinan & 32 Hubungan KK
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: '31. Status Kawin'),
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
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: '32. Hubungan KK'),
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
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: '33. Partisipasi Sekolah'),
                  value: _tempMember.partisipasiSekolah,
                  items: const [
                    DropdownMenuItem(value: '0', child: Text('0. Tidak/Belum Pernah Sekolah')),
                    DropdownMenuItem(value: '1', child: Text('1. Masih Sekolah')),
                    DropdownMenuItem(value: '2', child: Text('2. Tidak Bersekolah Lagi')),
                  ],
                  onChanged: (val) => setState(() => _tempMember.partisipasiSekolah = val),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: '34. Ijazah/STTB Tertinggi'),
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
                const SizedBox(height: 12),
                _buildIncomeField('b. Tunjangan', _tempMember.tunjangan, (val) => setState(() => _tempMember.tunjangan = val)),
                const SizedBox(height: 12),
                _buildIncomeField('c. Uang Makan', _tempMember.uangMakan, (val) => setState(() => _tempMember.uangMakan = val)),
                const SizedBox(height: 12),
                _buildIncomeField('d. Honor', _tempMember.honor, (val) => setState(() => _tempMember.honor = val)),
                const SizedBox(height: 12),
                _buildIncomeField('e. Lembur', _tempMember.lembur, (val) => setState(() => _tempMember.lembur = val)),
                const SizedBox(height: 12),
                _buildIncomeField('f. Lainnya', _tempMember.pendapatanLain, (val) => setState(() => _tempMember.pendapatanLain = val)),
                
                const SizedBox(height: 16),
                
                // Total Income Autofill Display
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Total Pendapatan Pekerjaan (Autofill)',
                    prefixText: 'Rp. ',
                  ),
                  readOnly: true,
                  controller: TextEditingController(text: _calculateTotalIncome()),
                ),
                const SizedBox(height: 16),

                _buildIncomeField('35. b. Pendapatan dari Usaha (Warung/Affiliate/etc.)', _tempMember.pendapatanUsaha, (val) => setState(() => _tempMember.pendapatanUsaha = val)),
                const SizedBox(height: 16),
                _buildIncomeField('35. c. Pendapatan Lain (Pensiunan/Passive/etc.)', _tempMember.pendapatanPassive, (val) => setState(() => _tempMember.pendapatanPassive = val)),
                const SizedBox(height: 16),

                // Profesi
                TextFormField(
                  initialValue: _tempMember.profesi,
                  decoration: const InputDecoration(
                    labelText: '36. Profesi Pekerjaan Utama',
                    helperText: 'Jika tidak bekerja, tulis strip (-)',
                  ),
                  onChanged: (val) => setState(() => _tempMember.profesi = val),
                ),
                const SizedBox(height: 16),

                // Status Kedudukan
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: '37. Status Kedudukan Pekerjaan Utama'),
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
              _buildDisabilitySwitch('Disabilitas Fisik', _tempMember.disabilitasFisik, (val) => setState(() => _tempMember.disabilitasFisik = val)),
              _buildDisabilitySwitch('Disabilitas Mental', _tempMember.disabilitasMental, (val) => setState(() => _tempMember.disabilitasMental = val)),
              _buildDisabilitySwitch('Disabilitas Intelektual', _tempMember.disabilitasIntelektual, (val) => setState(() => _tempMember.disabilitasIntelektual = val)),
              _buildDisabilitySwitch('Disabilitas Sensorik Netra', _tempMember.disabilitasNetra, (val) => setState(() => _tempMember.disabilitasNetra = val)),
              _buildDisabilitySwitch('Disabilitas Sensorik Rungu', _tempMember.disabilitasRungu, (val) => setState(() => _tempMember.disabilitasRungu = val)),
              _buildDisabilitySwitch('Disabilitas Sensorik Wicara', _tempMember.disabilitasWicara, (val) => setState(() => _tempMember.disabilitasWicara = val)),
              
              const Divider(height: 48),

              // Penyakit Kronis (39)
              Text(
                '39. Keluhan Kesehatan Kronis / Menahun',
                style: theme.textTheme.titleMedium?.copyWith(color: theme.primaryColor, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _buildDisabilitySwitch('Hipertensi', _tempMember.hipertensi, (val) => setState(() => _tempMember.hipertensi = val)),
              _buildDisabilitySwitch('Rematik', _tempMember.rematik, (val) => setState(() => _tempMember.rematik = val)),
              _buildDisabilitySwitch('Asma', _tempMember.asma, (val) => setState(() => _tempMember.asma = val)),
              _buildDisabilitySwitch('Masalah Jantung', _tempMember.jantung, (val) => setState(() => _tempMember.jantung = val)),
              _buildDisabilitySwitch('Diabetes (Kencing Manis)', _tempMember.diabetes, (val) => setState(() => _tempMember.diabetes = val)),
              _buildDisabilitySwitch('Tuberkulosis (TBC)', _tempMember.tbc, (val) => setState(() => _tempMember.tbc = val)),
              _buildDisabilitySwitch('Stroke', _tempMember.stroke, (val) => setState(() => _tempMember.stroke = val)),
              _buildDisabilitySwitch('Kanker / Tumor Ganas', _tempMember.kanker, (val) => setState(() => _tempMember.kanker = val)),
              _buildDisabilitySwitch('Gagal Ginjal', _tempMember.ginjal, (val) => setState(() => _tempMember.ginjal = val)),
              _buildDisabilitySwitch('Hemofilia', _tempMember.hemofilia, (val) => setState(() => _tempMember.hemofilia = val)),
              _buildDisabilitySwitch('HIV/AIDS', _tempMember.hiv, (val) => setState(() => _tempMember.hiv = val)),
              _buildDisabilitySwitch('Kolesterol', _tempMember.kolesterol, (val) => setState(() => _tempMember.kolesterol = val)),
              _buildDisabilitySwitch('Sirosis Hati', _tempMember.sirosis, (val) => setState(() => _tempMember.sirosis = val)),
              _buildDisabilitySwitch('Talasemia', _tempMember.talasemia, (val) => setState(() => _tempMember.talasemia = val)),
              _buildDisabilitySwitch('Leukemia', _tempMember.leukemia, (val) => setState(() => _tempMember.leukemia = val)),
              _buildDisabilitySwitch('Alzheimer', _tempMember.alzheimer, (val) => setState(() => _tempMember.alzheimer = val)),
              _buildDisabilitySwitch('Lainnya', _tempMember.sakitLainnya, (val) => setState(() => _tempMember.sakitLainnya = val)),

              const Divider(height: 48),

              // Rekening Digital (40) (Conditional: Age >= 5 years)
              if (age >= 5) ...[
                Text(
                  '40. Kepemilikan Rekening / Dompet Digital',
                  style: theme.textTheme.titleMedium?.copyWith(color: theme.primaryColor, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Jenis Kepemilikan'),
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
                const SizedBox(height: 24),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIncomeField(String label, String? initialValue, void Function(String) onChanged) {
    return TextFormField(
      initialValue: initialValue,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        prefixText: 'Rp. ',
      ),
      onChanged: (val) {
        onChanged(val);
        setState(() {}); // refresh sum calculation display
      },
    );
  }

  String _calculateTotalIncome() {
    final double g = double.tryParse(_tempMember.gaji ?? '0') ?? 0;
    final double t = double.tryParse(_tempMember.tunjangan ?? '0') ?? 0;
    final double u = double.tryParse(_tempMember.uangMakan ?? '0') ?? 0;
    final double h = double.tryParse(_tempMember.honor ?? '0') ?? 0;
    final double l = double.tryParse(_tempMember.lembur ?? '0') ?? 0;
    final double o = double.tryParse(_tempMember.pendapatanLain ?? '0') ?? 0;
    return (g + t + u + h + l + o).toStringAsFixed(0);
  }

  Widget _buildDisabilitySwitch(String label, String? currentValue, void Function(String) onChanged) {
    final bool isOn = currentValue == '1';
    final theme = Theme.of(context);

    return SwitchListTile(
      title: Text(label, style: const TextStyle(fontSize: 14)),
      value: isOn,
      activeColor: theme.primaryColor,
      onChanged: (bool value) {
        onChanged(value ? '1' : '2');
      },
    );
  }
}
