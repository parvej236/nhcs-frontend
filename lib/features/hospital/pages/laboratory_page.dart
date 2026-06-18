import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

class LaboratoryPage extends StatefulWidget {
  const LaboratoryPage({super.key});

  @override
  State<LaboratoryPage> createState() => _LaboratoryPageState();
}

class _LaboratoryPageState extends State<LaboratoryPage> {
  // Test records database in state for simulation
  List<Map<String, dynamic>> _labOrders = [
    {
      'id': 'LB-101',
      'patient': 'Rahim Islam',
      'healthId': 'NUD-892-441-X7',
      'test': 'Complete Blood Count (CBC)',
      'doctor': 'Dr. Ahmed Khan',
      'status': 'Ordered',
      'results': {},
    },
    {
      'id': 'LB-102',
      'patient': 'Jahanara Begum',
      'healthId': 'NUD-123-456-A1',
      'test': 'Fasting Blood Glucose',
      'doctor': 'Trauma Lead',
      'status': 'Sample Collected',
      'results': {},
    },
    {
      'id': 'LB-103',
      'patient': 'Kamal Hossain',
      'healthId': 'NUD-987-654-B2',
      'test': 'Lipid Profile',
      'doctor': 'Dr. Fatima',
      'status': 'Processing',
      'results': {},
    },
    {
      'id': 'LB-104',
      'patient': 'Abdul Karim',
      'healthId': 'NUD-111-222-A2',
      'test': 'Serum Creatinine',
      'doctor': 'Dr. Ahmed Khan',
      'status': 'Verified',
      'results': {'Creatinine': '1.1 mg/dL'},
    },
    {
      'id': 'LB-105',
      'patient': 'Hasan Ali',
      'healthId': 'NUD-444-555-C3',
      'test': 'ECG / Electrocardiogram',
      'doctor': 'Trauma Lead',
      'status': 'Published',
      'results': {'Rhythm': 'Normal Sinus Rhythm'},
    }
  ];

  void _nextStage(String orderId) {
    final idx = _labOrders.indexWhere((o) => o['id'] == orderId);
    if (idx != -1) {
      final currentStatus = _labOrders[idx]['status'];
      String nextStatus = currentStatus;

      if (currentStatus == 'Ordered') {
        nextStatus = 'Sample Collected';
      } else if (currentStatus == 'Sample Collected') {
        nextStatus = 'Processing';
      } else if (currentStatus == 'Processing') {
        _showResultEntryDialog(orderId);
        return; // Dialog handles the transition
      } else if (currentStatus == 'Verified') {
        nextStatus = 'Published';
      }

      setState(() {
        _labOrders[idx]['status'] = nextStatus;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order $orderId moved to $nextStatus')),
      );
    }
  }

  void _submitResults(String orderId, Map<String, String> results) {
    final idx = _labOrders.indexWhere((o) => o['id'] == orderId);
    if (idx != -1) {
      setState(() {
        _labOrders[idx]['results'] = results;
        _labOrders[idx]['status'] = 'Verified';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Results submitted for $orderId. Awaiting senior approval.'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          _buildWorkloadStats(),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildKanbanColumn('Ordered', Icons.assignment_rounded, AppColors.info),
                  _buildKanbanColumn('Sample Collected', Icons.biotech_rounded, AppColors.accent),
                  _buildKanbanColumn('Processing', Icons.sync_rounded, AppColors.warning),
                  _buildKanbanColumn('Verified', Icons.verified_rounded, AppColors.success),
                  _buildKanbanColumn('Published', Icons.check_circle_rounded, AppColors.primary),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      color: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Laboratory Operations',
            style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Track and enter diagnostic results from collection to digital publication.',
            style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkloadStats() {
    final ordered = _labOrders.where((o) => o['status'] == 'Ordered').length;
    final processing = _labOrders.where((o) => o['status'] == 'Processing' || o['status'] == 'Sample Collected').length;
    final verified = _labOrders.where((o) => o['status'] == 'Verified').length;
    final completed = _labOrders.where((o) => o['status'] == 'Published').length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.divider.withOpacity(0.5))),
      ),
      child: Row(
        children: [
          _statMini('Pending Orders', ordered.toString(), AppColors.info),
          _statDivider(),
          _statMini('In Lab Processing', processing.toString(), AppColors.warning),
          _statDivider(),
          _statMini('Awaiting Verification', verified.toString(), AppColors.accent),
          _statDivider(),
          _statMini('Published Today', completed.toString(), AppColors.success),
        ],
      ),
    );
  }

  Widget _statMini(String label, String value, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text('$label: ', style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13)),
        Text(value, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary)),
      ],
    );
  }

  Widget _statDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(width: 1, height: 16, color: AppColors.divider),
    );
  }

  Widget _buildKanbanColumn(String status, IconData icon, Color color) {
    final list = _labOrders.where((o) => o['status'] == status).toList();

    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.05),
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
              border: Border(bottom: BorderSide(color: AppColors.divider.withOpacity(0.5))),
            ),
            child: Row(
              children: [
                Icon(icon, color: color, size: 18),
                const SizedBox(width: 8),
                Text(status, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                  child: Text(list.length.toString(), style: GoogleFonts.inter(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          Expanded(
            child: list.isEmpty
                ? Center(
                    child: Text('No orders in this column', style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 12)),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: list.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final order = list[index];
                      return _buildKanbanCard(order, color);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildKanbanCard(Map<String, dynamic> order, Color themeColor) {
    final String status = order['status'];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                order['id'],
                style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.textMuted),
              ),
              if (order['results'].isNotEmpty)
                const Icon(Icons.description_rounded, size: 14, color: AppColors.textSecondary),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            order['test'],
            style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            'Patient: ${order['patient']}',
            style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
          ),
          Text(
            'Dr: ${order['doctor']}',
            style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Actions',
                style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted),
              ),
              if (status != 'Published')
                InkWell(
                  onTap: () => _nextStage(order['id']),
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: themeColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        Text(
                          status == 'Processing' ? 'Enter' : 'Advance',
                          style: GoogleFonts.inter(color: themeColor, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.arrow_forward_rounded, size: 10, color: themeColor),
                      ],
                    ),
                  ),
                )
              else
                const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 16),
            ],
          ),
        ],
      ),
    );
  }

  void _showResultEntryDialog(String orderId) {
    final idx = _labOrders.indexWhere((o) => o['id'] == orderId);
    if (idx == -1) return;
    final order = _labOrders[idx];

    final keyCont = TextEditingController(text: 'Hemoglobin');
    final valCont = TextEditingController(text: '14.2 g/dL');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Enter Lab Results (${order['id']})', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Test: ${order['test']}', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14)),
              Text('Patient: ${order['patient']}', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              TextField(
                controller: keyCont,
                decoration: const InputDecoration(labelText: 'Parameter / Biomarker'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: valCont,
                decoration: const InputDecoration(labelText: 'Measured Value'),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.cloud_upload_outlined, color: AppColors.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Simulate PDF Upload', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 12)),
                          Text('Report is uploaded to MinIO storage', style: GoogleFonts.inter(fontSize: 10, color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    const Icon(Icons.check_circle, color: AppColors.success, size: 18),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (keyCont.text.isNotEmpty && valCont.text.isNotEmpty) {
                  _submitResults(orderId, {keyCont.text: valCont.text});
                  Navigator.pop(context);
                }
              },
              child: const Text('Submit & Send to Verification'),
            ),
          ],
        );
      },
    );
  }
}
