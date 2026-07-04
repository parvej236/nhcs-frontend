import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_primitives.dart';
import '../data/models/appointment.dart';
import '../presentation/providers/booking_provider.dart';
import '../presentation/providers/patient_providers.dart';
import '../presentation/providers/ai_suggestion_provider.dart';
import '../data/models/ai_suggestion.dart';

class AppointmentsPage extends ConsumerStatefulWidget {
  const AppointmentsPage({super.key});

  @override
  ConsumerState<AppointmentsPage> createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends ConsumerState<AppointmentsPage> {
  String _activeTab = 'Upcoming';
  String _searchQuery = '';
  String _specializationFilter = 'All Specializations';
  final TextEditingController _symptomController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _symptomController.text = 'গত কয়েক ঘণ্টা ধরে বুকের মাঝখানে তীব্র চাপ ও ভারী ভাব অনুভব করছি, যা আস্তে আস্তে বাম হাত এবং ঘাড়ে ছড়িয়ে যাচ্ছে। প্রচণ্ড ঘাম হচ্ছে এবং শ্বাস নিতে খুব কষ্ট হচ্ছে। সেই সাথে প্রচণ্ড মাথা ঘোরা এবং বমি বমি ভাব আছে। পালস রেট অনেক বেশি (Pulse 110 bpm), রক্তচাপ BP 165/100 এবং শরীরে অক্সিজেনের মাত্রা SpO2 92% দেখাচ্ছে।';
  }

