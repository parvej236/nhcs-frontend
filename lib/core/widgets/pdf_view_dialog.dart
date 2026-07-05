import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../../features/patient/data/models/medical_record.dart';

class PdfViewDialog extends StatelessWidget {
  final String title;
  final Widget content;
  final VoidCallback? onDownload;

  const PdfViewDialog({
    super.key,
    required this.title,
    required this.content,
    this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
      child: Center(
        child: Container(
          width: 800,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.9,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF1E222B), // Dark background mimicking PDF viewer
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 25,
                offset: const Offset(0, 10),
              )
            ],
          ),
          child: Column(
            children: [
              // PDF Viewer Top Toolbar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                decoration: const BoxDecoration(
                  color: Color(0xFF2C313C),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.picture_as_pdf_rounded, color: AppColors.danger, size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title,
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Simulated controls
                    IconButton(
                      icon: const Icon(Icons.zoom_out_rounded, color: Colors.white70, size: 18),
                      onPressed: () {},
                      tooltip: 'Zoom Out',
                    ),
                    Text(
                      '100%',
                      style: GoogleFonts.inter(color: Colors.white70, fontSize: 12),
                    ),
                    IconButton(
                      icon: const Icon(Icons.zoom_in_rounded, color: Colors.white70, size: 18),
                      onPressed: () {},
                      tooltip: 'Zoom In',
                    ),
                    const SizedBox(width: 8),
                    Container(width: 1, height: 20, color: Colors.white24),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.download_rounded, color: Colors.white, size: 20),
                      onPressed: onDownload ?? () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Document PDF download initiated.'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      },
                      tooltip: 'Download PDF',
                    ),
                    IconButton(
                      icon: const Icon(Icons.print_rounded, color: Colors.white, size: 20),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Simulated printing document...'),
                            backgroundColor: AppColors.primary,
                          ),
                        );
                      },
                      tooltip: 'Print',
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white70, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              // Page Mockup Canvas
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 40),
                  child: Center(
                    child: Container(
                      width: 700,
                      decoration: BoxDecoration(
                        color: Colors.white, // Page background
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          )
                        ],
                      ),
                      padding: const EdgeInsets.all(40),
                      child: content,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom widget to render the Prescription PDF layout
class PrescriptionPdfView extends StatelessWidget {
  final Prescription prescription;

  const PrescriptionPdfView({super.key, required this.prescription});

