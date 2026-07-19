import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import '../services/auth_service.dart';
import '../providers/survey_provider.dart';
import 'survey_stepper_screen.dart';

class SurveyDashboardScreen extends StatefulWidget {
  const SurveyDashboardScreen({super.key});

  @override
  State<SurveyDashboardScreen> createState() => _SurveyDashboardScreenState();
}

class _SurveyDashboardScreenState extends State<SurveyDashboardScreen> {
  final _urlController = TextEditingController();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<SurveyProvider>(context, listen: false);
      _urlController.text = provider.apiBaseUrl;
      provider.fetchUserProfile(); // Fetch user profile details on load
    });
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  void _showApiSettings() {
    final provider = Provider.of<SurveyProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('API Backend Settings'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Enter the backend URL running on your server/cPanel hosting to sync survey records:',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _urlController,
                decoration: const InputDecoration(
                  labelText: 'Backend URL',
                  hintText: 'http://domain.com or http://localhost:3000',
                  prefixIcon: Icon(Icons.dns_outlined),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL'),
            ),
            ElevatedButton(
              onPressed: () {
                provider.apiBaseUrl = _urlController.text.trim();
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Sukses'),
                    content: Text('API Base URL berhasil diperbarui: ${provider.apiBaseUrl}'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              },
              child: const Text('SAVE'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleLogout() async {
    try {
      await AuthService.logout();
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      debugPrint('Logout error: $e');
    }
  }

  Future<void> _syncAllDrafts() async {
    final provider = Provider.of<SurveyProvider>(context, listen: false);
    
    // Filter drafts that are 100% complete
    final readyDrafts = provider.drafts.where((d) => d.completionPercentage >= 100).toList();
    
    if (readyDrafts.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Sinkronisasi'),
          content: const Text('Tidak ada draf kuesioner yang sudah 100% lengkap untuk disinkronkan.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    int successCount = 0;
    int failCount = 0;
    
    // Copy the IDs because syncSurvey removes items from the list
    final draftIds = readyDrafts.map((d) => d.id).toList();

    for (final id in draftIds) {
      final success = await provider.syncSurvey(id);
      if (success) {
        successCount++;
      } else {
        failCount++;
      }
    }

    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Sinkronisasi Selesai'),
          content: Text('Proses sinkronisasi selesai.\nBerhasil: $successCount\nGagal/Terlewati: $failCount'),
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

  Future<void> _syncSingleDraft(String surveyId) async {
    final provider = Provider.of<SurveyProvider>(context, listen: false);
    
    // Find the survey and run validation
    final draftIndex = provider.drafts.indexWhere((d) => d.id == surveyId);
    if (draftIndex >= 0) {
      final draft = provider.drafts[draftIndex];
      final errors = draft.validate();
      if (errors.isNotEmpty) {
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Kesalahan Validasi'),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    const Text('Kuesioner ini belum dapat disinkronkan karena terdapat kesalahan data berikut:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    ...errors.map((err) => Padding(
                      padding: const EdgeInsets.only(bottom: 6.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red, size: 16),
                          const SizedBox(width: 8),
                          Expanded(child: Text(err, style: const TextStyle(fontSize: 13))),
                        ],
                      ),
                    )),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
        return;
      }
    }

    final success = await provider.syncSurvey(surveyId);
    
    if (mounted) {
      if (success) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Sinkronisasi Sukses'),
            content: const Text('Kuesioner berhasil disinkronkan ke database server.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Sinkronisasi Gagal'),
            content: const Text('Terjadi kesalahan saat menyinkronkan data. Silakan periksa koneksi internet atau pengaturan API Anda.'),
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

  Widget _buildNavItem(int index, IconData icon, String label) {
    final theme = Theme.of(context);
    final isActive = _currentIndex == index;

    if (isActive) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(icon, color: theme.colorScheme.primary, size: 20),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    } else {
      return IconButton(
        icon: Icon(icon, color: theme.colorScheme.onSurfaceVariant),
        onPressed: () {
          setState(() {
            _currentIndex = index;
          });
        },
      );
    }
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return _buildHomeTab();
      case 1:
        return _buildTugasTab();
      case 2:
        return _buildRiwayatTab();
      case 3:
        return _buildUserTab();
      default:
        return _buildHomeTab();
    }
  }

  Widget _buildHomeTab() {
    final theme = Theme.of(context);
    final provider = Provider.of<SurveyProvider>(context);
    final districtName = provider.userProfile?['kecamatan'] ?? 'Tahuna';
    final villageName = provider.userProfile?['desa'] ?? 'Tahuna Barat';
    final email = provider.userProfile?['email'] ?? 'surveyor@bps.go.id';
    
    final nameParts = email.split('@').first.split('.');
    final defaultNama = nameParts.map((p) => p.isEmpty ? '' : '${p[0].toUpperCase()}${p.substring(1)}').join(' ');
    final profileNama = provider.userProfile?['nama'];
    final surveyorName = (profileNama != null && profileNama.isNotEmpty) ? profileNama : defaultNama;
    
    final role = provider.userProfile?['role'] ?? 'Pencacah';

    return SingleChildScrollView(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 90),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Profile Bento Card
              Card(
                color: Colors.white,
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: theme.colorScheme.outlineVariant),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person,
                          color: Color(0xFF9A4600),
                          size: 36,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  role.toString().toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.0,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.tertiaryContainer.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'ONLINE',
                                    style: TextStyle(
                                      color: theme.colorScheme.tertiary,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              surveyorName,
                              style: TextStyle(
                                color: theme.colorScheme.onSurface,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'ID: 7103-01 • Kec. $districtName',
                              style: TextStyle(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Sync & Statistics Grid
              Row(
                children: [
                  // Left Bento: Sync status
                  Expanded(
                    child: Card(
                      color: Colors.white,
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: theme.colorScheme.outlineVariant),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.cloud_off,
                                  color: theme.colorScheme.primary,
                                  size: 18,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Offline Data',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${provider.drafts.length}',
                              style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSurface,
                              ),
                            ),
                            Text(
                              'Survei Belum Sinkron',
                              style: TextStyle(
                                fontSize: 11,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              height: 38,
                              child: ElevatedButton.icon(
                                onPressed: provider.isSyncing || provider.drafts.isEmpty ? null : _syncAllDrafts,
                                icon: provider.isSyncing
                                    ? const SizedBox(
                                        width: 14,
                                        height: 14,
                                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                      )
                                    : const Icon(Icons.sync, size: 16),
                                label: const Text('Sinkron', style: TextStyle(fontSize: 12)),
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  backgroundColor: theme.colorScheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Right Bento: Target Desa
                  Expanded(
                    child: Card(
                      color: Colors.white,
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: theme.colorScheme.outlineVariant),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.task_alt,
                                  color: theme.colorScheme.secondary,
                                  size: 18,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Target Desa',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.secondary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '85%',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: 0.85,
                                backgroundColor: theme.colorScheme.secondaryContainer.withValues(alpha: 0.2),
                                valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.secondary),
                                minHeight: 6,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '12/14 Blok Selesai',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 14),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Quick Action: Survey Desa Cantik
              Card(
                elevation: 1,
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: theme.colorScheme.outlineVariant),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.primaryContainer,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'PROGRAM UNGGULAN',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Survei Desa Cantik\n(Desa Cinta Statistik)',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Mulai pendataan untuk program pemberdayaan statistik desa $villageName.',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            final userId = provider.userProfile?['id'] ?? 'mock-user-123';
                            provider.startNewSurvey(userId);
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const SurveyStepperScreen()),
                            ).then((_) => setState(() {}));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: theme.colorScheme.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          icon: const Icon(Icons.add_circle),
                          label: const Text('Mulai Survei Baru', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Recent Activity / Drafts
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'AKTIVITAS TERAKHIR',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (provider.drafts.isNotEmpty)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _currentIndex = 2; // Jump to History tab
                        });
                      },
                      child: Text(
                        'Lihat Semua',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),

              // Drafts container Card
              provider.drafts.isEmpty
                  ? Card(
                      color: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: theme.colorScheme.outlineVariant),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 16.0),
                        child: Column(
                          children: [
                            Icon(Icons.assignment_turned_in_outlined, size: 48, color: theme.colorScheme.outlineVariant),
                            const SizedBox(height: 12),
                            Text(
                              'Semua draf selesai disinkronkan!',
                              style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Tap tombol di atas untuk memulai survei baru.',
                              style: TextStyle(color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7), fontSize: 12),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  : Card(
                      color: Colors.white,
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: theme.colorScheme.outlineVariant),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: provider.drafts.length > 3 ? 3 : provider.drafts.length, // Show up to 3 drafts on home
                        separatorBuilder: (context, index) => Divider(color: theme.colorScheme.outlineVariant, height: 1),
                        itemBuilder: (context, index) {
                          final survey = provider.drafts[index];
                          final title = survey.namaKk?.isNotEmpty == true ? survey.namaKk! : 'Unnamed Family';
                          final subTitle = 'Kec. ${survey.kecamatan ?? districtName} • SLS: ${survey.namaSls ?? '-'}';
                          
                          // Format time ago or date
                          String timeAgo = 'Baru saja';
                          if (survey.updatedAt != null) {
                            final diff = DateTime.now().difference(survey.updatedAt!);
                            if (diff.inMinutes < 60) {
                              timeAgo = '${diff.inMinutes} menit yang lalu';
                            } else if (diff.inHours < 24) {
                              timeAgo = '${diff.inHours} jam yang lalu';
                            } else {
                              timeAgo = '${survey.updatedAt!.day}/${survey.updatedAt!.month}/${survey.updatedAt!.year}';
                            }
                          }

                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(Icons.drafts, color: theme.colorScheme.primary, size: 20),
                            ),
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    title,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.onSurface,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primaryContainer.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'DRAFT',
                                    style: TextStyle(
                                      color: theme.colorScheme.primary,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                '$subTitle • $timeAgo',
                                style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 11),
                              ),
                            ),
                            trailing: Icon(Icons.chevron_right, color: theme.colorScheme.outline, size: 20),
                            onTap: () {
                              provider.loadSurvey(survey);
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const SurveyStepperScreen()),
                              ).then((_) => setState(() {}));
                            },
                          );
                        },
                      ),
                    ),
              const SizedBox(height: 16),

              // Help Banner
              Card(
                color: const Color(0xFFD5E3FF), // secondary-fixed
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.5)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.4),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.contact_support,
                          color: theme.colorScheme.secondary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Butuh Bantuan Lapangan?',
                              style: TextStyle(
                                color: theme.colorScheme.onSurface,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              'Hubungi Koordinator Kecamatan',
                              style: TextStyle(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Menghubungi Koordinator Kecamatan Tahuna...')),
                          );
                        },
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.secondary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.call,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTugasTab() {
    final theme = Theme.of(context);
    final provider = Provider.of<SurveyProvider>(context);
    final drafts = provider.drafts;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 90),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'DRAF & SINKRONISASI',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              drafts.isEmpty
                  ? Card(
                      color: Colors.white,
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: theme.colorScheme.outlineVariant),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 48.0, horizontal: 16.0),
                        child: Column(
                          children: [
                            Icon(Icons.assignment_turned_in_outlined, size: 64, color: theme.colorScheme.primary.withValues(alpha: 0.3)),
                            const SizedBox(height: 16),
                            const Text(
                              'Tidak Ada Draf Kuesioner',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Semua kuesioner telah disinkronkan ke database atau belum ada survei baru yang dimulai.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: drafts.length,
                      itemBuilder: (context, index) {
                        final survey = drafts[index];
                        final title = survey.namaKk?.isNotEmpty == true ? survey.namaKk! : 'Unnamed Family';
                        final subTitle = 'Kec. ${survey.kecamatan ?? "-"} • SLS: ${survey.namaSls ?? "-"}';
                        final pct = survey.completionPercentage;
                        final isComplete = pct >= 100;

                        return Card(
                          color: Colors.white,
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: theme.colorScheme.outlineVariant),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        title,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: isComplete
                                            ? const Color(0xFFE8F5E9)
                                            : const Color(0xFFFFF3E0),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        isComplete ? 'LENGKAP' : 'DRAF',
                                        style: TextStyle(
                                          color: isComplete ? Colors.green : Colors.orange.shade800,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(subTitle, style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12)),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(4),
                                            child: LinearProgressIndicator(
                                              value: pct / 100.0,
                                              backgroundColor: Colors.grey.shade200,
                                              valueColor: AlwaysStoppedAnimation<Color>(
                                                isComplete ? Colors.green : Colors.orange,
                                              ),
                                              minHeight: 8,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            isComplete ? 'Siap Sinkron (100%)' : 'Belum Lengkap ($pct%)',
                                            style: TextStyle(
                                              color: isComplete ? Colors.green : Colors.orange.shade800,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    ElevatedButton.icon(
                                      onPressed: isComplete && !provider.isSyncing
                                          ? () => _syncSingleDraft(survey.id)
                                          : () {
                                              if (!isComplete) {
                                                showDialog(
                                                  context: context,
                                                  builder: (context) => AlertDialog(
                                                    title: const Text('Peringatan'),
                                                    content: const Text('Kuesioner belum lengkap (100%). Selesaikan semua pengisian blok terlebih dahulu agar dapat disinkronkan.'),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () => Navigator.pop(context),
                                                        child: const Text('OK'),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              }
                                            },
                                      icon: provider.isSyncing
                                          ? const SizedBox(
                                              width: 14,
                                              height: 14,
                                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                            )
                                          : const Icon(Icons.cloud_upload, size: 16),
                                      label: const Text('Sync', style: TextStyle(fontSize: 12)),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: isComplete ? theme.colorScheme.primary : Colors.grey.shade400,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRiwayatTab() {
    final theme = Theme.of(context);
    final provider = Provider.of<SurveyProvider>(context);
    final drafts = provider.drafts;
    final synced = provider.syncedSurveys;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 90),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Section 1: Belum Sinkron (Drafts)
              Text(
                'DRAF (BELUM SINKRON)',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              drafts.isEmpty
                  ? const Card(
                      color: Colors.white,
                      elevation: 0,
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(
                          child: Text('Tidak ada draf aktif.', style: TextStyle(color: Colors.grey, fontSize: 13)),
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: drafts.length,
                      itemBuilder: (context, index) {
                        final survey = drafts[index];
                        final title = survey.namaKk?.isNotEmpty == true ? survey.namaKk! : 'Unnamed Family';
                        final pct = survey.completionPercentage;
                        
                        return Card(
                          color: Colors.white,
                          margin: const EdgeInsets.only(bottom: 8),
                          elevation: 1,
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.orange.shade100,
                              child: Icon(Icons.drafts, color: Colors.orange.shade800, size: 20),
                            ),
                            title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('Kelengkapan: $pct% • Belum Sinkron', style: const TextStyle(fontSize: 12)),
                            trailing: const Icon(Icons.chevron_right, size: 16),
                            onTap: () {
                              provider.loadSurvey(survey);
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const SurveyStepperScreen()),
                              ).then((_) => setState(() {}));
                            },
                          ),
                        );
                      },
                    ),
              
              const SizedBox(height: 24),

              // Section 2: Sudah Sinkron (Synced History)
              Text(
                'SUDAH SINKRON (RIWAYAT)',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              synced.isEmpty
                  ? const Card(
                      color: Colors.white,
                      elevation: 0,
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(
                          child: Text('Belum ada kuesioner yang disinkronkan.', style: TextStyle(color: Colors.grey, fontSize: 13)),
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: synced.length,
                      itemBuilder: (context, index) {
                        final survey = synced[index];
                        final title = survey.namaKk?.isNotEmpty == true ? survey.namaKk! : 'Unnamed Family';
                        
                        return Card(
                          color: Colors.white,
                          margin: const EdgeInsets.only(bottom: 8),
                          elevation: 1,
                          child: ListTile(
                            leading: const CircleAvatar(
                              backgroundColor: Color(0xFFE8F5E9),
                              child: Icon(Icons.cloud_done, color: Colors.green, size: 20),
                            ),
                            title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: const Text('Kelengkapan: 100% • Sudah Sinkron', style: TextStyle(fontSize: 12)),
                            trailing: const Icon(Icons.check, color: Colors.green, size: 16),
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text(title),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('NIK Kepala Keluarga: ${survey.nikKk ?? "-"}'),
                                      Text('Kecamatan: ${survey.kecamatan ?? "-"}'),
                                      Text('Desa: ${survey.desaKelurahan ?? "-"}'),
                                      Text('SLS: ${survey.namaSls ?? "-"}'),
                                      const SizedBox(height: 8),
                                      const Text('Kuesioner ini sudah berhasil dikirim ke database cloud.', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('TUTUP'),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserTab() {
    final theme = Theme.of(context);
    final provider = Provider.of<SurveyProvider>(context);
    final email = provider.userProfile?['email'] ?? 'surveyor@bps.go.id';
    
    final nameParts = email.split('@').first.split('.');
    final defaultNama = nameParts.map((p) => p.isEmpty ? '' : '${p[0].toUpperCase()}${p.substring(1)}').join(' ');
    final profileNama = provider.userProfile?['nama'];
    final surveyorName = (profileNama != null && profileNama.isNotEmpty) ? profileNama : defaultNama;
    
    final role = provider.userProfile?['role'] ?? 'Pencacah';
    
    final districtName = provider.userProfile?['kecamatan'] ?? 'Tahuna';
    final villageName = provider.userProfile?['desa'] ?? 'Tahuna Barat';
    final regencyName = provider.userProfile?['kabupaten'] ?? 'Kepulauan Sangihe';

    return SingleChildScrollView(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 90),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // User Avatar Card
              Card(
                color: Colors.white,
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: theme.colorScheme.outlineVariant),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 48,
                        backgroundColor: theme.colorScheme.primaryContainer.withValues(alpha: 0.2),
                        child: const Icon(
                          Icons.person,
                          color: Color(0xFF9A4600),
                          size: 48,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        surveyorName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email,
                        style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '${role.toString().toUpperCase()} AKTIF',
                          style: const TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Region Assignment Details Card
              Card(
                color: Colors.white,
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: theme.colorScheme.outlineVariant),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.location_city, color: theme.colorScheme.primary),
                      title: const Text('Provinsi', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      subtitle: const Text('SULAWESI UTARA', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: Icon(Icons.map, color: theme.colorScheme.primary),
                      title: const Text('Kabupaten / Kota', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      subtitle: Text(regencyName.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: Icon(Icons.explore, color: theme.colorScheme.primary),
                      title: const Text('Kecamatan', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      subtitle: Text(districtName.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: Icon(Icons.home_work, color: theme.colorScheme.primary),
                      title: const Text('Desa / Kelurahan', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      subtitle: Text(villageName.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Logout Button
              ElevatedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext dialogContext) {
                      return AlertDialog(
                        title: const Text('Logout'),
                        content: const Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(dialogContext),
                            child: const Text('BATAL', style: TextStyle(color: Colors.grey)),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(dialogContext);
                              _handleLogout();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('LOGOUT'),
                          ),
                        ],
                      );
                    },
                  );
                },
                icon: const Icon(Icons.logout),
                label: const Text('KELUAR DARI APLIKASI', style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBackupDialog() {
    final provider = Provider.of<SurveyProvider>(context, listen: false);
    final backupData = provider.exportBackupData();
    final draftsCount = provider.drafts.length;
    final syncedCount = provider.syncedSurveys.length;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.backup_outlined, color: Colors.blueAccent),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Backup Data Kuesioner',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Simpan data kuesioner lokal Anda ke dalam file cadangan (.json) agar mudah dibagikan via WhatsApp atau disimpan ke HP.',
                style: TextStyle(fontSize: 13, color: Colors.black87),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Flexible(
                          child: Text('Total Draf Kuesioner:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        ),
                        Chip(
                          label: Text('$draftsCount Draf', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                          backgroundColor: Colors.orange,
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Flexible(
                          child: Text('Total Tersinkron:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        ),
                        Chip(
                          label: Text('$syncedCount Data', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                          backgroundColor: Colors.green,
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.share, size: 20),
                label: const Text(
                  'BAGIKAN / SIMPAN FILE BACKUP (.json)',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(48),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () async {
                  try {
                    final tempDir = await getTemporaryDirectory();
                    final nowStr = DateTime.now().toIso8601String().replaceAll(':', '-').split('.').first;
                    final filePath = '${tempDir.path}/backup_descan_$nowStr.json';
                    final file = File(filePath);
                    await file.writeAsString(backupData);

                    if (context.mounted) {
                      Navigator.pop(context);
                      await Share.shareXFiles(
                        [XFile(file.path)],
                        text: 'File Backup Data Kuesioner Form Descan (BPS Sangihe)',
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Gagal membuat file backup: $e'), backgroundColor: Colors.red),
                      );
                    }
                  }
                },
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                icon: const Icon(Icons.copy, size: 18),
                label: const Text('Salin Teks Kode Backup', style: TextStyle(fontSize: 12)),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(42),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: backupData));
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✓ Teks backup berhasil disalin ke clipboard!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('TUTUP', style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  void _showRestoreDialog() {
    final provider = Provider.of<SurveyProvider>(context, listen: false);
    final restoreController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.restore_outlined, color: Colors.orangeAccent),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Restore Data Kuesioner',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Pilih file backup (.json / .zip) dari HP Anda untuk memulihkan draf kuesioner saat pindah perangkat atau update aplikasi.',
                style: TextStyle(fontSize: 13, color: Colors.black87),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.upload_file, size: 20),
                label: const Text(
                  'PILIH FILE BACKUP (.json / .zip)',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(48),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () async {
                  try {
                    final result = await FilePicker.platform.pickFiles(
                      type: FileType.any,
                    );

                    if (result != null && result.files.isNotEmpty) {
                      String fileContent = '';
                      final file = result.files.first;

                      if (file.path != null) {
                        fileContent = await File(file.path!).readAsString();
                      } else if (file.bytes != null) {
                        fileContent = String.fromCharCodes(file.bytes!);
                      }

                      if (fileContent.isNotEmpty) {
                        final restoreResult = await provider.importBackupData(fileContent);
                        if (context.mounted) {
                          Navigator.pop(context);
                          if (restoreResult['success'] == true) {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Row(
                                  children: [
                                    Icon(Icons.check_circle, color: Colors.green),
                                    SizedBox(width: 8),
                                    Expanded(child: Text('Restorasi Sukses')),
                                  ],
                                ),
                                content: Text(
                                  'Berhasil memulihkan data dari file "${file.name}":\n\n'
                                  '• ${restoreResult['restoredDrafts']} Draf Kuesioner\n'
                                  '• ${restoreResult['restoredSynced']} Kuesioner Tersinkronisasi',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('OK'),
                                  ),
                                ],
                              ),
                            );
                          } else {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Row(
                                  children: [
                                    Icon(Icons.error, color: Colors.red),
                                    SizedBox(width: 8),
                                    Expanded(child: Text('Restorasi Gagal')),
                                  ],
                                ),
                                content: Text('Gagal memproses file backup: ${restoreResult['error']}'),
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
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Gagal membaca file: $e'), backgroundColor: Colors.red),
                      );
                    }
                  }
                },
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              const Text('Atau Tempel Teks Backup (Opsional):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              const SizedBox(height: 6),
              TextField(
                controller: restoreController,
                maxLines: 3,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
                decoration: InputDecoration(
                  hintText: 'Tempel teks JSON di sini...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.all(10),
                ),
              ),
              const SizedBox(height: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  OutlinedButton.icon(
                    icon: const Icon(Icons.paste, size: 16),
                    label: const Text('Tempel dari Clipboard', style: TextStyle(fontSize: 12)),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () async {
                      final data = await Clipboard.getData(Clipboard.kTextPlain);
                      if (data?.text != null && data!.text!.isNotEmpty) {
                        restoreController.text = data.text!;
                      }
                    },
                  ),
                  const SizedBox(height: 6),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orangeAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () async {
                      final text = restoreController.text.trim();
                      if (text.isEmpty) return;

                      final restoreResult = await provider.importBackupData(text);
                      if (context.mounted) {
                        Navigator.pop(context);
                        if (restoreResult['success'] == true) {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Row(
                                children: [
                                  Icon(Icons.check_circle, color: Colors.green),
                                  SizedBox(width: 8),
                                  Expanded(child: Text('Restorasi Sukses')),
                                ],
                              ),
                              content: Text(
                                'Berhasil memulihkan data:\n\n'
                                '• ${restoreResult['restoredDrafts']} Draf Kuesioner\n'
                                '• ${restoreResult['restoredSynced']} Kuesioner Tersinkronisasi',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          );
                        } else {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Row(
                                children: [
                                  Icon(Icons.error, color: Colors.red),
                                  SizedBox(width: 8),
                                  Expanded(child: Text('Restorasi Gagal')),
                                ],
                              ),
                              content: Text('Gagal memulihkan data: ${restoreResult['error']}'),
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
                    },
                    child: const Text('RESTORE TEKS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('BATAL', style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Image.asset('logo.png', height: 72, errorBuilder: (context, error, stackTrace) => const Icon(Icons.assessment, size: 72, color: Colors.blueAccent)),
              const SizedBox(height: 12),
              const Text(
                'Form Descan',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)),
              ),
              const Text(
                'Versi 1.0.0+1',
                style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                'Aplikasi Pendataan Desa Cantik',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.blueAccent),
              ),
              const Divider(height: 24),
              const Text(
                'Aplikasi pendataan kuesioner digital terintegrasi BPS Kabupaten Kepulauan Sangihe untuk survei lapangan.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.black87),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.blue.withValues(alpha: 0.15)),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.system_update_alt, size: 18, color: Colors.blueAccent),
                        SizedBox(width: 8),
                        Text('Informasi Distribusi & Update:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.chat, size: 16, color: Colors.green),
                        SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Saat ini dikirim via WhatsApp (Direct APK).',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.store, size: 16, color: Colors.deepPurple),
                        SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Kedepannya akan didistribusikan melalui Google Play Store.',
                            style: TextStyle(fontSize: 11, color: Colors.black87),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '© 2026 BPS Kabupaten Kepulauan Sangihe\nHak Cipta Dilindungi Undang-Undang',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
        ),
        actions: [
          Center(
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('TUTUP', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppDrawer() {
    final provider = Provider.of<SurveyProvider>(context);
    final userEmail = provider.userProfile?['email'] ?? 'surveyor@bps.go.id';
    final userKec = provider.userProfile?['kecamatan'] ?? 'Kecamatan Tahuna';
    final userDesa = provider.userProfile?['desa'] ?? 'Desa Tahuna Barat';

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            accountName: const Text(
              'Form Descan (BPS Sangihe)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            accountEmail: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(userEmail, style: const TextStyle(fontSize: 13, color: Color(0xE6FFFFFF))),
                const SizedBox(height: 2),
                Text('$userDesa, $userKec', style: const TextStyle(fontSize: 11, color: Colors.white70)),
              ],
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Image.asset(
                  'logo.png',
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.assessment, size: 36, color: Color(0xFF1E3A8A)),
                ),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: const Text('Home Dashboard'),
            selected: _currentIndex == 0,
            onTap: () {
              Navigator.pop(context);
              setState(() => _currentIndex = 0);
            },
          ),
          ListTile(
            leading: const Icon(Icons.assignment_outlined),
            title: const Text('Tugas Pendataan'),
            selected: _currentIndex == 1,
            onTap: () {
              Navigator.pop(context);
              setState(() => _currentIndex = 1);
            },
          ),
          ListTile(
            leading: const Icon(Icons.history_outlined),
            title: const Text('Riwayat Kuesioner'),
            selected: _currentIndex == 2,
            onTap: () {
              Navigator.pop(context);
              setState(() => _currentIndex = 2);
            },
          ),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Profil Pengguna'),
            selected: _currentIndex == 3,
            onTap: () {
              Navigator.pop(context);
              setState(() => _currentIndex = 3);
            },
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text('MANAJEMEN DATA', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
          ),
          ListTile(
            leading: const Icon(Icons.backup_outlined, color: Colors.blueAccent),
            title: const Text('Backup Data (ZIP/JSON)'),
            subtitle: const Text('Cadangkan draf & riwayat kuesioner', style: TextStyle(fontSize: 11)),
            onTap: () {
              Navigator.pop(context);
              _showBackupDialog();
            },
          ),
          ListTile(
            leading: const Icon(Icons.restore_outlined, color: Colors.orangeAccent),
            title: const Text('Restore Data'),
            subtitle: const Text('Pulihkan data cadangan kuesioner', style: TextStyle(fontSize: 11)),
            onTap: () {
              Navigator.pop(context);
              _showRestoreDialog();
            },
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text('INFORMASI APLIKASI', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline, color: Colors.teal),
            title: const Text('Tentang Aplikasi'),
            subtitle: const Text('Versi 1.0.0+1 & Info Distribusi', style: TextStyle(fontSize: 11)),
            onTap: () {
              Navigator.pop(context);
              _showAboutDialog();
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings_outlined, color: Colors.blueGrey),
            title: const Text('Pengaturan API Backend'),
            onTap: () {
              Navigator.pop(context);
              _showApiSettings();
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text('Keluar (Logout)', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
            onTap: () {
              Navigator.pop(context);
              _handleLogout();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = Provider.of<SurveyProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F3F5),
      drawer: _buildAppDrawer(),
      appBar: AppBar(
        title: const Text(
          'BPS Sangihe',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.cloud_sync),
            tooltip: 'Sync All Drafts',
            onPressed: provider.isSyncing ? null : _syncAllDrafts,
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'API Settings',
            onPressed: _showApiSettings,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext dialogContext) {
                  return AlertDialog(
                    title: const Text('Logout'),
                    content: const Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        child: const Text('BATAL', style: TextStyle(color: Colors.grey)),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(dialogContext);
                          _handleLogout();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('LOGOUT'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      extendBody: true,
      body: _buildBody(),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 70,
          alignment: Alignment.center,
          color: Colors.transparent,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 380),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12, left: 16, right: 16),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(40),
                border: Border.all(color: theme.colorScheme.outlineVariant),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(0, Icons.home, 'Home'),
                    _buildNavItem(1, Icons.assignment, 'Tugas'),
                    _buildNavItem(2, Icons.history, 'Riwayat'),
                    _buildNavItem(3, Icons.person, 'User'),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
