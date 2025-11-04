import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homely/core/providers/firestore_providers.dart';
import 'package:homely/features/household/providers/household_providers.dart';
import 'package:homely/features/vault/data/vault_service.dart';
import 'package:homely/features/vault/models/vault_item_model.dart';

// --- 1. IMPORT TASK MODEL AND SERVICE ---
import 'package:homely/features/tasks/domain/task_model.dart';
import 'package:homely/features/tasks/data/task_service.dart';

// Provider for the VaultService
final vaultServiceProvider = Provider<VaultService>((ref) {
  return VaultService(ref.watch(firestoreProvider));
});

// Stream provider for the list of vault items
final vaultListProvider = StreamProvider<List<VaultItemModel>>((ref) {
  final vaultService = ref.watch(vaultServiceProvider);
  final householdId = ref.watch(currentUserModelProvider)?.householdId;

  if (householdId == null) {
    return Stream.value([]);
  }
  return vaultService.getVaultItemsStream(householdId);
});

// StateNotifier for vault actions
final vaultControllerProvider =
    StateNotifierProvider<VaultController, bool>((ref) {
  return VaultController(
    ref.watch(vaultServiceProvider),
    TaskService(ref.watch(firestoreProvider)), // For the "magic"
    ref,
  );
});

class VaultController extends StateNotifier<bool> {
  final VaultService _vaultService;
  final TaskService _taskService; // For the "magic"
  final Ref _ref;

  VaultController(this._vaultService, this._taskService, this._ref)
      : super(false);

  String? get _householdId => _ref.read(currentUserModelProvider)?.householdId;

  Future<void> addVaultItem(VaultItemModel item) async {
    state = true;
    try {
      if (_householdId == null) {
        throw Exception('User is not in a household.');
      }
      await _vaultService.addVaultItem(
        householdId: _householdId!,
        item: item,
      );

      // --- 2. THE "MAGIC" [cite: 132-134] ---
      // If it's a warranty with an expiry date, create a reminder
      if (item.type == 'Warranty' && item.expiryDate != null) {
        // Create reminder 30 days before expiry
        final reminderDate =
            item.expiryDate!.toDate().subtract(const Duration(days: 30));

        // Only create a reminder if the date is in the future
        if (reminderDate.isAfter(DateTime.now())) {
          final reminderTask = TaskModel(
            name: '${item.name} warranty expires in 30 days',
            dueDate: item.expiryDate!,
            isRepeating: false,
            type: 'Reminder', // As per your schema
            sourceId: item.id, // Will be null on creation, but that's okay
          );

          await _taskService.addTask(
            householdId: _householdId!,
            task: reminderTask,
          );
        }
      }
      // --- END MAGIC ---
    } finally {
      state = false;
    }
  }

  Future<void> deleteVaultItem(String itemId) async {
    try {
      if (_householdId == null) {
        throw Exception('User is not in a household.');
      }
      await _vaultService.deleteVaultItem(
        householdId: _householdId!,
        itemId: itemId,
      );
      // TODO: Also delete associated reminder task if it exists
    } catch (e) {
      print('Error deleting vault item: $e');
    }
  }
}
