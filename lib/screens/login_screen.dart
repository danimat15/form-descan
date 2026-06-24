import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/survey_provider.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  // Profile registration controllers
  final _desaController = TextEditingController();
  final _kecamatanController = TextEditingController();
  final _kabupatenController = TextEditingController();

  bool _isLoading = false;
  bool _isSignUp = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _desaController.dispose();
    _kecamatanController.dispose();
    _kabupatenController.dispose();
    super.dispose();
  }

  Future<void> _handleAuth() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final provider = Provider.of<SurveyProvider>(context, listen: false);

      if (_isSignUp) {
        final result = await AuthService.register(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          desa: _desaController.text.trim(),
          kecamatan: _kecamatanController.text.trim(),
          kabupaten: _kabupatenController.text.trim(),
        );

        if (result['success'] == true) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Registration successful! You can now log in.')),
            );
            setState(() {
              _isSignUp = false;
              _isLoading = false;
            });
          }
        } else {
          setState(() {
            _errorMessage = result['error'];
            _isLoading = false;
          });
        }
      } else {
        final result = await AuthService.login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        if (result['success'] == true) {
          await provider.initializeProvider();
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/dashboard');
          }
        } else {
          setState(() {
            _errorMessage = result['error'];
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F3F5),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 40),
              // Hero/Logo Section
              Center(
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: theme.colorScheme.outlineVariant),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      )
                    ],
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Image.asset(
                    'logo.png',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.assignment_ind_rounded,
                        size: 48,
                        color: theme.primaryColor,
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Desa Cantik',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Text(
                  'Sistem Informasi Pengolahan Data Desa Cinta Statistik Kabupaten Kepulauan Sangihe.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 28),

              // Login Container Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Card(
                    color: Colors.white,
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: theme.colorScheme.outlineVariant),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (_errorMessage != null) ...[
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.error.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: theme.colorScheme.error.withOpacity(0.2)),
                                ),
                                child: Text(
                                  _errorMessage!,
                                  style: TextStyle(color: theme.colorScheme.error, fontWeight: FontWeight.w600),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],

                            // Email Field
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              style: TextStyle(color: theme.colorScheme.onSurface),
                              decoration: const InputDecoration(
                                labelText: 'E-mail Petugas',
                                hintText: 'contoh@bps.go.id',
                                prefixIcon: Icon(Icons.email_outlined),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Email is required';
                                }
                                if (!value.contains('@')) {
                                  return 'Please enter a valid email';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Password Field
                            TextFormField(
                              controller: _passwordController,
                              obscureText: true,
                              style: TextStyle(color: theme.colorScheme.onSurface),
                              decoration: const InputDecoration(
                                labelText: 'Password',
                                hintText: '••••••••',
                                prefixIcon: Icon(Icons.lock_outline),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Password is required';
                                }
                                if (value.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }
                                return null;
                              },
                            ),

                            // Fields for registration
                            if (_isSignUp) ...[
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _desaController,
                                style: TextStyle(color: theme.colorScheme.onSurface),
                                decoration: const InputDecoration(
                                  labelText: 'Nama Desa / Kelurahan',
                                  prefixIcon: Icon(Icons.location_city_outlined),
                                ),
                                validator: (value) => value == null || value.trim().isEmpty ? 'Desa is required' : null,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _kecamatanController,
                                style: TextStyle(color: theme.colorScheme.onSurface),
                                decoration: const InputDecoration(
                                  labelText: 'Kecamatan',
                                  prefixIcon: Icon(Icons.map_outlined),
                                ),
                                validator: (value) => value == null || value.trim().isEmpty ? 'Kecamatan is required' : null,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _kabupatenController,
                                style: TextStyle(color: theme.colorScheme.onSurface),
                                decoration: const InputDecoration(
                                  labelText: 'Kabupaten',
                                  prefixIcon: Icon(Icons.explore_outlined),
                                ),
                                validator: (value) => value == null || value.trim().isEmpty ? 'Kabupaten is required' : null,
                              ),
                            ],
                            const SizedBox(height: 20),

                            // Keep logged in & Forgot password
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: Checkbox(
                                        value: true,
                                        onChanged: (val) {},
                                        activeColor: theme.colorScheme.primary,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Ingat Saya',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                                TextButton(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Silakan hubungi admin BPS Kabupaten untuk reset password.')),
                                    );
                                  },
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size.zero,
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: Text(
                                    'Lupa Password?',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Submit Button
                            ElevatedButton.icon(
                              onPressed: _isLoading ? null : _handleAuth,
                              icon: _isLoading
                                  ? const SizedBox.shrink()
                                  : const Icon(Icons.login),
                              label: _isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                    )
                                  : Text(_isSignUp ? 'REGISTER' : 'Masuk dengan Email'),
                            ),
                            const SizedBox(height: 16),

                            // Switch Login / Sign Up
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _isSignUp = !_isSignUp;
                                  _errorMessage = null;
                                });
                              },
                              child: Text(
                                _isSignUp
                                    ? 'Already have an account? Log In'
                                    : 'Don\'t have an account? Sign Up',
                                style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
                              ),
                            ),

                            // Divider
                            Row(
                              children: [
                                Expanded(child: Divider(color: theme.colorScheme.outlineVariant)),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                  child: Text(
                                    'atau',
                                    style: TextStyle(
                                      color: theme.colorScheme.onSurfaceVariant,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                Expanded(child: Divider(color: theme.colorScheme.outlineVariant)),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Google Button
                            OutlinedButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Fitur masuk dengan Google sedang dalam pengembangan. Silakan gunakan E-mail Petugas.')),
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: theme.colorScheme.outlineVariant, width: 1.5),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                backgroundColor: Colors.white,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.network(
                                    'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/24px-Google_%22G%22_logo.svg.png',
                                    height: 18,
                                    width: 18,
                                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.g_mobiledata),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Lanjutkan dengan Google',
                                    style: TextStyle(
                                      color: theme.colorScheme.onSurface,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 36),

              // Footer Attribution
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.business, size: 16, color: theme.colorScheme.onSurfaceVariant.withOpacity(0.6)),
                      const SizedBox(width: 6),
                      Text(
                        'BPS SANGIHE',
                        style: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '© 2026 Badan Pusat Statistik Kab. Kepulauan Sangihe.\nSemua Hak Dilindungi.',
                    style: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                      fontSize: 11,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
