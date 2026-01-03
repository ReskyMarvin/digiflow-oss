import 'package:flutter/material.dart';
import '../models/stuffing_control.dart';
import '../models/pallet.dart';
import '../models/checking_list.dart';
import '../data/outbound_memory.dart';
import 'qr_scan_screen.dart';

class StuffingControlDetailScreen extends StatefulWidget {
  final StuffingControl stuffing;

  const StuffingControlDetailScreen({super.key, required this.stuffing});

  @override
  State<StuffingControlDetailScreen> createState() =>
      _StuffingControlDetailScreenState();
}

class _StuffingControlDetailScreenState
    extends State<StuffingControlDetailScreen> {
  CheckingList? get sourceCheckingList {
    return widget.stuffing.getSourceCheckingList(
      OutboundMemory.checkingListBox,
    );
  }

  // ===== HAPUS SELURUH STUFFING CONTROL (HARD DELETE) =====
  void _confirmDeleteStuffingControl() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Stuffing Control'),
        content: const Text(
          'Semua data stuffing untuk checking list ini akan dihapus.\n\n'
          'Tindakan ini tidak bisa dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              // Simpan context sebelum async
              final navigator = Navigator.of(context);
              final scaffoldMessenger = ScaffoldMessenger.of(context);

              try {
                await OutboundMemory.deleteStuffingControl(widget.stuffing);

                navigator.pop(); // tutup dialog
                navigator.pop(); // kembali ke list stuffing

                scaffoldMessenger.showSnackBar(
                  const SnackBar(
                    content: Text('Stuffing Control berhasil dihapus'),
                  ),
                );
              } catch (e) {
                navigator.pop();
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text('Error: ${e.toString()}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  // ===== HAPUS 1 PALLET =====
  void _deleteSinglePallet(int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Pallet'),
        content: const Text(
          'Pallet ini akan dihapus dari stuffing.\n'
          'Tindakan ini tidak bisa dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              // Simpan context sebelum async
              final navigator = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);

              try {
                setState(() {
                  widget.stuffing.stuffedPallets.removeAt(index);
                });

                await OutboundMemory.updateStuffingControl(widget.stuffing);
                navigator.pop();

                messenger.showSnackBar(
                  const SnackBar(content: Text('Pallet berhasil dihapus')),
                );
              } catch (e) {
                navigator.pop();
                messenger.showSnackBar(
                  SnackBar(
                    content: Text('Error: ${e.toString()}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  // ===== SCAN PALLET =====
  void _scanPallet() async {
    if (sourceCheckingList == null) {
      if (!mounted) return;
      _showMsg('Error: Source Checking List tidak ditemukan');
      return;
    }

    try {
      final result = await Navigator.push<String>(
        context,
        MaterialPageRoute(builder: (_) => const QrScanScreen()),
      );

      if (!mounted) return; // ← FIX
      if (result == null || result.isEmpty) return;

      // Validate format with regex
      final regex = RegExp(r'^[\w]+-[\w]+$');
      if (!regex.hasMatch(result.trim())) {
        _showMsg('Format QR tidak valid. Gunakan format: BATCH-PALLET');
        return;
      }

      final parts = result.split('-');
      final batch = parts.first;
      final palletNo = parts.sublist(1).join('-');
      final scanned = Pallet(batch: batch, palletNo: palletNo);

      // Check if pallet exists in checking list
      final allowed = sourceCheckingList!.pallets.any(
        (p) => p.batch == scanned.batch && p.palletNo == scanned.palletNo,
      );

      if (!allowed) {
        _showMsg('Pallet tidak ada di Checking List');
        return;
      }

      // Check duplicate
      final duplicated = widget.stuffing.stuffedPallets.any(
        (p) => p.batch == scanned.batch && p.palletNo == scanned.palletNo,
      );

      if (duplicated) {
        _showMsg('Pallet sudah di-stuff');
        return;
      }

      setState(() {
        widget.stuffing.stuffedPallets.add(scanned);
      });

      await OutboundMemory.updateStuffingControl(widget.stuffing);

      if (!mounted) return; // ← FIX
      _showMsg('Pallet ditambahkan');
    } catch (e) {
      if (!mounted) return; // ← FIX
      _showMsg('Error: ${e.toString()}');
    }
  }

  void _showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final pallets = widget.stuffing.stuffedPallets;
    final checkingListName = sourceCheckingList?.name ?? 'Unknown';

    return Scaffold(
      appBar: AppBar(
        title: Text('Stuffing - $checkingListName'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _confirmDeleteStuffingControl,
          ),
        ],
      ),
      body: pallets.isEmpty
          ? const Center(child: Text('Belum ada pallet di-stuff'))
          : ListView.builder(
              itemCount: pallets.length,
              itemBuilder: (context, index) {
                final p = pallets[index];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 14,
                      backgroundColor: Colors.green.shade200,
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    title: Text('${p.batch}-${p.palletNo}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => _deleteSinglePallet(index),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _scanPallet,
        child: const Icon(Icons.qr_code_scanner),
      ),
    );
  }
}
