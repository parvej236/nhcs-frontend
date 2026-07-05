import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_colors.dart';
import '../providers/auth_provider.dart';
import '../providers/language_provider.dart';
import '../utils/constants.dart';
import '../../features/public/widgets/public_header.dart';
import 'judge_role_switcher.dart';

// Sidebar for patient role
// Sidebar for patient role
class PatientSidebar extends ConsumerWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const PatientSidebar({super.key, required this.selectedIndex, required this.onItemSelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppColors.of(context);
    final tr = ref.watch(translationsProvider);
    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: t.bgCard,
        border: Border(right: BorderSide(color: t.border)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    const SizedBox(height: 32),
                    // Logo
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: InkWell(
                        onTap: () => context.go('/'),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: t.brandPrimary,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.health_and_safety, color: Colors.white, size: 24),
                              ),
                              const SizedBox(width: 12),
                              Text('NHCS', style: GoogleFonts.outfit(color: t.textPrimary, fontSize: 22, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const WorkspaceSwitcher(),
                    const SizedBox(height: 12),
                    const JudgeRoleSwitcher(),
                    const SizedBox(height: 24),
                    // Menu items
                    _buildMenuItem(context, 0, Icons.dashboard_rounded, tr('menu_dashboard')),
                    _buildMenuItem(context, 1, Icons.timeline_rounded, tr('menu_timeline')),
                    _buildMenuItem(context, 2, Icons.calendar_month_rounded, tr('menu_appointments')),
                    _buildMenuItem(context, 3, Icons.folder_shared_rounded, tr('menu_vault')),
                    _buildMenuItem(context, 4, Icons.person_rounded, tr('menu_profile')),
                    _buildMenuItem(context, 5, Icons.auto_awesome_rounded, tr('menu_healthcare_ai')),
                    _buildMenuItem(context, 6, Icons.bloodtype_rounded, tr('menu_blood_donation')),
                    const Spacer(),

                    // Language switcher
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${tr('language')}:', style: GoogleFonts.inter(fontSize: 12, color: t.textSecondary)),
                          const LanguageSwitcher(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Logout
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: InkWell(
                        onTap: () async {
                          await ref.read(authProvider.notifier).logout();
                          if (context.mounted) {
                            context.go('/');
                          }
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: t.danger.withValues(alpha: 0.1),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.logout_rounded, color: t.danger, size: 20),
                              const SizedBox(width: 12),
                              Text(tr('menu_sign_out'), style: GoogleFonts.inter(color: t.danger, fontSize: 14, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, int index, IconData icon, String label) {
    final t = AppColors.of(context);
    final isSelected = selectedIndex == index;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onItemSelected(index),
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: isSelected ? t.brandPrimary.withValues(alpha: 0.12) : Colors.transparent,
            ),
            child: Row(
              children: [
                Icon(icon, color: isSelected ? t.brandPrimary : t.textSecondary, size: 20),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: GoogleFonts.inter(
                    color: isSelected ? t.brandPrimary : t.textSecondary,
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Sidebar for doctor role
class DoctorSidebar extends ConsumerWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const DoctorSidebar({super.key, required this.selectedIndex, required this.onItemSelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = ref.watch(translationsProvider);
    return Container(
      width: 260,
      color: AppColors.sidebar,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    const SizedBox(height: 32),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: InkWell(
                        onTap: () => context.go('/'),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(10)),
                                child: const Icon(Icons.medical_services_rounded, color: Colors.white, size: 24),
                              ),
                              const SizedBox(width: 12),
                              Text('NHCS', style: GoogleFonts.outfit(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(tr('portal_doctor'), style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 12)),
                    ),
                    const SizedBox(height: 12),
                    const JudgeRoleSwitcher(forceDark: true),
                    const SizedBox(height: 12),
                    const WorkspaceSwitcher(),
                    const SizedBox(height: 24),
                    _buildMenuItem(0, Icons.dashboard_rounded, tr('menu_dashboard')),
                    _buildMenuItem(1, Icons.edit_note_rounded, tr('menu_clinical_workspace')),
                    _buildMenuItem(2, Icons.science_rounded, tr('menu_report_review')),
                    _buildMenuItem(3, Icons.schedule_rounded, tr('menu_schedule')),
                    _buildMenuItem(4, Icons.person_rounded, tr('menu_profile')),
                    const Spacer(),

                    // Language switcher
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${tr('language')}:', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted)),
                          const LanguageSwitcher(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: InkWell(
                        onTap: () async {
                          await ref.read(authProvider.notifier).logout();
                          if (context.mounted) {
                            context.go('/');
                          }
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Colors.white.withOpacity(0.05)),
                          child: Row(
                            children: [
                              const Icon(Icons.logout_rounded, color: AppColors.danger, size: 20),
                              const SizedBox(width: 12),
                              Text(tr('menu_sign_out'), style: GoogleFonts.inter(color: AppColors.danger, fontSize: 14, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMenuItem(int index, IconData icon, String label) {
    final isSelected = selectedIndex == index;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onItemSelected(index),
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: isSelected ? AppColors.primary : Colors.transparent),
            child: Row(
              children: [
                Icon(icon, color: isSelected ? Colors.white : AppColors.textMuted, size: 20),
                const SizedBox(width: 12),
                Text(label, style: GoogleFonts.inter(color: isSelected ? Colors.white : AppColors.textMuted, fontSize: 14, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Sidebar for hospital authority role
class HospitalSidebar extends ConsumerWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const HospitalSidebar({super.key, required this.selectedIndex, required this.onItemSelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = ref.watch(translationsProvider);
    return Container(
      width: 260,
      color: AppColors.sidebar,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    const SizedBox(height: 32),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: InkWell(
                        onTap: () => context.go('/'),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(10)),
                                child: const Icon(Icons.local_hospital_rounded, color: Colors.white, size: 24),
                              ),
                              const SizedBox(width: 12),
                              Text('NHCS', style: GoogleFonts.outfit(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(tr('portal_hospital'), style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 12)),
                    ),
                    const SizedBox(height: 12),
                    const JudgeRoleSwitcher(forceDark: true),
                    const SizedBox(height: 12),
                    const WorkspaceSwitcher(),
                    const SizedBox(height: 24),
                    _buildMenuItem(0, Icons.dashboard_rounded, tr('menu_command_center')),
                    _buildMenuItem(3, Icons.fact_check_rounded, tr('menu_appointment_approvals')),
                    _buildMenuItem(1, Icons.biotech_rounded, tr('menu_laboratory')),
                    _buildMenuItem(2, Icons.bloodtype_rounded, tr('menu_blood_donation')),
                    const Spacer(),

                    // Language switcher
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${tr('language')}:', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted)),
                          const LanguageSwitcher(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: InkWell(
                        onTap: () async {
                          await ref.read(authProvider.notifier).logout();
                          if (context.mounted) {
                            context.go('/');
                          }
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Colors.white.withOpacity(0.05)),
                          child: Row(
                            children: [
                              const Icon(Icons.logout_rounded, color: AppColors.danger, size: 20),
                              const SizedBox(width: 12),
                              Text(tr('menu_sign_out'), style: GoogleFonts.inter(color: AppColors.danger, fontSize: 14, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMenuItem(int index, IconData icon, String label) {
    final isSelected = selectedIndex == index;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onItemSelected(index),
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: isSelected ? AppColors.primary : Colors.transparent),
            child: Row(
              children: [
                Icon(icon, color: isSelected ? Colors.white : AppColors.textMuted, size: 20),
                const SizedBox(width: 12),
                Text(label, style: GoogleFonts.inter(color: isSelected ? Colors.white : AppColors.textMuted, fontSize: 14, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class WorkspaceSwitcher extends ConsumerWidget {
  const WorkspaceSwitcher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final roles = authState.roles;
    final currentRole = authState.role;
    final t = AppColors.of(context);

    if (roles.length <= 1) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: t.bgInput,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: t.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: currentRole,
          dropdownColor: t.bgCard,
          icon: Icon(Icons.swap_horiz_rounded, color: t.textSecondary, size: 20),
          isExpanded: true,
          style: GoogleFonts.inter(color: t.textPrimary, fontSize: 13, fontWeight: FontWeight.w600),
          items: roles.map((role) {
            String displayName = 'Citizen Workspace';
            IconData icon = Icons.person_rounded;
            Color iconColor = t.brandPrimary;

            if (role == AppConstants.roleDoctor) {
              displayName = 'Doctor Console';
              icon = Icons.medical_services_rounded;
              iconColor = t.brandSecondary;
            } else if (role == AppConstants.roleHospital) {
              displayName = 'Hospital Center';
              icon = Icons.local_hospital_rounded;
              iconColor = const Color(0xFF8B5CF6); // Soft purple matching dark mode
            }

            return DropdownMenuItem<String>(
              value: role,
              child: Row(
                children: [
                  Icon(icon, color: iconColor, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    displayName,
                    style: TextStyle(
                      color: t.textPrimary,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (newRole) {
            if (newRole != null && newRole != currentRole) {
              ref.read(authProvider.notifier).switchRole(newRole);
              String targetRoute = '/';
              if (newRole == AppConstants.rolePatient) {
                targetRoute = '/user';
              } else if (newRole == AppConstants.roleDoctor) {
                targetRoute = '/doctor';
              } else if (newRole == AppConstants.roleHospital) {
                targetRoute = '/authority';
              }
              context.go(targetRoute);
            }
          },
        ),
      ),
    );
  }
}
