import 'package:hive/hive.dart';

part 'pallet.g.dart';

@HiveType(typeId: 0)
class Pallet extends HiveObject {
  @HiveField(0)
  final String batch;

  @HiveField(1)
  final String palletNo;

  Pallet({required this.batch, required this.palletNo})
    : assert(batch.isNotEmpty, 'Batch cannot be empty'),
      assert(palletNo.isNotEmpty, 'PalletNo cannot be empty');

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Pallet &&
          runtimeType == other.runtimeType &&
          batch == other.batch &&
          palletNo == other.palletNo;

  @override
  int get hashCode => batch.hashCode ^ palletNo.hashCode;
}
