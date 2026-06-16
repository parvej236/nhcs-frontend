import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

class PharmacyPage extends StatefulWidget {
  const PharmacyPage({super.key});

  @override
  State<PharmacyPage> createState() => _PharmacyPageState();
}

class _PharmacyPageState extends State<PharmacyPage> {
  final TextEditingController _rxController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategoryFilter = 'All';

  // State Inventory
  List<Map<String, dynamic>> _inventory = [
    {'name': 'Metformin 500mg', 'generic': 'Metformin HCl', 'category': 'Antidiabetic', 'stock': 5000, 'min': 1000, 'price': 'BDT 5.00'},
    {'name': 'Amlodipine 5mg', 'generic': 'Amlodipine Besylate', 'category': 'Antihypertensive', 'stock': 2400, 'min': 500, 'price': 'BDT 8.00'},
    {'name': 'Aspirin 75mg', 'generic': 'Acetylsalicylic Acid', 'category': 'Antiplatelet', 'stock': 1800, 'min': 500, 'price': 'BDT 2.00'},
    {'name': 'Paracetamol 500mg', 'generic': 'Acetaminophen', 'category': 'Analgesic', 'stock': 400, 'min': 1000, 'price': 'BDT 1.50'}, // Alert
    {'name': 'Amoxicillin 500mg', 'generic': 'Amoxicillin Trihydrate', 'category': 'Antibiotic', 'stock': 1200, 'min': 300, 'price': 'BDT 12.00'},
    {'name': 'Atorvastatin 10mg', 'generic': 'Atorvastatin Calcium', 'category': 'Cardiovascular', 'stock': 150, 'min': 500, 'price': 'BDT 15.00'}, // Alert
  ];

  // Prescription Mock Database
  final Map<String, Map<String, dynamic>> _mockPrescriptions = {
    'RX-9921': {
      'patient': 'Rahim Islam',
      'id': 'RX-9921',
      'doctor': 'Dr. Ahmed Khan',
      'date': 'Jun 15, 2026',
      'items': [
        {'medicine': 'Metformin 500mg', 'qty': 60, 'instruction': '1 tablet twice daily after meals'},
        {'medicine': 'Amlodipine 5mg', 'qty': 30, 'instruction': '1 tablet daily in morning'},
      ]
    },
    'RX-1024': {
      'patient': 'Jahanara Begum',
      'id': 'RX-1024',
      'doctor': 'Dr. Fatima',
      'date': 'Jun 14, 2026',
      'items': [
        {'medicine': 'Amoxicillin 500mg', 'qty': 21, 'instruction': '1 tablet 3 times daily for 7 days'},
        {'medicine': 'Paracetamol 500mg', 'qty': 10, 'instruction': '1 tablet as needed for pain'},
      ]
    }
  };

  Map<String, dynamic>? _loadedPrescription;
  bool _rxSearched = false;

  void _searchRx() {
    final query = _rxController.text.trim();
    setState(() {
      _rxSearched = true;
      if (_mockPrescriptions.containsKey(query)) {
        _loadedPrescription = _mockPrescriptions[query];
      } else {
        _loadedPrescription = null;
      }
    });
  }

