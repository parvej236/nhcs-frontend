// Models for the AI Health Copilot hub.

class CopilotAlert {
  final String severity; // 'high' | 'moderate' | 'low'
  final String title;
  final String detail;

  CopilotAlert({required this.severity, required this.title, required this.detail});

  factory CopilotAlert.fromJson(Map<String, dynamic> j) => CopilotAlert(
        severity: (j['severity'] ?? 'low').toString(),
        title: (j['title'] ?? '').toString(),
        detail: (j['detail'] ?? '').toString(),
      );
}

class CopilotBriefing {
  final int healthScore;
  final String scoreBand;
  final String statusLine;
  final String patientName;
  final List<CopilotAlert> alerts;
  final bool aiQuotaExceeded;
  final String? aiStatus;

  CopilotBriefing({
    required this.healthScore,
    required this.scoreBand,
    required this.statusLine,
    required this.patientName,
    required this.alerts,
    this.aiQuotaExceeded = false,
    this.aiStatus,
  });

  factory CopilotBriefing.fromJson(Map<String, dynamic> j) => CopilotBriefing(
        healthScore: (j['healthScore'] as num?)?.toInt() ?? 0,
        scoreBand: (j['scoreBand'] ?? '').toString(),
        statusLine: (j['statusLine'] ?? '').toString(),
        patientName: (j['patientName'] ?? '').toString(),
        alerts: ((j['alerts'] as List<dynamic>?) ?? [])
            .map((e) => CopilotAlert.fromJson(e as Map<String, dynamic>))
            .toList(),
        aiQuotaExceeded: j['aiQuotaExceeded'] == true,
        aiStatus: j['aiStatus']?.toString(),
      );
}

class ChatMessage {
  final String role; // 'patient' | 'assistant'
  final String text;
  final bool isTyping;

  ChatMessage({required this.role, required this.text, this.isTyping = false});

  Map<String, dynamic> toJson() => {'role': role, 'text': text};
}

class MedicationInteraction {
  final String severity;
  final String title;
  final String detail;

  MedicationInteraction({required this.severity, required this.title, required this.detail});

  factory MedicationInteraction.fromJson(Map<String, dynamic> j) => MedicationInteraction(
        severity: (j['severity'] ?? 'low').toString(),
        title: (j['title'] ?? '').toString(),
        detail: (j['detail'] ?? '').toString(),
      );
}

class MedicationCheck {
  final String overallRisk;
  final String summaryEn;
  final String summaryBn;
  final List<String> medications;
  final String allergies;
  final List<MedicationInteraction> interactions;

  MedicationCheck({
    required this.overallRisk,
    required this.summaryEn,
    required this.summaryBn,
    required this.medications,
    required this.allergies,
    required this.interactions,
  });

  factory MedicationCheck.fromJson(Map<String, dynamic> j) => MedicationCheck(
        overallRisk: (j['overallRisk'] ?? 'low').toString(),
        summaryEn: (j['summaryEn'] ?? '').toString(),
        summaryBn: (j['summaryBn'] ?? '').toString(),
        medications: ((j['medications'] as List<dynamic>?) ?? []).map((e) => e.toString()).toList(),
        allergies: (j['allergies'] ?? '').toString(),
        interactions: ((j['interactions'] as List<dynamic>?) ?? [])
            .map((e) => MedicationInteraction.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class RiskItem {
  final String title;
  final int riskPercent;
  final String level;
  final List<String> factors;
  final String advice;

  RiskItem({
    required this.title,
    required this.riskPercent,
    required this.level,
    required this.factors,
    required this.advice,
  });

  factory RiskItem.fromJson(Map<String, dynamic> j) => RiskItem(
        title: (j['title'] ?? '').toString(),
        riskPercent: (j['riskPercent'] as num?)?.toInt() ?? 0,
        level: (j['level'] ?? 'Low').toString(),
        factors: ((j['factors'] as List<dynamic>?) ?? []).map((e) => e.toString()).toList(),
        advice: (j['advice'] ?? '').toString(),
      );
}

class RiskRadar {
  final RiskItem cardiovascular;
  final RiskItem diabetes;

  RiskRadar({required this.cardiovascular, required this.diabetes});

  factory RiskRadar.fromJson(Map<String, dynamic> j) => RiskRadar(
        cardiovascular: RiskItem.fromJson((j['cardiovascular'] as Map<String, dynamic>?) ?? {}),
        diabetes: RiskItem.fromJson((j['diabetes'] as Map<String, dynamic>?) ?? {}),
      );
}

class ReportExplanation {
  final String explanationEn;
  final String explanationBn;
  final List<String> keyPoints;
  final String reassurance;

  ReportExplanation({
    required this.explanationEn,
    required this.explanationBn,
    required this.keyPoints,
    required this.reassurance,
  });

  factory ReportExplanation.fromJson(Map<String, dynamic> j) => ReportExplanation(
        explanationEn: (j['explanationEn'] ?? '').toString(),
        explanationBn: (j['explanationBn'] ?? '').toString(),
        keyPoints: ((j['keyPoints'] as List<dynamic>?) ?? []).map((e) => e.toString()).toList(),
        reassurance: (j['reassurance'] ?? '').toString(),
      );
}
