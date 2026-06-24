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
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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
                  child: Row(
                    children: [
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
                      const SizedBox(width: 6),
                      // Step text label
                      if (isActive || MediaQuery.of(context).size.width > 600)
                        Text(
                          stepTitles[index].split(': ').last,
                          style: TextStyle(
                            color: isActive 
                                ? theme.colorScheme.primary 
                                : theme.colorScheme.onSurfaceVariant,
                            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                            fontSize: 12,
                          ),
                        ),
                      const SizedBox(width: 6),
                      // Divider line
                      if (index < 3)
                        Expanded(
                          child: Container(
                            height: 2,
                            color: isCompleted 
                                ? const Color(0xFF006E1C) 
                                : theme.colorScheme.outlineVariant,
                          ),
                        ),
                    ],
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
                  onPressed: () {
                    provider.recalculateActiveSurvey();
                    if (provider.currentStep < 3) {
                      provider.setStep(provider.currentStep + 1);
                    } else {
                      // Final Step - Complete
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Survei selesai! Draf disimpan. Anda dapat menyinkronkannya dari dashboard.'),
                          backgroundColor: Color(0xFF006E1C),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
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
