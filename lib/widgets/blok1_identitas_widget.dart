import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../providers/survey_provider.dart';
import '../models/wilayah_model.dart';
import 'form_helpers.dart';

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
          label: '1. a. Nama Kepala Keluarga *',
          initialValue: survey.namaKk,
          onChanged: (val) => provider.updateActiveSurvey((s) => s.namaKk = val),
        ),
        const SizedBox(height: 16),

        // 1.b NIK Kepala Keluarga
        _buildTextField(
          label: '1. b. NIK Kepala Keluarga *',
          initialValue: survey.nikKk,
          keyboardType: TextInputType.number,
          maxLength: 16,
          onChanged: (val) => provider.updateActiveSurvey((s) => s.nikKk = val),
        ),
        const SizedBox(height: 16),

        // 1.c Nomor KK Kepala Keluarga
        _buildTextField(
          label: '1. c. Nomor KK Kepala Keluarga *',
          initialValue: survey.noKk,
          keyboardType: TextInputType.number,
          maxLength: 16,
          onChanged: (val) => provider.updateActiveSurvey((s) => s.noKk = val),
        ),
        const SizedBox(height: 16),

        // 2.a Jumlah Anggota Keluarga sesuai KK
        _buildTextField(
          label: '2. a. Jumlah Anggota Keluarga sesuai KK *',
          initialValue: survey.jmlAnggotaKk?.toString() ?? '',
          keyboardType: TextInputType.number,
          onChanged: (val) => provider.updateActiveSurvey((s) => s.jmlAnggotaKk = int.tryParse(val) ?? 0),
        ),
        const SizedBox(height: 16),

        // 2.b Jumlah Anggota Keluarga hasil pendataan (Autofill)
        const FormLabel(
          '2. b. Jumlah Anggota Keluarga hasil pendataan (Autofill)',
          helperText: 'Otomatis dihitung dari jumlah anggota keluarga yang ditambahkan di Blok IV',
        ),
        TextFormField(
          decoration: getFormDecoration(
            value: survey.jmlAnggotaPendataan?.toString() ?? '0',
            isAutofill: true,
          ),
          readOnly: true,
          controller: TextEditingController(text: survey.jmlAnggotaPendataan?.toString() ?? '0'),
        ),
        const SizedBox(height: 24),

        Text(
          '3. Alamat Tempat Tinggal',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),

        // Resolve current codes based on names in active survey
        () {
          final wilayah = provider.wilayahList;
          String? selectedKdProv;
          String? selectedKdKab;
          String? selectedKdKec;
          String? selectedKdDesa;
          String? selectedKdSls;

          if (survey.provinsi != null && survey.provinsi!.isNotEmpty) {
            final match = wilayah.firstWhere(
              (w) => w.namaProv.toUpperCase() == survey.provinsi!.toUpperCase(),
              orElse: () => WilayahModel(idSubsls: '', kdProv: '', kdKab: '', kdKec: '', kdDesa: '', kdSls: '', namaProv: '', namaKab: '', namaKec: '', namaDesa: '', namaSls: '', kdPos: ''),
            );
            if (match.kdProv.isNotEmpty) {
              selectedKdProv = match.kdProv;
            }
          }

          if (selectedKdProv != null && survey.kabupatenKota != null && survey.kabupatenKota!.isNotEmpty) {
            final match = wilayah.firstWhere(
              (w) => w.kdProv == selectedKdProv && w.namaKab.toUpperCase() == survey.kabupatenKota!.toUpperCase(),
              orElse: () => WilayahModel(idSubsls: '', kdProv: '', kdKab: '', kdKec: '', kdDesa: '', kdSls: '', namaProv: '', namaKab: '', namaKec: '', namaDesa: '', namaSls: '', kdPos: ''),
            );
            if (match.kdKab.isNotEmpty) {
              selectedKdKab = match.kdKab;
            }
          }

          if (selectedKdProv != null && selectedKdKab != null && survey.kecamatan != null && survey.kecamatan!.isNotEmpty) {
            final match = wilayah.firstWhere(
              (w) => w.kdProv == selectedKdProv && w.kdKab == selectedKdKab && w.namaKec.toUpperCase() == survey.kecamatan!.toUpperCase(),
              orElse: () => WilayahModel(idSubsls: '', kdProv: '', kdKab: '', kdKec: '', kdDesa: '', kdSls: '', namaProv: '', namaKab: '', namaKec: '', namaDesa: '', namaSls: '', kdPos: ''),
            );
            if (match.kdKec.isNotEmpty) {
              selectedKdKec = match.kdKec;
            }
          }

          if (selectedKdProv != null && selectedKdKab != null && selectedKdKec != null && survey.desaKelurahan != null && survey.desaKelurahan!.isNotEmpty) {
            final match = wilayah.firstWhere(
              (w) => w.kdProv == selectedKdProv && w.kdKab == selectedKdKab && w.kdKec == selectedKdKec && w.namaDesa.toUpperCase() == survey.desaKelurahan!.toUpperCase(),
              orElse: () => WilayahModel(idSubsls: '', kdProv: '', kdKab: '', kdKec: '', kdDesa: '', kdSls: '', namaProv: '', namaKab: '', namaKec: '', namaDesa: '', namaSls: '', kdPos: ''),
            );
            if (match.kdDesa.isNotEmpty) {
              selectedKdDesa = match.kdDesa;
            }
          }

          if (selectedKdProv != null && selectedKdKab != null && selectedKdKec != null && selectedKdDesa != null && survey.kodeSls != null && survey.kodeSls!.isNotEmpty) {
            final match = wilayah.firstWhere(
              (w) => w.kdProv == selectedKdProv && w.kdKab == selectedKdKab && w.kdKec == selectedKdKec && w.kdDesa == selectedKdDesa && w.kdSls == survey.kodeSls,
              orElse: () => WilayahModel(idSubsls: '', kdProv: '', kdKab: '', kdKec: '', kdDesa: '', kdSls: '', namaProv: '', namaKab: '', namaKec: '', namaDesa: '', namaSls: '', kdPos: ''),
            );
            if (match.kdSls.isNotEmpty) {
              selectedKdSls = match.kdSls;
            }
          }

          // Ensure value is present in items or set to null
          final provinces = provider.getProvinces();
          if (selectedKdProv != null && !provinces.any((p) => p['kdProv'] == selectedKdProv)) {
            selectedKdProv = null;
          }

          final regencies = provider.getRegencies(selectedKdProv);
          if (selectedKdKab != null && !regencies.any((r) => r['kdKab'] == selectedKdKab)) {
            selectedKdKab = null;
          }

          final districts = provider.getDistricts(selectedKdProv, selectedKdKab);
          if (selectedKdKec != null && !districts.any((d) => d['kdKec'] == selectedKdKec)) {
            selectedKdKec = null;
          }

          final villages = provider.getVillages(selectedKdProv, selectedKdKab, selectedKdKec);
          if (selectedKdDesa != null && !villages.any((v) => v['kdDesa'] == selectedKdDesa)) {
            selectedKdDesa = null;
          }

          final slsList = provider.getSlsList(selectedKdProv, selectedKdKab, selectedKdKec, selectedKdDesa);
          if (selectedKdSls != null && !slsList.any((s) => s.kdSls == selectedKdSls)) {
            selectedKdSls = null;
          }

          final postalCodes = provider.getPostalCodes(selectedKdProv, selectedKdKab, selectedKdKec, selectedKdDesa);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 3.a Provinsi
              const FormLabel('3. a. Provinsi *'),
              DropdownButtonFormField<String>(
                decoration: getFormDecoration(
                  value: selectedKdProv,
                  hintText: 'Pilih Provinsi',
                ),
                isExpanded: true,
                value: selectedKdProv,
                items: provinces.map((p) {
                  return DropdownMenuItem<String>(
                    value: p['kdProv'],
                    child: Text(p['namaProv']!),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    final name = provinces.firstWhere((p) => p['kdProv'] == val)['namaProv']!;
                    provider.updateActiveSurvey((s) {
                      s.provinsi = name;
                      s.kabupatenKota = null;
                      s.kecamatan = null;
                      s.desaKelurahan = null;
                      s.kodeSls = null;
                      s.namaSls = null;
                      s.kodePos = null;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // 3.b Kabupaten/Kota
              const FormLabel('3. b. Kabupaten/Kota *'),
              DropdownButtonFormField<String>(
                decoration: getFormDecoration(
                  value: selectedKdKab,
                  hintText: 'Pilih Kabupaten/Kota',
                ),
                isExpanded: true,
                value: selectedKdKab,
                items: regencies.map((r) {
                  return DropdownMenuItem<String>(
                    value: r['kdKab'],
                    child: Text(r['namaKab']!),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    final name = regencies.firstWhere((r) => r['kdKab'] == val)['namaKab']!;
                    provider.updateActiveSurvey((s) {
                      s.kabupatenKota = name;
                      s.kecamatan = null;
                      s.desaKelurahan = null;
                      s.kodeSls = null;
                      s.namaSls = null;
                      s.kodePos = null;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // 3.c Kecamatan
              const FormLabel('3. c. Kecamatan *'),
              DropdownButtonFormField<String>(
                decoration: getFormDecoration(
                  value: selectedKdKec,
                  hintText: 'Pilih Kecamatan',
                ),
                isExpanded: true,
                value: selectedKdKec,
                items: districts.map((d) {
                  return DropdownMenuItem<String>(
                    value: d['kdKec'],
                    child: Text(d['namaKec']!),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    final name = districts.firstWhere((d) => d['kdKec'] == val)['namaKec']!;
                    provider.updateActiveSurvey((s) {
                      s.kecamatan = name;
                      s.desaKelurahan = null;
                      s.kodeSls = null;
                      s.namaSls = null;
                      s.kodePos = null;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // 3.d Desa/Kelurahan
              const FormLabel('3. d. Desa/Kelurahan *'),
              DropdownButtonFormField<String>(
                decoration: getFormDecoration(
                  value: selectedKdDesa,
                  hintText: 'Pilih Desa/Kelurahan',
                ),
                isExpanded: true,
                value: selectedKdDesa,
                items: villages.map((v) {
                  return DropdownMenuItem<String>(
                    value: v['kdDesa'],
                    child: Text(v['namaDesa']!),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    final name = villages.firstWhere((v) => v['kdDesa'] == val)['namaDesa']!;
                    final pCodes = provider.getPostalCodes(selectedKdProv, selectedKdKab, selectedKdKec, val);
                    provider.updateActiveSurvey((s) {
                      s.desaKelurahan = name;
                      s.kodeSls = null;
                      s.namaSls = null;
                      if (pCodes.isNotEmpty) {
                        s.kodePos = pCodes.first;
                      } else {
                        s.kodePos = null;
                      }
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // 3.e Klasifikasi Desa/Kota
              const FormLabel('3. e. Klasifikasi Desa/Kota'),
              DropdownButtonFormField<String>(
                decoration: getFormDecoration(
                  value: survey.klasifikasiDesa,
                ),
                isExpanded: true,
                value: survey.klasifikasiDesa,
                items: const [
                  DropdownMenuItem(value: '1', child: Text('1. Perkotaan')),
                  DropdownMenuItem(value: '2', child: Text('2. Perdesaan')),
                ],
                onChanged: (val) => provider.updateActiveSurvey((s) => s.klasifikasiDesa = val),
              ),
              const SizedBox(height: 16),

              // 3.f Kode Pos
              const FormLabel('3. f. Kode Pos'),
              DropdownButtonFormField<String>(
                decoration: getFormDecoration(
                  value: (survey.kodePos != null && postalCodes.contains(survey.kodePos)) ? survey.kodePos : null,
                  hintText: postalCodes.isEmpty ? 'Pilih Desa terlebih dahulu' : 'Pilih Kode Pos',
                ),
                isExpanded: true,
                value: (survey.kodePos != null && postalCodes.contains(survey.kodePos)) ? survey.kodePos : null,
                items: postalCodes.map((cp) {
                  return DropdownMenuItem<String>(
                    value: cp,
                    child: Text(cp),
                  );
                }).toList(),
                onChanged: postalCodes.isEmpty ? null : (val) {
                  if (val != null) {
                    provider.updateActiveSurvey((s) => s.kodePos = val);
                  }
                },
              ),
              const SizedBox(height: 16),

              // 3.g SLS (Dropdown)
              const FormLabel('3. g. Satuan Lingkungan Setempat (SLS) *'),
              DropdownButtonFormField<String>(
                decoration: getFormDecoration(
                  value: selectedKdSls,
                  hintText: 'Pilih SLS',
                ),
                isExpanded: true,
                value: selectedKdSls,
                items: slsList.map((s) {
                  return DropdownMenuItem<String>(
                    value: s.kdSls,
                    child: Text(s.namaSls),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    final match = slsList.firstWhere((s) => s.kdSls == val);
                    provider.updateActiveSurvey((s) {
                      s.kodeSls = match.kdSls;
                      s.namaSls = match.namaSls;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // 3.h Kode SLS (Autofill)
              const FormLabel('3. h. Kode SLS (Autofill)'),
              TextFormField(
                key: ValueKey('kodeSls_${survey.kodeSls}'),
                decoration: getFormDecoration(
                  value: survey.kodeSls,
                  isAutofill: true,
                  hintText: 'Kode SLS terisi otomatis',
                ),
                readOnly: true,
                controller: TextEditingController(text: survey.kodeSls ?? '-'),
              ),
              const SizedBox(height: 16),
            ],
          );
        }(),

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
        const FormLabel('3. l. Geotagging Wilayah'),
        TextFormField(
          key: ValueKey('latitude_${survey.latitude}'),
          decoration: getFormDecoration(
            value: survey.latitude != null && survey.latitude != 0.0 ? 'set' : '',
            isAutofill: true,
            hintText: 'Latitude',
          ),
          readOnly: true,
          controller: TextEditingController(
            text: survey.latitude != null && survey.latitude != 0.0
                ? survey.latitude!.toStringAsFixed(6)
                : 'Not set',
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          key: ValueKey('longitude_${survey.longitude}'),
          decoration: getFormDecoration(
            value: survey.longitude != null && survey.longitude != 0.0 ? 'set' : '',
            isAutofill: true,
            hintText: 'Longitude',
          ),
          readOnly: true,
          controller: TextEditingController(
            text: survey.longitude != null && survey.longitude != 0.0
                ? survey.longitude!.toStringAsFixed(6)
                : 'Not set',
          ),
        ),
        const SizedBox(height: 12),

        // Interactive Map
        if (survey.latitude != null && survey.latitude != 0.0 && survey.longitude != null && survey.longitude != 0.0)
          Container(
            height: 220,
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.colorScheme.outlineVariant),
            ),
            clipBehavior: Clip.antiAlias,
            child: FlutterMap(
              key: ValueKey('map_${survey.latitude}_${survey.longitude}'),
              options: MapOptions(
                initialCenter: LatLng(survey.latitude!, survey.longitude!),
                initialZoom: 16.0,
                onTap: (tapPosition, point) {
                  provider.updateActiveSurvey((s) {
                    s.latitude = point.latitude;
                    s.longitude = point.longitude;
                  });
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.form_descan',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(survey.latitude!, survey.longitude!),
                      width: 50,
                      height: 50,
                      child: const Icon(
                        Icons.location_pin,
                        color: Colors.red,
                        size: 40,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
        else
          Container(
            height: 120,
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.map_outlined, color: Colors.grey.shade500, size: 40),
                const SizedBox(height: 8),
                Text(
                  'Peta belum aktif. Ambil lokasi untuk menampilkan peta.',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.my_location),
            label: const Text('Ambil Lokasi (Geotagging)'),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor.withValues(alpha: 0.1),
              foregroundColor: theme.primaryColor,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            onPressed: () => _getCurrentLocation(context, provider),
          ),
        ),
        const SizedBox(height: 24),

        // 4. Apakah alamat tersebut sesuai KK?
        const FormLabel('4. Apakah alamat tersebut sesuai dengan alamat pada Kartu Keluarga?'),
        DropdownButtonFormField<String>(
          decoration: getFormDecoration(
            value: survey.alamatSesuaiKk,
          ),
          isExpanded: true,
          initialValue: survey.alamatSesuaiKk,
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

  Future<void> _getCurrentLocation(BuildContext context, SurveyProvider provider) async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (!context.mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Layanan Lokasi Tidak Aktif'),
          content: const Text('Harap aktifkan GPS / layanan lokasi pada perangkat Anda.'),
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

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (!context.mounted) return;
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Izin Lokasi Ditolak'),
            content: const Text('Aplikasi membutuhkan izin lokasi untuk mengambil koordinat geotagging.'),
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
    }

    if (permission == LocationPermission.deniedForever) {
      if (!context.mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Izin Lokasi Ditolak Permanen'),
          content: const Text('Izin lokasi ditolak secara permanen. Harap aktifkan izin lokasi untuk aplikasi ini di Pengaturan perangkat Anda.'),
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

    try {
      // Show loading indicator
      if (!context.mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      if (context.mounted) {
        Navigator.pop(context); // Close loading indicator
      }

      provider.updateActiveSurvey((s) {
        s.latitude = position.latitude;
        s.longitude = position.longitude;
      });

      if (!context.mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Sukses'),
          content: const Text('Koordinat lokasi berhasil dideteksi dan diperbarui.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Close loading indicator if open
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Gagal Mengambil Lokasi'),
            content: Text('Terjadi kesalahan saat mengambil koordinat: $e'),
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

  Widget _buildTextField({
    required String label,
    String? initialValue,
    TextInputType keyboardType = TextInputType.text,
    int? maxLength,
    int maxLines = 1,
    String? helperText,
    required void Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FormLabel(label, helperText: helperText),
        TextFormField(
          initialValue: initialValue,
          keyboardType: keyboardType,
          maxLength: maxLength,
          maxLines: maxLines,
          decoration: getFormDecoration(
            value: initialValue,
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
