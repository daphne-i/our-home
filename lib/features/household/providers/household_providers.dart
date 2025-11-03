import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homely/core/providers/firestore_providers.dart';
import 'package:homely/features/auth/domain/user_model.dart';
import 'package:homely/features/auth/providers/auth_providers.dart';
import 'package:homely/features/household/data/household_service.dart';
import 'package:homely/features/household/models/household_model.dart';

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

// 1. Provider to get the current user's Household object
final householdProvider = StreamProvider<HouseholdModel?>((ref) {
  final firestore = ref.watch(firestoreProvider);
  final authUser = ref.watch(authStateProvider).value;

  if (authUser == null) {
    return Stream.value(null);
  }

  final userAsync = ref.watch(userProvider(authUser.uid));
  final user = userAsync.value;

  // Get the householdId from the user. If null, return null.
  final householdId = user?.householdId;
  if (householdId == null) {
    return Stream.value(null);
  }

  // Stream the household document
  return firestore
      .collection('households')
      .doc(householdId)
      .snapshots()
      .map((doc) => doc.exists ? HouseholdModel.fromFirestore(doc) : null);
});

// 2. Provider to get the list of members in the current household
final householdMembersProvider = StreamProvider<List<UserModel>>((ref) {
  final household = ref.watch(householdProvider);
  final memberIds = household.valueOrNull?.members;

  if (memberIds == null || memberIds.isEmpty) {
    return Stream.value([]);
  }

  // Instead of using whereIn (which might have permission issues),
  // we'll watch individual user providers for each member
  final memberStreams = memberIds.map((uid) {
    return ref.watch(userProvider(uid));
  }).toList();

  // Combine all the individual user streams
  // Filter out null values (users that don't exist or failed to load)
  final members = memberStreams
      .where((userAsync) => userAsync.hasValue && userAsync.value != null)
      .map((userAsync) => userAsync.value!)
      .toList();

  return Stream.value(members);
});
