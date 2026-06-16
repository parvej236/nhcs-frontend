import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

class ReceptionQueuePage extends StatefulWidget {
  const ReceptionQueuePage({super.key});

  @override
  State<ReceptionQueuePage> createState() => _ReceptionQueuePageState();
}

class _ReceptionQueuePageState extends State<ReceptionQueuePage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedDept = 'Emergency';
  
  // Hardcoded patient lookup database for simulation
  final Map<String, Map<String, String>> _mockPatientsDb = {
    'NUD-892-441-X7': {
      'name': 'Rahim Islam',
      'id': 'NUD-892-441-X7',
      'nid': '1984261523412',
      'age': '42',
      'gender': 'Male',
      'blood': 'O+',
      'specialty': 'Cardiology',
      'doctor': 'Dr. Ahmed',
    },
    'NUD-123-456-A1': {
      'name': 'Jahanara Begum',
      'id': 'NUD-123-456-A1',
      'nid': '1992261543210',
      'age': '31',
      'gender': 'Female',
      'blood': 'A-',
      'specialty': 'Emergency',
      'doctor': 'On-Duty Trauma Team',
    },
    'NUD-987-654-B2': {
      'name': 'Kamal Hossain',
      'id': 'NUD-987-654-B2',
      'nid': '1975261598765',
      'age': '50',
      'gender': 'Male',
      'blood': 'B+',
      'specialty': 'Pediatrics',
      'doctor': 'Dr. Fatima',
    }
  };

  Map<String, String>? _searchedPatient;
  bool _searchPerformed = false;

  // Active queues in memory for simulation
  List<Map<String, dynamic>> _queueList = [
    {
      'queueNo': 'EM-04',
      'name': 'Hasan Ali',
      'age': '52',
      'gender': 'M',
      'dept': 'Emergency',
      'doctor': 'Trauma Lead',
      'status': 'In Consultation',
    },
    {
      'queueNo': 'EM-05',
      'name': 'Fatema Zohra',
      'age': '24',
      'gender': 'F',
      'dept': 'Emergency',
      'doctor': 'Dr. Subrata',
      'status': 'Waiting',
    },
    {
      'queueNo': 'EM-06',
      'name': 'Adnan Sami',
      'age': '35',
      'gender': 'M',
      'dept': 'Emergency',
      'doctor': 'Dr. Subrata',
      'status': 'Waiting',
    },
    {
      'queueNo': 'CD-01',
      'name': 'Abdul Karim',
      'age': '62',
      'gender': 'M',
      'dept': 'Cardiology',
      'doctor': 'Dr. Ahmed',
      'status': 'In Consultation',
    },
    {
      'queueNo': 'CD-02',
      'name': 'Shahnaz Parveen',
      'age': '45',
      'gender': 'F',
      'dept': 'Cardiology',
      'doctor': 'Dr. Ahmed',
      'status': 'Waiting',
    },
    {
      'queueNo': 'PD-01',
      'name': 'Tahsan Karim',
      'age': '6',
      'gender': 'M',
      'dept': 'Pediatrics',
      'doctor': 'Dr. Fatima',
      'status': 'Waiting',
    }
  ];

  void _searchPatient() {
    final query = _searchController.text.trim();
    setState(() {
      _searchPerformed = true;
      if (_mockPatientsDb.containsKey(query)) {
        _searchedPatient = _mockPatientsDb[query];
      } else {
        // Fallback or custom generation
        _searchedPatient = null;
      }
    });
  }

  void _checkInPatient() {
    if (_searchedPatient != null) {
      final dept = _searchedPatient!['specialty'] ?? 'Emergency';
      final String prefix = dept == 'Emergency' ? 'EM' : (dept == 'Cardiology' ? 'CD' : 'PD');
      final int nextNo = _queueList.where((p) => p['dept'] == dept).length + 1;
      
      setState(() {
        _queueList.add({
          'queueNo': '$prefix-${nextNo.toString().padLeft(2, '0')}',
          'name': _searchedPatient!['name'],
          'age': _searchedPatient!['age'],
          'gender': _searchedPatient!['gender']?[0] ?? 'M',
          'dept': dept,
          'doctor': _searchedPatient!['doctor'] ?? 'Unassigned',
          'status': 'Waiting',
        });
        // Clear search
        _searchedPatient = null;
        _searchPerformed = false;
        _searchController.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Patient successfully checked in! Placed in $dept Queue.'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  void _updateStatus(int index, String newStatus) {
    setState(() {
      _queueList[index]['status'] = newStatus;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Filter queue by active department selection
    final filteredQueue = _queueList.where((p) => p['dept'] == _selectedDept).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Side: Front Desk Check-In Desk
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Patient Check-In Desk',
                    style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Search for registered patients by Digital Health ID to verify identity and issue a queue number.',
                    style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13),
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
          Container(width: 1, color: AppColors.divider),
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
                            // Find real index in parent list for update operations
                            final realIndex = _queueList.indexWhere((p) => p['queueNo'] == patient['queueNo']);
                            return _buildQueueCard(patient, realIndex);
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
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Lookup Citizen Record',
            style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    labelText: 'NUDHEB Health ID / NID',
                    hintText: 'e.g., NUD-892-441-X7',
                    prefixIcon: Icon(Icons.badge_outlined),
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
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Try searching "NUD-892-441-X7" (Rahim Islam) or "NUD-123-456-A1" (Jahanara Begum)',
            style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResultSection() {
    if (_searchedPatient == null) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider),
        ),
        child: Center(
          child: Column(
            children: [
              const Icon(Icons.person_search_rounded, size: 48, color: AppColors.textMuted),
              const SizedBox(height: 16),
              Text(
                'No Citizen Record Found',
                style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Verify the Health ID number and search again.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    final p = _searchedPatient!;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(color: AppColors.primary.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
              border: Border(bottom: BorderSide(color: AppColors.divider.withOpacity(0.5))),
            ),
            child: Row(
              children: [
                const Icon(Icons.verified_user_rounded, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Active Identity Verified',
                  style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primary),
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
                      backgroundColor: AppColors.primaryLight,
                      child: Text(
                        p['name']?[0] ?? 'P',
                        style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p['name'] ?? '',
                            style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Health ID: ${p['id']}',
                            style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 12),
                _buildDetailRow('National ID', p['nid'] ?? ''),
                _buildDetailRow('Age / Gender', '${p['age']} years • ${p['gender']}'),
                _buildDetailRow('Blood Group', p['blood'] ?? ''),
                _buildDetailRow('Scheduled Specialty', p['specialty'] ?? ''),
                _buildDetailRow('Assigned Doctor', p['doctor'] ?? ''),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _checkInPatient,
                    icon: const Icon(Icons.check_circle_outline_rounded),
                    label: const Text('Confirm Check-In & Issue Queue Ticket'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: AppColors.success,
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13)),
          Text(value, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textPrimary)),
        ],
      ),
    );
  }

  Widget _buildQueueDashboardHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      color: AppColors.surface,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Live Queue Dashboard',
                style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Track patient transit and consultation status across clinics.',
                style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.timer_outlined, color: AppColors.primary, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Average Wait: 18m',
                  style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDepartmentTabs() {
    final List<String> depts = ['Emergency', 'Cardiology', 'Pediatrics'];
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: depts.map((dept) {
          final isSelected = _selectedDept == dept;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(dept),
              selected: isSelected,
              onSelected: (val) {
                if (val) {
                  setState(() => _selectedDept = dept);
                }
              },
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(color: isSelected ? Colors.white : AppColors.textSecondary),
              backgroundColor: AppColors.background,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildQueueCard(Map<String, dynamic> patient, int realIndex) {
    final status = patient['status'];
    Color statusColor;
    Color statusBg;

    switch (status) {
      case 'In Consultation':
        statusColor = AppColors.warning;
        statusBg = AppColors.warningLight;
        break;
      case 'Completed':
        statusColor = AppColors.success;
        statusBg = AppColors.successLight;
        break;
      default: // Waiting
        statusColor = AppColors.info;
        statusBg = AppColors.infoLight;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          // Queue Number Badge
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.divider),
            ),
            alignment: Alignment.center,
            child: Text(
              patient['queueNo'],
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary),
            ),
          ),
          const SizedBox(width: 16),
          // Patient Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      patient['name'],
                      style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: statusBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        status,
                        style: GoogleFonts.inter(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${patient['age']}Y • ${patient['gender']} • Assigned: ${patient['doctor']}',
                  style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          // Actions
          Row(
            children: [
              if (status == 'Waiting') ...[
                IconButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Paging patient ${patient['name']}...')),
                    );
                  },
                  icon: const Icon(Icons.volume_up_rounded, color: AppColors.primary),
                  tooltip: 'Announce Call',
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: () => _updateStatus(realIndex, 'In Consultation'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Start'),
                ),
              ],
              if (status == 'In Consultation') ...[
                ElevatedButton(
                  onPressed: () => _updateStatus(realIndex, 'Completed'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Complete'),
                ),
              ],
              if (status == 'Completed') ...[
                const Icon(Icons.check_circle, color: AppColors.success, size: 24),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyQueue() {
    return Container(
      padding: const EdgeInsets.all(48),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.queue_rounded, size: 54, color: AppColors.textMuted),
          const SizedBox(height: 16),
          Text(
            'No Patients in Queue',
            style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Check in patients on the left desk to start the queue.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
