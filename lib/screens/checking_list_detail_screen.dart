import 'package:flutter/material.dart';
import '../models/checking_list.dart';
import '../data/outbound_memory.dart';
import '../models/stuffing_control.dart';

class CheckingListDetailScreen extends StatefulWidget {
  final CheckingList checkingList;
  final bool editable;

  const CheckingListDetailScreen({
    super.key,
    required this.checkingList,
    this.editable = false,
  });

  @override
  State<CheckingListDetailScreen> createState() =>
      _CheckingListDetailScreenState();
}

class _CheckingListDetailScreenState extends State<CheckingListDetailScreen> {
  bool get _hasStuffingControl {
    return OutboundMemory.hasStuffingControl(widget.checkingList);
  }

  void _createStuffingControl() async {
    if (_hasStuffingControl) return;

    try {
      final stuffing = StuffingControl(checkingListId: widget.checkingList.id);
      await OutboundMemory.addStuffingControl(stuffing);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Stuffing Control berhasil dibuat')),
      );
      setState(() {});
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final pallets = widget.checkingList.pallets;

    return Scaffold(
      appBar: AppBar(title: Text(widget.checkingList.name)),
      body: SafeArea(
        child: pallets.isEmpty
            ? const Center(child: Text('Belum ada pallet'))
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: pallets.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final p = pallets[index];
                  return _PalletCard(
                    index: index,
                    code: '${p.batch}-${p.palletNo}',
                    editable: widget.editable,
                    onDelete: () async {
                      setState(() {
                        pallets.removeAt(index);
                      });
                      await OutboundMemory.updateCheckingList(
                        widget.checkingList,
                      );
                    },
                  );
                },
              ),
      ),
      bottomNavigationBar: widget.editable
          ? null
          : Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: _hasStuffingControl ? null : _createStuffingControl,
                child: Text(
                  _hasStuffingControl
                      ? 'Stuffing Control sudah dibuat'
                      : 'Create Stuffing Control',
                ),
              ),
            ),
    );
  }
}

class _PalletCard extends StatelessWidget {
  final int index;
  final String code;
  final bool editable;
  final Future<void> Function() onDelete;

  const _PalletCard({
    required this.index,
    required this.code,
    required this.editable,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.black12,
            child: Text(
              '${index + 1}',
              style: const TextStyle(
                color: Colors.black,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              code,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (editable)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () async {
                await onDelete();
              },
            ),
        ],
      ),
    );
  }
}
