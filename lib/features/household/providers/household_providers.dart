import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homely/core/providers/firestore_providers.dart';
import 'package:homely/features/auth/domain/user_model.dart';
import 'package:homely/features/auth/providers/auth_providers.dart';
import 'package:homely/features/household/data/household_service.dart';

// Provider for the HouseholdService
final householdServiceProvider = Provider<HouseholdService>((ref) {
  return HouseholdService(
    ref.watch(firestoreProvider),
  );
});

// This provider gives us the full UserModel object for the *current* user
// This is useful for passing to our household service
final currentUserModelProvider = Provider<UserModel?>((ref) {
  final authUser = ref.watch(authStateProvider).value;
  if (authUser == null) return null;
  return ref.watch(userProvider(authUser.uid)).value;
});

// StateNotifier for household actions (create, join)
final householdControllerProvider =
    StateNotifierProvider<HouseholdController, bool>((ref) {
  return HouseholdController(
    ref.watch(householdServiceProvider),
    ref,
  );
});

class HouseholdController extends StateNotifier<bool> {
  final HouseholdService _householdService;
  final Ref _ref;

  HouseholdController(this._householdService, this._ref) : super(false);

  Future<void> createHousehold(String householdName) async {
    state = true;
    try {
      final user = _ref.read(currentUserModelProvider);
      if (user == null) {
        throw Exception('No user is logged in.');
      }
      await _householdService.createHousehold(
        householdName: householdName,
        user: user,
      );

      // Force refresh the user provider to immediately detect the householdId change
      _ref.invalidate(userProvider(user.uid));
    } finally {
      state = false;
    }
  }

  Future<void> joinHousehold(String inviteCode) async {
    state = true;
    try {
      final user = _ref.read(currentUserModelProvider);
      if (user == null) {
        throw Exception('No user is logged in.');
      }
      await _householdService.joinHousehold(
        inviteCode: inviteCode,
        user: user,
      );

      // Force refresh the user provider to immediately detect the householdId change
      _ref.invalidate(userProvider(user.uid));
    } finally {
      state = false;
    }
  }
}
