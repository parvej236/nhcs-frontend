import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_primitives.dart';
import '../../../core/providers/dio_provider.dart';
import '../../../core/network/api_endpoints.dart';

class BloodRequestDialog extends ConsumerStatefulWidget {
  const BloodRequestDialog({super.key});

  @override
  ConsumerState<BloodRequestDialog> createState() => _BloodRequestDialogState();
}

class _BloodRequestDialogState extends ConsumerState<BloodRequestDialog> {
  final _nameController = TextEditingController();
  final _historyController = TextEditingController();
  final _timelineController = TextEditingController(text: 'Within 3 hours');
  
  String _selectedBloodGroup = 'O+';
  String _selectedUrgency = 'High';
  String? _selectedHospitalName;

  List<dynamic> _hospitals = [];
  bool _isLoadingHospitals = true;
  bool _isSubmitting = false;
  bool _isSuccess = false;

  final List<String> _bloodGroups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
  final List<String> _urgencies = ['High', 'Medium', 'Low'];

  @override
  void initState() {
    super.initState();
    _fetchHospitals();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _historyController.dispose();
    _timelineController.dispose();
    super.dispose();
  }

  Future<void> _fetchHospitals() async {
    try {
      final dio = ref.read(dioProvider);
      final res = await dio.get(ApiEndpoints.publicHospitals);
      if (res.data is List) {
        final list = List<dynamic>.from(res.data as List);
        bool hasDMC = list.any((h) => h['name'] == 'Dhaka Medical College Hospital');
        if (!hasDMC) {
          list.insert(0, {
            'name': 'Dhaka Medical College Hospital',
            'facilityId': 'FAC-1001',
          });
        }
        setState(() {
          _hospitals = list;
          _selectedHospitalName = 'Dhaka Medical College Hospital';
          _isLoadingHospitals = false;
        });
        return;
      }
    } catch (e) {
      // Handled by fallback below
    }
    setState(() {
      _hospitals = [
        {'name': 'Dhaka Medical College Hospital', 'facilityId': 'FAC-1001'},
        {'name': 'Ibn Sina Medical College', 'facilityId': 'FAC-1005'},
        {'name': 'Labaid Specialized Hospital', 'facilityId': 'FAC-1006'},
        {'name': 'United Hospital', 'facilityId': 'FAC-1007'},
      ];
      _selectedHospitalName = 'Dhaka Medical College Hospital';
      _isLoadingHospitals = false;
    });
  }

  Future<void> _submitRequest() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter patient name')),
      );
      return;
    }
    if (_selectedHospitalName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a hospital')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final dio = ref.read(dioProvider);
      await dio.post(ApiEndpoints.publicBloodRequests, data: {
        'patientName': _nameController.text.trim(),
        'bloodGroup': _selectedBloodGroup,
        'hospital': _selectedHospitalName,
        'previousDiseaseHistory': _historyController.text.trim(),
        'urgency': _selectedUrgency,
        'timeline': _timelineController.text.trim(),
      });

      setState(() {
        _isSubmitting = false;
        _isSuccess = true;
      });
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Submission failed: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppColors.of(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 540),
        child: Container(
          decoration: BoxDecoration(
            color: t.bgCard,
            borderRadius: BorderRadius.circular(AppColors.radius),
            border: Border.all(color: t.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 20,
                offset: const Offset(0, 10),
              )
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppColors.radius),
            child: _isSuccess ? _buildSuccessView(t) : _buildFormView(t),
          ),
        ),
      ),
    );
  }

  Widget _buildFormView(AppColorTokens t) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: t.border)),
            gradient: LinearGradient(
              colors: [t.brandPrimary.withOpacity(0.1), Colors.transparent],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: t.danger.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.bloodtype, color: t.danger, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Emergency Blood Request',
                      style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: t.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'This request will be sent to the selected hospital & matching active donors.',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: t.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, color: t.textSecondary),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),

        // Scrollable Form
        Flexible(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppInput(
                  label: "Patient's Full Name",
                  hint: "Enter patient's name",
                  controller: _nameController,
                ),
                const SizedBox(height: 20),
                
                Row(
                  children: [
                    Expanded(
                      child: AppSelect<String>(
                        label: 'Required Blood Group',
                        value: _selectedBloodGroup,
                        options: _bloodGroups.map((bg) => AppSelectOption(value: bg, label: bg)).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _selectedBloodGroup = val);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: AppSelect<String>(
                        label: 'Urgency Level',
                        value: _selectedUrgency,
                        options: _urgencies.map((u) => AppSelectOption(value: u, label: u)).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _selectedUrgency = val);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                if (_isLoadingHospitals)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                else
                  AppSelect<String>(
                    label: 'Target Hospital',
                    value: _selectedHospitalName,
                    options: _hospitals
                        .map((h) => AppSelectOption<String>(
                              value: h['name'] as String,
                              label: h['name'] as String,
                            ))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedHospitalName = val);
                      }
                    },
                  ),
                const SizedBox(height: 20),

                AppInput(
                  label: 'Required Timeline',
                  hint: 'e.g. Within 3 hours, By tomorrow morning',
                  controller: _timelineController,
                ),
                const SizedBox(height: 20),

                AppInput(
                  label: 'Patient Disease History (Optional)',
                  hint: 'e.g. Hypertension, Diabetic (helps donors prepare)',
                  controller: _historyController,
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),

        // Actions
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: t.border)),
            color: t.bgCard,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              AppButton(
                label: 'Cancel',
                variant: AppButtonVariant.secondary,
                onPressed: _isSubmitting ? null : () => Navigator.pop(context),
              ),
              const SizedBox(width: 16),
              AppButton(
                label: _isSubmitting ? 'Submitting...' : 'Submit Request',
                variant: AppButtonVariant.primary,
                onPressed: _isSubmitting ? null : _submitRequest,
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildSuccessView(AppColorTokens t) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: t.success.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check_circle_rounded, color: t.success, size: 64),
          ),
          const SizedBox(height: 24),
          Text(
            'Emergency Request Posted!',
            style: GoogleFonts.outfit(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: t.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'The request has been routed to the Hospital Manager and active matching donors have been notified.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: t.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          AppButton(
            label: 'Got it',
            variant: AppButtonVariant.primary,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
