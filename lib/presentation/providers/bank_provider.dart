import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../constants/app_strings.dart';
import '../../data/hive/models/bank_model.dart';
import '../../data/hive/storage/bank_storage.dart';

final bankBoxProvider = Provider<Box<BankModel>>((ref) {
  return BankStorage.getBox();
});

final bankProvider = AsyncNotifierProvider<BankNotifier, List<BankModel>>(
  BankNotifier.new,
);

class BankNotifier extends AsyncNotifier<List<BankModel>> {
  Box<BankModel> get _box => ref.read(bankBoxProvider);

  @override
  Future<List<BankModel>> build() async {
    try {
      _box.listenable().addListener(_onBoxChange);
      final banks =
          _box.values.toList()..sort((a, b) {
            if (a.name == 'Other') return 1;
            if (b.name == 'Other') return -1;
            return a.name.compareTo(b.name);
          });
      return banks;
    } catch (e) {
      throw Exception('${AppStrings.bankLoadError}: $e');
    }
  }

  void _onBoxChange() {
    try {
      final newBanks =
          _box.values.toList()..sort((a, b) {
            if (a.name == 'Other') return 1;
            if (b.name == 'Other') return -1;
            return a.name.compareTo(b.name);
          });
      if (state.valueOrNull != newBanks) {
        state = AsyncValue.data(newBanks);
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  BankModel getById(String id) {
    final banks = state.valueOrNull ?? [];
    return banks.firstWhere(
      (bank) => bank.id == id,
      orElse: () => throw Exception(AppStrings.invalidBankError),
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    try {
      final banks =
          _box.values.toList()..sort((a, b) {
            if (a.name == 'Other') return 1;
            if (b.name == 'Other') return -1;
            return a.name.compareTo(b.name);
          });
      state = AsyncValue.data(banks);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}
