import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

class BedManagementPage extends StatefulWidget {
  const BedManagementPage({super.key});

  @override
  State<BedManagementPage> createState() => _BedManagementPageState();
}

class _BedManagementPageState extends State<BedManagementPage> {
  String _selectedWard = 'General Ward (Male)';

  // Mock beds database in state for simulation
  late List<Map<String, dynamic>> _beds;

  @override
  void initState() {
    super.initState();
    _beds = [
      {'id': 'B-101', 'ward': 'General Ward (Male)', 'number': 'Bed 101', 'status': 'Occupied', 'patient': 'Rahim Islam', 'healthId': 'NUD-892-441-X7', 'doctor': 'Dr. Ahmed Khan', 'days': 3},
      {'id': 'B-102', 'ward': 'General Ward (Male)', 'number': 'Bed 102', 'status': 'Available'},
      {'id': 'B-103', 'ward': 'General Ward (Male)', 'number': 'Bed 103', 'status': 'Available'},
      {'id': 'B-104', 'ward': 'General Ward (Male)', 'number': 'Bed 104', 'status': 'Maintenance'},
      {'id': 'B-105', 'ward': 'General Ward (Male)', 'number': 'Bed 105', 'status': 'Available'},
      {'id': 'B-106', 'ward': 'General Ward (Male)', 'number': 'Bed 106', 'status': 'Occupied', 'patient': 'Kamal Hossain', 'healthId': 'NUD-987-654-B2', 'doctor': 'Dr. Fatima', 'days': 1},
      
      {'id': 'B-201', 'ward': 'General Ward (Female)', 'number': 'Bed 201', 'status': 'Occupied', 'patient': 'Jahanara Begum', 'healthId': 'NUD-123-456-A1', 'doctor': 'Dr. Fatima', 'days': 2},
      {'id': 'B-202', 'ward': 'General Ward (Female)', 'number': 'Bed 202', 'status': 'Available'},
      {'id': 'B-203', 'ward': 'General Ward (Female)', 'number': 'Bed 203', 'status': 'Available'},
      {'id': 'B-204', 'ward': 'General Ward (Female)', 'number': 'Bed 204', 'status': 'Available'},
      
      {'id': 'B-301', 'ward': 'ICU', 'number': 'Bed 301', 'status': 'Occupied', 'patient': 'Hasan Ali', 'healthId': 'NUD-444-555-C3', 'doctor': 'Trauma Lead', 'days': 5},
      {'id': 'B-302', 'ward': 'ICU', 'number': 'Bed 302', 'status': 'Available'},
    ];
  }

  void _admitPatient(String bedId, String patientName, String healthId, String doctor) {
    final idx = _beds.indexWhere((b) => b['id'] == bedId);
    if (idx != -1) {
      setState(() {
        _beds[idx]['status'] = 'Occupied';
        _beds[idx]['patient'] = patientName;
        _beds[idx]['healthId'] = healthId;
        _beds[idx]['doctor'] = doctor;
        _beds[idx]['days'] = 0;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Patient $patientName admitted to ${_beds[idx]['number']} successfully.'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  void _dischargePatient(String bedId) {
    final idx = _beds.indexWhere((b) => b['id'] == bedId);
    if (idx != -1) {
      final bed = _beds[idx];
      showDialog(
        context: context,
        builder: (context) {
          final diagCont = TextEditingController();
          final summaryCont = TextEditingController();
          return AlertDialog(
            title: Text('Discharge Patient (${bed['patient']})', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: diagCont,
                  decoration: const InputDecoration(labelText: 'Final Diagnosis', hintText: 'e.g., Acute Myocardial Infarction'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: summaryCont,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Discharge Summary Notes', hintText: 'Patient is stable. Prescribed meds...'),
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _beds[idx]['status'] = 'Available';
                    _beds[idx].remove('patient');
                    _beds[idx].remove('healthId');
                    _beds[idx].remove('doctor');
                    _beds[idx].remove('days');
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Patient discharged. ${bed['number']} is now available.'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                },
                child: const Text('Confirm Discharge'),
              ),
            ],
          );
        },
      );
    }
  }

  void _showAdmitDialog(String bedId) {
    final idx = _beds.indexWhere((b) => b['id'] == bedId);
    if (idx == -1) return;
    final bed = _beds[idx];

    final nameCont = TextEditingController();
    final idCont = TextEditingController();
    String doctor = 'Dr. Ahmed Khan';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Admit to ${bed['number']} (${bed['ward']})', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: idCont,
                    decoration: const InputDecoration(labelText: 'Digital Health ID', hintText: 'NUD-892-441-X7'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameCont,
                    decoration: const InputDecoration(labelText: 'Patient Name', hintText: 'Rahim Islam'),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: doctor,
                    decoration: const InputDecoration(labelText: 'Attending Physician'),
                    onChanged: (val) => setDialogState(() => doctor = val!),
                    items: ['Dr. Ahmed Khan', 'Dr. Subrata Sen', 'Dr. Fatima', 'Trauma Lead']
                        .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                        .toList(),
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                ElevatedButton(
                  onPressed: () {
                    if (nameCont.text.isNotEmpty && idCont.text.isNotEmpty) {
                      _admitPatient(bedId, nameCont.text, idCont.text, doctor);
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Admit Patient'),
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
    final activeAdmissions = _beds.where((b) => b['status'] == 'Occupied').toList();

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
                  Text(
                    'Bed Capacity Management',
                    style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Click on any bed slot to admit a patient or manage occupancy.',
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
                    'Active Admissions',
                    style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  activeAdmissions.isEmpty
                      ? Center(child: Text('No patients currently admitted.', style: GoogleFonts.inter(color: AppColors.textSecondary)))
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

  Widget _buildWardTabs() {
    final wards = ['General Ward (Male)', 'General Ward (Female)', 'ICU'];
    return Row(
      children: wards.map((w) {
        final isSelected = _selectedWard == w;
        return Padding(
          padding: const EdgeInsets.only(right: 12),
          child: ChoiceChip(
            label: Text(w),
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

  Widget _buildBedMatrix() {
    final filteredBeds = _beds.where((b) => b['ward'] == _selectedWard).toList();

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
        final status = bed['status'];
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
              _showAdmitDialog(bed['id']);
            } else if (status == 'Occupied') {
              _dischargePatient(bed['id']);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Bed is currently undergoing sanitary maintenance.')),
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
                  bed['number'],
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 2),
                Text(
                  status == 'Occupied' ? bed['patient'] : status,
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

  Widget _buildAdmissionCard(Map<String, dynamic> bed) {
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
                bed['number'],
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
              Text(
                '${bed['days']} days admitted',
                style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            bed['patient'],
            style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          Text(
            'Health ID: ${bed['healthId']}',
            style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
          ),
          Text(
            'Doctor: ${bed['doctor']}',
            style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton(
              onPressed: () => _dischargePatient(bed['id']),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.danger,
                side: const BorderSide(color: AppColors.danger),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Discharge Workflow'),
            ),
          ),
        ],
      ),
    );
  }
}
