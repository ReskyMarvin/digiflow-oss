import 'qr_scan_screen.dart';
import 'package:flutter/material.dart';
import '../models/pallet.dart';
import '../data/outbound_memory.dart';
import '../models/checking_list.dart';

class ImportPalletScreen extends StatefulWidget {
  final CheckingList? editingList;

  const ImportPalletScreen({super.key, this.editingList});

  @override
  State<ImportPalletScreen> createState() => _ImportPalletScreenState();
}

class _ImportPalletScreenState extends State<ImportPalletScreen> {
  final TextEditingController controller = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  void _scanQrAndAppend() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const QrScanScreen()),
    );

    if (result == null || result.trim().isEmpty) return;

    setState(() {
      if (controller.text.trim().isEmpty) {
        controller.text = result.trim();
      } else {
        controller.text = '${controller.text.trim()}\n${result.trim()}';
      }
    });
  }

  @override
  void initState() {
    super.initState();

    // EDIT MODE: preload data
    if (widget.editingList != null) {
      nameController.text = widget.editingList!.name;
      controller.text = widget.editingList!.pallets
          .map((p) => '${p.batch}-${p.palletNo}')
          .join('\n');
    }
  }

  List<Pallet> parseData(String text) {
    final lines = text.trim().split('\n');
    final List<Pallet> pallets = [];

    for (final line in lines) {
      if (line.trim().isEmpty) continue;
      if (!line.contains('-')) continue;

      final parts = line.split('-');
      if (parts.length != 2) continue;

      pallets.add(Pallet(batch: parts[0].trim(), palletNo: parts[1].trim()));
    }

    return pallets;
  }

  void handleSave() async {
    final pallets = parseData(controller.text);

    if (pallets.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Data pallet tidak valid')));
      return;
    }

    final name = nameController.text.trim().isEmpty
        ? widget.editingList?.name ?? 'Checking List'
        : nameController.text.trim();

    // Simpan context sebelum async
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    try {
      // =====================
      // EDIT MODE
      // =====================
      if (widget.editingList != null) {
        setState(() {
          widget.editingList!.name = name;
          widget.editingList!.pallets
            ..clear()
            ..addAll(pallets);
        });

        await OutboundMemory.updateCheckingList(widget.editingList!);

        messenger.showSnackBar(
          const SnackBar(content: Text('Checking list berhasil diperbarui')),
        );
      }
      // =====================
      // CREATE MODE
      // =====================
      else {
        final index = OutboundMemory.checkingLists.length + 1;

        final newList = CheckingList(
          name: name.isEmpty ? 'Checking List $index' : name,
          pallets: pallets,
        );

        await OutboundMemory.addCheckingList(newList);

        messenger.showSnackBar(
          SnackBar(content: Text('$name berhasil di-import')),
        );
      }

      navigator.pop();
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final pallets = parseData(controller.text);
    final isEditMode = widget.editingList != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Edit Pallet' : 'Import Checking List'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Format: BATCH-PALLET'),
            const SizedBox(height: 8),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text('SCAN QR'),
                onPressed: _scanQrAndAppend,
              ),
            ),
            const SizedBox(height: 8),

            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nama Checking List',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: controller,
              maxLines: 6,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Contoh: 1AR2070727-001',
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Total pallet: ${pallets.length}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Expanded(
              child: ListView.builder(
                itemCount: pallets.length,
                itemBuilder: (context, index) {
                  final p = pallets[index];
                  return Text('${index + 1}. ${p.batch}-${p.palletNo}');
                },
              ),
            ),

            const SizedBox(height: 8),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: handleSave,
                child: Text(isEditMode ? 'SAVE CHANGES' : 'IMPORT'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