  @override
  Widget build(BuildContext context) {
    final dateStr = "${prescription.date.day}/${prescription.date.month}/${prescription.date.year}";
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Govt Banner
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'গণপ্রজাতন্ত্রী বাংলাদেশ সরকার',
                  style: GoogleFonts.hindSiliguri(
                    color: Colors.green[800],
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                Text(
                  'HEALTH SERVICES DIVISION (NHCS)',
                  style: GoogleFonts.outfit(
                    color: Colors.green[900],
                    fontWeight: FontWeight.w800,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.red[800]!, width: 1.5),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'GOVT DIGITAL PRESCRIPTION',
                style: GoogleFonts.inter(
                  color: Colors.red[800],
                  fontWeight: FontWeight.w800,
                  fontSize: 8,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Divider(thickness: 2, color: Colors.black87),
        const SizedBox(height: 12),

        // Doctor details
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    prescription.doctorName,
                    style: GoogleFonts.inter(
                      color: const Color(0xFF1E222B),
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    prescription.doctorSpecialization,
                    style: GoogleFonts.inter(
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    prescription.hospitalName,
                    style: GoogleFonts.inter(
                      color: Colors.black54,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Date: $dateStr',
                  style: GoogleFonts.inter(
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
                Text(
                  'ID: ${prescription.id}',
                  style: GoogleFonts.inter(
                    color: Colors.black54,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),
        const Divider(thickness: 1, color: Colors.black26),
        const SizedBox(height: 12),

        // Patient Details
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Patient: Laila Khan', // Reusable target patient
                style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 13),
              ),
              Text(
                'Age: 40  |  Gender: Female',
                style: GoogleFonts.inter(color: Colors.black87, fontSize: 12),
              ),
              Text(
                'Blood: O+',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.black87, fontSize: 12),
              ),
            ],
          ),
        ),

        const SizedBox(height: 30),

        // Rx Sign
        Text(
          '℞',
          style: GoogleFonts.outfit(
            fontSize: 36,
            fontWeight: FontWeight.w600,
            fontStyle: FontStyle.italic,
            color: const Color(0xFF1E222B),
          ),
        ),
        const SizedBox(height: 12),

        // Medicines Table
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black12),
            borderRadius: BorderRadius.circular(4),
          ),
          child: DataTable(
            headingRowHeight: 36,
            dataRowMaxHeight: 52,
            dataRowMinHeight: 40,
            headingTextStyle: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black87),
            dataTextStyle: GoogleFonts.inter(fontSize: 12, color: Colors.black87),
            columns: const [
              DataColumn(label: Text('S.No.')),
              DataColumn(label: Text('Medicine & Dosage')),
              DataColumn(label: Text('Duration')),
              DataColumn(label: Text('Instructions')),
            ],
            rows: List.generate(prescription.medicines.length, (index) {
              final med = prescription.medicines[index];
              return DataRow(
                cells: [
                  DataCell(Text((index + 1).toString())),
                  DataCell(
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(med.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text(med.dosage, style: const TextStyle(fontSize: 10, color: Colors.black54)),
                      ],
                    ),
                  ),
                  DataCell(Text(med.duration)),
                  DataCell(Text(med.instruction)),
                ],
              );
            }),
          ),
        ),

        const SizedBox(height: 30),

        // Diagnosis
        Text(
          'Diagnosis:',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87),
        ),
        const SizedBox(height: 4),
        Text(
          prescription.diagnosis,
          style: GoogleFonts.inter(fontSize: 13, color: Colors.black87),
        ),
        const SizedBox(height: 16),

        // Notes
        if (prescription.clinicalNotes.isNotEmpty) ...[
          Text(
            'Clinical Advice & Notes:',
            style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87),
          ),
          const SizedBox(height: 4),
          Text(
            prescription.clinicalNotes,
            style: GoogleFonts.inter(fontSize: 13, color: Colors.black54, height: 1.5),
          ),
          const SizedBox(height: 16),
        ],

        // Follow-up
        if (prescription.followUpDate != null && prescription.followUpDate!.isNotEmpty) ...[
          Text(
            'Follow-up Advice:',
            style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87),
          ),
          const SizedBox(height: 4),
          Text(
            prescription.followUpDate!,
            style: GoogleFonts.inter(fontSize: 13, color: Colors.green[800], fontWeight: FontWeight.w600),
          ),
        ],

        const SizedBox(height: 60),

        // Footer layout: Sign and Stamp / QR Code
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // QR Code Mock
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black26),
                borderRadius: BorderRadius.circular(4),
              ),
              padding: const EdgeInsets.all(4),
              child: const Icon(Icons.qr_code_2_rounded, size: 60, color: Colors.black87),
            ),
            // Sign block
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 140,
                  height: 1,
                  color: Colors.black38,
                ),
                const SizedBox(height: 6),
                Text(
                  'Authorized Digital Signature',
                  style: GoogleFonts.inter(fontSize: 10, color: Colors.black54, fontWeight: FontWeight.bold),
                ),
                Text(
                  prescription.doctorName,
                  style: GoogleFonts.inter(fontSize: 9, color: Colors.black38),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

// Custom widget to render the Lab Report PDF layout
class LabReportPdfView extends StatelessWidget {
  final LabReport report;

  const LabReportPdfView({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final dateStr = "${report.date.day}/${report.date.month}/${report.date.year}";
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Lab Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  report.hospitalName,
                  style: GoogleFonts.inter(
                    color: const Color(0xFF1E222B),
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                Text(
                  'DEPARTMENT OF DIAGNOSTIC PATHOLOGY',
                  style: GoogleFonts.inter(
                    color: Colors.black54,
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.green[800]!, width: 1.5),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'VERIFIED CLINICAL REPORT',
                style: GoogleFonts.inter(
                  color: Colors.green[800],
                  fontWeight: FontWeight.w800,
                  fontSize: 8,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Divider(thickness: 2, color: Colors.black87),
        const SizedBox(height: 12),

        // Report & Patient Info
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Report: ${report.testName}',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF1E222B),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Patient: Laila Khan (Age: 40, Gender: Female)',
                    style: GoogleFonts.inter(
                      color: Colors.black87,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    'Prescribed By: ${report.doctorName}',
                    style: GoogleFonts.inter(
                      color: Colors.black54,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Report Date: $dateStr',
                  style: GoogleFonts.inter(
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
                Text(
                  'Report ID: ${report.id}',
                  style: GoogleFonts.inter(
                    color: Colors.black54,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),
        const Divider(thickness: 1, color: Colors.black26),
        const SizedBox(height: 16),

        // Results Table
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black12),
            borderRadius: BorderRadius.circular(4),
          ),
          child: DataTable(
            headingRowHeight: 36,
            dataRowMaxHeight: 48,
            dataRowMinHeight: 38,
            headingTextStyle: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black87),
            dataTextStyle: GoogleFonts.inter(fontSize: 12, color: Colors.black87),
            columns: const [
              DataColumn(label: Text('Investigation Parameter')),
              DataColumn(label: Text('Observed Value')),
              DataColumn(label: Text('Reference Interval')),
              DataColumn(label: Text('Status')),
            ],
            rows: report.results.isEmpty 
                ? [
                    const DataRow(
                      cells: [
                        DataCell(Text('Glucose (Fasting)')),
                        DataCell(Text('7.2 mmol/L', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataCell(Text('< 5.6 mmol/L')),
                        DataCell(Text('High', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))),
                      ],
                    ),
                  ]
                : report.results.map((res) {
                    final isHigh = res.status.toLowerCase() == 'high';
                    final isLow = res.status.toLowerCase() == 'low';
                    return DataRow(
                      cells: [
                        DataCell(Text(res.parameter)),
                        DataCell(Text('${res.value} ${res.unit}', style: TextStyle(fontWeight: isHigh || isLow ? FontWeight.bold : FontWeight.normal))),
                        DataCell(Text(res.referenceRange)),
                        DataCell(
                          Text(
                            res.status, 
                            style: TextStyle(
                              color: isHigh || isLow ? Colors.red : Colors.green[800],
                              fontWeight: isHigh || isLow ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
          ),
        ),

        const SizedBox(height: 30),

        // AI Interpretation Box
        if (report.aiInterpretation.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.yellow[50]!.withOpacity(0.8),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.yellow[700]!.withOpacity(0.4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.auto_awesome_rounded, color: Colors.yellow[800], size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'AI Clinical Interpretation & Insights',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Colors.yellow[900],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  report.aiInterpretation,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.black87,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
        ],

        // Signatures & End
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // QR Code Mock
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black26),
                borderRadius: BorderRadius.circular(4),
              ),
              padding: const EdgeInsets.all(4),
              child: const Icon(Icons.qr_code_2_rounded, size: 60, color: Colors.black87),
            ),
            // Sign block
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 140,
                  height: 1,
                  color: Colors.black38,
                ),
                const SizedBox(height: 6),
                Text(
                  'Pathologist Signature',
                  style: GoogleFonts.inter(fontSize: 10, color: Colors.black54, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Verified Laboratory Registry',
                  style: GoogleFonts.inter(fontSize: 9, color: Colors.black38),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
