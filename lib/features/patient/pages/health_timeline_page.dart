import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/language_provider.dart';
import '../data/models/health_event.dart';
import '../presentation/providers/patient_providers.dart';

class HealthTimelinePage extends ConsumerStatefulWidget {
  const HealthTimelinePage({super.key});

  @override
  ConsumerState<HealthTimelinePage> createState() => _HealthTimelinePageState();
}

class _HealthTimelinePageState extends ConsumerState<HealthTimelinePage> {
  String _activeFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final timelineState = ref.watch(patientTimelineProvider);
    final t = AppColors.of(context);
    final tr = ref.watch(translationsProvider);

    return Scaffold(
      backgroundColor: t.bgMain,
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: t.bgCard,
              border: Border(bottom: BorderSide(color: t.border)),
            ),
            child: Row(
              children: [
                Text(
                  tr('patient_health_timeline'),
                  style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: t.textPrimary),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(Icons.refresh_rounded, color: t.brandPrimary),
                  tooltip: tr('patient_reload'),
                  onPressed: () {
                    ref.invalidate(patientTimelineProvider);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(tr('patient_reloaded')), duration: const Duration(seconds: 1)),
                    );
                  },
                ),
                const SizedBox(width: 12),
                _filterChip(context, 'All'),
                const SizedBox(width: 8),
                _filterChip(context, 'Consultations'),
                const SizedBox(width: 8),
                _filterChip(context, 'Lab Tests'),
                const SizedBox(width: 8),
                _filterChip(context, 'Imaging'),
              ],
            ),
          ),
          Expanded(
            child: timelineState.when(
              loading: () => Center(child: CircularProgressIndicator(color: t.brandPrimary)),
              error: (err, stack) => Center(
                child: Text('${tr('patient_err_loading_timeline')}: $err', style: TextStyle(color: t.textSecondary)),
              ),
              data: (events) {
                // Apply Filter
                final filtered = events.where((e) {
                  if (_activeFilter == 'All') return true;
                  if (_activeFilter == 'Consultations') return e.type == HealthEventType.consultation;
                  if (_activeFilter == 'Lab Tests') return e.type == HealthEventType.labTest;
                  if (_activeFilter == 'Imaging') return e.type == HealthEventType.imaging;
                  return true;
                }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.history_toggle_off_rounded, size: 48, color: t.textSecondary.withValues(alpha: 0.5)),
                        const SizedBox(height: 16),
                        Text(
                          tr('patient_no_matching_events'),
                          style: GoogleFonts.inter(color: t.textSecondary),
                        ),
                      ],
                    ),
                  );
                }

                // Group by year
                final Map<String, List<HealthEvent>> grouped = {};
                for (var event in filtered) {
                  final year = event.date.year.toString();
                  grouped.putIfAbsent(year, () => []).add(event);
                }

                final sortedYears = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

                return ListView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: sortedYears.length,
                  itemBuilder: (context, index) {
                    final year = sortedYears[index];
                    final yearEvents = grouped[year]!;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _yearLabel(context, year),
                        ...yearEvents.asMap().entries.map((entry) {
                          final eventIndex = entry.key;
                          final event = entry.value;
                          final isFirst = eventIndex == 0;
                          final isLast = eventIndex == yearEvents.length - 1;

                          return _buildTimelineItem(context, event, isFirst: isFirst, isLast: isLast);
                        }),
                        const SizedBox(height: 16),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(BuildContext context, String label) {
    final t = AppColors.of(context);
    final tr = ref.watch(translationsProvider);
    final selected = _activeFilter == label;
    const labelKeys = {
      'All': 'patient_filter_all',
      'Consultations': 'patient_filter_consultations',
      'Lab Tests': 'patient_filter_lab_tests',
      'Imaging': 'patient_filter_imaging',
    };
    return InkWell(
      onTap: () {
        setState(() {
          _activeFilter = label;
        });
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? t.brandPrimary : t.bgInput,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? t.brandPrimary : t.border),
        ),
        child: Text(
          tr(labelKeys[label] ?? label),
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: selected ? Colors.white : t.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _yearLabel(BuildContext context, String year) {
    final t = AppColors.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: t.brandPrimary.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          year,
          style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: t.brandPrimary),
        ),
      ),
    );
  }

  Widget _buildTimelineItem(BuildContext context, HealthEvent event, {required bool isFirst, required bool isLast}) {
    final t = AppColors.of(context);
    final iconData = _getEventIcon(event.type);
    final themeColor = _getEventColor(context, event.type);
    final dateStr = "${event.date.day} ${_getMonthName(event.date.month)} ${event.date.year}";

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline line + dot
          SizedBox(
            width: 40,
            child: Column(
              children: [
                if (!isFirst) Container(width: 2, height: 12, color: t.border),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: themeColor.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: themeColor, width: 2),
                  ),
                  child: Icon(iconData, size: 14, color: themeColor),
                ),
                if (!isLast) Expanded(child: Container(width: 2, color: t.border)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Content card
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: t.bgCard,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: t.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          event.title,
                          style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15, color: t.textPrimary),
                        ),
                      ),
                      Text(dateStr, style: GoogleFonts.inter(color: t.textSecondary, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    event.description,
                    style: GoogleFonts.inter(color: t.textSecondary, fontSize: 13, height: 1.5),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 13, color: t.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        '${event.doctorName} • ${event.hospitalName}',
                        style: GoogleFonts.inter(color: t.textSecondary.withValues(alpha: 0.7), fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getEventIcon(HealthEventType type) {
    switch (type) {
      case HealthEventType.consultation:
        return Icons.medical_services_rounded;
      case HealthEventType.labTest:
        return Icons.science_rounded;
      case HealthEventType.imaging:
        return Icons.description_outlined;
      case HealthEventType.surgery:
        return Icons.local_hospital_rounded;
      case HealthEventType.admission:
        return Icons.meeting_room_rounded;
      case HealthEventType.discharge:
        return Icons.logout_rounded;
      case HealthEventType.vaccination:
        return Icons.vaccines_rounded;
      case HealthEventType.prescription:
        return Icons.medication_rounded;
      case HealthEventType.followUp:
        return Icons.event_note_rounded;
      case HealthEventType.emergency:
        return Icons.flash_on_rounded;
    }
  }

  Color _getEventColor(BuildContext context, HealthEventType type) {
    final t = AppColors.of(context);
    switch (type) {
      case HealthEventType.consultation:
        return t.brandPrimary;
      case HealthEventType.labTest:
        return t.brandSecondary;
      case HealthEventType.imaging:
        return t.warning;
      case HealthEventType.surgery:
        return t.danger;
      case HealthEventType.admission:
        return const Color(0xFF8B5CF6); // purple
      case HealthEventType.discharge:
        return const Color(0xFF3B82F6); // blue
      case HealthEventType.vaccination:
        return t.success;
      case HealthEventType.prescription:
        return t.success;
      case HealthEventType.followUp:
        return t.warning;
      case HealthEventType.emergency:
        return t.danger;
    }
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    if (month >= 1 && month <= 12) {
      return months[month - 1];
    }
    return '';
  }
}
