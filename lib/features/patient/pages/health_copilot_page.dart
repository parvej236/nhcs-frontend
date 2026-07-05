import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_primitives.dart';
import '../data/models/copilot_models.dart';
import '../presentation/providers/copilot_provider.dart';
import '../presentation/providers/patient_providers.dart';

/// The AI Health Copilot — a personalised hub grounded in the patient's own
/// medical record. Replaces the old generic VitalsChecker.
class HealthCopilotPage extends ConsumerStatefulWidget {
  const HealthCopilotPage({super.key});

  @override
  ConsumerState<HealthCopilotPage> createState() => _HealthCopilotPageState();
}

class _HealthCopilotPageState extends ConsumerState<HealthCopilotPage> {
  @override
  Widget build(BuildContext context) {
    final t = AppColors.of(context);
    final tab = ref.watch(copilotTabProvider);

    return Container(
      color: t.bgMain,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(28, 28, 28, 48),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1180),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _header(t),
                _quotaBanner(t),
                const SizedBox(height: 24),
                _briefingHero(t),
                const SizedBox(height: 24),
                _tabBar(t, tab),
                const SizedBox(height: 20),
                _tabContent(t, tab),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  Widget _header(AppColorTokens t) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [t.brandPrimary, t.brandSecondary]),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 26),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'AI Health Copilot',
                style: GoogleFonts.outfit(fontSize: 26, fontWeight: FontWeight.w800, color: t.textPrimary),
              ),
              Text(
                'Your personal assistant — knows your record, watches your health, talks in your language.',
                style: GoogleFonts.inter(fontSize: 13, color: t.textSecondary),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: t.success.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: t.success.withValues(alpha: 0.3)),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.bolt_rounded, size: 15, color: t.success),
            const SizedBox(width: 5),
            Text('Powered by Gemini',
                style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: t.success)),
          ]),
        ),
      ],
    );
  }

  // -------------------------------------------------------------------------
  Widget _quotaBanner(AppColorTokens t) {
    final b = ref.watch(copilotBriefingProvider).value;
    if (b == null || !b.aiQuotaExceeded) return const SizedBox.shrink();
    final msg = b.aiStatus ??
        '⚠️ আজকের ফ্রি AI সীমা শেষ — AI সহকারী আগামীকাল আবার কাজ করবে। (Health Score, Alerts ও Risk ঠিকঠাক আছে।)';
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: t.warning.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: t.warning.withValues(alpha: 0.35)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.hourglass_disabled_rounded, color: t.warning, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(msg,
                  style: GoogleFonts.inter(fontSize: 12.5, height: 1.5, color: t.textPrimary)),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  Widget _briefingHero(AppColorTokens t) {
    final async = ref.watch(copilotBriefingProvider);
    return AppCard(
      padding: const EdgeInsets.all(24),
      child: async.when(
        loading: () => const SizedBox(
          height: 180,
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (e, _) => _heroError(t),
        data: (b) {
          final color = _scoreColor(t, b.healthScore);
          return LayoutBuilder(builder: (context, c) {
            final narrow = c.maxWidth < 720;
            final gauge = _scoreGauge(t, b, color);
            final alerts = _alertsColumn(t, b.alerts);
            if (narrow) {
              return Column(children: [gauge, const SizedBox(height: 24), alerts]);
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: 260, child: gauge),
                const SizedBox(width: 28),
                Expanded(child: alerts),
              ],
            );
          });
        },
      ),
    );
  }

  Widget _scoreGauge(AppColorTokens t, CopilotBriefing b, Color color) {
    return Column(
      children: [
        SizedBox(
          width: 180,
          height: 180,
          child: CustomPaint(
            painter: _GaugePainter(value: b.healthScore / 100, color: color, track: t.bgInput),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('${b.healthScore}',
                      style: GoogleFonts.outfit(fontSize: 46, fontWeight: FontWeight.w800, color: t.textPrimary, height: 1)),
                  Text('Health Score',
                      style: GoogleFonts.inter(fontSize: 11, color: t.textSecondary, letterSpacing: 0.5)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(20)),
          child: Text(b.scoreBand,
              style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: color)),
        ),
      ],
    );
  }

  Widget _alertsColumn(AppColorTokens t, List<CopilotAlert> alerts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Today\'s Briefing',
            style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: t.textPrimary)),
        const SizedBox(height: 4),
        Consumer(builder: (context, ref, _) {
          final b = ref.watch(copilotBriefingProvider).value;
          return Text(b?.statusLine ?? '',
              style: GoogleFonts.inter(fontSize: 14, color: t.textSecondary, height: 1.5));
        }),
        const SizedBox(height: 16),
        if (alerts.isEmpty)
          Row(children: [
            Icon(Icons.check_circle_rounded, color: t.success, size: 18),
            const SizedBox(width: 8),
            Text('No urgent alerts. Keep up the good work!',
                style: GoogleFonts.inter(fontSize: 13, color: t.textSecondary)),
          ])
        else
          ...alerts.map((a) => _alertRow(t, a)),
      ],
    );
  }

  Widget _alertRow(AppColorTokens t, CopilotAlert a) {
    final color = _sevColor(t, a.severity);
    final icon = a.severity == 'high'
        ? Icons.warning_amber_rounded
        : a.severity == 'moderate'
            ? Icons.error_outline_rounded
            : Icons.info_outline_rounded;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(a.title,
                    style: GoogleFonts.inter(fontSize: 13.5, fontWeight: FontWeight.w700, color: t.textPrimary)),
                const SizedBox(height: 2),
                Text(a.detail, style: GoogleFonts.inter(fontSize: 12.5, color: t.textSecondary, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _heroError(AppColorTokens t) {
    return SizedBox(
      height: 160,
      child: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.cloud_off_rounded, color: t.textSecondary, size: 34),
          const SizedBox(height: 10),
          Text('Could not load your briefing. Is the server running?',
              style: GoogleFonts.inter(fontSize: 13, color: t.textSecondary)),
          const SizedBox(height: 10),
          AppButton(
            label: 'Retry',
            variant: AppButtonVariant.outline,
            onPressed: () => ref.invalidate(copilotBriefingProvider),
          ),
        ]),
      ),
    );
  }

  // -------------------------------------------------------------------------
  Widget _tabBar(AppColorTokens t, int active) {
    final tabs = [
      (Icons.chat_bubble_rounded, 'Chat'),
      (Icons.medication_rounded, 'Medication Safety'),
      (Icons.monitor_heart_rounded, 'Risk Radar'),
      (Icons.science_rounded, 'Report Explainer'),
    ];
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: List.generate(tabs.length, (i) {
        final selected = i == active;
        return InkWell(
          onTap: () => ref.read(copilotTabProvider.notifier).state = i,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
            decoration: BoxDecoration(
              color: selected ? t.brandPrimary : t.bgCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: selected ? t.brandPrimary : t.border),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(tabs[i].$1, size: 17, color: selected ? Colors.white : t.textSecondary),
              const SizedBox(width: 8),
              Text(tabs[i].$2,
                  style: GoogleFonts.inter(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: selected ? Colors.white : t.textSecondary)),
            ]),
          ),
        );
      }),
    );
  }

  Widget _tabContent(AppColorTokens t, int tab) {
    switch (tab) {
      case 1:
        return _MedicationTab();
      case 2:
        return _RiskTab();
      case 3:
        return _ReportExplainerTab();
      default:
        return _ChatTab();
    }
  }

  // -------------------------------------------------------------------------
  Color _scoreColor(AppColorTokens t, int s) {
    if (s >= 85) return t.success;
    if (s >= 70) return const Color(0xFF16A34A);
    if (s >= 50) return t.warning;
    return t.danger;
  }

  Color _sevColor(AppColorTokens t, String sev) {
    if (sev == 'high') return t.danger;
    if (sev == 'moderate') return t.warning;
    return t.brandSecondary;
  }
}

