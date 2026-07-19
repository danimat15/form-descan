import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import '../models/survey_model.dart';
import '../models/wilayah_model.dart';
import '../services/auth_service.dart';

class SurveyProvider with ChangeNotifier {
  List<SurveyModel> _drafts = [];
  List<SurveyModel> _syncedSurveys = [];
  SurveyModel? _activeSurvey;
  int _currentStep = 0; // 0 = Blok I, 1 = Blok II, 2 = Blok III, 3 = Blok IV
  bool _isSaving = false;
  bool _isSyncing = false;

  // Configuration (should match backend deployment URL)
  String _apiBaseUrl = 'https://nlab-sangihe.web.bps.go.id/backend-form';

  List<SurveyModel> get drafts => _drafts;
  List<SurveyModel> get syncedSurveys => _syncedSurveys;
  SurveyModel? get activeSurvey => _activeSurvey;
  int get currentStep => _currentStep;
  bool get isSaving => _isSaving;
  bool get isSyncing => _isSyncing;
  
  Map<String, dynamic>? _userProfile;
  Map<String, dynamic>? get userProfile => _userProfile;

  set apiBaseUrl(String url) {
    _apiBaseUrl = url;
    notifyListeners();
  }

  String get apiBaseUrl => _apiBaseUrl;

  List<WilayahModel> _wilayahList = [];
  List<WilayahModel> get wilayahList => _wilayahList;
  bool _isLoadingWilayah = false;
  bool get isLoadingWilayah => _isLoadingWilayah;

  // Load drafts, API URL, and profile details on startup
  Future<void> initializeProvider() async {
    await loadDrafts();
    await loadSyncedSurveys();
    _apiBaseUrl = await AuthService.getApiBaseUrl();
    _userProfile = await AuthService.getUser();
    await loadCachedWilayah();
    fetchAndCacheWilayah(); // background fetch
    notifyListeners();
  }

