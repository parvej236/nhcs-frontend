import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../network/api_endpoints.dart';
import 'dio_provider.dart';

final publicStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final dio = ref.watch(dioProvider);
  final res = await dio.get(ApiEndpoints.publicStats);
  return res.data as Map<String, dynamic>;
});

final publicDoctorsProvider = FutureProvider<List<dynamic>>((ref) async {
  final dio = ref.watch(dioProvider);
  try {
    final res = await dio.get(ApiEndpoints.publicDoctors);
    if (res.data is List) {
      return res.data as List;
    }
  } catch (e) {
    // return empty or handle error
  }
  return [];
});

const List<Map<String, dynamic>> mockPreviewDoctors = [
  {
    'id': '1000',
    'name': 'Dr. Tariq Ali',
    'specialization': 'Gynaecology & Obstetrics',
    'hospital': 'BIRDEM General Hospital',
    'rating': 4.46,
    'experience': 27,
    'fee': 600,
    'queueCount': 0,
  },
  {
    'id': '1001',
    'name': 'Dr. Simin Siddique',
    'specialization': 'Urology',
    'hospital': 'Kurmitola General Hospital',
    'rating': 4.68,
    'experience': 8,
    'fee': 600,
    'queueCount': 0,
  },
  {
    'id': '1002',
    'name': 'Dr. Keya Rahman',
    'specialization': 'Urology',
    'hospital': 'Anwer Khan Modern Medical College Hospital',
    'rating': 4.43,
    'experience': 18,
    'fee': 600,
    'queueCount': 0,
  },
  {
    'id': '1003',
    'name': 'Dr. Rahim Akter',
    'specialization': 'General Surgery',
    'hospital': 'Apollo Imperial Hospital',
    'rating': 4.8,
    'experience': 6,
    'fee': 600,
    'queueCount': 0,
  },
  {
    'id': '1004',
    'name': 'Dr. Selim Hasan',
    'specialization': 'General Medicine',
    'hospital': 'Anwer Khan Modern Medical College Hospital',
    'rating': 4.86,
    'experience': 8,
    'fee': 500,
    'queueCount': 0,
  },
  {
    'id': '1005',
    'name': 'Dr. Mahbub Ali',
    'specialization': 'Endocrinology & Diabetology',
    'hospital': 'Dhaka Medical College Hospital',
    'rating': 4.24,
    'experience': 24,
    'fee': 1200,
    'queueCount': 0,
  },
  {
    'id': '1006',
    'name': 'Dr. Nusrat Begum',
    'specialization': 'Urology',
    'hospital': 'National Cancer Research Institute & Hospital',
    'rating': 4.75,
    'experience': 15,
    'fee': 700,
    'queueCount': 0,
  },
  {
    'id': '1007',
    'name': 'Dr. Sadia Begum',
    'specialization': 'Urology',
    'hospital': 'National Medical Center',
    'rating': 4.9,
    'experience': 12,
    'fee': 800,
    'queueCount': 0,
  },
  {
    'id': '1008',
    'name': 'Dr. Sana Ahmed',
    'specialization': 'ENT',
    'hospital': 'Square Hospitals Ltd.',
    'rating': 4.65,
    'experience': 14,
    'fee': 1000,
    'queueCount': 0,
  },
  {
    'id': '1009',
    'name': 'Dr. Rafiq Hasan',
    'specialization': 'Orthopedics',
    'hospital': 'Mugda Medical College Hospital',
    'rating': 4.5,
    'experience': 11,
    'fee': 600,
    'queueCount': 0,
  },
];

class VitalsAnalysisState {
  final bool isLoading;
  final String? error;
  final Map<String, dynamic>? result;

  const VitalsAnalysisState({
    this.isLoading = false,
    this.error,
    this.result,
  });

  VitalsAnalysisState copyWith({
    bool? isLoading,
    String? error,
    Map<String, dynamic>? result,
    bool clearResult = false,
  }) {
    return VitalsAnalysisState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      result: clearResult ? null : (result ?? this.result),
    );
  }
}

class VitalsAnalysisNotifier extends StateNotifier<VitalsAnalysisState> {
  final Dio _dio;

  VitalsAnalysisNotifier(this._dio) : super(const VitalsAnalysisState());

  Future<void> analyze({
    required String symptomsText,
    int? bpSystolic,
    int? bpDiastolic,
    double? glucose,
  }) async {
    state = state.copyWith(isLoading: true, error: null, clearResult: true);
    try {
      final res = await _dio.post(
        ApiEndpoints.publicVitalsAnalyze,
        data: {
          'symptomsText': symptomsText,
          'bpSystolic': ?bpSystolic,
          'bpDiastolic': ?bpDiastolic,
          'glucose': ?glucose,
        },
      );
      state = state.copyWith(isLoading: false, result: res.data);
    } catch (e) {
      String errorMessage = 'Vitals analysis failed. Please try again.';
      if (e is DioException) {
        if (e.response != null && e.response?.data != null) {
          errorMessage = e.response?.data['message'] ?? errorMessage;
        } else {
          errorMessage = e.message ?? errorMessage;
        }
      }
      state = state.copyWith(isLoading: false, error: errorMessage);
    }
  }

  void reset() {
    state = const VitalsAnalysisState();
  }
}

final vitalsAnalysisProvider = StateNotifierProvider<VitalsAnalysisNotifier, VitalsAnalysisState>((ref) {
  return VitalsAnalysisNotifier(ref.watch(dioProvider));
});