// ===========================================================================
// Gauge painter
// ===========================================================================
class _GaugePainter extends CustomPainter {
  final double value; // 0..1
  final Color color;
  final Color track;

  _GaugePainter({required this.value, required this.color, required this.track});

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 14.0;
    final rect = Offset(stroke / 2, stroke / 2) &
        Size(size.width - stroke, size.height - stroke);
    const start = math.pi * 0.75;
    const sweep = math.pi * 1.5;

    final bg = Paint()
      ..color = track
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, start, sweep, false, bg);

    final fg = Paint()
      ..shader = SweepGradient(
        startAngle: start,
        endAngle: start + sweep,
        colors: [color.withValues(alpha: 0.6), color],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, start, sweep * value.clamp(0.0, 1.0), false, fg);
  }

  @override
  bool shouldRepaint(covariant _GaugePainter old) =>
      old.value != value || old.color != color;
}

// ===========================================================================
// Chat tab
// ===========================================================================
class _ChatTab extends ConsumerStatefulWidget {
  @override
  ConsumerState<_ChatTab> createState() => _ChatTabState();
}

class _ChatTabState extends ConsumerState<_ChatTab> {
  final _controller = TextEditingController();
  final _scroll = ScrollController();

  static const _quickPrompts = [
    'আমার সুগার বাড়ছে কেন?',
    'আমার ওষুধগুলো কি নিরাপদ?',
    'আজ আমার কী খাওয়া উচিত?',
    'What should I ask my doctor next visit?',
  ];

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _send(String text) {
    if (text.trim().isEmpty) return;
    ref.read(copilotChatProvider.notifier).send(text);
    _controller.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent + 200,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppColors.of(context);
    final state = ref.watch(copilotChatProvider);

    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            CircleAvatar(radius: 16, backgroundColor: t.brandPrimary.withValues(alpha: 0.15),
                child: Icon(Icons.smart_toy_rounded, size: 18, color: t.brandPrimary)),
            const SizedBox(width: 10),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Shonko — your health companion',
                  style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w700, color: t.textPrimary)),
              Text('Ask anything about your health. I read your records.',
                  style: GoogleFonts.inter(fontSize: 12, color: t.textSecondary)),
            ]),
          ]),
          const SizedBox(height: 16),
          Container(
            height: 360,
            decoration: BoxDecoration(
              color: t.bgMain,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: t.border),
            ),
            child: state.messages.isEmpty
                ? _emptyChat(t)
                : ListView.builder(
                    controller: _scroll,
                    padding: const EdgeInsets.all(16),
                    itemCount: state.messages.length,
                    itemBuilder: (context, i) => _bubble(t, state.messages[i]),
                  ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _quickPrompts
                .map((q) => InkWell(
                      onTap: state.isSending ? null : () => _send(q),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: t.bgInput,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: t.border),
                        ),
                        child: Text(q, style: GoogleFonts.inter(fontSize: 12, color: t.textPrimary)),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
              child: TextField(
                controller: _controller,
                style: GoogleFonts.inter(color: t.textPrimary, fontSize: 14),
                onSubmitted: state.isSending ? null : _send,
                decoration: InputDecoration(
                  hintText: 'Type your question in Bangla or English…',
                  filled: true,
                  fillColor: t.bgInput,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: t.border)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: t.border)),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Material(
              color: state.isSending ? t.textSecondary : t.brandPrimary,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: state.isSending ? null : () => _send(_controller.text),
                child: const Padding(
                  padding: EdgeInsets.all(14),
                  child: Icon(Icons.send_rounded, color: Colors.white, size: 20),
                ),
              ),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _emptyChat(AppColorTokens t) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.forum_rounded, size: 40, color: t.textSecondary.withValues(alpha: 0.5)),
        const SizedBox(height: 12),
        Text('Start a conversation',
            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: t.textSecondary)),
        const SizedBox(height: 4),
        Text('Try a quick prompt below 👇',
            style: GoogleFonts.inter(fontSize: 12.5, color: t.textSecondary)),
      ]),
    );
  }

  Widget _bubble(AppColorTokens t, ChatMessage m) {
    final isUser = m.role == 'patient';
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 460),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isUser ? t.brandPrimary : t.bgCard,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(14),
            topRight: const Radius.circular(14),
            bottomLeft: Radius.circular(isUser ? 14 : 2),
            bottomRight: Radius.circular(isUser ? 2 : 14),
          ),
          border: isUser ? null : Border.all(color: t.border),
        ),
        child: m.isTyping
            ? _TypingDots(color: t.textSecondary)
            : Text(
                m.text,
                style: GoogleFonts.inter(
                    fontSize: 13.5, height: 1.5, color: isUser ? Colors.white : t.textPrimary),
              ),
      ),
    );
  }
}

