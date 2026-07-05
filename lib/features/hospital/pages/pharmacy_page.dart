import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/language_provider.dart';
import '../data/models/pharmacy_item.dart';
import '../data/repositories/hospital_repository.dart';
import '../presentation/providers/hospital_providers.dart';

class PharmacyPage extends ConsumerStatefulWidget {
  const PharmacyPage({super.key});

  @override
  ConsumerState<PharmacyPage> createState() => _PharmacyPageState();
}

class _PharmacyPageState extends ConsumerState<PharmacyPage> {
  final TextEditingController _rxController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategoryFilter = 'All';

  Map<String, dynamic>? _loadedPrescription;
  bool _rxSearched = false;

  void _searchRx() async {
    final query = _rxController.text.trim();
    final repo = ref.read(hospitalRepositoryProvider);
    final rx = await repo.getPrescriptionById(query);

    setState(() {
      _rxSearched = true;
      _loadedPrescription = rx;
    });
  }

  void _dispensePrescription() async {
    final tr = ref.read(translationsProvider);
    if (_loadedPrescription != null) {
      final String rxId = _loadedPrescription!['id'] ?? '';
      final success = await ref.read(pharmacyInventoryProvider.notifier).dispensePrescription(rxId);

      if (success) {
        setState(() {
          _loadedPrescription = null;
          _rxSearched = false;
          _rxController.clear();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(tr('hospital_pharm_dispense_success')),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(tr('hospital_pharm_stock_out_warning'), style: GoogleFonts.outfit(color: AppColors.danger, fontWeight: FontWeight.bold)),
            content: Text(tr('hospital_pharm_insufficient_stock')),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: Text(tr('hospital_pharm_dismiss'))),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tr = ref.watch(translationsProvider);
    final inventoryList = ref.watch(pharmacyInventoryProvider);
    final query = _searchController.text.toLowerCase();
    
    final filteredInventory = inventoryList.where((item) {
      final matchesQuery = item.name.toLowerCase().contains(query) || item.generic.toLowerCase().contains(query);
      final matchesCategory = _selectedCategoryFilter == 'All' || item.category == _selectedCategoryFilter;
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
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          tr('hospital_pharm_dispensing_counter'),
                          style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
                        tooltip: tr('hospital_pharm_reload'),
                        onPressed: () {
                          ref.invalidate(pharmacyInventoryProvider);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(tr('hospital_pharm_reloaded')), duration: const Duration(seconds: 1)),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    tr('hospital_pharm_dispensing_subtitle'),
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
                  _buildStockAlertsCard(inventoryList),
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
                                Text(tr('hospital_pharm_formulary_inventory'), style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
                                const SizedBox(width: 24),
                                Expanded(
                                  child: TextField(
                                    controller: _searchController,
                                    decoration: InputDecoration(
                                      hintText: tr('hospital_pharm_search_formulary_hint'),
                                      prefixIcon: const Icon(Icons.search_rounded),
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
                                ? Center(child: Text(tr('hospital_pharm_no_matches'), style: GoogleFonts.inter(color: AppColors.textSecondary)))
                                : ListView.separated(
                                    itemCount: filteredInventory.length,
                                    separatorBuilder: (context, index) => const Divider(height: 1),
                                    itemBuilder: (context, index) {
                                      final item = filteredInventory[index];
                                      final bool isLow = item.stock < item.min;
                                      return ListTile(
                                        title: Text(item.name, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14)),
                                        subtitle: Text('${item.generic} • ${item.category}', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
                                        trailing: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              '${tr('hospital_pharm_stock')}: ${item.stock}',
                                              style: GoogleFonts.inter(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
                                                color: isLow ? AppColors.danger : AppColors.textPrimary,
                                              ),
                                            ),
                                            Text(
                                              item.price,
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
    final tr = ref.watch(translationsProvider);
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
            tr('hospital_pharm_lookup_eprescription'),
            style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _rxController,
                  decoration: InputDecoration(
                    labelText: tr('hospital_pharm_prescription_code'),
                    hintText: 'e.g., RX-9921',
                    prefixIcon: const Icon(Icons.receipt_rounded),
                  ),
                  onSubmitted: (_) => _searchRx(),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: _searchRx,
                icon: const Icon(Icons.search_rounded),
                label: Text(tr('hospital_pharm_retrieve_rx')),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            tr('hospital_pharm_try_searching'),
            style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  Widget _buildRxResultSection() {
    final tr = ref.watch(translationsProvider);
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
                tr('hospital_pharm_record_not_found'),
                style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                tr('hospital_pharm_verify_rx'),
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
                  tr('hospital_pharm_valid_esigned'),
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
                    Text('${tr('hospital_pharm_patient')}: ${rx['patient']}', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold)),
                    Text('${tr('hospital_pharm_code')}: ${rx['id']}', style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 13)),
                  ],
                ),
                Text('${tr('hospital_pharm_prescribed_by')}: ${rx['doctor']} ${tr('hospital_pharm_on')} ${rx['date']}', style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 12)),
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
                          '${tr('hospital_pharm_qty')}: ${item['qty']}',
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
                    label: Text(tr('hospital_pharm_dispense_medications')),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStockAlertsCard(List<PharmacyItem> inventoryList) {
    final tr = ref.watch(translationsProvider);
    final lowStockItems = inventoryList.where((i) => i.stock < i.min).toList();

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
              Text(tr('hospital_pharm_stock_warnings'), style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          lowStockItems.isEmpty
              ? Text(tr('hospital_pharm_levels_normal'), style: GoogleFonts.inter(color: AppColors.success, fontSize: 13))
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
                          Text(item.name, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.danger)),
                          Text(
                            '${tr('hospital_pharm_stock')}: ${item.stock} (${tr('hospital_pharm_min')}: ${item.min})',
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

  @override
  void dispose() {
    _rxController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}
