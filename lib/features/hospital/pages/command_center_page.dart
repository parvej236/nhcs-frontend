import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uhcs/features/patient/data/models/appointment.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/ai_insight_panel.dart';
import '../../../core/widgets/notification_dropdown.dart';
import '../../../core/providers/notifications_provider.dart';
import '../presentation/providers/hospital_providers.dart';

class CommandCenterPage extends ConsumerStatefulWidget {
  const CommandCenterPage({super.key});

  @override
  ConsumerState<CommandCenterPage> createState() => _CommandCenterPageState();
}

class _CommandCenterPageState extends ConsumerState<CommandCenterPage> {
  bool _isRefreshing = false;
  DateTime _lastUpdated = DateTime.now();
  int _activeSubTab = 0;

  void _simulateRefresh() {
    setState(() {
      _isRefreshing = true;
    });
    ref.read(hospitalDashboardStatsProvider.notifier).refresh();
    ref.read(pendingAppointmentsProvider.notifier).loadPending();
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
    final notifications = ref.watch(hospitalNotificationsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildHeader(notifications),
          _buildSubTabBar(),
          Expanded(
            child: _activeSubTab == 0
                ? _buildDashboardContent()
                : _buildApprovalsContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildSubTabBar() {
    final t = AppColors.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        color: t.bgCard,
        border: Border(bottom: BorderSide(color: t.border)),
      ),
      child: Row(
        children: [
          _buildTabButton(0, 'Operations Overview', Icons.dashboard_rounded),
          const SizedBox(width: 16),
          _buildTabButton(1, 'Appointment Approvals', Icons.fact_check_rounded),
        ],
      ),
    );
  }

  Widget _buildTabButton(int index, String title, IconData icon) {
    final t = AppColors.of(context);
    final isSelected = _activeSubTab == index;
    return InkWell(
      onTap: () => setState(() => _activeSubTab = index),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? t.brandPrimary.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? t.brandPrimary : t.textSecondary, size: 18),
            const SizedBox(width: 8),
            Text(
              title,
              style: GoogleFonts.inter(
                color: isSelected ? t.brandPrimary : t.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardContent() {
    return Row(
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
                const AiInsightPanel(
                  title: 'ICU & Workforce Optimization Forecast',
                  description: 'AI model predicts a 15% increase in emergency intake over the next 6 hours due to local holiday traffic. ICU capacity is currently at critical levels.',
                  type: 'warning',
                  recommendations: [
                    'Pre-emptively route non-emergency triage to OPD wings.',
                    'Onboard call-shift nurses for the 8 PM - 2 AM block.',
                    'Coordinate with Dhaka South general ward for tertiary back-up beds.'
                  ],
                ),
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
    );
  }

  Widget _buildApprovalsContent() {
    final pendingState = ref.watch(pendingAppointmentsProvider);
    final t = AppColors.of(context);

    return pendingState.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
      error: (err, stack) => Center(
        child: Text(
          'Error loading pending appointments: $err',
          style: GoogleFonts.inter(color: t.danger),
        ),
      ),
      data: (appointments) {
        if (appointments.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.done_all_rounded, size: 64, color: t.success.withValues(alpha: 0.6)),
                const SizedBox(height: 16),
                Text(
                  'All caught up!',
                  style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: t.textPrimary),
                ),
                const SizedBox(height: 8),
                Text(
                  'No pending appointment requests need verification.',
                  style: GoogleFonts.inter(color: t.textSecondary, fontSize: 14),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Appointment Verification Queue',
                style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: t.textPrimary),
              ),
              const SizedBox(height: 8),
              Text(
                'Verify citizen details and doctor schedule compatibility before approving medical bookings.',
                style: GoogleFonts.inter(color: t.textSecondary, fontSize: 14),
              ),
              const SizedBox(height: 24),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 450,
                  mainAxisExtent: 220,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: appointments.length,
                itemBuilder: (context, index) {
                  final app = appointments[index];
                  return _buildApprovalCard(app);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildApprovalCard(Appointment app) {
    final t = AppColors.of(context);
    final patientIdStr = 'NUD-000-${app.id.hashCode.abs() % 100}'; // Clean Health ID mapping
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: t.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: t.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: t.brandPrimary.withValues(alpha: 0.1),
                child: Icon(Icons.person_rounded, color: t.brandPrimary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rahim Islam', // We know the seeded patient name is Rahim Islam
                      style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 15, color: t.textPrimary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Health ID: $patientIdStr',
                      style: GoogleFonts.inter(color: t.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: t.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'PENDING',
                  style: GoogleFonts.inter(color: t.warning, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.medical_services_outlined, size: 16, color: t.textSecondary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${app.doctor.name} (${app.doctor.specialization})',
                  style: GoogleFonts.inter(fontSize: 13, color: t.textPrimary, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.calendar_today_outlined, size: 16, color: t.textSecondary),
              const SizedBox(width: 8),
              Text(
                '${app.date.year}-${app.date.month.toString().padLeft(2, '0')}-${app.date.day.toString().padLeft(2, '0')} • ${app.timeSlot}',
                style: GoogleFonts.inter(fontSize: 13, color: t.textPrimary),
              ),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () async {
                    final success = await ref.read(pendingAppointmentsProvider.notifier).rejectAppointment(app.id);
                    if (success && mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Appointment ${app.id} rejected.'), backgroundColor: t.danger),
                      );
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: t.danger,
                    side: BorderSide(color: t.danger.withValues(alpha: 0.3)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text('Reject', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    final success = await ref.read(pendingAppointmentsProvider.notifier).approveAppointment(app.id);
                    if (success && mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Appointment ${app.id} approved!'), backgroundColor: t.success),
                      );
                      // Trigger stats reload
                      ref.read(hospitalDashboardStatsProvider.notifier).refresh();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: t.brandPrimary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 0,
                  ),
                  child: Text('Verify & Approve', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(List<AppNotification> notifications) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.divider.withValues(alpha: 0.5))),
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
          const SizedBox(width: 16),
          NotificationDropdown(
            notifications: notifications,
            onMarkRead: (id) => ref.read(hospitalNotificationsProvider.notifier).markAsRead(id),
            onMarkAllRead: () => ref.read(hospitalNotificationsProvider.notifier).markAllAsRead(),
            onNavigate: (tabIndex) {
              ref.read(hospitalNavigationProvider.notifier).state = tabIndex;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    final stats = ref.watch(hospitalDashboardStatsProvider);

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
              value: stats.activePatients.toString(),
              icon: Icons.people_rounded,
              color: AppColors.primary,
              trend: '+12% from yesterday',
              trendColor: AppColors.success,
            ),
            _buildStatCard(
              title: 'Bed Occupancy',
              value: '${stats.bedOccupancyRate}%',
              subvalue: '${stats.occupiedBeds} / ${stats.totalBeds} Occupied',
              icon: Icons.bed_rounded,
              color: AppColors.secondary,
              trend: '${stats.totalBeds - stats.occupiedBeds} beds available',
              trendColor: AppColors.textSecondary,
            ),
            _buildStatCard(
              title: 'On-Duty Staff',
              value: stats.onDutyStaff.toString(),
              subvalue: '${stats.onDutyDoctors} Doctors • ${stats.onDutyNurses} Nurses',
              icon: Icons.badge_rounded,
              color: const Color(0xFF10B981),
              trend: 'All shifts covered',
              trendColor: AppColors.success,
            ),
            _buildStatCard(
              title: 'Emergency Intake',
              value: stats.emergencyIntake.toString(),
              subvalue: '${stats.criticalCases} Critical Cases',
              icon: Icons.emergency_rounded,
              color: AppColors.danger,
              trend: 'Response time: 4m',
              trendColor: AppColors.success,
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
  }) {
    final t = AppColors.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: t.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: t.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(color: t.textSecondary, fontSize: 14, fontWeight: FontWeight.w500),
              ),
              Icon(icon, color: color, size: 24),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold, color: t.textPrimary),
          ),
          if (subvalue != null) ...[
            const SizedBox(height: 4),
            Text(
              subvalue,
              style: GoogleFonts.inter(color: t.textSecondary, fontSize: 12),
            ),
          ],
          const Spacer(),
          Row(
            children: [
              Icon(Icons.trending_up_rounded, color: trendColor, size: 16),
              const SizedBox(width: 4),
              Text(
                trend,
                style: GoogleFonts.inter(color: trendColor, fontSize: 11, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDepartmentLoadList() {
    final stats = ref.watch(hospitalDashboardStatsProvider);
    final t = AppColors.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: t.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: t.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Department Triage Load',
            style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: t.textPrimary),
          ),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: stats.departmentLoads.length,
            separatorBuilder: (context, index) => const Divider(height: 16),
            itemBuilder: (context, index) {
              final dept = stats.departmentLoads[index];
              Color loadColor;
              switch (dept.load) {
                case 'Critical':
                  loadColor = t.danger;
                  break;
                case 'High':
                  loadColor = t.warning;
                  break;
                default:
                  loadColor = t.success;
              }

              return Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dept.name,
                          style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14, color: t.textPrimary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${dept.patients} patients • ${dept.staff} staff on duty',
                          style: GoogleFonts.inter(color: t.textSecondary, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: loadColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      dept.load,
                      style: GoogleFonts.inter(color: loadColor, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLoadChartCard() {
    final t = AppColors.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: t.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: t.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Patient Intake Volume (24 Hours)',
            style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: t.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            'Displays the hourly patient intake numbers, highlighting peak hours.',
            style: GoogleFonts.inter(color: t.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 240,
            child: CustomPaint(
              size: Size.infinite,
              painter: _LoadChartPainter(
                line1Color: t.danger,
                line2Color: t.brandPrimary,
                gridColor: t.border,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem('Emergency Admissions', t.danger),
              const SizedBox(width: 24),
              _buildLegendItem('OPD Consultations', t.brandPrimary),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    final t = AppColors.of(context);
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
          style: GoogleFonts.inter(fontSize: 12, color: t.textSecondary, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildAlertsPanel() {
    final stats = ref.watch(hospitalDashboardStatsProvider);
    final t = AppColors.of(context);

    return Container(
      decoration: BoxDecoration(
        color: t.bgCard,
        border: Border(left: BorderSide(color: t.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Icon(Icons.notifications_active_rounded, color: t.danger.withValues(alpha: 0.8), size: 22),
                const SizedBox(width: 10),
                Text(
                  'Operational Alerts',
                  style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: t.textPrimary),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              itemCount: stats.alerts.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final alert = stats.alerts[index];
                Color cardColor;
                Color textColor;
                IconData alertIcon;

                switch (alert.type) {
                  case 'danger':
                    cardColor = t.danger;
                    textColor = t.danger;
                    alertIcon = Icons.warning_amber_rounded;
                    break;
                  case 'warning':
                    cardColor = t.warning;
                    textColor = t.warning;
                    alertIcon = Icons.error_outline_rounded;
                    break;
                  default:
                    cardColor = t.brandSecondary;
                    textColor = t.brandSecondary;
                    alertIcon = Icons.info_outline_rounded;
                }

                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: textColor.withValues(alpha: 0.2)),
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
                              alert.title,
                              style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13, color: textColor),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        alert.description,
                        style: GoogleFonts.inter(fontSize: 12, color: t.textSecondary, height: 1.4),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Text(
                          alert.timeAgo,
                          style: GoogleFonts.inter(fontSize: 10, color: t.textSecondary, fontWeight: FontWeight.w500),
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
  final Color line1Color;
  final Color line2Color;
  final Color gridColor;

  _LoadChartPainter({
    required this.line1Color,
    required this.line2Color,
    required this.gridColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double width = size.width;
    final double height = size.height;

    // Draw Grid Lines
    final Paint gridPaint = Paint()
      ..color = gridColor.withValues(alpha: 0.5)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final double stepY = height / 5;
    for (int i = 0; i <= 5; i++) {
      final double y = i * stepY;
      canvas.drawLine(Offset(0, y), Offset(width, y), gridPaint);
    }

    final List<double> emergencyPoints = [0.2, 0.15, 0.1, 0.3, 0.6, 0.8, 0.9, 0.7, 0.5, 0.6, 0.4, 0.3];
    final List<double> opdPoints = [0.05, 0.05, 0.1, 0.4, 0.8, 0.95, 0.7, 0.6, 0.9, 0.5, 0.2, 0.1];

    _drawLine(canvas, size, emergencyPoints, line1Color);
    _drawLine(canvas, size, opdPoints, line2Color);
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

    final Paint areaPaint = Paint()
      ..color = color.withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < points.length; i++) {
      final double x = i * stepX;
      final double y = size.height * (1.0 - points[i]);

      if (i == 0) {
        path.moveTo(x, y);
        areaPath.moveTo(x, size.height);
        areaPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        areaPath.lineTo(x, y);
      }
    }

    areaPath.lineTo(size.width, size.height);
    areaPath.close();

    canvas.drawPath(areaPath, areaPaint);
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
