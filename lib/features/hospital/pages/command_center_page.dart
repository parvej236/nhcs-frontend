import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

class CommandCenterPage extends StatefulWidget {
  const CommandCenterPage({super.key});

  @override
  State<CommandCenterPage> createState() => _CommandCenterPageState();
}

class _CommandCenterPageState extends State<CommandCenterPage> {
  bool _isRefreshing = false;
  DateTime _lastUpdated = DateTime.now();

  void _simulateRefresh() {
    setState(() {
      _isRefreshing = true;
    });
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
          _lastUpdated = DateTime.now();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Main stats & lists
                Expanded(
                  flex: 3,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStatsGrid(),
                        const SizedBox(height: 24),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 2,
                              child: _buildDepartmentLoadList(),
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              flex: 3,
                              child: _buildLoadChartCard(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                // Sidebar Alerts
                Expanded(
                  flex: 1,
                  child: _buildAlertsPanel(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.divider.withOpacity(0.5))),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dhaka Central Hospital',
                style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Connected to National Ecosystem • Live Feed',
                    style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          Text(
            'Last Sync: ${_lastUpdated.hour.toString().padLeft(2, '0')}:${_lastUpdated.minute.toString().padLeft(2, '0')}:${_lastUpdated.second.toString().padLeft(2, '0')}',
            style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 13),
          ),
          const SizedBox(width: 16),
          IconButton(
            onPressed: _simulateRefresh,
            icon: _isRefreshing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                  )
                : const Icon(Icons.refresh_rounded, color: AppColors.primary),
            tooltip: 'Sync Live Data',
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final int crossAxisCount = width > 900 ? 4 : (width > 600 ? 2 : 1);
        
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.5,
          children: [
            _buildStatCard(
              title: 'Active Patients',
              value: '184',
              icon: Icons.people_rounded,
              color: AppColors.primary,
              trend: '+12% from yesterday',
              trendColor: AppColors.success,
            ),
            _buildStatCard(
              title: 'Bed Occupancy',
              value: '80.8%',
              subvalue: '202 / 250 Occupied',
              icon: Icons.bed_rounded,
              color: AppColors.secondary,
              trend: '48 beds available',
              trendColor: AppColors.textSecondary,
            ),
            _buildStatCard(
              title: 'On-Duty Staff',
              value: '24',
              subvalue: '10 Doctors, 14 Nurses',
              icon: Icons.badge_rounded,
              color: AppColors.accent,
              trend: 'All shifts covered',
              trendColor: AppColors.success,
            ),
            _buildStatCard(
              title: 'Emergency Intake',
              value: '5',
              subvalue: '3 Critical Cases',
              icon: Icons.emergency_rounded,
              color: AppColors.danger,
              trend: 'Critical Load Warning',
              trendColor: AppColors.danger,
              pulse: true,
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    String? subvalue,
    required IconData icon,
    required Color color,
    required String trend,
    required Color trendColor,
    bool pulse = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          if (subvalue != null) ...[
            const SizedBox(height: 2),
            Text(
              subvalue,
              style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 12),
            ),
          ],
          const Spacer(),
          Row(
            children: [
              if (pulse) ...[
                _buildPulseIndicator(),
                const SizedBox(width: 6),
              ],
              Text(
                trend,
                style: GoogleFonts.inter(fontSize: 11, color: trendColor, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPulseIndicator() {
    return Container(
      width: 8,
      height: 8,
      decoration: const BoxDecoration(
        color: AppColors.danger,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildDepartmentLoadList() {
    final List<Map<String, dynamic>> departments = [
      {'name': 'Emergency', 'patients': 28, 'staff': 5, 'load': 'Critical', 'color': AppColors.danger},
      {'name': 'Cardiology', 'patients': 15, 'staff': 3, 'load': 'High', 'color': AppColors.warning},
      {'name': 'ICU', 'patients': 14, 'staff': 4, 'load': 'Critical', 'color': AppColors.danger},
      {'name': 'General Ward', 'patients': 82, 'staff': 8, 'load': 'Normal', 'color': AppColors.success},
      {'name': 'Pediatrics', 'patients': 22, 'staff': 2, 'load': 'Normal', 'color': AppColors.success},
      {'name': 'Outpatient (OPD)', 'patients': 23, 'staff': 2, 'load': 'Normal', 'color': AppColors.success},
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Department Workload',
                style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                'Active Staffing',
                style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: departments.length,
            separatorBuilder: (context, index) => const Divider(height: 12),
            itemBuilder: (context, index) {
              final dept = departments[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            dept['name'],
                            style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${dept['patients']} patients • ${dept['staff']} staff active',
                            style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: (dept['color'] as Color).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        dept['load'],
                        style: GoogleFonts.inter(
                          color: dept['color'],
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLoadChartCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Patient Intake Volume (24 Hours)',
            style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Displays the hourly patient intake numbers, highlighting peak hours.',
            style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 240,
            child: CustomPaint(
              size: Size.infinite,
              painter: _LoadChartPainter(),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem('Emergency Admissions', AppColors.danger),
              const SizedBox(width: 24),
              _buildLegendItem('OPD Consultations', AppColors.primary),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildAlertsPanel() {
    final List<Map<String, dynamic>> alerts = [
      {
        'title': 'Critical Bed Capacity',
        'desc': 'ICU Occupancy is at 94% (15/16 beds occupied). Only 1 bed remaining.',
        'time': 'Just now',
        'type': 'danger',
      },
      {
        'title': 'Medicine Shortage',
        'desc': 'Paracetamol 500mg stock is below 1,000 tablets (reorder threshold).',
        'time': '10 mins ago',
        'type': 'warning',
      },
      {
        'title': 'Ambulance Out of Service',
        'desc': 'Ambulance #3 is currently offline for scheduled engine maintenance.',
        'time': '1 hour ago',
        'type': 'info',
      },
      {
        'title': 'Roster Discrepancy',
        'desc': 'Pediatrics shift gap identified for night duty on Wednesday.',
        'time': '2 hours ago',
        'type': 'warning',
      },
      {
        'title': 'Bio-Waste Collection',
        'desc': 'Environmental service has completed the weekly waste clearance.',
        'time': '4 hours ago',
        'type': 'success',
      },
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(left: BorderSide(color: AppColors.divider.withOpacity(0.5))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Icon(Icons.notifications_active_rounded, color: AppColors.danger.withOpacity(0.8), size: 22),
                const SizedBox(width: 10),
                Text(
                  'Operational Alerts',
                  style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              itemCount: alerts.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final alert = alerts[index];
                Color cardColor;
                Color textColor;
                IconData alertIcon;

                switch (alert['type']) {
                  case 'danger':
                    cardColor = AppColors.dangerLight;
                    textColor = AppColors.danger;
                    alertIcon = Icons.warning_amber_rounded;
                    break;
                  case 'warning':
                    cardColor = AppColors.warningLight;
                    textColor = AppColors.warning;
                    alertIcon = Icons.error_outline_rounded;
                    break;
                  case 'success':
                    cardColor = AppColors.successLight;
                    textColor = AppColors.success;
                    alertIcon = Icons.check_circle_outline_rounded;
                    break;
                  default:
                    cardColor = AppColors.infoLight;
                    textColor = AppColors.info;
                    alertIcon = Icons.info_outline_rounded;
                }

                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: textColor.withOpacity(0.15)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(alertIcon, color: textColor, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              alert['title'],
                              style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13, color: textColor),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        alert['desc'],
                        style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Text(
                          alert['time'],
                          style: GoogleFonts.inter(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double width = size.width;
    final double height = size.height;

    // Draw Grid Lines
    final Paint gridPaint = Paint()
      ..color = AppColors.divider.withOpacity(0.5)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final double stepY = height / 5;
    for (int i = 0; i <= 5; i++) {
      final double y = i * stepY;
      canvas.drawLine(Offset(0, y), Offset(width, y), gridPaint);
    }

    // Points representing hospital admissions load (24h)
    // Emergency line points (y values scaled from 0 to 1)
    final List<double> emergencyPoints = [0.2, 0.15, 0.1, 0.3, 0.6, 0.8, 0.9, 0.7, 0.5, 0.6, 0.4, 0.3];
    // OPD line points
    final List<double> opdPoints = [0.05, 0.05, 0.1, 0.4, 0.8, 0.95, 0.7, 0.6, 0.9, 0.5, 0.2, 0.1];

    _drawLine(canvas, size, emergencyPoints, AppColors.danger);
    _drawLine(canvas, size, opdPoints, AppColors.primary);
  }

  void _drawLine(Canvas canvas, Size size, List<double> points, Color color) {
    final double stepX = size.width / (points.length - 1);
    final Path path = Path();
    final Path areaPath = Path();

    final Paint linePaint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final Paint fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [color.withOpacity(0.25), color.withOpacity(0.0)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTRB(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    for (int i = 0; i < points.length; i++) {
      final double x = i * stepX;
      // Invert Y coordinate because canvas y goes down
      final double y = size.height - (points[i] * size.height * 0.8) - 10;

      if (i == 0) {
        path.moveTo(x, y);
        areaPath.moveTo(x, size.height);
        areaPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        areaPath.lineTo(x, y);
      }

      if (i == points.length - 1) {
        areaPath.lineTo(x, size.height);
        areaPath.close();
      }
    }

    canvas.drawPath(areaPath, fillPaint);
    canvas.drawPath(path, linePaint);

    // Draw little points at peak
    final Paint pointPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    for (int i = 0; i < points.length; i++) {
      if (points[i] > 0.8) {
        final double x = i * stepX;
        final double y = size.height - (points[i] * size.height * 0.8) - 10;
        canvas.drawCircle(Offset(x, y), 4, pointPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
