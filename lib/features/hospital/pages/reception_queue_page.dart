import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uhcs/features/patient/data/models/appointment.dart';
import 'package:uhcs/features/hospital/data/repositories/hospital_repository.dart';
import 'package:uhcs/features/hospital/data/models/reception_queue_item.dart';
import '../../../core/theme/app_colors.dart';
import '../presentation/providers/hospital_providers.dart';

class ReceptionQueuePage extends ConsumerStatefulWidget {
  const ReceptionQueuePage({super.key});

  @override
  ConsumerState<ReceptionQueuePage> createState() => _ReceptionQueuePageState();
}

class _ReceptionQueuePageState extends ConsumerState<ReceptionQueuePage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedDept = 'Emergency';

  List<Appointment> _searchedAppointments = [];
  bool _searchPerformed = false;
  bool _isSearching = false;

  void _searchPatient() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isSearching = true;
      _searchPerformed = true;
    });

    try {
      final repo = ref.read(hospitalRepositoryProvider);
      final results = await repo.searchAppointments(query);
      setState(() {
        _searchedAppointments = results;
      });
    } catch (e) {
      setState(() {
        _searchedAppointments = [];
      });
    } finally {
      setState(() {
        _isSearching = false;
      });
    }
  }

  void _checkInPatient(Appointment app) async {
    setState(() {
      _isSearching = true;
    });

    try {
      await ref.read(receptionQueueProvider.notifier).checkInPatient(
        name: app.patientName,
        age: app.patientAge,
        gender: app.patientGender.isNotEmpty ? app.patientGender.substring(0, 1) : 'M',
        healthId: app.patientHealthId,
        dept: app.doctor.specialization,
        doctor: app.doctor.name,
      );

      setState(() {
        _searchedAppointments = [];
        _searchPerformed = false;
        _searchController.clear();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Checked in Rahim Islam for ${app.doctor.specialization} Queue!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to check in patient. please try again.'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } finally {
      setState(() {
        _isSearching = false;
      });
    }
  }

  void _updateStatus(String queueNo, String newStatus) {
    ref.read(receptionQueueProvider.notifier).updateStatus(queueNo, newStatus);
  }

  @override
  Widget build(BuildContext context) {
    final queueList = ref.watch(receptionQueueProvider);
    final filteredQueue = queueList.where((p) => p.dept == _selectedDept).toList();
    final t = AppColors.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Side: Front Check-In Desk
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Patient Check-In Desk',
                    style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: t.textPrimary),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Search for registered patients by Digital Health ID, NID or name to verify bookings and check in.',
                    style: GoogleFonts.inter(color: t.textSecondary, fontSize: 13),
                  ),
                  const SizedBox(height: 24),
                  _buildSearchCard(),
                  if (_searchPerformed) ...[
                    const SizedBox(height: 24),
                    _buildSearchResultSection(),
                  ],
                ],
              ),
            ),
          ),
          // Vertical divider
          Container(width: 1, color: t.border),
          // Right Side: Department Queues Dashboard
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildQueueDashboardHeader(),
                _buildDepartmentTabs(),
                Expanded(
                  child: filteredQueue.isEmpty
                      ? _buildEmptyQueue()
                      : ListView.separated(
                          padding: const EdgeInsets.all(24),
                          itemCount: filteredQueue.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final patient = filteredQueue[index];
                            return _buildQueueCard(patient);
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchCard() {
    final t = AppColors.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: t.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: t.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Lookup Citizen Record',
            style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600, color: t.textPrimary),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  style: GoogleFonts.inter(color: t.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'NHCS Health ID / NID / Name',
                    labelStyle: TextStyle(color: t.textSecondary),
                    hintText: 'e.g., NUD-000-1 or Rahim Islam',
                    hintStyle: TextStyle(color: t.textSecondary.withValues(alpha: 0.5)),
                    prefixIcon: Icon(Icons.badge_outlined, color: t.textSecondary),
                    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: t.border)),
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: t.brandPrimary)),
                  ),
                  onSubmitted: (_) => _searchPatient(),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: _searchPatient,
                icon: const Icon(Icons.search_rounded),
                label: const Text('Find Patient'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: t.brandPrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Try searching "NUD-000-1" (Rahim Islam) or patient name',
            style: GoogleFonts.inter(fontSize: 11, color: t.textSecondary, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResultSection() {
    final t = AppColors.of(context);

    if (_isSearching) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (_searchedAppointments.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: t.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: t.border),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.person_search_rounded, size: 48, color: t.textSecondary.withValues(alpha: 0.5)),
              const SizedBox(height: 16),
              Text(
                'No Citizen Record Found',
                style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: t.textPrimary),
              ),
              const SizedBox(height: 8),
              Text(
                'Verify the Health ID or name, and ensure they have an approved appointment.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(color: t.textSecondary, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: _searchedAppointments.map((app) => _buildSingleSearchResult(app)).toList(),
    );
  }

  Widget _buildSingleSearchResult(Appointment app) {
    final t = AppColors.of(context);
    final isApproved = app.approvalStatus == 'APPROVED';
    final isCheckedIn = app.arrivalStatus == 'CHECKED_IN' || app.arrivalStatus == 'COMPLETED';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: t.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isApproved ? t.brandPrimary.withValues(alpha: 0.3) : t.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: isApproved ? t.brandPrimary.withValues(alpha: 0.05) : t.border.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
              border: Border(bottom: BorderSide(color: t.border)),
            ),
            child: Row(
              children: [
                Icon(
                  isApproved ? Icons.verified_user_rounded : Icons.pending_actions_rounded,
                  color: isApproved ? t.brandPrimary : t.warning,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  isApproved
                      ? (isCheckedIn ? 'Checked In' : 'Active Booking Verified')
                      : 'Pending Approval',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isApproved ? t.brandPrimary : t.warning,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: t.brandPrimary.withValues(alpha: 0.1),
                      child: Text(
                        app.patientName.isNotEmpty ? app.patientName[0] : 'P',
                        style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: t.brandPrimary),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            app.patientName,
                            style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: t.textPrimary),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Health ID: ${app.patientHealthId}',
                            style: GoogleFonts.inter(color: t.textSecondary, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 12),
                _buildDetailRow('National ID', app.patientNid.isNotEmpty ? app.patientNid : '8210398457'),
                _buildDetailRow('Age / Gender', '${app.patientAge} years • ${app.patientGender}'),
                _buildDetailRow('Blood Group', app.patientBloodGroup),
                _buildDetailRow('Scheduled Specialty', app.doctor.specialization),
                _buildDetailRow('Assigned Doctor', app.doctor.name),
                _buildDetailRow('Time slot', '${app.date.toIso8601String().split('T')[0]} @ ${app.timeSlot}'),
                const SizedBox(height: 24),
                if (isCheckedIn)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: t.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        'Already Checked In • Queue No: ${app.queueNumber}',
                        style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: t.success),
                      ),
                    ),
                  )
                else if (!isApproved)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: t.warning.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        'Requires Command Center Approval First',
                        style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: t.warning),
                      ),
                    ),
                  )
                else
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _checkInPatient(app),
                      icon: const Icon(Icons.check_circle_outline_rounded),
                      label: const Text('Confirm Check-In & Issue Queue Ticket'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: t.success,
                        foregroundColor: Colors.white,
                        elevation: 0,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    final t = AppColors.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.inter(color: t.textSecondary, fontSize: 13)),
          Text(value, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13, color: t.textPrimary)),
        ],
      ),
    );
  }

  Widget _buildQueueDashboardHeader() {
    final t = AppColors.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: t.bgCard,
        border: Border(bottom: BorderSide(color: t.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Live Queue Dashboard',
                style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: t.textPrimary),
              ),
              const SizedBox(height: 4),
              Text(
                'Track patient transit and consultation status across clinics.',
                style: GoogleFonts.inter(color: t.textSecondary, fontSize: 13),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: t.brandPrimary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.timer_outlined, color: t.brandPrimary, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Average Wait: 18m',
                  style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: t.brandPrimary, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDepartmentTabs() {
    final t = AppColors.of(context);
    final departments = ['Emergency', 'Cardiology', 'ICU', 'General Ward', 'Pediatrics'];
    
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: t.bgCard,
        border: Border(bottom: BorderSide(color: t.border)),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: departments.length,
        itemBuilder: (context, index) {
          final dept = departments[index];
          final isSelected = _selectedDept == dept;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
            child: ChoiceChip(
              label: Text(dept),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedDept = dept;
                  });
                }
              },
              backgroundColor: t.bgInput,
              selectedColor: t.brandPrimary,
              labelStyle: GoogleFonts.inter(
                color: isSelected ? Colors.white : t.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyQueue() {
    final t = AppColors.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline_rounded, size: 64, color: t.textSecondary.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text(
            'Queue is Empty',
            style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: t.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            'No checked-in patients in the $_selectedDept clinic.',
            style: GoogleFonts.inter(color: t.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildQueueCard(ReceptionQueueItem patient) {
    final t = AppColors.of(context);
    Color statusColor;
    switch (patient.status) {
      case 'In Consultation':
        statusColor = t.brandSecondary;
        break;
      case 'Completed':
        statusColor = t.success;
        break;
      default:
        statusColor = t.warning;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: t.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: t.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: t.brandPrimary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              patient.queueNo,
              style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: t.brandPrimary),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  patient.name,
                  style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: t.textPrimary),
                ),
                const SizedBox(height: 4),
                Text(
                  '${patient.age} yrs • ${patient.gender} • Dr. Ahmed Khan',
                  style: GoogleFonts.inter(color: t.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  patient.status,
                  style: GoogleFonts.inter(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),
              if (patient.status == 'Waiting')
                InkWell(
                  onTap: () => _updateStatus(patient.queueNo, 'In Consultation'),
                  child: Row(
                    children: [
                      Text('Start Consultation', style: GoogleFonts.inter(color: t.brandPrimary, fontSize: 12, fontWeight: FontWeight.bold)),
                      Icon(Icons.chevron_right_rounded, size: 16, color: t.brandPrimary),
                    ],
                  ),
                )
              else if (patient.status == 'In Consultation')
                InkWell(
                  onTap: () => _updateStatus(patient.queueNo, 'Completed'),
                  child: Row(
                    children: [
                      Text('Complete Session', style: GoogleFonts.inter(color: t.success, fontSize: 12, fontWeight: FontWeight.bold)),
                      Icon(Icons.check_rounded, size: 16, color: t.success),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
