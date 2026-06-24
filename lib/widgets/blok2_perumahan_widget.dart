import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/survey_provider.dart';

class Blok2PerumahanWidget extends StatelessWidget {
  const Blok2PerumahanWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SurveyProvider>(context);
    final survey = provider.activeSurvey!;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Keterangan Perumahan',
          style: theme.textTheme.titleLarge?.copyWith(color: theme.primaryColor),
        ),
        const SizedBox(height: 8),
        const Text(
          'Lengkapi data terkait kualitas fisik bangunan, fasilitas sanitasi, air minum, dan kelistrikan.',
          style: TextStyle(fontSize: 14),
        ),
        const Divider(height: 32),

        // 5.a Jumlah keluarga tinggal dalam 1 rumah
        TextFormField(
          initialValue: survey.jmlKeluargaTinggal?.toString() ?? '',
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: '5. a. Berapa jumlah keluarga yang tinggal dalam 1 rumah/tempat tinggal?',
            helperText: 'Jika isian = 1, rincian 5.b dilewati',
          ),
          onChanged: (val) {
            final parsed = int.tryParse(val) ?? 1;
            provider.updateActiveSurvey((s) => s.jmlKeluargaTinggal = parsed);
          },
        ),
        const SizedBox(height: 16),

        // 5.b Nomor KK lain (Conditional: Only show if 5.a > 1)
        if ((survey.jmlKeluargaTinggal ?? 1) > 1) ...[
          TextFormField(
            initialValue: survey.noKkLain,
            keyboardType: TextInputType.number,
            maxLength: 16,
            decoration: const InputDecoration(
              labelText: '5. b. Sebutkan Nomor KK dari keluarga yang tinggal bersama!',
              counterText: '',
            ),
            onChanged: (val) => provider.updateActiveSurvey((s) => s.noKkLain = val),
          ),
          const SizedBox(height: 16),
        ],

        // 6.a Jenis Bangunan
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(labelText: '6. a. Apa jenis bangunan tempat tinggal yang ditempati?'),
          value: survey.jenisBangunan,
          items: const [
            DropdownMenuItem(value: '1', child: Text('1. Rumah tinggal tunggal')),
            DropdownMenuItem(value: '2', child: Text('2. Apartemen')),
            DropdownMenuItem(value: '3', child: Text('3. Rumah susun')),
            DropdownMenuItem(value: '4', child: Text('4. Rumah deret')),
            DropdownMenuItem(value: '5', child: Text('5. Kos')),
          ],
          onChanged: (val) => provider.updateActiveSurvey((s) => s.jenisBangunan = val),
        ),
        const SizedBox(height: 16),

        // 6.b Nama/Nomor Lantai (Conditional: Only show if 6.a is Apartemen or Rusun (2, 3))
        if (survey.jenisBangunan == '2' || survey.jenisBangunan == '3') ...[
          TextFormField(
            initialValue: survey.namaNoLantai,
            decoration: const InputDecoration(
              labelText: '6. b. Jika apartemen/rumah susun, tuliskan Nama/Nomor lantai',
            ),
            onChanged: (val) => provider.updateActiveSurvey((s) => s.namaNoLantai = val),
          ),
          const SizedBox(height: 16),
        ],

        // 7.a Status kepemilikan bangunan
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(labelText: '7. a. Apa status kepemilikan bangunan tempat tinggal?'),
          value: survey.statusKepemilikan,
          items: const [
            DropdownMenuItem(value: '1', child: Text('1. Milik sendiri')),
            DropdownMenuItem(value: '2', child: Text('2. Kontrak/sewa')),
            DropdownMenuItem(value: '3', child: Text('3. Bebas sewa')),
            DropdownMenuItem(value: '4', child: Text('4. Dinas')),
            DropdownMenuItem(value: '5', child: Text('5. Lainnya')),
          ],
          onChanged: (val) => provider.updateActiveSurvey((s) => s.statusKepemilikan = val),
        ),
        const SizedBox(height: 16),

        // 7.b Bukti kepemilikan (Conditional: Only show if 7.a is Milik Sendiri (1))
        if (survey.statusKepemilikan == '1') ...[
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: '7. b. Apa jenis bukti kepemilikan tanah & bangunan?'),
            value: survey.buktiKepemilikan,
            items: const [
              DropdownMenuItem(value: '1', child: Text('1. SHM')),
              DropdownMenuItem(value: '2', child: Text('2. Sertifikat selain SHM (SHGB, SHSRS)')),
              DropdownMenuItem(value: '3', child: Text('3. Surat bukti lainnya (Girik, Letter C, dll)')),
              DropdownMenuItem(value: '4', child: Text('4. Tidak punya')),
            ],
            onChanged: (val) => provider.updateActiveSurvey((s) => s.buktiKepemilikan = val),
          ),
          const SizedBox(height: 16),
        ],

        // 8 Perkiraan Sewa Sebulan (Label changes depending on 7.a status)
        if (survey.statusKepemilikan != null) ...[
          TextFormField(
            initialValue: survey.sewaPerkiraan,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: _getSewaLabel(survey.statusKepemilikan!),
              prefixText: 'Rp. ',
            ),
            onChanged: (val) => provider.updateActiveSurvey((s) => s.sewaPerkiraan = val),
          ),
          const SizedBox(height: 16),
        ],

        // 9 Luas lantai
        TextFormField(
          initialValue: survey.luasLantai?.toString() ?? '',
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: '9. Berapa luas lantai bangunan tempat tinggal?',
            suffixText: 'm²',
          ),
          onChanged: (val) => provider.updateActiveSurvey((s) => s.luasLantai = int.tryParse(val) ?? 0),
        ),
        const SizedBox(height: 16),

        // 10.a Bahan Lantai Terluas
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(labelText: '10. a. Apa bahan bangunan utama lantai rumah terluas?'),
          value: survey.bahanLantai,
          items: const [
            DropdownMenuItem(value: '1', child: Text('1. Marmer/granit')),
            DropdownMenuItem(value: '2', child: Text('2. Keramik')),
            DropdownMenuItem(value: '3', child: Text('3. Parket/vinil/karpet')),
            DropdownMenuItem(value: '4', child: Text('4. Ubin/tegel/teraso')),
            DropdownMenuItem(value: '5', child: Text('5. Kayu/papan')),
            DropdownMenuItem(value: '6', child: Text('6. Semen/bata merah')),
            DropdownMenuItem(value: '7', child: Text('7. Bambu')),
            DropdownMenuItem(value: '8', child: Text('8. Tanah')),
            DropdownMenuItem(value: '9', child: Text('9. Lainnya')),
          ],
          onChanged: (val) => provider.updateActiveSurvey((s) => s.bahanLantai = val),
        ),
        const SizedBox(height: 16),

        // 10.b Kondisi Lantai
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(labelText: '10. b. Kondisi Lantai'),
          value: survey.kondisiLantai,
          items: const [
            DropdownMenuItem(value: '1', child: Text('1. Baik')),
            DropdownMenuItem(value: '2', child: Text('2. Rusak Ringan')),
            DropdownMenuItem(value: '3', child: Text('3. Rusak Sedang')),
            DropdownMenuItem(value: '4', child: Text('4. Rusak Berat')),
          ],
          onChanged: (val) => provider.updateActiveSurvey((s) => s.kondisiLantai = val),
        ),
        const SizedBox(height: 16),

        // 11.a Bahan Dinding Terluas
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(labelText: '11. a. Apa bahan bangunan utama dinding rumah terluas?'),
          value: survey.bahanDinding,
          items: const [
            DropdownMenuItem(value: '1', child: Text('1. Tembok')),
            DropdownMenuItem(value: '2', child: Text('2. Plesteran anyaman bambu/kawat')),
            DropdownMenuItem(value: '3', child: Text('3. Kayu/papan/gipsum/GRC')),
            DropdownMenuItem(value: '4', child: Text('4. Anyaman bambu')),
            DropdownMenuItem(value: '5', child: Text('5. Batang kayu')),
            DropdownMenuItem(value: '6', child: Text('6. Bambu')),
            DropdownMenuItem(value: '7', child: Text('7. Lainnya')),
          ],
          onChanged: (val) => provider.updateActiveSurvey((s) => s.bahanDinding = val),
        ),
        const SizedBox(height: 16),

        // 11.b Kondisi Dinding
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(labelText: '11. b. Kondisi Dinding'),
          value: survey.kondisiDinding,
          items: const [
            DropdownMenuItem(value: '1', child: Text('1. Baik')),
            DropdownMenuItem(value: '2', child: Text('2. Rusak Ringan')),
            DropdownMenuItem(value: '3', child: Text('3. Rusak Sedang')),
            DropdownMenuItem(value: '4', child: Text('4. Rusak Berat')),
          ],
          onChanged: (val) => provider.updateActiveSurvey((s) => s.kondisiDinding = val),
        ),
        const SizedBox(height: 16),

        // 12.a Bahan Atap Terluas
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(labelText: '12. a. Apa bahan bangunan utama atap rumah terluas?'),
          value: survey.bahanAtap,
          items: const [
            DropdownMenuItem(value: '1', child: Text('1. Beton')),
            DropdownMenuItem(value: '2', child: Text('2. Genteng')),
            DropdownMenuItem(value: '3', child: Text('3. Seng')),
            DropdownMenuItem(value: '4', child: Text('4. Asbes')),
            DropdownMenuItem(value: '5', child: Text('5. Bambu')),
            DropdownMenuItem(value: '6', child: Text('6. Kayu/sirap')),
            DropdownMenuItem(value: '7', child: Text('7. Jerami/daun-daunan/rumbia')),
            DropdownMenuItem(value: '8', child: Text('8. Lainnya')),
          ],
          onChanged: (val) => provider.updateActiveSurvey((s) => s.bahanAtap = val),
        ),
        const SizedBox(height: 16),

        // 12.b Kondisi Atap
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(labelText: '12. b. Kondisi Atap'),
          value: survey.kondisiAtap,
          items: const [
            DropdownMenuItem(value: '1', child: Text('1. Baik')),
            DropdownMenuItem(value: '2', child: Text('2. Rusak Ringan')),
            DropdownMenuItem(value: '3', child: Text('3. Rusak Sedang')),
            DropdownMenuItem(value: '4', child: Text('4. Rusak Berat')),
          ],
          onChanged: (val) => provider.updateActiveSurvey((s) => s.kondisiAtap = val),
        ),
        const SizedBox(height: 16),

        // 13 Fasilitas Sanitasi (BAB)
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            labelText: '13. Fasilitas tempat buang air besar & siapa yang menggunakan?',
          ),
          value: survey.fasilitasBab,
          items: const [
            DropdownMenuItem(value: '1', child: Text('1. Ada, digunakan anggota keluarga sendiri')),
            DropdownMenuItem(value: '2', child: Text('2. Ada, digunakan bersama beberapa rumah')),
            DropdownMenuItem(value: '3', child: Text('3. Ada, di MCK komunal')),
            DropdownMenuItem(value: '4', child: Text('4. Ada, di MCK umum')),
            DropdownMenuItem(value: '5', child: Text('5. Ada, anggota keluarga tidak menggunakan')),
            DropdownMenuItem(value: '6', child: Text('6. Tidak ada')),
          ],
          onChanged: (val) => provider.updateActiveSurvey((s) => s.fasilitasBab = val),
        ),
        const SizedBox(height: 16),

        // 14 Jenis Kloset (Conditional: Only show if 13 is 1, 2, 3)
        if (survey.fasilitasBab == '1' || survey.fasilitasBab == '2' || survey.fasilitasBab == '3') ...[
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: '14. Apa jenis kloset yang digunakan?'),
            value: survey.jenisKloset,
            items: const [
              DropdownMenuItem(value: '1', child: Text('1. Leher angsa')),
              DropdownMenuItem(value: '2', child: Text('2. Plengsengan dengan tutup')),
              DropdownMenuItem(value: '3', child: Text('3. Plengsengan tanpa tutup')),
              DropdownMenuItem(value: '4', child: Text('4. Cemplung/cubluk')),
            ],
            onChanged: (val) => provider.updateActiveSurvey((s) => s.jenisKloset = val),
          ),
          const SizedBox(height: 16),
        ],

        // 15 Tempat pembuangan tinja
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(labelText: '15. Di manakah tempat pembuangan akhir tinja?'),
          value: survey.pembuanganTinja,
          items: const [
            DropdownMenuItem(value: '1', child: Text('1. Tangki septik')),
            DropdownMenuItem(value: '2', child: Text('2. IPAL')),
            DropdownMenuItem(value: '3', child: Text('3. Kolam/sawah/sungai/danau/laut')),
            DropdownMenuItem(value: '4', child: Text('4. Lubang tanah')),
            DropdownMenuItem(value: '5', child: Text('5. Pantai/tanah lapang/kebun')),
            DropdownMenuItem(value: '6', child: Text('6. Lainnya')),
          ],
          onChanged: (val) => provider.updateActiveSurvey((s) => s.pembuanganTinja = val),
        ),
        const SizedBox(height: 16),

        // 16 Sumber Air Minum
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(labelText: '16. Apa sumber air utama untuk minum?'),
          value: survey.sumberAirMinum,
          items: const [
            DropdownMenuItem(value: '1', child: Text('1. Air kemasan bermerek')),
            DropdownMenuItem(value: '2', child: Text('2. Air isi ulang')),
            DropdownMenuItem(value: '3', child: Text('3. Leding')),
            DropdownMenuItem(value: '4', child: Text('4. Sumur bor/pompa')),
            DropdownMenuItem(value: '5', child: Text('5. Sumur terlindung')),
            DropdownMenuItem(value: '6', child: Text('6. Sumur tak terlindung')),
            DropdownMenuItem(value: '7', child: Text('7. Mata air terlindung')),
            DropdownMenuItem(value: '8', child: Text('8. Mata air tak terlindung')),
            DropdownMenuItem(value: '9', child: Text('9. Air permukaan (sungai/waduk/irigasi)')),
            DropdownMenuItem(value: '10', child: Text('10. Air hujan')),
            DropdownMenuItem(value: '11', child: Text('11. Lainnya')),
          ],
          onChanged: (val) => provider.updateActiveSurvey((s) => s.sumberAirMinum = val),
        ),
        const SizedBox(height: 16),

        // 17 Sumber Penerangan Utama
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(labelText: '17. Apa sumber penerangan utama rumah ini?'),
          value: survey.sumberPenerangan,
          items: const [
            DropdownMenuItem(value: '1', child: Text('1. Listrik PLN dengan meteran')),
            DropdownMenuItem(value: '2', child: Text('2. Listrik PLN tanpa meteran')),
            DropdownMenuItem(value: '3', child: Text('3. Listrik non-PLN')),
            DropdownMenuItem(value: '4', child: Text('4. Bukan listrik')),
          ],
          onChanged: (val) => provider.updateActiveSurvey((s) => s.sumberPenerangan = val),
        ),
        const SizedBox(height: 16),

        // 18.a Jumlah meteran (Conditional: Only show if 17 is Listrik PLN dengan meteran (1))
        if (survey.sumberPenerangan == '1') ...[
          DropdownButtonFormField<int>(
            decoration: const InputDecoration(labelText: '18. a. Berapa jumlah meteran listrik terpasang?'),
            value: survey.meteranPlnCount,
            items: const [
              DropdownMenuItem(value: 1, child: Text('1 Meteran')),
              DropdownMenuItem(value: 2, child: Text('2 Meteran')),
            ],
            onChanged: (val) => provider.updateActiveSurvey((s) => s.meteranPlnCount = val ?? 1),
          ),
          const SizedBox(height: 16),

          // Meteran Grid
          _buildMeteranInputs(context, survey, provider),
          const SizedBox(height: 16),
        ],

        // 19 Pengeluaran listrik sebulan
        TextFormField(
          initialValue: survey.pengeluaranListrik,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: '19. Berapa nilai pengeluaran listrik sebulan?',
            prefixText: 'Rp. ',
          ),
          onChanged: (val) => provider.updateActiveSurvey((s) => s.pengeluaranListrik = val),
        ),
        const SizedBox(height: 16),

        // 20 Pengeluaran pulsa sebulan
        TextFormField(
          initialValue: survey.pengeluaranInternet,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: '20. Berapa pengeluaran pulsa & internet seluruh anggota sebulan?',
            prefixText: 'Rp. ',
          ),
          onChanged: (val) => provider.updateActiveSurvey((s) => s.pengeluaranInternet = val),
        ),
        const SizedBox(height: 24),

        // 21 Foto Rumah
        Text(
          '21. Foto Rumah (Pencerminan Kualitas Bangunan)',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildPhotoPicker(
              context,
              'Tampak Depan',
              survey.fotoDepanUrl,
              (url) => provider.updateActiveSurvey((s) => s.fotoDepanUrl = url),
            ),
            _buildPhotoPicker(
              context,
              'Ruang Tamu',
              survey.fotoTamuUrl,
              (url) => provider.updateActiveSurvey((s) => s.fotoTamuUrl = url),
            ),
            _buildPhotoPicker(
              context,
              'Kamar Mandi',
              survey.fotoMandiUrl,
              (url) => provider.updateActiveSurvey((s) => s.fotoMandiUrl = url),
            ),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  String _getSewaLabel(String status) {
    switch (status) {
      case '1':
      case '3':
        return '8. a. Perkiraan sewa sebulan jika milik sendiri/bebas sewa';
      case '2':
        return '8. b. Nilai sewa/kontrak sebulan';
      case '4':
      case '5':
      default:
        return '8. c. Perkiraan sewa sebulan jika dinas atau lainnya';
    }
  }

  Widget _buildMeteranInputs(BuildContext context, var survey, var provider) {
    final theme = Theme.of(context);
    final count = survey.meteranPlnCount ?? 1;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Rincian Daya & ID Pelanggan PLN', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          
          // Meteran 1
          Text('Meteran Listrik 1', style: TextStyle(color: theme.primaryColor, fontSize: 13)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: 'Daya Listrik (Meteran 1)'),
            value: survey.dayaMeteran1,
            items: const [
              DropdownMenuItem(value: '1', child: Text('1. 450 watt')),
              DropdownMenuItem(value: '2', child: Text('2. 900 watt')),
              DropdownMenuItem(value: '3', child: Text('3. 1.300 watt')),
              DropdownMenuItem(value: '4', child: Text('4. 2.200 watt')),
              DropdownMenuItem(value: '5', child: Text('5. >2.200 watt')),
            ],
            onChanged: (val) => provider.updateActiveSurvey((s) => s.dayaMeteran1 = val),
          ),
          const SizedBox(height: 8),
          TextFormField(
            initialValue: survey.idPelanggan1,
            keyboardType: TextInputType.number,
            maxLength: 12,
            decoration: const InputDecoration(labelText: 'ID Pelanggan (11-12 digit)', counterText: ''),
            onChanged: (val) => provider.updateActiveSurvey((s) => s.idPelanggan1 = val),
          ),
          
          // Meteran 2
          if (count > 1) ...[
            const Divider(height: 24),
            Text('Meteran Listrik 2', style: TextStyle(color: theme.primaryColor, fontSize: 13)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Daya Listrik (Meteran 2)'),
              value: survey.dayaMeteran2,
              items: const [
                DropdownMenuItem(value: '1', child: Text('1. 450 watt')),
                DropdownMenuItem(value: '2', child: Text('2. 900 watt')),
                DropdownMenuItem(value: '3', child: Text('3. 1.300 watt')),
                DropdownMenuItem(value: '4', child: Text('4. 2.200 watt')),
                DropdownMenuItem(value: '5', child: Text('5. >2.200 watt')),
              ],
              onChanged: (val) => provider.updateActiveSurvey((s) => s.dayaMeteran2 = val),
            ),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: survey.idPelanggan2,
              keyboardType: TextInputType.number,
              maxLength: 12,
              decoration: const InputDecoration(labelText: 'ID Pelanggan (11-12 digit)', counterText: ''),
              onChanged: (val) => provider.updateActiveSurvey((s) => s.idPelanggan2 = val),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildPhotoPicker(BuildContext context, String label, String? currentUrl, void Function(String) onPicked) {
    final theme = Theme.of(context);
    final hasPhoto = currentUrl != null && currentUrl.isNotEmpty;

    return GestureDetector(
      onTap: () {
        // Simulate Camera input by assigning a mock local path/URL
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        onPicked('https://images.unsplash.com/photo-1570129477492-45c003edd2be?q=80&w=200&t=$timestamp');
      },
      child: Column(
        children: [
          Container(
            height: 80,
            width: 80,
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: hasPhoto ? theme.primaryColor : theme.dividerColor),
              image: hasPhoto
                  ? DecorationImage(image: NetworkImage(currentUrl), fit: BoxFit.cover)
                  : null,
            ),
            child: !hasPhoto
                ? const Icon(Icons.camera_alt_outlined, size: 28, color: Colors.grey)
                : null,
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 11)),
        ],
      ),
    );
  }
}
