import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final donorStatusProvider =
    StateNotifierProvider<DonorStatusNotifier, bool>((ref) {
  return DonorStatusNotifier();
});

class DonorStatusNotifier extends StateNotifier<bool> {
  DonorStatusNotifier() : super(false) {
    _loadDonorStatus();
  }

  Future<void> _loadDonorStatus() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool('isDonor') ?? false;
  }

  // ignore: avoid_positional_boolean_parameters
  Future<void> setDonorStatus(bool isDonor) async {
    final prefs = await SharedPreferences.getInstance();
    state = isDonor;
    await prefs.setBool('isDonor', isDonor);
  }
}
