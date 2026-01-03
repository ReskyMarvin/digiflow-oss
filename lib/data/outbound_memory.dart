import 'package:hive_flutter/hive_flutter.dart';
import '../models/checking_list.dart';
import '../models/stuffing_control.dart';
import '../models/pallet.dart';

class OutboundMemory {
  static late Box<CheckingList> _checkingListBox;
  static late Box<StuffingControl> _stuffingControlBox;

  static bool _initialized = false;

  // Initialize Hive
  static Future<void> init() async {
    if (_initialized) return;

    await Hive.initFlutter();

    // Register Adapters
    Hive.registerAdapter(PalletAdapter());
    Hive.registerAdapter(CheckingListAdapter());
    Hive.registerAdapter(StuffingControlAdapter());

    // Open Boxes
    _checkingListBox = await Hive.openBox<CheckingList>('checking_lists');
    _stuffingControlBox = await Hive.openBox<StuffingControl>(
      'stuffing_controls',
    );

    _initialized = true;
  }

  // ===== CHECKING LIST =====
  static List<CheckingList> get checkingLists =>
      _checkingListBox.values.toList();

  static Future<void> addCheckingList(CheckingList list) async {
    await _checkingListBox.add(list);
  }

  static Future<void> updateCheckingList(CheckingList list) async {
    await list.save();
  }

  static Future<void> deleteCheckingList(CheckingList list) async {
    // Validate: check if has stuffing control
    final hasStuffing = stuffingControls.any(
      (s) => s.checkingListId == list.id,
    );

    if (hasStuffing) {
      throw Exception('Cannot delete: Checking List has Stuffing Control');
    }

    await list.delete();
  }

  // ===== STUFFING CONTROL =====
  static List<StuffingControl> get stuffingControls =>
      _stuffingControlBox.values.toList();

  static Future<void> addStuffingControl(StuffingControl control) async {
    await _stuffingControlBox.add(control);
  }

  static Future<void> updateStuffingControl(StuffingControl control) async {
    await control.save();
  }

  static Future<void> deleteStuffingControl(StuffingControl control) async {
    await control.delete();
  }

  // Helper: Check if CheckingList has StuffingControl
  static bool hasStuffingControl(CheckingList checkingList) {
    return stuffingControls.any((s) => s.checkingListId == checkingList.id);
  }

  // Helper: Get StuffingControl by CheckingList
  static StuffingControl? getStuffingControl(CheckingList checkingList) {
    try {
      return stuffingControls.firstWhere(
        (s) => s.checkingListId == checkingList.id,
      );
    } catch (e) {
      return null;
    }
  }

  // Helper: Get CheckingList Box (untuk akses di StuffingControl)
  static Box<CheckingList> get checkingListBox => _checkingListBox;
}
