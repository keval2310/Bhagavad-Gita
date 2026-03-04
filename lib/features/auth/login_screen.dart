import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../../core/app_theme.dart';
import '../home/main_navigation_screen.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/user_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your Divine Credentials.')),
      );
      return;
    }

    if (!email.toLowerCase().endsWith('@gmail.com')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Only @gmail.com IDs are accepted for this journey.'),
          backgroundColor: AppTheme.accentColor,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    final success = await ref.read(userProvider.notifier).login(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (success) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid credentials. Please check if your Soul exists in our records.'),
            backgroundColor: AppTheme.accentColor,
          ),
        );
      }
    }
  }

  void _showRegisterDialog() {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('New Journey', style: GoogleFonts.playfairDisplay(color: AppTheme.textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Soul Name')),
            TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Spiritual ID (Email)')),
            TextField(controller: passCtrl, decoration: const InputDecoration(labelText: 'Divine Key (Pass)')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
          ElevatedButton(
            onPressed: () async {
              final email = emailCtrl.text.trim();
              final pass = passCtrl.text.trim();
              final name = nameCtrl.text.trim();

              if (name.isEmpty || email.isEmpty || pass.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Fill all details to begin.')),
                );
                return;
              }

              if (!email.toLowerCase().endsWith('@gmail.com')) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Only @gmail.com is allowed.')),
                );
                return;
              }

              final ok = await ref.read(userProvider.notifier).register(email, pass, name);
              
              if (!context.mounted) return;
              
              if (ok) {
                Navigator.pop(context); // Close dialog
                _login(); // Auto-login
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Journey failed to start. Spiritual ID may already exist.'),
                    backgroundColor: Colors.redAccent,
                  ),
                );
              }
            },
            child: const Text('BEGIN'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Stack(
        children: [
          // Background Glow and Sacred Accents
          Positioned(
            top: -150,
            left: -150,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryColor.withOpacity(0.08),
              ),
            ),
          ),
          
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: Column(
                  children: [
                    const SizedBox(height: 80),
                    
                    // Rotating Om Symbol
                    FadeInDown(
                      child: Container(
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.cardColor,
                          border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3), width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryColor.withOpacity(0.15),
                              blurRadius: 30,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Text(
                          'ॐ',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 72,
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // App Name
                    FadeInDown(
                      delay: const Duration(milliseconds: 200),
                      child: Text(
                        'Soul Guide',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    
                    FadeInDown(
                      delay: const Duration(milliseconds: 400),
                      child: Text(
                        'भगवद्गीता : विचारों का दर्पण',
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          color: AppTheme.primaryColor,
                          letterSpacing: 2,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 80),
                    
                    // Form Card
                    FadeInUp(
                      delay: const Duration(milliseconds: 600),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
                        decoration: AppTheme.glassDecoration,
                        child: Column(
                          children: [
                            TextField(
                              controller: _emailController,
                              style: GoogleFonts.outfit(color: AppTheme.textPrimary),
                              decoration: InputDecoration(
                                labelText: 'Spiritual ID',
                                labelStyle: GoogleFonts.outfit(color: AppTheme.textSecondary, fontSize: 13),
                                prefixIcon: const Icon(Icons.person_outline_rounded, color: AppTheme.primaryColor, size: 20),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: AppTheme.primaryColor.withOpacity(0.2)),
                                ),
                                focusedBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),
                            TextField(
                              controller: _passwordController,
                              obscureText: true,
                              style: GoogleFonts.outfit(color: AppTheme.textPrimary),
                              decoration: InputDecoration(
                                labelText: 'Divine Key',
                                labelStyle: GoogleFonts.outfit(color: AppTheme.textSecondary, fontSize: 13),
                                prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppTheme.primaryColor, size: 20),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: AppTheme.primaryColor.withOpacity(0.2)),
                                ),
                                focusedBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
                                ),
                              ),
                            ),
                            const SizedBox(height: 60),
                            
                            // High-end Button
                            GestureDetector(
                              onTap: _login,
                              child: Container(
                                height: 60,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [AppTheme.primaryColor, AppTheme.accentColor],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.primaryColor.withOpacity(0.4),
                                      blurRadius: 15,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: _isLoading ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : Text(
                                    'BEGIN JOURNEY',
                                    style: GoogleFonts.outfit(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 48),
                    
                    FadeInUp(
                      delay: const Duration(milliseconds: 800),
                      child: TextButton(
                        onPressed: _showRegisterDialog,
                        child: Text(
                          'SEEK NEW PATH',
                          style: GoogleFonts.outfit(
                            color: AppTheme.primaryColor.withOpacity(0.8), 
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
