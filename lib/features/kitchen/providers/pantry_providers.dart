import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homely/core/providers/firestore_providers.dart';
import 'package:homely/features/household/providers/household_providers.dart';
import 'package:homely/features/kitchen/data/pantry_service.dart';
import 'package:homely/features/kitchen/models/pantry_item_model.dart';

// 1. Provider for the PantryService
final pantryServiceProvider = Provider<PantryService>((ref) {
  return PantryService(ref.watch(firestoreProvider));
});

// 2. Stream provider for the list of pantry items
final pantryListProvider = StreamProvider<List<PantryItemModel>>((ref) {
  final pantryService = ref.watch(pantryServiceProvider);
  final userModel = ref.watch(currentUserModelProvider);
  final householdId = userModel?.householdId;

  if (householdId == null) {
    return Stream.value([]);
  }
  return pantryService.getPantryStream(householdId);
});

// 3. StateNotifier for pantry actions (add, delete)
final pantryControllerProvider =
    StateNotifierProvider<PantryController, bool>((ref) {
  return PantryController(
    ref.watch(pantryServiceProvider),
    ref,
  );
});

class PantryController extends StateNotifier<bool> {
  final PantryService _pantryService;
  final Ref _ref;

  PantryController(this._pantryService, this._ref) : super(false);

  String? get _householdId => _ref.read(currentUserModelProvider)?.householdId;

  Future<void> addItem(PantryItemModel item) async {
    state = true;
    try {
      if (_householdId == null) {
        throw Exception('User is not in a household.');
      }
      await _pantryService.addItem(
        householdId: _householdId!,
        item: item,
      );
    } finally {
      state = false;
    }
  }

  Future<void> deleteItem(String itemId) async {
    // No loading state for quick delete
    try {
      if (_householdId == null) {
        throw Exception('User is not in a household.');
      }
      await _pantryService.deleteItem(
        householdId: _householdId!,
        itemId: itemId,
      );
    } catch (e) {
      // Handle error, e.g., show a snackbar
      print('Error deleting item: $e');
    }
  }

  Future<void> updateItem(PantryItemModel item) async {
    // No loading state for quick update
    try {
      if (_householdId == null) {
        throw Exception('User is not in a household.');
      }
      await _pantryService.updateItem(
        householdId: _householdId!,
        item: item,
      );
    } catch (e) {
      // Handle error
      print('Error updating item: $e');
    }
  }
}
