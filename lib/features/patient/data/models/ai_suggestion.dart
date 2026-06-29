import 'appointment.dart';

class SuggestedHospital {
  final String name;
  final String distance;
  final String address;

  SuggestedHospital({
    required this.name,
    required this.distance,
    required this.address,
  });

  factory SuggestedHospital.fromJson(Map<String, dynamic> json) {
    return SuggestedHospital(
      name: json['name'] as String? ?? '',
      distance: json['distance'] as String? ?? '',
      address: json['address'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'distance': distance,
      'address': address,
    };
  }
}

class AiSuggestionResponse {
  final String summaryEn;
  final String summaryBn;
  final String specialization;
  final List<SuggestedHospital> suggestedHospitals;
  final List<DoctorSpecialist> suggestedDoctors;

  AiSuggestionResponse({
    required this.summaryEn,
    required this.summaryBn,
    required this.specialization,
    required this.suggestedHospitals,
    required this.suggestedDoctors,
  });

  factory AiSuggestionResponse.fromJson(Map<String, dynamic> json) {
    var hospitalsList = json['suggestedHospitals'] as List<dynamic>? ?? [];
    var doctorsList = json['suggestedDoctors'] as List<dynamic>? ?? [];

    return AiSuggestionResponse(
      summaryEn: json['summaryEn'] as String? ?? '',
      summaryBn: json['summaryBn'] as String? ?? '',
      specialization: json['specialization'] as String? ?? '',
      suggestedHospitals: hospitalsList.map((e) => SuggestedHospital.fromJson(e as Map<String, dynamic>)).toList(),
      suggestedDoctors: doctorsList.map((e) => DoctorSpecialist.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'summaryEn': summaryEn,
      'summaryBn': summaryBn,
      'specialization': specialization,
      'suggestedHospitals': suggestedHospitals.map((e) => e.toJson()).toList(),
      'suggestedDoctors': suggestedDoctors.map((e) => e.toJson()).toList(),
    };
  }
}
