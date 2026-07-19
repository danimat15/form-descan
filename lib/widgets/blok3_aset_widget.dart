import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/survey_provider.dart';
import 'form_helpers.dart';

class Blok3AsetWidget extends StatelessWidget {
  const Blok3AsetWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SurveyProvider>(context);
    final survey = provider.activeSurvey!;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Keterangan Kepemilikan Aset',
          style: theme.textTheme.titleLarge?.copyWith(color: theme.primaryColor),
        ),
        const SizedBox(height: 8),
        const Text(
          'Lengkapi data terkait kepemilikan aset bergerak dan tidak bergerak dari keluarga.',
          style: TextStyle(fontSize: 14),
        ),
        const Divider(height: 32),

        Text(
          '22. Kepemilikan Barang Rumah Tangga',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        // a. Tabung gas 3 kg & b. Tabung gas 5,5 kg
        Row(
          children: [
            Expanded(
              child: _buildCounterField(
                label: 'Tabung Gas 3 kg',
                value: survey.gas3kg ?? 0,
                onChanged: (val) => provider.updateActiveSurvey((s) => s.gas3kg = val),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildCounterField(
                label: 'Tabung Gas >5.5 kg',
                value: survey.gas5kgPlus ?? 0,
                onChanged: (val) => provider.updateActiveSurvey((s) => s.gas5kgPlus = val),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // c. Lemari es & d. AC
        Row(
          children: [
            Expanded(
              child: _buildCounterField(
                label: 'Lemari Es / Kulkas',
                value: survey.kulkas ?? 0,
                onChanged: (val) => provider.updateActiveSurvey((s) => s.kulkas = val),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildCounterField(
                label: 'AC',
                value: survey.ac ?? 0,
                onChanged: (val) => provider.updateActiveSurvey((s) => s.ac = val),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // e. Emas/Perhiasan & f. Komputer/laptop
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildTextFormField(
                label: 'Emas / Perhiasan (gram)',
                value: survey.emas != null && survey.emas != 0.0 ? survey.emas.toString() : '',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                suffixText: 'gram',
                onChanged: (val) => provider.updateActiveSurvey((s) => s.emas = double.tryParse(val) ?? 0.0),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildCounterField(
                label: 'Komputer / Laptop',
                value: survey.komputer ?? 0,
                onChanged: (val) => provider.updateActiveSurvey((s) => s.komputer = val),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // g. Sepeda Motor (Count + Total Value)
        Text(
          'Sepeda Motor',
          style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold, fontSize: 13),
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 120,
              child: _buildCounterField(
                label: 'Unit',
                value: survey.motor ?? 0,
                onChanged: (val) => provider.updateActiveSurvey((s) => s.motor = val),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextFormField(
                label: 'Total Nilai Aset Motor',
                value: survey.motorNilai,
                keyboardType: TextInputType.number,
                prefixText: 'Rp. ',
                onChanged: (val) => provider.updateActiveSurvey((s) => s.motorNilai = val),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // h. Mobil (Count + Total Value)
        Text(
          'Mobil',
          style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold, fontSize: 13),
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 120,
              child: _buildCounterField(
                label: 'Unit',
                value: survey.mobil ?? 0,
                onChanged: (val) => provider.updateActiveSurvey((s) => s.mobil = val),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextFormField(
                label: 'Total Nilai Aset Mobil',
                value: survey.mobilNilai,
                keyboardType: TextInputType.number,
                prefixText: 'Rp. ',
                onChanged: (val) => provider.updateActiveSurvey((s) => s.mobilNilai = val),
              ),
            ),
          ],
        ),
        const Divider(height: 48),

        Text(
          '23. Kepemilikan Aset Tidak Bergerak',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        // a. Tanah di tempat lain
        Text(
          'Tanah / Lahan di Tempat Lain (selain yang ditempati)',
          style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold, fontSize: 13),
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 120,
              child: _buildCounterField(
                label: 'Lokasi',
                value: survey.tanahLain ?? 0,
                onChanged: (val) => provider.updateActiveSurvey((s) => s.tanahLain = val),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextFormField(
                label: 'Total Nilai Jual Tanah',
                value: survey.tanahLainNilai,
                keyboardType: TextInputType.number,
                prefixText: 'Rp. ',
                onChanged: (val) => provider.updateActiveSurvey((s) => s.tanahLainNilai = val),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // b. Rumah/Bangunan di tempat lain
        Text(
          'Rumah / Bangunan di Tempat Lain (selain yang ditempati)',
          style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold, fontSize: 13),
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 120,
              child: _buildCounterField(
                label: 'Bangunan',
                value: survey.rumahLain ?? 0,
                onChanged: (val) => provider.updateActiveSurvey((s) => s.rumahLain = val),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextFormField(
                label: 'Total Nilai Jual Bangunan',
                value: survey.rumahLainNilai,
                keyboardType: TextInputType.number,
                prefixText: 'Rp. ',
                onChanged: (val) => provider.updateActiveSurvey((s) => s.rumahLainNilai = val),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildTextFormField({
    required String label,
    required String? value,
    required void Function(String) onChanged,
    TextInputType keyboardType = TextInputType.text,
    String? prefixText,
    String? suffixText,
  }) {
    final isCurrency = prefixText == 'Rp. ';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FormLabel(label),
        TextFormField(
          initialValue: isCurrency ? formatThousands(value) : value,
          keyboardType: keyboardType,
          inputFormatters: isCurrency
              ? [ThousandsSeparatorInputFormatter()]
              : null,
          decoration: getFormDecoration(
            value: value,
            prefixText: prefixText,
            suffixText: suffixText,
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildCounterField({
    required String label,
    required int value,
    required void Function(int) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FormLabel(label),
        TextFormField(
          initialValue: value.toString(),
          keyboardType: TextInputType.number,
          decoration: getFormDecoration(
            value: value > 0 ? value.toString() : '',
            suffixText: 'unit',
          ),
          onChanged: (val) {
            onChanged(int.tryParse(val) ?? 0);
          },
        ),
      ],
    );
  }
}
