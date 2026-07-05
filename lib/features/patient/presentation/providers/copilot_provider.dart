import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../data/models/copilot_models.dart';
import '../../data/repositories/patient_repository.dart';
import 'patient_providers.dart';

// Daily briefing: health score + proactive alerts.
final copilotBriefingProvider = FutureProvider<CopilotBriefing>((ref) async {
  final repo = ref.watch(patientRepositoryProvider);
  return repo.getCopilotBriefing();
});

// Risk radar (cardiovascular + diabetes).
final copilotRiskProvider = FutureProvider<RiskRadar>((ref) async {
  final repo = ref.watch(patientRepositoryProvider);
  return repo.getRiskRadar();
});

// Medication safety check.
final copilotMedicationProvider = FutureProvider<MedicationCheck>((ref) async {
  final repo = ref.watch(patientRepositoryProvider);
  return repo.getMedicationCheck();
});

// ---------------------------------------------------------------------------
// Chat
// ---------------------------------------------------------------------------
class CopilotChatState {
  final List<ChatMessage> messages;
  final bool isSending;

  CopilotChatState({this.messages = const [], this.isSending = false});

  CopilotChatState copyWith({List<ChatMessage>? messages, bool? isSending}) =>
      CopilotChatState(
        messages: messages ?? this.messages,
        isSending: isSending ?? this.isSending,
      );
}

class CopilotChatNotifier extends StateNotifier<CopilotChatState> {
  final PatientRepository _repository;

  CopilotChatNotifier(this._repository) : super(CopilotChatState());

  Future<void> send(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || state.isSending) return;

    final history = List<ChatMessage>.from(state.messages);
    final userMsg = ChatMessage(role: 'patient', text: trimmed);
    state = state.copyWith(
      messages: [...state.messages, userMsg, ChatMessage(role: 'assistant', text: '', isTyping: true)],
      isSending: true,
    );

    try {
      final reply = await _repository.copilotChat(trimmed, history);
      final msgs = List<ChatMessage>.from(state.messages)
        ..removeWhere((m) => m.isTyping)
        ..add(ChatMessage(role: 'assistant', text: reply));
      state = state.copyWith(messages: msgs, isSending: false);
    } catch (e) {
      final msgs = List<ChatMessage>.from(state.messages)
        ..removeWhere((m) => m.isTyping)
        ..add(ChatMessage(
          role: 'assistant',
          text: 'দুঃখিত, এই মুহূর্তে উত্তর দিতে পারছি না। একটু পরে আবার চেষ্টা করুন।',
        ));
      state = state.copyWith(messages: msgs, isSending: false);
    }
  }

  void reset() => state = CopilotChatState();
}

final copilotChatProvider =
    StateNotifierProvider<CopilotChatNotifier, CopilotChatState>((ref) {
  final repo = ref.watch(patientRepositoryProvider);
  return CopilotChatNotifier(repo);
});

// Currently selected feature tab within the Copilot hub.
final copilotTabProvider = StateProvider<int>((ref) => 0);
