import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../../core/app_theme.dart';
import '../home/main_navigation_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _login() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
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
                                  child: Text(
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
                        onPressed: () {},
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