class _TypingDots extends StatefulWidget {
  final Color color;
  const _TypingDots({required this.color});
  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))..repeat();
  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final v = (math.sin((_c.value * 2 * math.pi) - i * 0.8) + 1) / 2;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Opacity(
                opacity: 0.4 + v * 0.6,
                child: Container(
                  width: 7, height: 7,
                  decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

// ===========================================================================
// Medication Safety tab
// ===========================================================================
class _MedicationTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppColors.of(context);
    final async = ref.watch(copilotMedicationProvider);
    return AppCard(
      child: async.when(
        loading: () => const SizedBox(height: 200, child: Center(child: CircularProgressIndicator())),
        error: (e, _) => _errorBox(context, t, 'medication check', () => ref.invalidate(copilotMedicationProvider)),
        data: (m) {
          final risk = m.overallRisk.toLowerCase();
          final color = risk == 'high' ? t.danger : risk == 'moderate' ? t.warning : t.success;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Icon(Icons.medication_liquid_rounded, color: t.brandPrimary),
                const SizedBox(width: 10),
                Text('Medication Safety Check',
                    style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: t.textPrimary)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: color.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(20)),
                  child: Text('${risk.toUpperCase()} RISK',
                      style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
                ),
              ]),
              const SizedBox(height: 14),
              if (m.summaryBn.isNotEmpty)
                Text(m.summaryBn, style: GoogleFonts.inter(fontSize: 13.5, height: 1.5, color: t.textPrimary)),
              if (m.summaryEn.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(m.summaryEn, style: GoogleFonts.inter(fontSize: 12.5, height: 1.5, color: t.textSecondary)),
              ],
              const SizedBox(height: 16),
              _label(t, 'YOUR CURRENT MEDICINES'),
              const SizedBox(height: 8),
              if (m.medications.isEmpty)
                Text('No medicines on record.', style: GoogleFonts.inter(fontSize: 13, color: t.textSecondary))
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: m.medications
                      .map((md) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                            decoration: BoxDecoration(
                                color: t.bgInput, borderRadius: BorderRadius.circular(10), border: Border.all(color: t.border)),
                            child: Row(mainAxisSize: MainAxisSize.min, children: [
                              Icon(Icons.local_pharmacy_rounded, size: 14, color: t.brandSecondary),
                              const SizedBox(width: 6),
                              Text(md, style: GoogleFonts.inter(fontSize: 12.5, color: t.textPrimary)),
                            ]),
                          ))
                      .toList(),
                ),
              const SizedBox(height: 8),
              Row(children: [
                Icon(Icons.warning_amber_rounded, size: 15, color: t.warning),
                const SizedBox(width: 6),
                Expanded(
                  child: Text('Allergies on file: ${m.allergies}',
                      style: GoogleFonts.inter(fontSize: 12.5, color: t.textSecondary)),
                ),
              ]),
              if (m.interactions.isNotEmpty) ...[
                const SizedBox(height: 18),
                _label(t, 'FINDINGS'),
                const SizedBox(height: 8),
                ...m.interactions.map((it) => _interactionCard(t, it)),
              ] else ...[
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                      color: t.success.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: t.success.withValues(alpha: 0.25))),
                  child: Row(children: [
                    Icon(Icons.verified_rounded, color: t.success, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text('No dangerous interactions found among your current medicines.',
                          style: GoogleFonts.inter(fontSize: 13, color: t.textPrimary)),
                    ),
                  ]),
                ),
              ],
              const SizedBox(height: 12),
              Text('⚠️ This is AI guidance, not a prescription. Always confirm with your doctor or pharmacist.',
                  style: GoogleFonts.inter(fontSize: 11.5, fontStyle: FontStyle.italic, color: t.textSecondary)),
            ],
          );
        },
      ),
    );
  }

  Widget _interactionCard(AppColorTokens t, MedicationInteraction it) {
    final color = it.severity == 'high' ? t.danger : it.severity == 'moderate' ? t.warning : t.brandSecondary;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.link_rounded, size: 17, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(it.title, style: GoogleFonts.inter(fontSize: 13.5, fontWeight: FontWeight.w700, color: t.textPrimary)),
          ),
          Text(it.severity.toUpperCase(), style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: color)),
        ]),
        const SizedBox(height: 6),
        Text(it.detail, style: GoogleFonts.inter(fontSize: 12.5, height: 1.4, color: t.textSecondary)),
      ]),
    );
  }
}

