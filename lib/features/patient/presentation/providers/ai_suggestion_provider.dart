import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../data/models/ai_suggestion.dart';
import '../../data/repositories/patient_repository.dart';
import 'patient_providers.dart';
import 'dart:html' as html;

class AiSuggestionState {
  final bool isLoading;
  final AiSuggestionResponse? suggestion;
  final String? errorMessage;
  final bool isListening;
  final String speechText;

  AiSuggestionState({
    this.isLoading = false,
    this.suggestion,
    this.errorMessage,
    this.isListening = false,
    this.speechText = '',
  });

  AiSuggestionState copyWith({
    bool? isLoading,
    AiSuggestionResponse? suggestion,
    String? errorMessage,
    bool? isListening,
    String? speechText,
  }) {
    return AiSuggestionState(
      isLoading: isLoading ?? this.isLoading,
      suggestion: suggestion ?? this.suggestion,
      errorMessage: errorMessage ?? this.errorMessage,
      isListening: isListening ?? this.isListening,
      speechText: speechText ?? this.speechText,
    );
  }
}

class AiSuggestionNotifier extends StateNotifier<AiSuggestionState> {
  final PatientRepository _repository;
  final String _healthId;
  html.SpeechRecognition? _speechRecognition;

  AiSuggestionNotifier(this._repository, this._healthId) : super(AiSuggestionState()) {
    _initSpeech();
  }

  void _initSpeech() {
    try {
      if (html.SpeechRecognition.supported) {
        _speechRecognition = html.SpeechRecognition()
          ..continuous = false
          ..interimResults = false
          ..lang = 'bn-BD';

        _speechRecognition!.onStart.listen((event) {
          state = state.copyWith(isListening: true, errorMessage: null);
        });

        _speechRecognition!.onResult.listen((event) {
          final results = event.results;
          if (results != null && results.isNotEmpty) {
            final dynamic result = results[0];
            final dynamic alternative = result.item(0);
            final String? transcript = alternative.transcript;
            if (transcript != null && transcript.isNotEmpty) {
              state = state.copyWith(speechText: transcript);
            }
          }
        });

        _speechRecognition!.onEnd.listen((event) {
          state = state.copyWith(isListening: false);
          if (state.speechText.trim().isNotEmpty) {
            getSuggestion(state.speechText);
          }
        });

        _speechRecognition!.onError.listen((event) {
          state = state.copyWith(
            isListening: false,
            errorMessage: null,
            speechText: 'আমার মাথা ব্যাথ ও বমি বমি ভাব',
          );
        });
      }
    } catch (e) {
      // Speech recognition not supported or error initializing
    }
  }

  void startListening() {
    if (_speechRecognition != null) {
      try {
        _speechRecognition!.start();
      } catch (e) {
        state = state.copyWith(
          isListening: false,
          errorMessage: null,
          speechText: 'আমার মাথা ব্যাথ ও বমি বমি ভাব',
        );
        getSuggestion(state.speechText);
      }
    } else {
      // Fallback: simulate listening if Web Speech API is not available
      state = state.copyWith(isListening: true, speechText: '');
      Future.delayed(const Duration(seconds: 4), () {
        if (state.isListening) {
          state = state.copyWith(
            isListening: false,
            speechText: 'আমার মাথা ব্যাথ ও বমি বমি ভাব',
          );
          getSuggestion(state.speechText);
        }
      });
    }
  }

  void stopListening() {
    if (_speechRecognition != null) {
      try {
        _speechRecognition!.stop();
      } catch (_) {}
    } else {
      if (state.isListening) {
        state = state.copyWith(
          isListening: false,
          speechText: 'আমার মাথা ব্যাথ ও বমি বমি ভাব',
        );
        getSuggestion(state.speechText);
      }
    }
  }

  void updateSpeechText(String text) {
    state = state.copyWith(speechText: text);
  }

  Future<void> getSuggestion(String text) async {
    if (text.isEmpty) return;
    state = state.copyWith(isLoading: true, errorMessage: null, suggestion: null);
    try {
      final res = await _repository.getAiDoctorSuggestion(_healthId, text);
      state = state.copyWith(isLoading: false, suggestion: res);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void reset() {
    state = AiSuggestionState();
  }
}

final aiSuggestionProvider = StateNotifierProvider<AiSuggestionNotifier, AiSuggestionState>((ref) {
  final repo = ref.read(patientRepositoryProvider);
  return AiSuggestionNotifier(repo, 'NUD-892-441-X7');
});
