import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homely/core/providers/firestore_providers.dart';
import 'package:homely/features/auth/providers/auth_providers.dart';
import 'package:homely/features/household/providers/household_providers.dart';
import 'package:homely/features/kitchen/data/shopping_list_service.dart';
import 'package:homely/features/kitchen/models/shopping_list_item_model.dart';

// Provider for the ShoppingListService
final shoppingListServiceProvider = Provider<ShoppingListService>((ref) {
  return ShoppingListService(ref.watch(firestoreProvider));
});

// This provider streams the list of shopping items
final shoppingListProvider = StreamProvider<List<ShoppingListItemModel>>((ref) {
  final service = ref.watch(shoppingListServiceProvider);
  final householdId = ref.watch(currentUserModelProvider.select(
    (userModel) => userModel?.householdId,
  ));

  if (householdId == null) {
    return Stream.value([]);
  }
  return service.getShoppingListStream(householdId);
});

// StateNotifier for shopping list actions
final shoppingListControllerProvider =
    StateNotifierProvider<ShoppingListController, bool>((ref) {
  return ShoppingListController(
    ref.watch(shoppingListServiceProvider),
    ref,
  );
});

class ShoppingListController extends StateNotifier<bool> {
  final ShoppingListService _service;
  final Ref _ref;

  ShoppingListController(this._service, this._ref) : super(false);

  // Helper getters
  String? get _householdId => _ref.read(currentUserModelProvider)?.householdId;
  String? get _userId => _ref.read(authStateProvider).value?.uid;

  Future<void> addItem(String name, String? quantity) async {
    state = true;
    try {
      if (_householdId == null || _userId == null) {
        throw Exception('User is not associated with a household.');
      }
      final newItem = ShoppingListItemModel(
        name: name,
        quantity: quantity,
        addedBy: _userId!,
      );
      await _service.addItem(householdId: _householdId!, item: newItem);
    } finally {
      state = false;
    }
  }

  Future<void> toggleItemStatus(ShoppingListItemModel item) async {
    try {
      if (_householdId == null) throw Exception('No household found.');
      final updatedItem = item.copyWith(isChecked: !item.isChecked);
      await _service.updateItem(householdId: _householdId!, item: updatedItem);
    } catch (e) {
      print('Error toggling item: $e');
    }
  }

  Future<void> deleteItem(ShoppingListItemModel item) async {
    try {
      if (_householdId == null || item.id == null) {
        throw Exception('Cannot delete item.');
      }
      await _service.deleteItem(householdId: _householdId!, itemId: item.id!);
    } catch (e) {
      print('Error deleting item: $e');
    }
  }

  Future<void> clearCheckedItems() async {
    try {
      if (_householdId == null) throw Exception('No household found.');
      await _service.clearCheckedItems(householdId: _householdId!);
    } catch (e) {
      print('Error clearing checked items: $e');
    }
  }
}
