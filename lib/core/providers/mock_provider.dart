import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

// Global toggle for mock mode vs remote API mode
final isMockModeProvider = StateProvider<bool>((ref) => true);
