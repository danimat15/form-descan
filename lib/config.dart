class AppConfig {
  static const String supabaseUrl = 'https://supabase-sangihe.mentorku.online/';
  static const String supabaseAnonKey = 'sb_publishable_utiC9_PLzI8hhbp7jbgSDz_ttAnF1hS';

  // Helper getter to determine if the app is running in mock mode
  static bool get isMockMode => supabaseUrl.contains('placeholder');
}