// ===========================================================================
// Risk Radar tab
// ===========================================================================
class _RiskTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppColors.of(context);
    final async = ref.watch(copilotRiskProvider);
    return async.when(
      loading: () => const AppCard(child: SizedBox(height: 200, child: Center(child: CircularProgressIndicator()))),
      error: (e, _) => AppCard(child: _errorBox(context, t, 'risk radar', () => ref.invalidate(copilotRiskProvider))),
      data: (r) {
        return LayoutBuilder(builder: (context, c) {
          final narrow = c.maxWidth < 720;
          final cards = [
            _riskCard(t, r.cardiovascular, Icons.favorite_rounded),
            _riskCard(t, r.diabetes, Icons.water_drop_rounded),
          ];
          if (narrow) return Column(children: [cards[0], const SizedBox(height: 16), cards[1]]);
          return Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Expanded(child: cards[0]),
            const SizedBox(width: 16),
            Expanded(child: cards[1]),
          ]);
        });
      },
    );
  }

  Widget _riskCard(AppColorTokens t, RiskItem item, IconData icon) {
    final color = item.riskPercent >= 70
        ? t.danger
        : item.riskPercent >= 45
            ? t.warning
            : item.riskPercent >= 25
                ? const Color(0xFFEAB308)
                : t.success;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(item.title,
                  style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: t.textPrimary)),
            ),
          ]),
          const SizedBox(height: 16),
          Row(children: [
            Text('${item.riskPercent}%',
                style: GoogleFonts.outfit(fontSize: 34, fontWeight: FontWeight.w800, color: color)),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(16)),
              child: Text('${item.level} risk',
                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
            ),
          ]),
          const SizedBox(height: 12),
          AppProgress(value: item.riskPercent.toDouble(), color: color),
          const SizedBox(height: 16),
          if (item.factors.isNotEmpty) ...[
            Text('CONTRIBUTING FACTORS',
                style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: t.textSecondary, letterSpacing: 0.5)),
            const SizedBox(height: 8),
            ...item.factors.map((f) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Text(f, style: GoogleFonts.inter(fontSize: 12.5, color: t.textPrimary))),
                  ]),
                )),
          ],
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: t.bgInput, borderRadius: BorderRadius.circular(10)),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(Icons.tips_and_updates_rounded, size: 16, color: t.brandPrimary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(item.advice, style: GoogleFonts.inter(fontSize: 12.5, height: 1.4, color: t.textSecondary)),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}

