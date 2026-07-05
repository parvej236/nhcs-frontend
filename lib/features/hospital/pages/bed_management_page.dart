import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/language_provider.dart';
import '../data/models/bed_allocation.dart';
import '../presentation/providers/hospital_providers.dart';

class BedManagementPage extends ConsumerStatefulWidget {
  const BedManagementPage({super.key});

  @override
  ConsumerState<BedManagementPage> createState() => _BedManagementPageState();
}

class _BedManagementPageState extends ConsumerState<BedManagementPage> {
  String _selectedWard = 'General Ward (Male)';

  void _admitPatient(String bedId, String patientName, String healthId, String doctor) {
    final tr = ref.read(translationsProvider);
    ref.read(bedCapacityProvider.notifier).admitPatient(bedId, patientName, healthId, doctor);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${tr('hospital_bed_patient')} $patientName ${tr('hospital_bed_admitted_success')}'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _dischargePatient(String bedId, String patientName, String bedNumber) {
    final tr = ref.read(translationsProvider);
    final diagCont = TextEditingController();
    final summaryCont = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('${tr('hospital_bed_discharge_patient')} ($patientName)', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: diagCont,
                decoration: InputDecoration(labelText: tr('hospital_bed_final_diagnosis'), hintText: 'e.g., Acute Myocardial Infarction'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: summaryCont,
                maxLines: 3,
                decoration: InputDecoration(labelText: tr('hospital_bed_discharge_summary'), hintText: tr('hospital_bed_discharge_summary_hint')),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text(tr('hospital_bed_cancel'))),
            ElevatedButton(
              onPressed: () {
                ref.read(bedCapacityProvider.notifier).dischargePatient(bedId);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${tr('hospital_bed_patient_discharged')} $bedNumber ${tr('hospital_bed_now_available')}'),
                    backgroundColor: AppColors.success,
                  ),
                );
              },
              child: Text(tr('hospital_bed_confirm_discharge')),
            ),
          ],
        );
      },
    );
  }

  void _showAdmitDialog(BedAllocation bed) {
    final tr = ref.read(translationsProvider);
    final nameCont = TextEditingController();
    final idCont = TextEditingController();
    String doctor = 'Dr. Ahmed Khan';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('${tr('hospital_bed_admit_to')} ${bed.number} (${bed.ward})', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: idCont,
                    decoration: InputDecoration(labelText: tr('hospital_bed_digital_health_id'), hintText: 'NUD-892-441-X7'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameCont,
                    decoration: InputDecoration(labelText: tr('hospital_bed_patient_name'), hintText: 'Rahim Islam'),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: doctor,
                    decoration: InputDecoration(labelText: tr('hospital_bed_attending_physician')),
                    onChanged: (val) => setDialogState(() => doctor = val!),
                    items: ['Dr. Ahmed Khan', 'Dr. Subrata Sen', 'Dr. Fatima', 'Trauma Lead']
                        .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                        .toList(),
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: Text(tr('hospital_bed_cancel'))),
                ElevatedButton(
                  onPressed: () {
                    if (nameCont.text.isNotEmpty && idCont.text.isNotEmpty) {
                      _admitPatient(bed.id, nameCont.text, idCont.text, doctor);
                      Navigator.pop(context);
                    }
                  },
                  child: Text(tr('hospital_bed_admit_patient')),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final tr = ref.watch(translationsProvider);
    final bedsList = ref.watch(bedCapacityProvider);
    final activeAdmissions = bedsList.where((b) => b.status == 'Occupied').toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left: Ward Matrix Grid Selector
          Expanded(
            flex: 3,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          tr('hospital_bed_capacity_management'),
                          style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
                        tooltip: tr('hospital_bed_reload'),
                        onPressed: () {
                          ref.invalidate(bedCapacityProvider);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(tr('hospital_bed_reloaded')), duration: const Duration(seconds: 1)),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    tr('hospital_bed_subtitle'),
                    style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13),
                  ),
                  const SizedBox(height: 24),
                  _buildWardTabs(),
                  const SizedBox(height: 24),
                  _buildBedMatrix(),
                ],
              ),
            ),
          ),
          // Vertical divider
          Container(width: 1, color: AppColors.divider),
          // Right: Active Admissions Panel
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tr('hospital_bed_active_admissions'),
                    style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  activeAdmissions.isEmpty
                      ? Center(child: Text(tr('hospital_bed_no_patients'), style: GoogleFonts.inter(color: AppColors.textSecondary)))
                      : ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: activeAdmissions.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final admission = activeAdmissions[index];
                            return _buildAdmissionCard(admission);
                          },
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _wardLabel(String ward) {
    final tr = ref.watch(translationsProvider);
    switch (ward) {
      case 'General Ward (Male)':
        return tr('hospital_bed_ward_general_male');
      case 'General Ward (Female)':
        return tr('hospital_bed_ward_general_female');
      case 'ICU':
        return tr('hospital_bed_ward_icu');
      default:
        return ward;
    }
  }

  Widget _buildWardTabs() {
    final wards = ['General Ward (Male)', 'General Ward (Female)', 'ICU'];
    return Row(
      children: wards.map((w) {
        final isSelected = _selectedWard == w;
        return Padding(
          padding: const EdgeInsets.only(right: 12),
          child: ChoiceChip(
            label: Text(_wardLabel(w)),
            selected: isSelected,
            onSelected: (val) {
              if (val) {
                setState(() => _selectedWard = w);
              }
            },
            selectedColor: AppColors.primary,
            labelStyle: TextStyle(color: isSelected ? Colors.white : AppColors.textSecondary),
            backgroundColor: AppColors.surface,
          ),
        );
      }).toList(),
    );
  }

  String _statusLabel(String status) {
    final tr = ref.watch(translationsProvider);
    switch (status) {
      case 'Occupied':
        return tr('hospital_bed_status_occupied');
      case 'Maintenance':
        return tr('hospital_bed_status_maintenance');
      case 'Available':
        return tr('hospital_bed_status_available');
      default:
        return status;
    }
  }

  Widget _buildBedMatrix() {
    final tr = ref.watch(translationsProvider);
    final bedsList = ref.watch(bedCapacityProvider);
    final filteredBeds = bedsList.where((b) => b.ward == _selectedWard).toList();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: filteredBeds.length,
      itemBuilder: (context, index) {
        final bed = filteredBeds[index];
        final status = bed.status;
        Color statusColor = AppColors.success;
        Color bg = AppColors.successLight;
        IconData icon = Icons.check_circle_outline_rounded;

        if (status == 'Occupied') {
          statusColor = AppColors.danger;
          bg = AppColors.dangerLight;
          icon = Icons.hotel_rounded;
        } else if (status == 'Maintenance') {
          statusColor = AppColors.textMuted;
          bg = AppColors.divider;
          icon = Icons.handyman_rounded;
        }

        return InkWell(
          onTap: () {
            if (status == 'Available') {
              _showAdmitDialog(bed);
            } else if (status == 'Occupied') {
              _dischargePatient(bed.id, bed.patient ?? 'Unknown', bed.number);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(tr('hospital_bed_maintenance_snack'))),
              );
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: bg.withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: statusColor.withOpacity(0.3), width: 1.5),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: statusColor, size: 28),
                const SizedBox(height: 8),
                Text(
                  bed.number,
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 2),
                Text(
                  status == 'Occupied' ? (bed.patient ?? _statusLabel('Occupied')) : _statusLabel(status),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAdmissionCard(BedAllocation bed) {
    final tr = ref.watch(translationsProvider);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                bed.number,
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
              Text(
                '${bed.days ?? 0} ${tr('hospital_bed_days_admitted')}',
                style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            bed.patient ?? tr('hospital_bed_unknown_patient'),
            style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          Text(
            '${tr('hospital_bed_health_id')}: ${bed.healthId ?? tr('hospital_bed_na')}',
            style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
          ),
          Text(
            '${tr('hospital_bed_doctor')}: ${bed.doctor ?? tr('hospital_bed_unassigned')}',
            style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton(
              onPressed: () => _dischargePatient(bed.id, bed.patient ?? 'Unknown', bed.number),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.danger,
                side: const BorderSide(color: AppColors.danger),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(tr('hospital_bed_discharge_workflow')),
            ),
          ),
        ],
      ),
    );
  }
}
