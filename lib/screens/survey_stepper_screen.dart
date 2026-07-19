import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/survey_provider.dart';
import '../widgets/blok1_identitas_widget.dart';
import '../widgets/blok2_perumahan_widget.dart';
import '../widgets/blok3_aset_widget.dart';
import '../widgets/blok4_anggota_widget.dart';

class SurveyStepperScreen extends StatelessWidget {
  const SurveyStepperScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SurveyProvider>(context);
    final theme = Theme.of(context);

    if (provider.activeSurvey == null) {
      return const Scaffold(
        body: Center(child: Text('No active survey.')),
      );
    }

    final List<Widget> steps = [
      const Blok1IdentitasWidget(),
      const Blok2PerumahanWidget(),
      const Blok3AsetWidget(),
      const Blok4AnggotaWidget(),
    ];

    final List<String> stepTitles = [
      'BLOK I: Identitas',
      'BLOK II: Perumahan',
      'BLOK III: Aset',
      'BLOK IV: Anggota',
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF1F3F5),
      appBar: AppBar(
        title: Text(
          stepTitles[provider.currentStep],
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF1C5FA8), // BPS Deep Blue Block Header
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            provider.recalculateActiveSurvey();
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save_outlined),
            tooltip: 'Simpan Draf',
            onPressed: () {
              provider.recalculateActiveSurvey();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Draf berhasil disimpan secara lokal.'),
                  backgroundColor: Color(0xFF006E1C),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Premium Light Progress Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: theme.colorScheme.outlineVariant)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(4, (index) {
                final isCompleted = index < provider.currentStep;
                final isActive = index == provider.currentStep;
                return Expanded(
                  child: InkWell(
                    onTap: () {
                      provider.recalculateActiveSurvey();
                      provider.setStep(index);
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            // Left line connecting to previous step
                            Expanded(
                              child: index == 0
                                  ? const SizedBox()
                                  : Container(
                                      height: 2,
                                      color: index <= provider.currentStep
                                          ? const Color(0xFF006E1C)
                                          : theme.colorScheme.outlineVariant,
                                    ),
                            ),
                            // Step dot
                            CircleAvatar(
                              radius: 13,
                              backgroundColor: isActive
                                  ? theme.colorScheme.primaryContainer
                                  : isCompleted
                                      ? const Color(0xFF006E1C)
                                      : theme.colorScheme.outlineVariant,
                              child: Text(
                                '${index + 1}',
                                style: TextStyle(
                                  color: isActive || isCompleted
                                      ? Colors.white
                                      : theme.colorScheme.onSurfaceVariant,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            // Right line connecting to next step
                            Expanded(
                              child: index == 3
                                  ? const SizedBox()
                                  : Container(
                                      height: 2,
                                      color: index < provider.currentStep
                                          ? const Color(0xFF006E1C)
                                          : theme.colorScheme.outlineVariant,
                                    ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        // Step text label below the dot
                        Text(
                          stepTitles[index].split(': ').last,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isActive
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurfaceVariant,
                            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),

          // Main form content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Card(
                color: Colors.white,
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: theme.colorScheme.outlineVariant),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: steps[provider.currentStep],
                ),
              ),
            ),
          ),

          // Warning banner if step is not valid
          if (!provider.activeSurvey!.isStepValid(provider.currentStep))
            Container(
              width: double.infinity,
              color: Colors.amber.shade50,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.amber.shade900, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      provider.currentStep == 3 
                        ? 'Harap isi data anggota (NIK wajib 16 digit & harus ada 1 Kepala Keluarga)'
                        : 'Harap lengkapi semua isian wajib di blok ini sebelum melanjutkan',
                      style: TextStyle(color: Colors.amber.shade900, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),

          // Navigation buttons footer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: theme.colorScheme.outlineVariant)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Back button
                TextButton.icon(
                  onPressed: provider.currentStep == 0
                      ? null
                      : () => provider.setStep(provider.currentStep - 1),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('KEMBALI'),
                  style: TextButton.styleFrom(
                    foregroundColor: provider.currentStep == 0 
                        ? theme.colorScheme.outlineVariant 
                        : theme.colorScheme.primary,
                    textStyle: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
 
                // Next/Finish button
                ElevatedButton.icon(
                  onPressed: provider.activeSurvey!.isStepValid(provider.currentStep)
                      ? () {
                          provider.recalculateActiveSurvey();
                          if (provider.currentStep < 3) {
                            provider.setStep(provider.currentStep + 1);
                          } else {
                            // Final Step - Validate
                            final errors = provider.activeSurvey!.validate();
                            if (errors.isNotEmpty) {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Kuesioner Belum Lengkap'),
                                  content: SizedBox(
                                    width: double.maxFinite,
                                    child: ListView(
                                      shrinkWrap: true,
                                      children: [
                                        const Text('Ditemukan kesalahan atau data wajib yang belum terisi:', style: TextStyle(fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 12),
                                        ...errors.map((err) => Padding(
                                          padding: const EdgeInsets.only(bottom: 6.0),
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 16),
                                              const SizedBox(width: 8),
                                              Expanded(child: Text(err, style: const TextStyle(fontSize: 13))),
                                            ],
                                          ),
                                        )),
                                        const SizedBox(height: 16),
                                        const Text('Anda tetap dapat menyimpan data ini sebagai draf lokal dan melengkapinya nanti.'),
                                      ],
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('LANJUTKAN PENGISIAN'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(context); // Close dialog
                                        Navigator.pop(context); // Exit stepper
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Draf berhasil disimpan secara lokal.'),
                                            backgroundColor: Color(0xFF006E1C),
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.orange.shade800,
                                        foregroundColor: Colors.white,
                                      ),
                                      child: const Text('SIMPAN SEBAGAI DRAF'),
                                    ),
                                  ],
                                ),
                              );
                            } else {
                              // All validated!
                              Navigator.pop(context);
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Sukses'),
                                  content: const Text('Kuesioner telah lengkap 100% dan tervalidasi! Silakan sinkronkan data dari dashboard.'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('OK'),
                                    ),
                                  ],
                                ),
                              );
                            }
                          }
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: provider.activeSurvey!.isStepValid(provider.currentStep)
                        ? theme.colorScheme.primary
                        : Colors.grey.shade300,
                    foregroundColor: provider.activeSurvey!.isStepValid(provider.currentStep)
                        ? Colors.white
                        : Colors.grey.shade600,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  icon: Icon(provider.currentStep == 3 ? Icons.check : Icons.arrow_forward),
                  label: Text(provider.currentStep == 3 ? 'SELESAI' : 'LANJUT'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