  Future<void> loadCachedWilayah() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString('cached_wilayah_data');
      if (cached != null) {
        final List<dynamic> decoded = json.decode(cached);
        _wilayahList = decoded.map((e) => WilayahModel.fromJson(e)).toList();
        _autoFillActiveSurveyFromProfile();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading cached wilayah: $e');
    }
  }

  Future<void> fetchAndCacheWilayah() async {
    final token = await AuthService.getToken();
    if (token == null) return;
    
    _isLoadingWilayah = true;
    notifyListeners();
    
    try {
      final response = await http.get(
        Uri.parse('$_apiBaseUrl/api/wilayah'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> decoded = json.decode(response.body);
        _wilayahList = decoded.map((e) => WilayahModel.fromJson(e)).toList();
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('cached_wilayah_data', response.body);
        debugPrint('✓ Wilayah data cached successfully: ${_wilayahList.length} records.');
        _autoFillActiveSurveyFromProfile();
      }
    } catch (e) {
      debugPrint('Error fetching wilayah: $e');
    } finally {
      _isLoadingWilayah = false;
      notifyListeners();
    }
  }

  List<Map<String, String>> getProvinces() {
    final Map<String, String> unique = {};
    for (var item in _wilayahList) {
      unique[item.kdProv] = item.namaProv;
    }
    return unique.entries.map((e) => {'kdProv': e.key, 'namaProv': e.value}).toList();
  }

  List<Map<String, String>> getRegencies(String? provCode) {
    if (provCode == null || provCode.isEmpty) return [];
    final Map<String, String> unique = {};
    for (var item in _wilayahList) {
      if (item.kdProv == provCode) {
        unique[item.kdKab] = item.namaKab;
      }
    }
    return unique.entries.map((e) => {'kdKab': e.key, 'namaKab': e.value}).toList();
  }

  List<Map<String, String>> getDistricts(String? provCode, String? regencyCode) {
    if (provCode == null || regencyCode == null || provCode.isEmpty || regencyCode.isEmpty) return [];
    final Map<String, String> unique = {};
    for (var item in _wilayahList) {
      if (item.kdProv == provCode && item.kdKab == regencyCode) {
        unique[item.kdKec] = item.namaKec;
      }
    }
    return unique.entries.map((e) => {'kdKec': e.key, 'namaKec': e.value}).toList();
  }

  List<Map<String, String>> getVillages(String? provCode, String? regencyCode, String? districtCode) {
    if (provCode == null || regencyCode == null || districtCode == null || 
        provCode.isEmpty || regencyCode.isEmpty || districtCode.isEmpty) return [];
    final Map<String, String> unique = {};
    for (var item in _wilayahList) {
      if (item.kdProv == provCode && item.kdKab == regencyCode && item.kdKec == districtCode) {
        unique[item.kdDesa] = item.namaDesa;
      }
    }
    return unique.entries.map((e) => {'kdDesa': e.key, 'namaDesa': e.value}).toList();
  }

  List<WilayahModel> getSlsList(String? provCode, String? regencyCode, String? districtCode, String? villageCode) {
    if (provCode == null || regencyCode == null || districtCode == null || villageCode == null ||
        provCode.isEmpty || regencyCode.isEmpty || districtCode.isEmpty || villageCode.isEmpty) return [];
    return _wilayahList.where((item) => 
      item.kdProv == provCode && 
      item.kdKab == regencyCode && 
      item.kdKec == districtCode && 
      item.kdDesa == villageCode
    ).toList();
  }

  List<String> getPostalCodes(String? provCode, String? regencyCode, String? districtCode, String? villageCode) {
    if (provCode == null || regencyCode == null || districtCode == null || villageCode == null ||
        provCode.isEmpty || regencyCode.isEmpty || districtCode.isEmpty || villageCode.isEmpty) return [];
    
    final Set<String> unique = {};
    for (var item in _wilayahList) {
      if (item.kdProv == provCode && 
          item.kdKab == regencyCode && 
          item.kdKec == districtCode && 
          item.kdDesa == villageCode) {
        if (item.kdPos.isNotEmpty) {
          unique.add(item.kdPos);
        }
      }
    }
    return unique.toList();
  }

  // Fetch surveyor profile details from MySQL backend
  Future<void> fetchUserProfile() async {
    final token = await AuthService.getToken();
    if (token == null) return;
    
    try {
      final response = await http.get(
        Uri.parse('$_apiBaseUrl/api/profile'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        _userProfile = json.decode(response.body);
        
        // Keep local storage updated
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_user', response.body);
        
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching user profile: $e');
    }
  }

  // Set active step
  void setStep(int step) {
    if (step >= 0 && step <= 3) {
      _currentStep = step;
      notifyListeners();
    }
  }

  // Load drafts from Shared Preferences
  Future<void> loadDrafts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final draftsJson = prefs.getStringList('survey_drafts') ?? [];
      
      _drafts = draftsJson
          .map((item) => SurveyModel.fromJson(json.decode(item)))
          .toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading drafts: $e');
    }
  }

  // Save drafts list to Shared Preferences
  Future<void> _saveDraftsToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final draftsJson = _drafts
          .map((item) => json.encode(item.toJson()))
          .toList();
      await prefs.setStringList('survey_drafts', draftsJson);
    } catch (e) {
      debugPrint('Error storing drafts: $e');
    }
  }

  // Load synced surveys from Shared Preferences
  Future<void> loadSyncedSurveys() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final syncedJson = prefs.getStringList('survey_synced') ?? [];
      
      _syncedSurveys = syncedJson
          .map((item) => SurveyModel.fromJson(json.decode(item)))
          .toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading synced surveys: $e');
    }
  }

  // Save synced list to Shared Preferences
  Future<void> _saveSyncedSurveysToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final syncedJson = _syncedSurveys
          .map((item) => json.encode(item.toJson()))
          .toList();
      await prefs.setStringList('survey_synced', syncedJson);
    } catch (e) {
      debugPrint('Error storing synced surveys: $e');
    }
  }

  // Start a new survey
  void startNewSurvey(String userId) {
    _activeSurvey = SurveyModel.createNew(userId);
    _autoFillActiveSurveyFromProfile();
    _currentStep = 0;
    notifyListeners();
  }

  void _autoFillActiveSurveyFromProfile() {
    if (_activeSurvey != null && _userProfile != null && _wilayahList.isNotEmpty) {
      final userDesa = _userProfile!['desa']?.toString().toUpperCase() ?? '';
      final userKec = _userProfile!['kecamatan']?.toString().toUpperCase() ?? '';
      final userKab = _userProfile!['kabupaten']?.toString().toUpperCase() ?? '';
      
      final match = _wilayahList.firstWhere(
        (w) => w.namaDesa.toUpperCase() == userDesa &&
               w.namaKec.toUpperCase() == userKec &&
               w.namaKab.toUpperCase() == userKab,
        orElse: () => WilayahModel(idSubsls: '', kdProv: '', kdKab: '', kdKec: '', kdDesa: '', kdSls: '', namaProv: '', namaKab: '', namaKec: '', namaDesa: '', namaSls: '', kdPos: ''),
      );

      if (match.idSubsls.isNotEmpty) {
        _activeSurvey!.provinsi = match.namaProv;
        _activeSurvey!.kabupatenKota = match.namaKab;
        _activeSurvey!.kecamatan = match.namaKec;
        _activeSurvey!.desaKelurahan = match.namaDesa;
      } else {
        // Fallback to profile strings
        _activeSurvey!.provinsi = 'SULAWESI UTARA';
        _activeSurvey!.kabupatenKota = _userProfile!['kabupaten']?.toString().toUpperCase();
        _activeSurvey!.kecamatan = _userProfile!['kecamatan']?.toString().toUpperCase();
        _activeSurvey!.desaKelurahan = _userProfile!['desa']?.toString().toUpperCase();
      }
    } else if (_activeSurvey != null && _userProfile != null) {
      // If wilayahList is not loaded yet, do a simple fallback
      _activeSurvey!.provinsi = 'SULAWESI UTARA';
      _activeSurvey!.kabupatenKota = _userProfile!['kabupaten']?.toString().toUpperCase();
      _activeSurvey!.kecamatan = _userProfile!['kecamatan']?.toString().toUpperCase();
      _activeSurvey!.desaKelurahan = _userProfile!['desa']?.toString().toUpperCase();
    }
  }

  // Load a draft as active
  void loadSurvey(SurveyModel survey) {
    _activeSurvey = survey;
    _currentStep = 0;
    notifyListeners();
  }

  // Update active survey fields
  void updateActiveSurvey(void Function(SurveyModel survey) updateFn) {
    if (_activeSurvey != null) {
      updateFn(_activeSurvey!);
      _activeSurvey!.updatedAt = DateTime.now();
      
      // Update in drafts list
      final index = _drafts.indexWhere((d) => d.id == _activeSurvey!.id);
      if (index >= 0) {
        _drafts[index] = _activeSurvey!;
      } else {
        _drafts.add(_activeSurvey!);
      }
      
      _saveDraftsToStorage();
      notifyListeners();
    }
  }

  // Delete a survey draft
  Future<void> deleteSurvey(String id) async {
    _drafts.removeWhere((d) => d.id == id);
    if (_activeSurvey?.id == id) {
      _activeSurvey = null;
      _currentStep = 0;
    }
    await _saveDraftsToStorage();
    notifyListeners();
  }

  // Dynamic automatic calculations
  void recalculateActiveSurvey() {
    if (_activeSurvey == null) return;

    // Ensure first family member represents Kepala Keluarga
    final namaKk = _activeSurvey!.namaKk ?? '';
    final nikKk = _activeSurvey!.nikKk ?? '';
    if (namaKk.isNotEmpty || nikKk.isNotEmpty) {
      final firstMemberIndex = _activeSurvey!.familyMembers.indexWhere((m) => m.noUrut == 1);
      if (firstMemberIndex >= 0) {
        final member = _activeSurvey!.familyMembers[firstMemberIndex];
        // Only set values if they are empty (or differ, to prevent loops)
        if (member.nama.isEmpty && namaKk.isNotEmpty) {
          member.nama = namaKk;
        }
        if ((member.nik == null || member.nik!.isEmpty) && nikKk.isNotEmpty) {
          member.nik = nikKk;
        }
        member.hubunganKk = '1';

        // Update survey details if the member is updated
        if (_activeSurvey!.namaKk != member.nama && member.nama.isNotEmpty) {
          _activeSurvey!.namaKk = member.nama;
        }
        if (_activeSurvey!.nikKk != member.nik && member.nik != null && member.nik!.isNotEmpty) {
          _activeSurvey!.nikKk = member.nik;
        }
      } else {
        // Insert Kepala Keluarga as member 1
        _activeSurvey!.familyMembers.insert(0, FamilyMemberModel(
          id: const Uuid().v4(),
          surveyId: _activeSurvey!.id,
          noUrut: 1,
          nama: namaKk,
          nik: nikKk,
          hubunganKk: '1', // Kepala Keluarga
        ));
      }
    }

    // 1. Auto-fill Jumlah Anggota Keluarga hasil pendataan (Blok I r2.b)
    _activeSurvey!.jmlAnggotaPendataan = _activeSurvey!.familyMembers.length;

    // 2. Recalculate member total income
    for (var member in _activeSurvey!.familyMembers) {
      final double g = double.tryParse(member.gaji ?? '0') ?? 0;
      final double t = double.tryParse(member.tunjangan ?? '0') ?? 0;
      final double u = double.tryParse(member.uangMakan ?? '0') ?? 0;
      final double h = double.tryParse(member.honor ?? '0') ?? 0;
      final double l = double.tryParse(member.lembur ?? '0') ?? 0;
      final double o = double.tryParse(member.pendapatanLain ?? '0') ?? 0;
      
      member.totalPendapatan = (g + t + u + h + l + o).toStringAsFixed(0);
    }

    _activeSurvey!.updatedAt = DateTime.now();
    notifyListeners();
    _saveDraftsToStorage();
  }

  // Family Member CRUD
  void addFamilyMember() {
    if (_activeSurvey != null) {
      final nextUrut = _activeSurvey!.familyMembers.length + 1;
      final newMember = FamilyMemberModel.createNew(_activeSurvey!.id, nextUrut);
      _activeSurvey!.familyMembers.add(newMember);
      recalculateActiveSurvey();
    }
  }

  void removeFamilyMember(String memberId) {
    if (_activeSurvey != null) {
      final index = _activeSurvey!.familyMembers.indexWhere((m) => m.id == memberId);
      final isFirst = index >= 0 && _activeSurvey!.familyMembers[index].noUrut == 1;

      _activeSurvey!.familyMembers.removeWhere((m) => m.id == memberId);
      
      if (isFirst) {
        _activeSurvey!.namaKk = '';
        _activeSurvey!.nikKk = '';
      }

      // Re-sequence noUrut
      for (int i = 0; i < _activeSurvey!.familyMembers.length; i++) {
        _activeSurvey!.familyMembers[i].noUrut = i + 1;
      }
      recalculateActiveSurvey();
    }
  }

  void updateFamilyMember(String memberId, void Function(FamilyMemberModel member) updateFn) {
    if (_activeSurvey != null) {
      final index = _activeSurvey!.familyMembers.indexWhere((m) => m.id == memberId);
      if (index >= 0) {
        updateFn(_activeSurvey!.familyMembers[index]);

        final member = _activeSurvey!.familyMembers[index];
        if (member.noUrut == 1) {
          _activeSurvey!.namaKk = member.nama;
          _activeSurvey!.nikKk = member.nik;
          member.hubunganKk = '1'; // Force hubunganKk to be '1' (Kepala Keluarga)
        }

        recalculateActiveSurvey();
      }
    }
  }

  // Sync active or specific survey with Express/cPanel API
  Future<bool> syncSurvey(String surveyId) async {
    final survey = _drafts.firstWhere((d) => d.id == surveyId);
    if (survey.completionPercentage < 100) {
      throw Exception('Kuesioner belum lengkap (100%). Selesaikan pengisian sebelum melakukan sinkronisasi.');
    }

    _isSyncing = true;
    notifyListeners();

    try {
      final token = await AuthService.getToken();

      if (token == null) {
        throw Exception('User is not authenticated.');
      }

      final response = await http.post(
        Uri.parse('$_apiBaseUrl/api/surveys'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(survey.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Move from drafts to synced surveys list
        final surveyIndex = _drafts.indexWhere((d) => d.id == surveyId);
        if (surveyIndex >= 0) {
          final s = _drafts[surveyIndex];
          if (!_syncedSurveys.any((item) => item.id == surveyId)) {
            _syncedSurveys.add(s);
          }
          _drafts.removeAt(surveyIndex);
        }

        if (_activeSurvey?.id == surveyId) {
          _activeSurvey = null;
          _currentStep = 0;
        }
        await _saveDraftsToStorage();
        await _saveSyncedSurveysToStorage();
        _isSyncing = false;
        notifyListeners();
        return true;
      } else {
        final err = json.decode(response.body);
        throw Exception(err['error'] ?? 'Sync failed with status code ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Sync Error: $e');
      _isSyncing = false;
      notifyListeners();
      return false;
    }
  }

  // Export backup data as JSON string
  String exportBackupData() {
    final Map<String, dynamic> backupPayload = {
      'app': 'Form Descan',
      'version': '1.0.0+1',
      'timestamp': DateTime.now().toIso8601String(),
      'exportedBy': _userProfile?['email'] ?? 'surveyor@bps.go.id',
      'draftsCount': _drafts.length,
      'syncedCount': _syncedSurveys.length,
      'drafts': _drafts.map((d) => d.toJson()).toList(),
      'syncedSurveys': _syncedSurveys.map((s) => s.toJson()).toList(),
    };
    return json.encode(backupPayload);
  }

  // Import and restore backup data from JSON string
  Future<Map<String, dynamic>> importBackupData(String jsonString) async {
    try {
      final Map<String, dynamic> data = json.decode(jsonString);
      
      if (!data.containsKey('drafts') && !data.containsKey('syncedSurveys')) {
        throw const FormatException('Format data backup tidak valid (tidak ditemukan atribut drafts/syncedSurveys).');
      }

      int restoredDrafts = 0;
      int restoredSynced = 0;

      // Restore Drafts
      if (data['drafts'] != null && data['drafts'] is List) {
        final List<dynamic> draftsList = data['drafts'];
        for (var item in draftsList) {
          try {
            final survey = SurveyModel.fromJson(item is String ? json.decode(item) : item);
            final existingIndex = _drafts.indexWhere((d) => d.id == survey.id);
            if (existingIndex >= 0) {
              _drafts[existingIndex] = survey;
            } else {
              _drafts.add(survey);
            }
            restoredDrafts++;
          } catch (e) {
            debugPrint('Error restoring draft item: $e');
          }
        }
        await _saveDraftsToStorage();
      }

      // Restore Synced Surveys
      if (data['syncedSurveys'] != null && data['syncedSurveys'] is List) {
        final List<dynamic> syncedList = data['syncedSurveys'];
        for (var item in syncedList) {
          try {
            final survey = SurveyModel.fromJson(item is String ? json.decode(item) : item);
            final existingIndex = _syncedSurveys.indexWhere((s) => s.id == survey.id);
            if (existingIndex >= 0) {
              _syncedSurveys[existingIndex] = survey;
            } else {
              _syncedSurveys.add(survey);
            }
            restoredSynced++;
          } catch (e) {
            debugPrint('Error restoring synced item: $e');
          }
        }
        await _saveSyncedSurveysToStorage();
      }

      notifyListeners();

      return {
        'success': true,
        'restoredDrafts': restoredDrafts,
        'restoredSynced': restoredSynced,
      };
    } catch (e) {
      debugPrint('Restore error: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
}

