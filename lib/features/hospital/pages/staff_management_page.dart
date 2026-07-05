import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/language_provider.dart';
import '../data/models/staff_member.dart';
import '../presentation/providers/hospital_providers.dart';

class StaffManagementPage extends ConsumerStatefulWidget {
  const StaffManagementPage({super.key});

  @override
  ConsumerState<StaffManagementPage> createState() => _StaffManagementPageState();
}

class _StaffManagementPageState extends ConsumerState<StaffManagementPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _selectedRoleFilter = 'All';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _addStaffMember(String name, String role, String dept, String shift) {
    final tr = ref.read(translationsProvider);
    final staffList = ref.read(staffRosterProvider);
    final id = 'S-${(staffList.length + 1).toString().padLeft(3, '0')}';
    final newStaff = StaffMember(
      id: id,
      name: name,
      role: role,
      dept: dept,
      status: 'Active',
      shifts: {'Monday': shift},
    );
    ref.read(staffRosterProvider.notifier).addStaffMember(newStaff);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${tr('hospital_staff_added_prefix')} $name ${tr('hospital_staff_added_suffix')}'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _approveDoctor(String id, String name) {
    final tr = ref.read(translationsProvider);
    ref.read(doctorVerificationsProvider.notifier).verifyDoctor(id, true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${tr('hospital_staff_approved_prefix')} $name! ${tr('hospital_staff_approved_suffix')}'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _rejectDoctor(String id) {
    final tr = ref.read(translationsProvider);
    ref.read(doctorVerificationsProvider.notifier).verifyDoctor(id, false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(tr('hospital_staff_application_rejected')), backgroundColor: AppColors.danger),
    );
  }

  void _editShiftDialog(StaffMember staff, String day) {
    final tr = ref.read(translationsProvider);
    final shiftCont = TextEditingController(text: staff.shifts[day] ?? 'Off');
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('${tr('hospital_staff_edit_duty_shift_for')} ${staff.name}', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${tr('hospital_staff_day')}: $day', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: ['Off', 'OPD', 'Ward', 'Emergency', 'Night'].contains(shiftCont.text) ? shiftCont.text : 'OPD',
                decoration: InputDecoration(labelText: tr('hospital_staff_shift_designation')),
                onChanged: (val) {
                  if (val != null) {
                    shiftCont.text = val;
                  }
                },
                items: ['Off', 'OPD', 'Ward', 'Emergency', 'Night']
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text(tr('hospital_staff_cancel'))),
            ElevatedButton(
              onPressed: () {
                ref.read(staffRosterProvider.notifier).updateShift(staff.id, day, shiftCont.text);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${tr('hospital_staff_updated_shift_for')} ${staff.name} ${tr('hospital_staff_on')} $day ${tr('hospital_staff_to')} ${shiftCont.text}')),
                );
              },
              child: Text(tr('hospital_staff_save_shift')),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildDirectoryTab(),
                _buildRosterTab(),
                _buildApplicationsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final tr = ref.watch(translationsProvider);
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
      color: AppColors.surface,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tr('hospital_staff_title'),
                style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                tr('hospital_staff_subtitle'),
                style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
                tooltip: tr('hospital_staff_reload'),
                onPressed: () {
                  ref.invalidate(staffRosterProvider);
                  ref.invalidate(doctorVerificationsProvider);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(tr('hospital_staff_reloaded')), duration: const Duration(seconds: 1)),
                  );
                },
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () => _showAddStaffDialog(),
                icon: const Icon(Icons.person_add_rounded),
                label: Text(tr('hospital_staff_add_member')),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    final tr = ref.watch(translationsProvider);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.divider.withOpacity(0.5))),
      ),
      child: TabBar(
        controller: _tabController,
        tabs: [
          Tab(text: tr('hospital_staff_tab_directory')),
          Tab(text: tr('hospital_staff_tab_roster')),
          Tab(text: tr('hospital_staff_tab_verification')),
        ],
        isScrollable: true,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecondary,
        indicatorColor: AppColors.primary,
        labelStyle: GoogleFonts.inter(fontWeight: FontWeight.bold),
        unselectedLabelStyle: GoogleFonts.inter(fontWeight: FontWeight.normal),
      ),
    );
  }

  Widget _buildDirectoryTab() {
    final tr = ref.watch(translationsProvider);
    final staffList = ref.watch(staffRosterProvider);
    final query = _searchController.text.toLowerCase();
    
    final filtered = staffList.where((staff) {
      final matchesQuery = staff.name.toLowerCase().contains(query) || staff.dept.toLowerCase().contains(query);
      final matchesRole = _selectedRoleFilter == 'All' || staff.role == _selectedRoleFilter;
      return matchesQuery && matchesRole;
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Card(
        margin: EdgeInsets.zero,
        child: Column(
          children: [
            // Filter Bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: tr('hospital_staff_search_hint'),
                        prefixIcon: const Icon(Icons.search_rounded),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 16),
                  DropdownButton<String>(
                    value: _selectedRoleFilter,
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedRoleFilter = val);
                      }
                    },
                    items: [
                      DropdownMenuItem(value: 'All', child: Text(tr('hospital_staff_role_all'))),
                      DropdownMenuItem(value: 'Doctor', child: Text(tr('hospital_staff_role_doctor'))),
                      DropdownMenuItem(value: 'Nurse', child: Text(tr('hospital_staff_role_nurse'))),
                      DropdownMenuItem(value: 'Technician', child: Text(tr('hospital_staff_role_technician'))),
                      DropdownMenuItem(value: 'Pharmacist', child: Text(tr('hospital_staff_role_pharmacist'))),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Table
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Text(tr('hospital_staff_no_match'), style: GoogleFonts.inter(color: AppColors.textSecondary)),
                    )
                  : SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: SizedBox(
                        width: double.infinity,
                        child: DataTable(
                          columns: [
                            DataColumn(label: Text(tr('hospital_staff_col_name'))),
                            DataColumn(label: Text(tr('hospital_staff_col_role'))),
                            DataColumn(label: Text(tr('hospital_staff_col_department'))),
                            DataColumn(label: Text(tr('hospital_staff_col_shift_mon'))),
                            DataColumn(label: Text(tr('hospital_staff_col_status'))),
                          ],
                          rows: filtered.map((staff) {
                            return DataRow(cells: [
                              DataCell(Text(staff.name, style: GoogleFonts.inter(fontWeight: FontWeight.bold))),
                              DataCell(Text(staff.role)),
                              DataCell(Text(staff.dept)),
                              DataCell(Text(_trShift(staff.shifts['Monday'] ?? 'Off'))),
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.successLight,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    staff.status == 'Active' ? tr('hospital_staff_status_active') : staff.status,
                                    style: GoogleFonts.inter(color: AppColors.success, fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ]);
                          }).toList(),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  String _trDay(String day) {
    final tr = ref.watch(translationsProvider);
    const keys = {
      'Saturday': 'hospital_staff_day_saturday',
      'Sunday': 'hospital_staff_day_sunday',
      'Monday': 'hospital_staff_day_monday',
      'Tuesday': 'hospital_staff_day_tuesday',
      'Wednesday': 'hospital_staff_day_wednesday',
      'Thursday': 'hospital_staff_day_thursday',
      'Friday': 'hospital_staff_day_friday',
    };
    final key = keys[day];
    return key != null ? tr(key) : day;
  }

  String _trShift(String shift) {
    final tr = ref.watch(translationsProvider);
    const keys = {
      'Off': 'hospital_staff_shift_off',
      'OPD': 'hospital_staff_shift_opd',
      'Ward': 'hospital_staff_shift_ward',
      'Emergency': 'hospital_staff_shift_emergency',
      'Night': 'hospital_staff_shift_night',
    };
    final key = keys[shift];
    return key != null ? tr(key) : shift;
  }

  Widget _buildRosterTab() {
    final tr = ref.watch(translationsProvider);
    final List<String> days = ['Saturday', 'Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'];
    final staffList = ref.watch(staffRosterProvider);
    final clinicalStaff = staffList.where((s) => s.role == 'Doctor' || s.role == 'Nurse').toList();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Card(
        margin: EdgeInsets.zero,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: DataTable(
              columns: [
                DataColumn(label: Text(tr('hospital_staff_col_staff_member'))),
                ...days.map((d) => DataColumn(label: Text(_trDay(d)))),
              ],
              rows: clinicalStaff.map((staff) {
                return DataRow(
                  cells: [
                    DataCell(Text(staff.name, style: GoogleFonts.inter(fontWeight: FontWeight.bold))),
                    ...days.map((day) {
                      final shift = staff.shifts[day] ?? 'Off';
                      Color color = AppColors.textSecondary;
                      Color bg = AppColors.background;
                      if (shift == 'Emergency') {
                        color = AppColors.danger;
                        bg = AppColors.dangerLight;
                      } else if (shift == 'OPD') {
                        color = AppColors.primary;
                        bg = AppColors.primaryLight;
                      } else if (shift == 'Ward') {
                        color = AppColors.secondary;
                        bg = AppColors.secondaryLight;
                      } else if (shift == 'Night') {
                        color = Colors.indigo;
                        bg = Colors.indigo.shade50;
                      }

                      return DataCell(
                        InkWell(
                          onTap: () => _editShiftDialog(staff, day),
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: bg.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: color.withOpacity(0.15)),
                            ),
                            child: Text(
                              _trShift(shift),
                              style: GoogleFonts.inter(color: color, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildApplicationsTab() {
    final tr = ref.watch(translationsProvider);
    final pendingDoctors = ref.watch(doctorVerificationsProvider).where((r) => r.status == 'Pending').toList();

    return pendingDoctors.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle_rounded, size: 54, color: AppColors.success),
                const SizedBox(height: 16),
                Text(
                  tr('hospital_staff_all_reviewed'),
                  style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  tr('hospital_staff_no_pending'),
                  style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13),
                ),
              ],
            ),
          )
        : ListView.separated(
            padding: const EdgeInsets.all(24),
            itemCount: pendingDoctors.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final doc = pendingDoctors[index];
              return Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: AppColors.accentLight,
                      child: const Icon(Icons.medical_services_rounded, color: AppColors.accent),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(doc.name, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text('${tr('hospital_staff_bmdc_registration')}: ${doc.bmdcNo}', style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 12)),
                          Text('${tr('hospital_staff_specialization')}: ${doc.specialization}', style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 12)),
                          Text('${tr('hospital_staff_submitted_date')}: ${doc.date}', style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 12)),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              OutlinedButton.icon(
                                onPressed: () {
                                  _showCredentialsDialog(doc);
                                },
                                icon: const Icon(Icons.description_rounded, size: 16),
                                label: Text(tr('hospital_staff_view_credentials')),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        OutlinedButton(
                          onPressed: () => _rejectDoctor(doc.id),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.danger,
                            side: const BorderSide(color: AppColors.danger),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          ),
                          child: Text(tr('hospital_staff_reject')),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: () => _approveDoctor(doc.id, doc.name),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.success,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          ),
                          child: Text(tr('hospital_staff_approve_affiliation')),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
  }

  void _showCredentialsDialog(DoctorVerificationRequest doc) {
    final tr = ref.read(translationsProvider);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('${doc.name} - ${tr('hospital_staff_credentials_summary')}', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCredentialItem(tr('hospital_staff_cred_license_title'), tr('hospital_staff_cred_license_desc')),
              _buildCredentialItem(tr('hospital_staff_cred_degree_title'), tr('hospital_staff_cred_degree_desc')),
              _buildCredentialItem(tr('hospital_staff_cred_nid_title'), tr('hospital_staff_cred_nid_desc')),
              _buildCredentialItem(tr('hospital_staff_cred_specialist_title'), tr('hospital_staff_cred_specialist_desc')),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(tr('hospital_staff_close')),
            )
          ],
        );
      },
    );
  }

  Widget _buildCredentialItem(String title, String desc) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 16),
              const SizedBox(width: 8),
              Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 2),
          Padding(
            padding: const EdgeInsets.only(left: 24),
            child: Text(desc, style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  void _showAddStaffDialog() {
    final tr = ref.read(translationsProvider);
    final nameCont = TextEditingController();
    String role = 'Doctor';
    String dept = 'Cardiology';
    String shift = 'Morning';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(tr('hospital_staff_add_new_member'), style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameCont,
                    decoration: InputDecoration(labelText: tr('hospital_staff_full_name'), hintText: tr('hospital_staff_full_name_hint')),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: role,
                    decoration: InputDecoration(labelText: tr('hospital_staff_field_role')),
                    onChanged: (val) => setDialogState(() => role = val!),
                    items: [
                      DropdownMenuItem(value: 'Doctor', child: Text(tr('hospital_staff_role_doctor'))),
                      DropdownMenuItem(value: 'Nurse', child: Text(tr('hospital_staff_role_nurse'))),
                      DropdownMenuItem(value: 'Technician', child: Text(tr('hospital_staff_role_technician'))),
                      DropdownMenuItem(value: 'Pharmacist', child: Text(tr('hospital_staff_role_pharmacist'))),
                    ],
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: dept,
                    decoration: InputDecoration(labelText: tr('hospital_staff_field_department')),
                    onChanged: (val) => setDialogState(() => dept = val!),
                    items: [
                      DropdownMenuItem(value: 'Cardiology', child: Text(tr('hospital_staff_dept_cardiology'))),
                      DropdownMenuItem(value: 'Emergency', child: Text(tr('hospital_staff_dept_emergency'))),
                      DropdownMenuItem(value: 'Pediatrics', child: Text(tr('hospital_staff_dept_pediatrics'))),
                      DropdownMenuItem(value: 'Laboratory', child: Text(tr('hospital_staff_dept_laboratory'))),
                      DropdownMenuItem(value: 'Pharmacy', child: Text(tr('hospital_staff_dept_pharmacy'))),
                      DropdownMenuItem(value: 'General Ward', child: Text(tr('hospital_staff_dept_general_ward'))),
                    ],
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: shift,
                    decoration: InputDecoration(labelText: tr('hospital_staff_field_shift')),
                    onChanged: (val) => setDialogState(() => shift = val!),
                    items: [
                      DropdownMenuItem(value: 'Morning', child: Text(tr('hospital_staff_shift_morning'))),
                      DropdownMenuItem(value: 'Evening', child: Text(tr('hospital_staff_shift_evening'))),
                      DropdownMenuItem(value: 'Night', child: Text(tr('hospital_staff_shift_night'))),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(tr('hospital_staff_cancel')),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (nameCont.text.isNotEmpty) {
                      _addStaffMember(nameCont.text, role, dept, shift);
                      Navigator.pop(context);
                    }
                  },
                  child: Text(tr('hospital_staff_add_staff')),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
