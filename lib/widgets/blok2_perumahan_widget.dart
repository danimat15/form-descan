import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/survey_provider.dart';
import 'form_helpers.dart';

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
        _buildTextFormField(
          label: '5. a. Berapa jumlah keluarga yang tinggal dalam 1 rumah/tempat tinggal? *',
          value: survey.jmlKeluargaTinggal?.toString() ?? '',
          keyboardType: TextInputType.number,
          helperText: 'Jika isian = 1, rincian 5.b dilewati',
          onChanged: (val) {
            final parsed = int.tryParse(val) ?? 1;
            provider.updateActiveSurvey((s) => s.jmlKeluargaTinggal = parsed);
          },
        ),

        // 5.b Nomor KK lain (Conditional: Only show if 5.a > 1)
        if ((survey.jmlKeluargaTinggal ?? 1) > 1)
          _buildTextFormField(
            label: '5. b. Sebutkan Nomor KK dari keluarga yang tinggal bersama!',
            value: survey.noKkLain,
            keyboardType: TextInputType.number,
            maxLength: 16,
            onChanged: (val) => provider.updateActiveSurvey((s) => s.noKkLain = val),
          ),

        // 6.a Jenis Bangunan
        _buildDropdownButtonFormField<String>(
          label: '6. a. Apa jenis bangunan tempat tinggal yang ditempati? *',
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

        // 6.b Nama/Nomor Lantai (Conditional: Only show if 6.a is Apartemen or Rusun (2, 3))
        if (survey.jenisBangunan == '2' || survey.jenisBangunan == '3')
          _buildTextFormField(
            label: '6. b. Jika apartemen/rumah susun, tuliskan Nama/Nomor lantai',
            value: survey.namaNoLantai,
            onChanged: (val) => provider.updateActiveSurvey((s) => s.namaNoLantai = val),
          ),

        // 7.a Status kepemilikan bangunan
        _buildDropdownButtonFormField<String>(
          label: '7. a. Apa status kepemilikan bangunan tempat tinggal? *',
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

        // 7.b Bukti kepemilikan (Conditional: Only show if 7.a is Milik Sendiri (1))
        if (survey.statusKepemilikan == '1')
          _buildDropdownButtonFormField<String>(
            label: '7. b. Apa jenis bukti kepemilikan tanah & bangunan?',
            value: survey.buktiKepemilikan,
            items: const [
              DropdownMenuItem(value: '1', child: Text('1. SHM')),
              DropdownMenuItem(value: '2', child: Text('2. Sertifikat selain SHM (SHGB, SHSRS)')),
              DropdownMenuItem(value: '3', child: Text('3. Surat bukti lainnya (Girik, Letter C, dll)')),
              DropdownMenuItem(value: '4', child: Text('4. Tidak punya')),
            ],
            onChanged: (val) => provider.updateActiveSurvey((s) => s.buktiKepemilikan = val),
          ),

        // 8 Perkiraan Sewa Sebulan (Label changes depending on 7.a status)
        if (survey.statusKepemilikan != null)
          _buildTextFormField(
            label: _getSewaLabel(survey.statusKepemilikan!),
            value: survey.sewaPerkiraan,
            keyboardType: TextInputType.number,
            prefixText: 'Rp. ',
            onChanged: (val) => provider.updateActiveSurvey((s) => s.sewaPerkiraan = val),
          ),

        // 9 Luas lantai
        _buildTextFormField(
          label: '9. Berapa luas lantai bangunan tempat tinggal?',
          value: formatDouble(survey.luasLantai),
          keyboardType: TextInputType.number,
          suffixText: 'm²',
          isDoubleInput: true,
          onChanged: (val) => provider.updateActiveSurvey((s) => s.luasLantai = parseIndonesianDouble(val)),
        ),

        // 10.a Bahan Lantai Terluas
        _buildDropdownButtonFormField<String>(
          label: '10. a. Apa bahan bangunan utama lantai rumah terluas?',
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

        // 10.b Kondisi Lantai
        _buildDropdownButtonFormField<String>(
          label: '10. b. Kondisi Lantai',
          value: survey.kondisiLantai,
          items: const [
            DropdownMenuItem(value: '1', child: Text('1. Baik')),
            DropdownMenuItem(value: '2', child: Text('2. Rusak Ringan')),
            DropdownMenuItem(value: '3', child: Text('3. Rusak Sedang')),
            DropdownMenuItem(value: '4', child: Text('4. Rusak Berat')),
          ],
          onChanged: (val) => provider.updateActiveSurvey((s) => s.kondisiLantai = val),
        ),

        // 11.a Bahan Dinding Terluas
        _buildDropdownButtonFormField<String>(
          label: '11. a. Apa bahan bangunan utama dinding rumah terluas?',
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

        // 11.b Kondisi Dinding
        _buildDropdownButtonFormField<String>(
          label: '11. b. Kondisi Dinding',
          value: survey.kondisiDinding,
          items: const [
            DropdownMenuItem(value: '1', child: Text('1. Baik')),
            DropdownMenuItem(value: '2', child: Text('2. Rusak Ringan')),
            DropdownMenuItem(value: '3', child: Text('3. Rusak Sedang')),
            DropdownMenuItem(value: '4', child: Text('4. Rusak Berat')),
          ],
          onChanged: (val) => provider.updateActiveSurvey((s) => s.kondisiDinding = val),
        ),

        // 12.a Bahan Atap Terluas
        _buildDropdownButtonFormField<String>(
          label: '12. a. Apa bahan bangunan utama atap rumah terluas?',
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

        // 12.b Kondisi Atap
        _buildDropdownButtonFormField<String>(
          label: '12. b. Kondisi Atap',
          value: survey.kondisiAtap,
          items: const [
            DropdownMenuItem(value: '1', child: Text('1. Baik')),
            DropdownMenuItem(value: '2', child: Text('2. Rusak Ringan')),
            DropdownMenuItem(value: '3', child: Text('3. Rusak Sedang')),
            DropdownMenuItem(value: '4', child: Text('4. Rusak Berat')),
          ],
          onChanged: (val) => provider.updateActiveSurvey((s) => s.kondisiAtap = val),
        ),

        // 13 Fasilitas Sanitasi (BAB)
        _buildDropdownButtonFormField<String>(
          label: '13. Fasilitas tempat buang air besar & siapa yang menggunakan?',
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

        // 14 Jenis Kloset (Conditional: Only show if 13 is 1, 2, 3)
        if (survey.fasilitasBab == '1' || survey.fasilitasBab == '2' || survey.fasilitasBab == '3')
          _buildDropdownButtonFormField<String>(
            label: '14. Apa jenis kloset yang digunakan?',
            value: survey.jenisKloset,
            items: const [
              DropdownMenuItem(value: '1', child: Text('1. Leher angsa')),
              DropdownMenuItem(value: '2', child: Text('2. Plengsengan dengan tutup')),
              DropdownMenuItem(value: '3', child: Text('3. Plengsengan tanpa tutup')),
              DropdownMenuItem(value: '4', child: Text('4. Cemplung/cubluk')),
            ],
            onChanged: (val) => provider.updateActiveSurvey((s) => s.jenisKloset = val),
          ),

        // 15 Tempat pembuangan tinja
        _buildDropdownButtonFormField<String>(
          label: '15. Di manakah tempat pembuangan akhir tinja?',
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

        // 16 Sumber Air Minum
        _buildDropdownButtonFormField<String>(
          label: '16. Apa sumber air utama untuk minum? *',
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

        // 17 Sumber Penerangan Utama
        _buildDropdownButtonFormField<String>(
          label: '17. Apa sumber penerangan utama rumah ini? *',
          value: survey.sumberPenerangan,
          items: const [
            DropdownMenuItem(value: '1', child: Text('1. Listrik PLN dengan meteran')),
            DropdownMenuItem(value: '2', child: Text('2. Listrik PLN tanpa meteran')),
            DropdownMenuItem(value: '3', child: Text('3. Listrik non-PLN')),
            DropdownMenuItem(value: '4', child: Text('4. Bukan listrik')),
          ],
          onChanged: (val) => provider.updateActiveSurvey((s) => s.sumberPenerangan = val),
        ),

        // 18.a Jumlah meteran (Conditional: Only show if 17 is Listrik PLN dengan meteran (1))
        if (survey.sumberPenerangan == '1') ...[
          _buildDropdownButtonFormField<int>(
            label: '18. a. Berapa jumlah meteran listrik terpasang?',
            value: survey.meteranPlnCount,
            items: const [
              DropdownMenuItem(value: 1, child: Text('1 Meteran')),
              DropdownMenuItem(value: 2, child: Text('2 Meteran')),
            ],
            onChanged: (val) => provider.updateActiveSurvey((s) => s.meteranPlnCount = val ?? 1),
          ),

          // Meteran Grid
          _buildMeteranInputs(context, survey, provider),
          const SizedBox(height: 16),
        ],

        // 19 Pengeluaran listrik sebulan
        _buildTextFormField(
          label: '19. Berapa nilai pengeluaran listrik sebulan?',
          value: survey.pengeluaranListrik,
          keyboardType: TextInputType.number,
          prefixText: 'Rp. ',
          onChanged: (val) => provider.updateActiveSurvey((s) => s.pengeluaranListrik = val),
        ),

        // 20 Pengeluaran pulsa sebulan
        _buildTextFormField(
          label: '20. Berapa pengeluaran pulsa & internet seluruh anggota sebulan?',
          value: survey.pengeluaranInternet,
          keyboardType: TextInputType.number,
          prefixText: 'Rp. ',
          onChanged: (val) => provider.updateActiveSurvey((s) => s.pengeluaranInternet = val),
        ),

        // 21 Foto Rumah
        const FormLabel('21. Foto Rumah (Pencerminan Kualitas Bangunan)'),
        const SizedBox(height: 4),
        Column(
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
        const SizedBox(height: 24),
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
            decoration: getFormDecoration(value: survey.dayaMeteran1),
            isExpanded: true,
            initialValue: survey.dayaMeteran1,
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
            decoration: getFormDecoration(value: survey.idPelanggan1, hintText: 'ID Pelanggan (11-12 digit)'),
            onChanged: (val) => provider.updateActiveSurvey((s) => s.idPelanggan1 = val),
          ),

          // Meteran 2
          if (count > 1) ...[
            const Divider(height: 24),
            Text('Meteran Listrik 2', style: TextStyle(color: theme.primaryColor, fontSize: 13)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              decoration: getFormDecoration(value: survey.dayaMeteran2),
              isExpanded: true,
              initialValue: survey.dayaMeteran2,
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
              decoration: getFormDecoration(value: survey.idPelanggan2, hintText: 'ID Pelanggan (11-12 digit)'),
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
      onTap: () async {
        final ImagePicker picker = ImagePicker();
        try {
          final XFile? image = await picker.pickImage(
            source: ImageSource.camera,
            maxWidth: 1200,
            imageQuality: 80,
          );
          if (image != null) {
            onPicked(image.path);
          }
        } catch (e) {
          debugPrint('Error picking image: $e');
          // fallback simulator in case of error (e.g. no camera on emulator)
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          onPicked('https://images.unsplash.com/photo-1570129477492-45c003edd2be?q=80&w=600&t=$timestamp');
        }
      },
      child: Container(
        height: 150,
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasPhoto ? Colors.green.shade300 : theme.dividerColor,
            width: hasPhoto ? 2 : 1,
          ),
          image: hasPhoto
              ? DecorationImage(
                  image: currentUrl.startsWith('http')
                      ? NetworkImage(currentUrl) as ImageProvider
                      : FileImage(File(currentUrl)) as ImageProvider,
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: hasPhoto
            ? Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      const Row(
                        children: [
                          Icon(Icons.camera_alt, color: Colors.white, size: 16),
                          SizedBox(width: 4),
                          Text(
                            'Ubah Foto',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.camera_alt_outlined, size: 36, color: theme.primaryColor),
                  const SizedBox(height: 8),
                  Text(
                    'Ambil Foto $label',
                    style: TextStyle(
                      color: theme.primaryColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Ketuk untuk membuka kamera',
                    style: TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                ],
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
    int maxLines = 1,
    bool isDoubleInput = false,
  }) {
    final isFormatted = prefixText == 'Rp. ' || isDoubleInput;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FormLabel(label, helperText: helperText),
        TextFormField(
          initialValue: isFormatted ? formatThousands(value) : value,
          keyboardType: keyboardType,
          inputFormatters: isFormatted
              ? [ThousandsSeparatorInputFormatter()]
              : null,
          maxLength: maxLength,
          maxLines: maxLines,
          decoration: getFormDecoration(
            value: value,
            prefixText: prefixText,
            suffixText: suffixText,
          ),
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
}