  @override
  void dispose() {
    _symptomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AiSuggestionState>(aiSuggestionProvider, (previous, next) {
      if (next.speechText != previous?.speechText && _symptomController.text != next.speechText) {
        _symptomController.text = next.speechText;
      }
    });

    final appointmentsState = ref.watch(patientAppointmentsProvider);
    final bookingState = ref.watch(bookingProvider);
    final t = AppColors.of(context);

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
                  'Appointments Portal',
                  style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: t.textPrimary),
                ),
                const Spacer(),
                AppButton(
                  onPressed: () => _openBookingDialog(null),
                  icon: Icons.add_rounded,
                  label: 'Book New',
                  variant: AppButtonVariant.primary,
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tab selector
                  Row(
                    children: [
                      _tab(context, 'Upcoming'),
                      const SizedBox(width: 8),
                      _tab(context, 'Past'),
                      const SizedBox(width: 8),
                      _tab(context, 'Cancelled'),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Appointment listing based on selected tab
                  appointmentsState.when(
                    loading: () => Center(child: CircularProgressIndicator(color: t.brandPrimary)),
                    error: (err, stack) => Center(
                      child: Text('Error loading appointments: $err', style: TextStyle(color: t.textSecondary)),
                    ),
                    data: (appointments) {
                      final filtered = appointments.where((a) => a.status == _activeTab).toList();
                      if (filtered.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 40),
                            child: Column(
                              children: [
                                Icon(Icons.calendar_today_rounded, size: 40, color: t.textSecondary.withValues(alpha: 0.5)),
                                const SizedBox(height: 12),
                                Text(
                                  'No $_activeTab appointments found.',
                                  style: GoogleFonts.inter(color: t.textSecondary),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filtered.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final app = filtered[index];
                          return _buildAppointmentCard(context, app);
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 48),

                  _buildAiSmartBookingAssistant(context),
                  const SizedBox(height: 48),

                  // Find Doctor Section
                  Text(
                    'Find a Medical Specialist',
                    style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w600, color: t.textPrimary),
                  ),
                  const SizedBox(height: 16),
                  _buildDoctorFilters(context),
                  const SizedBox(height: 24),
                  
                  // Doctor list
                  if (bookingState.isLoading && bookingState.availableDoctors.isEmpty)
                    Center(child: CircularProgressIndicator(color: t.brandPrimary))
                  else
                    _buildDoctorList(context, bookingState.availableDoctors),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tab(BuildContext context, String label) {
    final t = AppColors.of(context);
    final active = _activeTab == label;
    return InkWell(
      onTap: () => setState(() => _activeTab = label),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: active ? t.brandPrimary : t.bgCard,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: active ? t.brandPrimary : t.border),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            color: active ? Colors.white : t.textSecondary,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildAppointmentCard(BuildContext context, Appointment app) {
    final t = AppColors.of(context);
    final dateStr = "${app.date.day} ${_getMonthName(app.date.month)} ${app.date.year}";
    final statusColor = _getStatusColor(context, app.status);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: t.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: t.border),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: t.brandPrimary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.person_rounded, color: t.brandPrimary, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  app.doctor.name,
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 16, color: t.textPrimary),
                ),
                Text(
                  app.doctor.specialization,
                  style: GoogleFonts.inter(color: t.brandSecondary, fontSize: 13, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.access_time_rounded, size: 14, color: t.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      '$dateStr, ${app.timeSlot}',
                      style: GoogleFonts.inter(color: t.textSecondary, fontSize: 13),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.location_on_outlined, size: 14, color: t.textSecondary),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        app.hospital,
                        style: GoogleFonts.inter(color: t.textSecondary.withValues(alpha: 0.7), fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (app.status == 'Upcoming') ...[
                if (app.approvalStatus == 'PENDING')
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: t.warning.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
                    child: Text(
                      'Pending Approval',
                      style: GoogleFonts.inter(color: t.warning, fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  )
                else if (app.approvalStatus == 'REJECTED')
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: t.danger.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
                    child: Text(
                      'Rejected',
                      style: GoogleFonts.inter(color: t.danger, fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  )
                else ...[
                  if (app.arrivalStatus == 'CHECKED_IN')
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: t.success.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
                      child: Text(
                        'Checked In',
                        style: GoogleFonts.inter(color: t.success, fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    )
                  else if (app.arrivalStatus == 'COMPLETED')
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: t.textSecondary.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
                      child: Text(
                        'Completed',
                        style: GoogleFonts.inter(color: t.textSecondary, fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: t.brandSecondary.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
                      child: Text(
                        'Approved',
                        style: GoogleFonts.inter(color: t.brandSecondary, fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ),
                ]
              ] else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
                  child: Text(
                    app.status,
                    style: GoogleFonts.inter(color: statusColor, fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ),
              const SizedBox(height: 8),
              Text(
                'Queue: ${app.queueNumber}',
                style: GoogleFonts.inter(color: t.textSecondary, fontSize: 12, fontWeight: FontWeight.w500),
              ),
              if (app.status == 'Upcoming' && app.approvalStatus == 'PENDING') ...[
                const SizedBox(height: 4),
                TextButton(
                  onPressed: () => _confirmCancel(context, app.id),
                  child: Text('Cancel', style: GoogleFonts.inter(color: t.danger, fontSize: 12)),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorFilters(BuildContext context) {
    final t = AppColors.of(context);
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: TextField(
            style: GoogleFonts.inter(color: t.textPrimary, fontSize: 14),
            onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
            decoration: InputDecoration(
              hintText: 'Search by doctor name or specialization...',
              hintStyle: GoogleFonts.inter(color: t.textSecondary, fontSize: 14),
              prefixIcon: Icon(Icons.search_rounded, color: t.textSecondary),
              filled: true,
              fillColor: t.bgCard,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: t.border)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: t.border)),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            height: 50,
            decoration: BoxDecoration(
              color: t.bgCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: t.border),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _specializationFilter,
                dropdownColor: t.bgCard,
                icon: Icon(Icons.arrow_drop_down, color: t.textSecondary),
                style: GoogleFonts.inter(fontSize: 14, color: t.textPrimary),
                items: ['All Specializations', 'Cardiology', 'Endocrinology', 'General Medicine', 'Gynaecology & Obstetrics']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (val) => setState(() => _specializationFilter = val ?? 'All Specializations'),
                isExpanded: true,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDoctorList(BuildContext context, List<DoctorSpecialist> doctors) {
    final t = AppColors.of(context);
    final filtered = doctors.where((doc) {
      final matchesSearch = doc.name.toLowerCase().contains(_searchQuery) ||
          doc.specialization.toLowerCase().contains(_searchQuery);
      final matchesSpecialization = _specializationFilter == 'All Specializations' ||
          doc.specialization.contains(_specializationFilter.split(' ').first);
      return matchesSearch && matchesSpecialization;
    }).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Text(
            'No doctors match your search filters.',
            style: GoogleFonts.inter(color: t.textSecondary),
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filtered.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final doc = filtered[index];
        return _buildDoctorCard(context, doc);
      },
    );
  }

  Widget _buildDoctorCard(BuildContext context, DoctorSpecialist doc) {
    final t = AppColors.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: t.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: t.border),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [t.brandSecondary, t.brandPrimary]),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.medical_services_rounded, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doc.name,
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15, color: t.textPrimary),
                ),
                Text(
                  '${doc.specialization} • ${doc.hospital}',
                  style: GoogleFonts.inter(color: t.brandSecondary, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '${doc.experienceYears} years exp.',
                      style: GoogleFonts.inter(color: t.textSecondary, fontSize: 12),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.star_rounded, size: 14, color: Colors.amber),
                    Text(
                      ' ${doc.rating}',
                      style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: t.textPrimary),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '৳${doc.consultationFee}',
                style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: t.brandPrimary),
              ),
              const SizedBox(height: 8),
              AppButton(
                label: 'Book Slot',
                onPressed: () => _openBookingDialog(doc),
                variant: AppButtonVariant.primary,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                fontSize: 13,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmCancel(BuildContext context, String appointmentId) {
    final t = AppColors.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: t.bgCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: t.border),
        ),
        title: Text(
          'Cancel Appointment',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: t.textPrimary),
        ),
        content: Text(
          'Are you sure you want to cancel this appointment? This action cannot be undone.',
          style: GoogleFonts.inter(color: t.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('No, Keep', style: TextStyle(color: t.textSecondary)),
          ),
          AppButton(
            onPressed: () {
              ref.read(patientAppointmentsProvider.notifier).cancelAppointment(appointmentId);
              Navigator.pop(context);
            },
            label: 'Yes, Cancel',
            variant: AppButtonVariant.danger,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
        ],
      ),
    );
  }

  void _openBookingDialog(DoctorSpecialist? doctor) {
    ref.read(bookingProvider.notifier).reset();
    if (doctor != null) {
      ref.read(bookingProvider.notifier).selectDoctor(doctor);
    }
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const _BookingWizardDialog(),
    );
  }

  Color _getStatusColor(BuildContext context, String status) {
    final t = AppColors.of(context);
    switch (status) {
      case 'Upcoming':
        return t.brandPrimary;
      case 'Past':
        return t.success;
      case 'Cancelled':
        return t.danger;
      default:
        return t.textSecondary;
    }
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    if (month >= 1 && month <= 12) {
      return months[month - 1];
    }
    return '';
  }

  Widget _buildAiSmartBookingAssistant(BuildContext context) {
    final aiState = ref.watch(aiSuggestionProvider);
    final t = AppColors.of(context);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: t.bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: t.brandPrimary.withValues(alpha: 0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: t.isDark ? 0.2 : 0.04),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Badge & Title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [const Color(0xFF8B5CF6), t.brandPrimary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.auto_awesome, color: Colors.white, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      'AI Smart Booking',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'AI-Powered Appointment Assistant',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: t.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Describe your medical symptoms in Bangla or English, or use voice input. The AI will analyze your condition, summarize your symptoms, recommend the proper specialist, and locate the nearest hospitals and doctors.',
            style: GoogleFonts.inter(
              color: t.textSecondary,
              fontSize: 13.5,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),

          // Search Field & Speech Controls
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextField(
                  controller: _symptomController,
                  maxLines: 3,
                  style: GoogleFonts.inter(fontSize: 14, color: t.textPrimary),
                  decoration: InputDecoration(
                    hintText: aiState.isListening
                        ? 'আমি শুনছি, বলুন... (উদা: আমার মাথা ব্যাথ ও বমি বমি ভাব)'
                        : 'আপনার সমস্যাটি বিস্তারিত লিখুন বা বলুন (উদা: কয়েক দিন ধরে বুকে ব্যথা ও শ্বাসকষ্ট)...',
                    hintStyle: GoogleFonts.inter(color: t.textSecondary, fontSize: 13.5),
                    fillColor: t.bgInput,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: t.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: t.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: t.brandPrimary, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                  onChanged: (val) {
                    ref.read(aiSuggestionProvider.notifier).updateSpeechText(val);
                  },
                ),
              ),
              const SizedBox(width: 16),
              Column(
                children: [
                  // Speech recognition button
                  Tooltip(
                    message: aiState.isListening ? 'Stop Listening' : 'Speak in Bangla',
                    child: InkWell(
                      onTap: () {
                        if (aiState.isListening) {
                          ref.read(aiSuggestionProvider.notifier).stopListening();
                        } else {
                          ref.read(aiSuggestionProvider.notifier).startListening();
                        }
                      },
                      borderRadius: BorderRadius.circular(50),
                      child: Container(
                        height: 56,
                        width: 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: aiState.isListening
                              ? t.danger.withValues(alpha: 0.12)
                              : t.brandPrimary.withValues(alpha: 0.12),
                          border: Border.all(
                            color: aiState.isListening ? t.danger : t.brandPrimary,
                            width: 1.5,
                          ),
                        ),
                        child: Icon(
                          aiState.isListening ? Icons.mic_off_rounded : Icons.mic_rounded,
                          color: aiState.isListening ? t.danger : t.brandPrimary,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Clear button
                  TextButton(
                    onPressed: () {
                      _symptomController.clear();
                      ref.read(aiSuggestionProvider.notifier).reset();
                    },
                    child: Text(
                      'Clear',
                      style: GoogleFonts.inter(
                        color: t.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          if (aiState.isListening) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(t.danger),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Listening... Speak in Bangla (বাংলায় বলুন)',
                  style: GoogleFonts.inter(
                    color: t.danger,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 16),

          // Primary Submit Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: aiState.isLoading || aiState.speechText.trim().isEmpty || aiState.isListening
                  ? null
                  : () {
                      ref.read(aiSuggestionProvider.notifier).getSuggestion(_symptomController.text);
                    },
              icon: aiState.isLoading
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.auto_awesome, size: 18),
              label: Text(
                aiState.isLoading ? 'AI Analyzing Symptoms...' : 'Analyze Symptoms with AI',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: t.brandPrimary,
                disabledBackgroundColor: t.bgInput,
                foregroundColor: Colors.white,
                disabledForegroundColor: t.textSecondary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),

          if (aiState.errorMessage != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: t.danger.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: t.danger, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      aiState.errorMessage!,
                      style: GoogleFonts.inter(color: t.danger, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // AI Suggestion Result Display
          if (aiState.suggestion != null) ...[
            const SizedBox(height: 24),
            Divider(color: t.border),
            const SizedBox(height: 16),
            _buildAiResultsSection(context, aiState.suggestion!),
          ],
        ],
      ),
    );
  }

  Widget _buildAiResultsSection(BuildContext context, AiSuggestionResponse suggestion) {
    final t = AppColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // AI Health Summary
        Row(
          children: [
            Icon(Icons.description_outlined, color: t.brandPrimary, size: 20),
            const SizedBox(width: 8),
            Text(
              'AI Health Summary (স্বাস্থ্য সারসংক্ষেপ):',
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: t.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: t.brandPrimary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: t.brandPrimary.withValues(alpha: 0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'English Summary:',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: t.brandPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                suggestion.summaryEn,
                style: GoogleFonts.inter(
                  fontSize: 13.5,
                  color: t.textPrimary,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'বাংলা সারসংক্ষেপ:',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: t.brandPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                suggestion.summaryBn,
                style: GoogleFonts.inter(
                  fontSize: 13.5,
                  color: t.textPrimary,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Estimated Specialization
        Row(
          children: [
            Icon(Icons.category_outlined, color: t.brandPrimary, size: 20),
            const SizedBox(width: 8),
            Text(
              'Recommended Specialization:',
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: t.textPrimary,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: t.brandPrimary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                suggestion.specialization,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Suggested Hospitals (Proximity Aware)
        Row(
          children: [
            Icon(Icons.location_on_rounded, color: t.brandPrimary, size: 20),
            const SizedBox(width: 8),
            Text(
              'Nearby Matching Hospitals:',
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: t.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: suggestion.suggestedHospitals.length,
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final hospital = suggestion.suggestedHospitals[index];
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: t.bgInput,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: t.border),
              ),
              child: Row(
                children: [
                  Icon(Icons.local_hospital_rounded, color: t.brandPrimary, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hospital.name,
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                            fontSize: 13.5,
                            color: t.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          hospital.address,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: t.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: t.brandPrimary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      hospital.distance,
                      style: GoogleFonts.inter(
                        color: t.brandPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),

        const SizedBox(height: 24),

        // Recommended Doctors
        Row(
          children: [
            Icon(Icons.people_outline_rounded, color: t.brandPrimary, size: 20),
            const SizedBox(width: 8),
            Text(
              'Recommended Doctors:',
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: t.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (suggestion.suggestedDoctors.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Text(
              'No matching doctors found for this specialization.',
              style: GoogleFonts.inter(color: t.textSecondary, fontStyle: FontStyle.italic),
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 2.1,
            ),
            itemCount: suggestion.suggestedDoctors.length,
            itemBuilder: (context, index) {
              final doc = suggestion.suggestedDoctors[index];
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: t.bgCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: t.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: t.isDark ? 0.2 : 0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: t.brandPrimary.withValues(alpha: 0.1),
                      backgroundImage: doc.imageUrl.isNotEmpty ? NetworkImage(doc.imageUrl) : null,
                      child: doc.imageUrl.isEmpty
                          ? Icon(Icons.person, size: 28, color: t.brandPrimary)
                          : null,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            doc.name,
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: t.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            doc.specialization,
                            style: GoogleFonts.inter(
                              fontSize: 11.5,
                              color: t.brandPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            doc.hospital,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: t.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.star_rounded, color: Colors.orange, size: 14),
                              const SizedBox(width: 2),
                              Text(
                                doc.rating.toString(),
                                style: GoogleFonts.inter(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                  color: t.textPrimary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${doc.experienceYears} Yrs Exp',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: t.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '৳${doc.consultationFee}',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: t.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        AppButton(
                          label: 'Book Slot',
                          onPressed: () => _openBookingDialog(doc),
                          variant: AppButtonVariant.primary,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          fontSize: 11.5,
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }
}

class _BookingWizardDialog extends ConsumerStatefulWidget {
  const _BookingWizardDialog();

  @override
  ConsumerState<_BookingWizardDialog> createState() => _BookingWizardDialogState();
}

class _BookingWizardDialogState extends ConsumerState<_BookingWizardDialog> {
  int _step = 0;

  @override
  Widget build(BuildContext context) {
    final bookingState = ref.watch(bookingProvider);
    final isDoctorSelected = bookingState.selectedDoctor != null;
    final t = AppColors.of(context);

    if (isDoctorSelected && _step == 0) {
      _step = 1;
    }

    return Dialog(
      backgroundColor: t.bgCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: t.border),
      ),
      child: Container(
        width: 550,
        height: 520,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  bookingState.createdAppointment != null ? 'Booking Confirmed' : 'Book Appointment',
                  style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: t.textPrimary),
                ),
                const Spacer(),
                if (bookingState.createdAppointment == null)
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close_rounded, color: t.textSecondary),
                  ),
              ],
            ),
            Divider(color: t.border),
            Expanded(
              child: bookingState.createdAppointment != null
                  ? _buildSuccessView(context, bookingState.createdAppointment!)
                  : _buildStepContent(context, bookingState),
            ),
            if (bookingState.createdAppointment == null) ...[
              Divider(color: t.border),
              _buildActionsRow(context, bookingState),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStepContent(BuildContext context, BookingState state) {
    final t = AppColors.of(context);
    if (state.isLoading) {
      return Center(child: CircularProgressIndicator(color: t.brandPrimary));
    }

    switch (_step) {
      case 0:
        return _buildDoctorSelectorStep(context, state);
      case 1:
        return _buildDateTimeSelectorStep(context, state);
      case 2:
        return _buildConfirmationStep(context, state);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildDoctorSelectorStep(BuildContext context, BookingState state) {
    final t = AppColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text(
          'Select a Doctor to begin:',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14, color: t.textPrimary),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.separated(
            itemCount: state.availableDoctors.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final doc = state.availableDoctors[index];
              return ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: t.border),
                ),
                title: Text(doc.name, style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: t.textPrimary)),
                subtitle: Text('${doc.specialization} • ${doc.hospital}', style: TextStyle(color: t.textSecondary)),
                trailing: Icon(Icons.arrow_forward_ios_rounded, size: 14, color: t.textSecondary),
                onTap: () {
                  ref.read(bookingProvider.notifier).selectDoctor(doc);
                  setState(() => _step = 1);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDateTimeSelectorStep(BuildContext context, BookingState state) {
    final t = AppColors.of(context);
    final next7Days = List.generate(7, (i) => DateTime.now().add(Duration(days: i + 1)));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text('Select Date:', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14, color: t.textPrimary)),
        const SizedBox(height: 12),
        SizedBox(
          height: 64,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: next7Days.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final date = next7Days[index];
              final isSelected = state.selectedDate != null &&
                  state.selectedDate!.year == date.year &&
                  state.selectedDate!.month == date.month &&
                  state.selectedDate!.day == date.day;

              return InkWell(
                onTap: () => ref.read(bookingProvider.notifier).selectDate(date),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 64,
                  decoration: BoxDecoration(
                    color: isSelected ? t.brandPrimary : t.bgInput,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isSelected ? t.brandPrimary : t.border),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _getWeekdayName(date.weekday),
                        style: GoogleFonts.inter(
                          color: isSelected ? Colors.white70 : t.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        date.day.toString(),
                        style: GoogleFonts.inter(
                          color: isSelected ? Colors.white : t.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 24),
        Text('Select Time Slot:', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14, color: t.textPrimary)),
        const SizedBox(height: 12),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 2.2,
            ),
            itemCount: state.availableSlots.length,
            itemBuilder: (context, index) {
              final slot = state.availableSlots[index];
              final isSelected = state.selectedTimeSlot == slot.time;

              return InkWell(
                onTap: slot.isAvailable 
                    ? () => ref.read(bookingProvider.notifier).selectSlot(slot.time)
                    : null,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? t.brandSecondary 
                        : (slot.isAvailable ? t.bgInput : t.border.withValues(alpha: 0.15)),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected 
                          ? t.brandSecondary 
                          : (slot.isAvailable ? t.border : Colors.transparent),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    slot.time,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected 
                          ? Colors.white 
                          : (slot.isAvailable ? t.textPrimary : t.textSecondary.withValues(alpha: 0.6)),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmationStep(BuildContext context, BookingState state) {
    final t = AppColors.of(context);
    final doc = state.selectedDoctor!;
    final dateStr = state.selectedDate != null
        ? "${state.selectedDate!.day} ${_getMonthName(state.selectedDate!.month)} ${state.selectedDate!.year}"
        : "";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: t.brandPrimary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline_rounded, color: t.brandPrimary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Please review the details below before confirming the booking.',
                  style: GoogleFonts.inter(color: t.brandPrimary, fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _detailRow(context, 'Doctor', doc.name),
        _detailRow(context, 'Specialization', doc.specialization),
        _detailRow(context, 'Hospital', doc.hospital),
        _detailRow(context, 'Date', dateStr),
        _detailRow(context, 'Time Slot', state.selectedTimeSlot ?? ''),
        _detailRow(context, 'Consultation Fee', '৳${doc.consultationFee}', isBold: true),
      ],
    );
  }

  Widget _buildSuccessView(BuildContext context, Appointment app) {
    final t = AppColors.of(context);
    final dateStr = "${app.date.day} ${_getMonthName(app.date.month)} ${app.date.year}";
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: t.success.withValues(alpha: 0.15), shape: BoxShape.circle),
            child: Icon(Icons.check_circle_rounded, size: 56, color: t.success),
          ),
          const SizedBox(height: 20),
          Text(
            'Appointment Placed!',
            style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: t.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            'Your appointment with ${app.doctor.name} has been booked.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(color: t.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: t.bgInput, borderRadius: BorderRadius.circular(12)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _successStat(context, 'Queue', app.queueNumber),
                Container(width: 1, height: 32, color: t.border),
                _successStat(context, 'Time', app.timeSlot),
                Container(width: 1, height: 32, color: t.border),
                _successStat(context, 'Date', dateStr),
              ],
            ),
          ),
          const SizedBox(height: 24),
          AppButton(
            onPressed: () => Navigator.pop(context),
            label: 'Back to Dashboard',
            variant: AppButtonVariant.primary,
          ),
        ],
      ),
    );
  }

  Widget _successStat(BuildContext context, String label, String val) {
    final t = AppColors.of(context);
    return Column(
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 11, color: t.textSecondary)),
        const SizedBox(height: 4),
        Text(val, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: t.textPrimary)),
      ],
    );
  }

  Widget _detailRow(BuildContext context, String label, String value, {bool isBold = false}) {
    final t = AppColors.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.inter(color: t.textSecondary, fontSize: 14)),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              color: isBold ? t.brandPrimary : t.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsRow(BuildContext context, BookingState state) {
    final t = AppColors.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (_step > 0)
          AppButton(
            onPressed: () => setState(() => _step--),
            label: 'Back',
            variant: AppButtonVariant.secondary,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          )
        else
          const SizedBox.shrink(),
        Row(
          children: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: t.textSecondary)),
            ),
            const SizedBox(width: 12),
            if (_step < 2)
              AppButton(
                onPressed: (state.selectedDoctor != null && _step == 0) ||
                           (state.selectedDate != null && state.selectedTimeSlot != null && _step == 1)
                    ? () => setState(() => _step++)
                    : null,
                label: 'Next',
                variant: AppButtonVariant.primary,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              )
            else
              AppButton(
                onPressed: () async {
                  await ref.read(bookingProvider.notifier).confirmBooking('NUD-892-441-X7', ref);
                },
                label: 'Confirm Booking',
                variant: AppButtonVariant.primary,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
          ],
        ),
      ],
    );
  }

  String _getWeekdayName(int w) {
    const list = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    if (w >= 1 && w <= 7) return list[w - 1];
    return '';
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    if (month >= 1 && month <= 12) {
      return months[month - 1];
    }
    return '';
  }
}
