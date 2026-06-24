import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../models/survey_model.dart';
import '../services/auth_service.dart';

class SurveyProvider with ChangeNotifier {
  List<SurveyModel> _drafts = [];
  SurveyModel? _activeSurvey;
  int _currentStep = 0; // 0 = Blok I, 1 = Blok II, 2 = Blok III, 3 = Blok IV
  bool _isSaving = false;
  bool _isSyncing = false;

  // Configuration (should match backend deployment URL)
  String _apiBaseUrl = 'https://nlab-sangihe.web.bps.go.id/backend-form';

  List<SurveyModel> get drafts => _drafts;
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

  // Load drafts, API URL, and profile details on startup
  Future<void> initializeProvider() async {
    await loadDrafts();
    _apiBaseUrl = await AuthService.getApiBaseUrl();
    _userProfile = await AuthService.getUser();
    notifyListeners();
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

  // Start a new survey
  void startNewSurvey(String userId) {
    _activeSurvey = SurveyModel.createNew(userId);
    if (_userProfile != null) {
      _activeSurvey!.provinsi = 'Sulawesi Utara'; // Default BPS Sangihe region
      _activeSurvey!.kabupatenKota = _userProfile!['kabupaten'];
      _activeSurvey!.kecamatan = _userProfile!['kecamatan'];
      _activeSurvey!.desaKelurahan = _userProfile!['desa'];
    }
    _currentStep = 0;
    notifyListeners();
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
      _activeSurvey!.familyMembers.removeWhere((m) => m.id == memberId);
      
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
        recalculateActiveSurvey();
      }
    }
  }

  // Sync active or specific survey with Express/cPanel API
  Future<bool> syncSurvey(String surveyId) async {
    _isSyncing = true;
    notifyListeners();

    try {
      final survey = _drafts.firstWhere((d) => d.id == surveyId);
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
        // Remove from local drafts after successful sync
        _drafts.removeWhere((d) => d.id == surveyId);
        if (_activeSurvey?.id == surveyId) {
          _activeSurvey = null;
          _currentStep = 0;
        }
        await _saveDraftsToStorage();
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
}
