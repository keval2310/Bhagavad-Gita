import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/app_theme.dart';
import '../emotion_engine/multi_stage_analysis_flow.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'My Wellness',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    'https://images.unsplash.com/photo-1544717305-2782549b5136?q=80&w=1000',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(color: AppTheme.surfaceColor),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          AppTheme.backgroundColor,
                          AppTheme.backgroundColor.withOpacity(0.5),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Streak Section
                FadeInDown(
                  child: Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryColor.withOpacity(0.3),
                          blurRadius: 25,
                          offset: const Offset(0, 10),
                        )
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.local_fire_department, color: Colors.white, size: 36),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '8 Day Streak!',
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Consistency is the key to Yoga.',
                                style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),

                // NEW: Mandatory Step moved to Home (Dharma)
                
                const SizedBox(height: 24),
                
                // Section Title: My Journey
                Text(
                  'Your Activity Log',
                  style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                ),
                const SizedBox(height: 16),
                
                const SizedBox(height: 16),
                _buildActivityItem('Holistic Analysis', 'Low Stress • Peace • 2m ago', Icons.psychology, AppTheme.primaryColor),
                _buildActivityItem('Journal Entry', 'Reflecting on Chapter 2 • 1h ago', Icons.edit_note, AppTheme.accentColor),
                _buildActivityItem('Voice Chanting', 'Sanskrit vibration analysis • 5h ago', Icons.mic, const Color(0xFF3498DB)),
                const SizedBox(height: 48),
                Text(
                  'Mood Trend',
                  style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                ),
                const SizedBox(height: 20),
                
                // Mood Chart
                FadeInUp(
                  child: Container(
                    height: 250,
                    padding: const EdgeInsets.all(24),
                    decoration: AppTheme.softCardDecoration,
                    child: LineChart(
                      LineChartData(
                        gridData: const FlGridData(show: false),
                        titlesData: const FlTitlesData(show: false),
                        borderData: FlBorderData(show: false),
                        minX: 0,
                        maxX: 6,
                        minY: 0,
                        maxY: 6,
                        lineBarsData: [
                          LineChartBarData(
                            spots: const [
                              FlSpot(0, 3),
                              FlSpot(1, 1),
                              FlSpot(2, 4),
                              FlSpot(3, 2),
                              FlSpot(4, 5),
                              FlSpot(5, 3),
                              FlSpot(6, 4),
                            ],
                            isCurved: true,
                            color: AppTheme.primaryColor,
                            barWidth: 4,
                            isStrokeCapRound: true,
                            dotData: FlDotData(
                              show: true,
                              getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                                radius: 4,
                                color: AppTheme.primaryColor,
                                strokeWidth: 2,
                                strokeColor: AppTheme.surfaceColor,
                              ),
                            ),
                            belowBarData: BarAreaData(
                              show: true,
                              gradient: LinearGradient(
                                colors: [
                                  AppTheme.primaryColor.withOpacity(0.2),
                                  AppTheme.primaryColor.withOpacity(0.0),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 48),
                Text(
                  'Frequent States',
                  style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                ),
                const SizedBox(height: 20),
                
                Row(
                  children: [
                    _StatTile(label: 'Peace', value: '45%', icon: Icons.sentiment_satisfied, color: const Color(0xFF2ECC71)),
                    const SizedBox(width: 16),
                    _StatTile(label: 'Stress', value: '30%', icon: Icons.sentiment_dissatisfied, color: AppTheme.accentColor),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _StatTile(label: 'Sacred Verses', value: '700+', icon: Icons.auto_stories, color: const Color(0xFFF1C40F)), // Kaggle data count
                    const SizedBox(width: 16),
                    _StatTile(label: 'Adhyays', value: '18', icon: Icons.account_balance, color: const Color(0xFF3498DB)),
                  ],
                ),
                const SizedBox(height: 48),
                
                // Daily Motivation
                FadeInUp(
                  child: Container(
                    padding: const EdgeInsets.all(28),
                    decoration: AppTheme.glassDecoration,
                    child: Column(
                      children: [
                        Icon(Icons.format_quote_rounded, color: AppTheme.primaryColor.withOpacity(0.5), size: 32),
                        const SizedBox(height: 16),
                        Text(
                          '\"The mind is restless and difficult to restrain, but it is subdued by practice.\"',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                            height: 1.6,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text('- Krishna (Gita 6.35)', style: GoogleFonts.outfit(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 80),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(String title, String subtitle, IconData icon, Color color) {
    return FadeInUp(
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: AppTheme.softCardDecoration,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppTheme.textPrimary, fontSize: 15)),
                   Text(subtitle, style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textSecondary)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppTheme.textSecondary, size: 16),
          ],
        ),
      ),
    );
  }
}


class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatTile({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: AppTheme.softCardDecoration,
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 16),
            Text(value, style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.textPrimary)),
            Text(label, style: GoogleFonts.outfit(color: AppTheme.textSecondary, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
