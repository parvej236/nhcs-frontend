import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_primitives.dart';
import '../../../core/providers/dio_provider.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/providers/language_provider.dart';

class BloodDonationManagementPage extends ConsumerStatefulWidget {
  const BloodDonationManagementPage({super.key});

  @override
  ConsumerState<BloodDonationManagementPage> createState() => _BloodDonationManagementPageState();
}

class _BloodDonationManagementPageState extends ConsumerState<BloodDonationManagementPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> _requests = [];
  bool _isLoadingRequests = true;

  // AI Matcher state
  dynamic _selectedRequestForMatching;
  List<dynamic> _matchedDonors = [];
  bool _isLoadingMatches = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchRequests();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchRequests() async {
    setState(() => _isLoadingRequests = true);
    try {
      final dio = ref.read(dioProvider);
      final res = await dio.get(ApiEndpoints.hospitalBloodRequests);
      if (res.data is List) {
        setState(() {
          _requests = res.data as List;
          _isLoadingRequests = false;
        });
      }
    } catch (e) {
      setState(() => _isLoadingRequests = false);
    }
  }

  Future<void> _runAiMatcher(dynamic request) async {
    setState(() {
      _selectedRequestForMatching = request;
      _isLoadingMatches = true;
      _matchedDonors = [];
    });

    try {
      final dio = ref.read(dioProvider);
      final id = request['id'].toString();
      final res = await dio.get(ApiEndpoints.hospitalBloodMatches(id));
      if (res.data is List) {
        setState(() {
          _matchedDonors = res.data as List;
          _isLoadingMatches = false;
        });
      }
    } catch (e) {
      setState(() => _isLoadingMatches = false);
    }
  }

  Future<void> _notifyDonor(dynamic donor) async {
    if (_selectedRequestForMatching == null) return;
    final tr = ref.read(translationsProvider);
    try {
      final dio = ref.read(dioProvider);
      final reqId = _selectedRequestForMatching['id'].toString();
      await dio.post(ApiEndpoints.hospitalBloodNotify(reqId));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Text('${tr('hospital_blood_notify_success')} ${donor['name']}!'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${tr('hospital_blood_notify_failed')}: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppColors.of(context);
    final tr = ref.watch(translationsProvider);

    // Filter pending and accepted requests
    final pendingRequests = _requests.where((r) => r['status'] == 'Pending').toList();
    final acceptedRequests = _requests.where((r) => r['status'] == 'Accepted' || r['status'] == 'Completed').toList();

    return Scaffold(
      backgroundColor: t.bgMain,
      body: Row(
        children: [
          // Left side: Main requests panel
          Expanded(
            flex: 6,
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(t),
                  const SizedBox(height: 24),
                  
                  // Tab selector
                  TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    labelColor: t.brandPrimary,
                    unselectedLabelColor: t.textSecondary,
                    indicatorColor: t.brandPrimary,
                    labelStyle: GoogleFonts.inter(fontWeight: FontWeight.bold),
                    tabs: [
                      Tab(text: '${tr('hospital_blood_tab_pending')} (${pendingRequests.length})'),
                      Tab(text: '${tr('hospital_blood_tab_accepted_closed')} (${acceptedRequests.length})'),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Expanded(
                    child: _isLoadingRequests
                        ? const Center(child: CircularProgressIndicator())
                        : TabBarView(
                            controller: _tabController,
                            children: [
                              _buildRequestsList(pendingRequests, true, t),
                              _buildRequestsList(acceptedRequests, false, t),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ),

          // Right side: AI Donor Matcher sidebar
          if (_selectedRequestForMatching != null)
            _buildAiMatcherSidebar(t),
        ],
      ),
    );
  }

  Widget _buildHeader(AppColorTokens t) {
    final tr = ref.watch(translationsProvider);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tr('hospital_blood_portal_title'),
              style: GoogleFonts.outfit(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: t.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              tr('hospital_blood_portal_subtitle'),
              style: GoogleFonts.inter(fontSize: 14, color: t.textSecondary),
            ),
          ],
        ),
        AppButton(
          label: tr('hospital_blood_refresh'),
          icon: Icons.refresh_rounded,
          variant: AppButtonVariant.secondary,
          onPressed: _fetchRequests,
        ),
      ],
    );
  }

  Widget _buildRequestsList(List<dynamic> list, bool isPending, AppColorTokens t) {
    final tr = ref.watch(translationsProvider);
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bloodtype_outlined, size: 64, color: t.textSecondary.withOpacity(0.3)),
            const SizedBox(height: 16),
            Text(
              isPending ? tr('hospital_blood_empty_pending') : tr('hospital_blood_empty_accepted'),
              style: GoogleFonts.inter(fontSize: 16, color: t.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (context, index) {
        final req = list[index];
        final isUrgent = req['urgency'] == 'High';
        
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Blood group bubble
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: t.danger.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: t.danger.withOpacity(0.3)),
                      ),
                      child: Text(
                        req['bloodGroup'] ?? 'O+',
                        style: GoogleFonts.outfit(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: t.danger,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Request Metadata
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                req['patientName'] ?? tr('hospital_blood_unknown_patient'),
                                style: GoogleFonts.inter(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: t.textPrimary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isUrgent ? t.danger.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  req['urgency'] ?? 'Medium',
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: isUrgent ? t.danger : Colors.orange,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 16,
                            runSpacing: 8,
                            children: [
                              _buildMetaRow(Icons.local_hospital_rounded, req['hospital'] ?? tr('hospital_blood_general_hospital'), t),
                              _buildMetaRow(Icons.location_on_rounded, req['location'] ?? tr('hospital_blood_unknown_location'), t),
                              _buildMetaRow(Icons.access_time_filled_rounded, req['timeline'] ?? 'Urgent', t),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Actions / Status indicators
                    if (isPending)
                      AppButton(
                        label: tr('hospital_blood_run_ai_matcher'),
                        icon: Icons.auto_awesome_rounded,
                        variant: AppButtonVariant.primary,
                        onPressed: () => _runAiMatcher(req),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: t.success.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: t.success.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_circle_rounded, color: t.success, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              tr('hospital_blood_accepted'),
                              style: GoogleFonts.inter(
                                color: t.success,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      )
                  ],
                ),

                // Expanded Section: Patient Disease History
                if (req['previousDiseaseHistory'] != null && req['previousDiseaseHistory'].toString().trim().isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: t.bgMain,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: t.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tr('hospital_blood_patient_medical_history'),
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: t.textSecondary,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          req['previousDiseaseHistory'],
                          style: GoogleFonts.inter(fontSize: 13, color: t.textPrimary),
                        ),
                      ],
                    ),
                  ),
                ],

                // Expanded Section: Accepted Donor Contact details
                if (!isPending && req['acceptedBy'] != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: t.success.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: t.success.withValues(alpha: 0.15)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.volunteer_activism_rounded, color: t.success, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              tr('hospital_blood_matched_donor_details'),
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: t.success,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    req['acceptedBy']['fullName'] ?? tr('hospital_blood_unknown_donor'),
                                    style: GoogleFonts.inter(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: t.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${tr('hospital_blood_blood_group_label')}: ${req['acceptedBy']['bloodGroup'] ?? 'O+'}  •  ${tr('hospital_blood_address_label')}: ${req['acceptedBy']['address'] ?? 'Dhanmondi, Dhaka'}',
                                    style: GoogleFonts.inter(fontSize: 13, color: t.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                            
                            // Contact number panel
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: t.bgCard,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: t.border),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.phone_rounded, color: t.brandPrimary, size: 16),
                                  const SizedBox(width: 8),
                                  SelectableText(
                                    req['acceptedBy']['contactNumber'] ?? tr('hospital_blood_no_contact'),
                                    style: GoogleFonts.outfit(
                                      color: t.brandPrimary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ]
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMetaRow(IconData icon, String text, AppColorTokens t) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: t.textSecondary),
        const SizedBox(width: 6),
        Text(
          text,
          style: GoogleFonts.inter(fontSize: 13, color: t.textSecondary),
        ),
      ],
    );
  }

  Widget _buildAiMatcherSidebar(AppColorTokens t) {
    final tr = ref.watch(translationsProvider);
    return Container(
      width: 440,
      decoration: BoxDecoration(
        color: t.bgCard,
        border: Border(left: BorderSide(color: t.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Sidebar Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: t.border)),
              gradient: LinearGradient(
                colors: [t.brandPrimary.withOpacity(0.05), Colors.transparent],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.auto_awesome_rounded, color: t.brandPrimary, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            tr('hospital_blood_ai_donor_matcher'),
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: t.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${tr('hospital_blood_searching_for')} ${_selectedRequestForMatching['patientName']}',
                        style: GoogleFonts.inter(fontSize: 12, color: t.textSecondary),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: t.textSecondary),
                  onPressed: () => setState(() => _selectedRequestForMatching = null),
                ),
              ],
            ),
          ),

          // Matches results list
          Expanded(
            child: _isLoadingMatches
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 16),
                        Text(tr('hospital_blood_analyzing')),
                      ],
                    ),
                  )
                : _matchedDonors.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.warning_rounded, size: 48, color: t.textSecondary.withOpacity(0.5)),
                              const SizedBox(height: 16),
                              Text(
                                tr('hospital_blood_no_matches'),
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(fontSize: 14, color: t.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(24),
                        itemCount: _matchedDonors.length,
                        itemBuilder: (context, index) {
                          final match = _matchedDonors[index];
                          final isEligible = match['isEligible'] as bool;
                          final matchScore = match['matchScore'] as int;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: t.bgMain,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isEligible 
                                  ? t.brandPrimary.withOpacity(0.15) 
                                  : t.border,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    // Donor info
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            match['name'] ?? tr('hospital_blood_unknown_donor'),
                                            style: GoogleFonts.inter(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: t.textPrimary,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: t.danger.withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  match['bloodGroup'] ?? 'O+',
                                                  style: GoogleFonts.inter(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold,
                                                    color: t.danger,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                '${tr('hospital_blood_distance')}: ${match['distance']} ${tr('hospital_blood_km')}',
                                                style: GoogleFonts.inter(
                                                  fontSize: 12,
                                                  color: t.textSecondary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    
                                    // Match Score Badge
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: isEligible 
                                          ? t.success.withValues(alpha: 0.1) 
                                          : t.textSecondary.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        '$matchScore% ${tr('hospital_blood_match')}',
                                        style: GoogleFonts.outfit(
                                          color: isEligible ? t.success : t.textSecondary,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 12,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                const SizedBox(height: 12),

                                // Proximity/Eligibility Description
                                Row(
                                  children: [
                                    Icon(
                                      isEligible ? Icons.check_circle : Icons.warning_amber_rounded,
                                      size: 14,
                                      color: isEligible ? t.success : Colors.orange,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        isEligible ? tr('hospital_blood_eligible_desc') : '${tr('hospital_blood_deferred')}: ${match['reason']}',
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          color: isEligible ? t.textSecondary : Colors.orange,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 16),
                                // Action button
                                SizedBox(
                                  width: double.infinity,
                                  child: AppButton(
                                    label: tr('hospital_blood_send_match_request'),
                                    icon: Icons.send_rounded,
                                    variant: isEligible 
                                      ? AppButtonVariant.primary 
                                      : AppButtonVariant.secondary,
                                    onPressed: isEligible 
                                      ? () => _notifyDonor(match) 
                                      : null,
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                  ),
                                )
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
