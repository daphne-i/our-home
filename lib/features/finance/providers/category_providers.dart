import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homely/core/providers/firestore_providers.dart';
import 'package:homely/features/finance/data/category_service.dart';
import 'package:homely/features/finance/models/category_model.dart';
import 'package:homely/features/household/providers/household_providers.dart';

// The default list you wanted
const List<String> _defaultCategories = [
  'Groceries',
  'Rent',
  'Utilities',
  'Transport',
  'Dining Out',
  'Entertainment',
  'Shopping',
  'Other',
];

// 1. Provider for the CategoryService
final categoryServiceProvider = Provider<CategoryService>((ref) {
  return CategoryService(ref.watch(firestoreProvider));
});

// 2. Stream provider for the category list
final categoryListProvider = StreamProvider<List<CategoryModel>>((ref) {
  final categoryService = ref.watch(categoryServiceProvider);
  final householdId = ref.watch(currentUserModelProvider)?.householdId;

  if (householdId == null) {
    return Stream.value([]);
  }

  final stream = categoryService.getCategoriesStream(householdId);

  // --- This is the logic to create defaults ---
  // We listen to the stream, and on the first data event,
  // we check if the list is empty.
  stream.first.then((list) {
    if (list.isEmpty) {
      print('Creating default categories for household $householdId');
      categoryService.addDefaultCategories(householdId, _defaultCategories);
    }
  });
  // --- End of logic ---

  return stream;
});

// 3. StateNotifier for category actions
final categoryControllerProvider =
    StateNotifierProvider<CategoryController, bool>((ref) {
  return CategoryController(
    ref.watch(categoryServiceProvider),
    ref,
  );
});

class CategoryController extends StateNotifier<bool> {
  final CategoryService _categoryService;
  final Ref _ref;

  CategoryController(this._categoryService, this._ref) : super(false);

  String? get _householdId => _ref.read(currentUserModelProvider)?.householdId;

  Future<void> addCategory(String categoryName) async {
    state = true;
    try {
      if (_householdId == null) {
        throw Exception('User is not in a household.');
      }
      // Check for duplicates (case-insensitive)
      final currentList = _ref.read(categoryListProvider).value ?? [];
      final exists = currentList
          .any((cat) => cat.name.toLowerCase() == categoryName.toLowerCase());

      if (exists) {
        throw Exception('Category "$categoryName" already exists.');
      }

      await _categoryService.addCategory(
        householdId: _householdId!,
        categoryName: categoryName,
      );
    } finally {
      state = false;
    }
  }

  Future<void> deleteCategory(String categoryId) async {
    try {
      if (_householdId == null) {
        throw Exception('User is not in a household.');
      }
      await _categoryService.deleteCategory(
        householdId: _householdId!,
        categoryId: categoryId,
      );
    } catch (e) {
      print('Error deleting category: $e');
    }
  }
}