  void _dispensePrescription() {
    if (_loadedPrescription != null) {
      final List items = _loadedPrescription!['items'];
      bool canDispense = true;
      String errorMsg = '';

      // Check stock first
      for (var item in items) {
        final String medName = item['medicine'];
        final int reqQty = item['qty'];

        final invItem = _inventory.firstWhere((i) => i['name'] == medName, orElse: () => {});
        if (invItem.isEmpty) {
          canDispense = false;
          errorMsg = '$medName is not in the hospital formulary database.';
          break;
        } else if ((invItem['stock'] as int) < reqQty) {
          canDispense = false;
          errorMsg = 'Insufficient stock for $medName. Available: ${invItem['stock']}, Required: $reqQty';
          break;
        }
      }

      if (canDispense) {
        setState(() {
          // Deduct from inventory stock
          for (var item in items) {
            final String medName = item['medicine'];
            final int reqQty = item['qty'];
            final idx = _inventory.indexWhere((i) => i['name'] == medName);
            if (idx != -1) {
              _inventory[idx]['stock'] = (_inventory[idx]['stock'] as int) - reqQty;
            }
          }
          _loadedPrescription = null;
          _rxSearched = false;
          _rxController.clear();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Prescription successfully dispensed. Inventory quantities updated!'),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Stock Out Warning', style: GoogleFonts.outfit(color: AppColors.danger, fontWeight: FontWeight.bold)),
            content: Text(errorMsg),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Dismiss')),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filter inventory
    final query = _searchController.text.toLowerCase();
    final filteredInventory = _inventory.where((item) {
      final matchesQuery = item['name'].toLowerCase().contains(query) || item['generic'].toLowerCase().contains(query);
      final matchesCategory = _selectedCategoryFilter == 'All' || item['category'] == _selectedCategoryFilter;
      return matchesQuery && matchesCategory;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left: Dispense desk lookup
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dispensing Counter',
                    style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Validate and dispense medications against electronic doctor prescriptions.',
                    style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13),
                  ),
                  const SizedBox(height: 24),
                  _buildRxLookupCard(),
                  if (_rxSearched) ...[
                    const SizedBox(height: 24),
                    _buildRxResultSection(),
                  ],
                ],
              ),
            ),
          ),
          // Vertical divider
          Container(width: 1, color: AppColors.divider),
          // Right: Stock Formulary List & Stock Alerts
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStockAlertsCard(),
                  const SizedBox(height: 24),
                  Expanded(
                    child: Card(
                      margin: EdgeInsets.zero,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Text('Formulary Inventory', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
                                const SizedBox(width: 24),
                                Expanded(
                                  child: TextField(
                                    controller: _searchController,
                                    decoration: const InputDecoration(
                                      hintText: 'Search medicine formulary list...',
                                      prefixIcon: Icon(Icons.search_rounded),
                                    ),
                                    onChanged: (_) => setState(() {}),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Divider(height: 1),
                          Expanded(
                            child: filteredInventory.isEmpty
                                ? Center(child: Text('No formulary matches found.', style: GoogleFonts.inter(color: AppColors.textSecondary)))
                                : ListView.separated(
                                    itemCount: filteredInventory.length,
                                    separatorBuilder: (context, index) => const Divider(height: 1),
                                    itemBuilder: (context, index) {
                                      final item = filteredInventory[index];
                                      final bool isLow = (item['stock'] as int) < (item['min'] as int);
                                      return ListTile(
                                        title: Text(item['name'], style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14)),
                                        subtitle: Text('${item['generic']} • ${item['category']}', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
                                        trailing: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              'Stock: ${item['stock']}',
                                              style: GoogleFonts.inter(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
                                                color: isLow ? AppColors.danger : AppColors.textPrimary,
                                              ),
                                            ),
                                            Text(
                                              item['price'],
                                              style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 11),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRxLookupCard() {
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
            'Lookup E-Prescription ID',
            style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _rxController,
                  decoration: const InputDecoration(
                    labelText: 'Prescription Code',
                    hintText: 'e.g., RX-9921',
                    prefixIcon: Icon(Icons.receipt_rounded),
                  ),
                  onSubmitted: (_) => _searchRx(),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: _searchRx,
                icon: const Icon(Icons.search_rounded),
                label: const Text('Retrieve RX'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Try searching "RX-9921" (Rahim Islam) or "RX-1024" (Jahanara Begum)',
            style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  Widget _buildRxResultSection() {
    if (_loadedPrescription == null) {
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
              const Icon(Icons.receipt_long_rounded, size: 48, color: AppColors.textMuted),
              const SizedBox(height: 16),
              Text(
                'Prescription Record Not Found',
                style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Verify the RX number and search again.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    final rx = _loadedPrescription!;
    final items = rx['items'] as List;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
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
                const Icon(Icons.check_circle_outline, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Valid Prescription E-Signed',
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Patient: ${rx['patient']}', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold)),
                    Text('Code: ${rx['id']}', style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 13)),
                  ],
                ),
                Text('Prescribed by: ${rx['doctor']} on ${rx['date']}', style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 12)),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 12),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: items.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 2),
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(6)),
                          child: const Icon(Icons.medication_rounded, color: AppColors.primary, size: 16),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item['medicine'], style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14)),
                              Text(item['instruction'], style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 12)),
                            ],
                          ),
                        ),
                        Text(
                          'Qty: ${item['qty']}',
                          style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _dispensePrescription,
                    icon: const Icon(Icons.done_all_rounded),
                    label: const Text('Dispense Medications'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStockAlertsCard() {
    final lowStockItems = _inventory.where((i) => (i['stock'] as int) < (i['min'] as int)).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: AppColors.danger, size: 22),
              const SizedBox(width: 8),
              Text('Inventory Stock Warnings', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          lowStockItems.isEmpty
              ? Text('All medication inventory levels are normal.', style: GoogleFonts.inter(color: AppColors.success, fontSize: 13))
              : Column(
                  children: lowStockItems.map((item) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.dangerLight.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.danger.withOpacity(0.15)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(item['name'], style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.danger)),
                          Text(
                            'Stock: ${item['stock']} (Min: ${item['min']})',
                            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.danger),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
        ],
      ),
    );
  }
}
