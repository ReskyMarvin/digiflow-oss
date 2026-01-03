import 'package:hive/hive.dart';
import 'pallet.dart';
import 'checking_list.dart';

part 'stuffing_control.g.dart';

@HiveType(typeId: 2)
class StuffingControl extends HiveObject {
  @HiveField(0)
  final String checkingListId; // Store ID instead of object

  @HiveField(1)
  final List<Pallet> stuffedPallets;

  StuffingControl({required this.checkingListId, List<Pallet>? stuffedPallets})
    : stuffedPallets = stuffedPallets ?? [];

  // Helper to get CheckingList from storage
  CheckingList? getSourceCheckingList(Box<CheckingList> checkingListBox) {
    return checkingListBox.values.firstWhere(
      (cl) => cl.id == checkingListId,
      orElse: () => CheckingList(name: 'Deleted', pallets: []),
    );
  }
}
