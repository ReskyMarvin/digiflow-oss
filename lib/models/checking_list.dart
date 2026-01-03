import 'package:hive/hive.dart';
import 'pallet.dart';

part 'checking_list.g.dart';

@HiveType(typeId: 1)
class CheckingList extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  final List<Pallet> pallets;

  @HiveField(2)
  final String id; // Unique ID untuk referensi

  CheckingList({required this.name, required this.pallets, String? id})
    : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CheckingList &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