// ===========================================================================
// Report Explainer tab
// ===========================================================================
class _ReportExplainerTab extends ConsumerStatefulWidget {
  @override
  ConsumerState<_ReportExplainerTab> createState() => _ReportExplainerTabState();
}

class _ReportExplainerTabState extends ConsumerState<_ReportExplainerTab> {
  String? _selectedType; // 'lab' | 'imaging'
  String? _selectedId;
  String? _selectedLabel;
  bool _loading = false;
  bool _showBangla = true;
  ReportExplanation? _explanation;

  Future<void> _explain() async {
    if (_selectedId == null || _selectedType == null) return;
    setState(() {
      _loading = true;
      _explanation = null;
    });
    try {
      final repo = ref.read(patientRepositoryProvider);
      final res = await repo.explainReport(reportType: _selectedType!, reportId: _selectedId!);
      setState(() {
        _explanation = res;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppColors.of(context);
    final labs = ref.watch(patientLabReportsProvider);
    final imaging = ref.watch(patientImagingReportsProvider);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.science_rounded, color: t.brandPrimary),
            const SizedBox(width: 10),
            Text('Report Explainer',
                style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: t.textPrimary)),
          ]),
          const SizedBox(height: 4),
          Text('Pick a report and I\'ll explain it in simple Bangla or English.',
              style: GoogleFonts.inter(fontSize: 13, color: t.textSecondary)),
          const SizedBox(height: 16),
          _label(t, 'SELECT A REPORT'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ...labs.maybeWhen(
                data: (list) => list.map((r) => _reportChip(t, 'lab', r.id, r.testName)),
                orElse: () => const <Widget>[],
              ),
              ...imaging.maybeWhen(
                data: (list) => list.map((r) => _reportChip(t, 'imaging', r.id, r.type)),
                orElse: () => const <Widget>[],
              ),
            ],
          ),
          const SizedBox(height: 16),
          AppButton(
            label: _loading ? 'Explaining…' : 'Explain This Report',
            icon: Icons.auto_awesome_rounded,
            onPressed: (_selectedId == null || _loading) ? null : _explain,
          ),
          if (_loading) ...[
            const SizedBox(height: 24),
            const Center(child: CircularProgressIndicator()),
          ],
          if (_explanation != null) ...[
            const SizedBox(height: 20),
            _explanationCard(t, _explanation!),
          ],
        ],
      ),
    );
  }

  Widget _reportChip(AppColorTokens t, String type, String id, String label) {
    final selected = _selectedId == id;
    return InkWell(
      onTap: () => setState(() {
        _selectedType = type;
        _selectedId = id;
        _selectedLabel = label;
        _explanation = null;
      }),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? t.brandPrimary.withValues(alpha: 0.12) : t.bgInput,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: selected ? t.brandPrimary : t.border),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(type == 'imaging' ? Icons.image_rounded : Icons.biotech_rounded,
              size: 15, color: selected ? t.brandPrimary : t.textSecondary),
          const SizedBox(width: 6),
          Text(label,
              style: GoogleFonts.inter(
                  fontSize: 12.5,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  color: selected ? t.brandPrimary : t.textPrimary)),
        ]),
      ),
    );
  }

  Widget _explanationCard(AppColorTokens t, ReportExplanation e) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: t.brandPrimary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: t.brandPrimary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(
              child: Text(_selectedLabel ?? 'Explanation',
                  style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w700, color: t.textPrimary)),
            ),
            _langToggle(t),
          ]),
          const SizedBox(height: 12),
          Text(_showBangla ? e.explanationBn : e.explanationEn,
              style: GoogleFonts.inter(fontSize: 14, height: 1.6, color: t.textPrimary)),
          if (e.keyPoints.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text('KEY POINTS',
                style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: t.textSecondary, letterSpacing: 0.5)),
            const SizedBox(height: 8),
            ...e.keyPoints.map((k) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Icon(Icons.check_circle_rounded, size: 16, color: t.success),
                    const SizedBox(width: 8),
                    Expanded(child: Text(k, style: GoogleFonts.inter(fontSize: 13, height: 1.4, color: t.textPrimary))),
                  ]),
                )),
          ],
          if (e.reassurance.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: t.success.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
              child: Row(children: [
                Icon(Icons.favorite_rounded, size: 16, color: t.success),
                const SizedBox(width: 8),
                Expanded(child: Text(e.reassurance, style: GoogleFonts.inter(fontSize: 12.5, color: t.textPrimary))),
              ]),
            ),
          ],
        ],
      ),
    );
  }

  Widget _langToggle(AppColorTokens t) {
    return Container(
      decoration: BoxDecoration(color: t.bgInput, borderRadius: BorderRadius.circular(8)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        _langBtn(t, 'বাংলা', _showBangla, () => setState(() => _showBangla = true)),
        _langBtn(t, 'EN', !_showBangla, () => setState(() => _showBangla = false)),
      ]),
    );
  }

  Widget _langBtn(AppColorTokens t, String label, bool active, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
            color: active ? t.brandPrimary : Colors.transparent, borderRadius: BorderRadius.circular(8)),
        child: Text(label,
            style: GoogleFonts.inter(
                fontSize: 12, fontWeight: FontWeight.w600, color: active ? Colors.white : t.textSecondary)),
      ),
    );
  }
}

// ===========================================================================
// Shared helpers
// ===========================================================================
Widget _label(AppColorTokens t, String text) => Text(
      text,
      style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: t.textSecondary, letterSpacing: 0.5),
    );

Widget _errorBox(BuildContext context, AppColorTokens t, String what, VoidCallback onRetry) {
  return SizedBox(
    height: 160,
    child: Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.cloud_off_rounded, color: t.textSecondary, size: 32),
        const SizedBox(height: 10),
        Text('Could not load $what.', style: GoogleFonts.inter(fontSize: 13, color: t.textSecondary)),
        const SizedBox(height: 10),
        AppButton(label: 'Retry', variant: AppButtonVariant.outline, onPressed: onRetry),
      ]),
    ),
  );
}
