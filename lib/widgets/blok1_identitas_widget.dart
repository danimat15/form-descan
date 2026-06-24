import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/survey_provider.dart';

class Blok1IdentitasWidget extends StatelessWidget {
  const Blok1IdentitasWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SurveyProvider>(context);
    final survey = provider.activeSurvey!;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Keterangan Identitas Keluarga',
          style: theme.textTheme.titleLarge?.copyWith(color: theme.primaryColor),
        ),
        const SizedBox(height: 8),
        const Text(
          'Lengkapi data identitas kepala keluarga dan rincian alamat tempat tinggal.',
          style: TextStyle(fontSize: 14),
        ),
        const Divider(height: 32),

        // 1.a Nama Kepala Keluarga
        _buildTextField(
          label: '1. a. Nama Kepala Keluarga',
          initialValue: survey.namaKk,
          onChanged: (val) => provider.updateActiveSurvey((s) => s.namaKk = val),
        ),
        const SizedBox(height: 16),

        // 1.b NIK Kepala Keluarga
        _buildTextField(
          label: '1. b. NIK Kepala Keluarga',
          initialValue: survey.nikKk,
          keyboardType: TextInputType.number,
          maxLength: 16,
          onChanged: (val) => provider.updateActiveSurvey((s) => s.nikKk = val),
        ),
        const SizedBox(height: 16),

        // 1.c Nomor KK Kepala Keluarga
        _buildTextField(
          label: '1. c. Nomor KK Kepala Keluarga',
          initialValue: survey.noKk,
          keyboardType: TextInputType.number,
          maxLength: 16,
          onChanged: (val) => provider.updateActiveSurvey((s) => s.noKk = val),
        ),
        const SizedBox(height: 16),

        // 2.a Jumlah Anggota Keluarga sesuai KK
        _buildTextField(
          label: '2. a. Jumlah Anggota Keluarga sesuai KK',
          initialValue: survey.jmlAnggotaKk?.toString() ?? '',
          keyboardType: TextInputType.number,
          onChanged: (val) => provider.updateActiveSurvey((s) => s.jmlAnggotaKk = int.tryParse(val) ?? 0),
        ),
        const SizedBox(height: 16),

        // 2.b Jumlah Anggota Keluarga hasil pendataan (Autofill)
        TextFormField(
          decoration: const InputDecoration(
            labelText: '2. b. Jumlah Anggota Keluarga hasil pendataan (Autofill)',
            helperText: 'Otomatis dihitung dari jumlah anggota keluarga yang ditambahkan di Blok IV',
          ),
          readOnly: true,
          controller: TextEditingController(text: survey.jmlAnggotaPendataan?.toString() ?? '0'),
        ),
        const SizedBox(height: 24),

        Text(
          '3. Alamat Tempat Tinggal',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        // 3.a Provinsi & 3.b Kabupaten/Kota
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                label: 'Provinsi',
                initialValue: survey.provinsi,
                onChanged: (val) => provider.updateActiveSurvey((s) => s.provinsi = val),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                label: 'Kabupaten/Kota',
                initialValue: survey.kabupatenKota,
                onChanged: (val) => provider.updateActiveSurvey((s) => s.kabupatenKota = val),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // 3.c Kecamatan & 3.d Desa/Kelurahan
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                label: 'Kecamatan',
                initialValue: survey.kecamatan,
                onChanged: (val) => provider.updateActiveSurvey((s) => s.kecamatan = val),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                label: 'Desa/Kelurahan',
                initialValue: survey.desaKelurahan,
                onChanged: (val) => provider.updateActiveSurvey((s) => s.desaKelurahan = val),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // 3.e Klasifikasi Desa/Kota
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(labelText: '3. e. Klasifikasi Desa/Kota'),
          value: survey.klasifikasiDesa,
          items: const [
            DropdownMenuItem(value: '1', child: Text('1. Perkotaan')),
            DropdownMenuItem(value: '2', child: Text('2. Perdesaan')),
          ],
          onChanged: (val) => provider.updateActiveSurvey((s) => s.klasifikasiDesa = val),
        ),
        const SizedBox(height: 16),

        // 3.f Kode Pos & 3.g Kode SLS
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                label: '3. f. Kode Pos',
                initialValue: survey.kodePos,
                keyboardType: TextInputType.number,
                maxLength: 5,
                onChanged: (val) => provider.updateActiveSurvey((s) => s.kodePos = val),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                label: '3. g. Kode SLS',
                initialValue: survey.kodeSls,
                keyboardType: TextInputType.number,
                maxLength: 6,
                onChanged: (val) => provider.updateActiveSurvey((s) => s.kodeSls = val),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // 3.h Nama SLS
        _buildTextField(
          label: '3. h. Nama SLS',
          initialValue: survey.namaSls,
          onChanged: (val) => provider.updateActiveSurvey((s) => s.namaSls = val),
        ),
        const SizedBox(height: 16),

        // 3.i Alamat Jalan/Gang/RT/RW
        _buildTextField(
          label: '3. i. Alamat (Jalan/Gang/Nomor Rumah/RT/RW)',
          initialValue: survey.alamat,
          maxLines: 3,
          onChanged: (val) => provider.updateActiveSurvey((s) => s.alamat = val),
        ),
        const SizedBox(height: 16),

        // 3.j Nama Jalan
        _buildTextField(
          label: '3. j. Tuliskan Nama Jalan',
          initialValue: survey.namaJalan,
          helperText: 'Jika tidak ada nama jalan, tulis strip (-)',
          onChanged: (val) => provider.updateActiveSurvey((s) => s.namaJalan = val),
        ),
        const SizedBox(height: 16),

        // 3.k Nomor Rumah
        _buildTextField(
          label: '3. k. Tuliskan Nomor Rumah',
          initialValue: survey.noRumah,
          helperText: 'Jika tidak ada nomor rumah, tulis strip (-)',
          onChanged: (val) => provider.updateActiveSurvey((s) => s.noRumah = val),
        ),
        const SizedBox(height: 16),

        // 3.l Geotagging
        Row(
          children: [
            Expanded(
              child: TextFormField(
                decoration: const InputDecoration(labelText: 'Latitude'),
                readOnly: true,
                controller: TextEditingController(text: survey.latitude?.toStringAsFixed(6) ?? 'Not set'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                decoration: const InputDecoration(labelText: 'Longitude'),
                readOnly: true,
                controller: TextEditingController(text: survey.longitude?.toStringAsFixed(6) ?? 'Not set'),
              ),
            ),
            const SizedBox(width: 12),
            IconButton(
              icon: const Icon(Icons.my_location, color: Colors.teal),
              tooltip: 'Geotag Now',
              style: IconButton.styleFrom(
                backgroundColor: theme.primaryColor.withOpacity(0.1),
              ),
              onPressed: () {
                // Simulate Geotagging coords
                provider.updateActiveSurvey((s) {
                  s.latitude = -6.2088 + (valSeed() * 0.01);
                  s.longitude = 106.8456 + (valSeed() * 0.01);
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 24),

        // 4. Apakah alamat tersebut sesuai KK?
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            labelText: '4. Apakah alamat tersebut sesuai dengan alamat pada Kartu Keluarga?',
          ),
          value: survey.alamatSesuaiKk,
          items: const [
            DropdownMenuItem(value: '1', child: Text('1. Ya Sesuai KK')),
            DropdownMenuItem(value: '2', child: Text('2. Tidak Sesuai KK')),
          ],
          onChanged: (val) => provider.updateActiveSurvey((s) => s.alamatSesuaiKk = val),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  double valSeed() => (DateTime.now().millisecond / 1000.0) - 0.5;

  Widget _buildTextField({
    required String label,
    String? initialValue,
    TextInputType keyboardType = TextInputType.text,
    int? maxLength,
    int maxLines = 1,
    String? helperText,
    required void Function(String) onChanged,
  }) {
    return TextFormField(
      initialValue: initialValue,
      keyboardType: keyboardType,
      maxLength: maxLength,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        helperText: helperText,
        counterText: '',
      ),
      onChanged: onChanged,
    );
  }
}
