import 'package:flutter/material.dart';
import '../data/outbound_memory.dart';
import '../models/checking_list.dart';
import 'checking_list_detail_screen.dart';
import 'import_pallet_screen.dart';

enum CheckingListAction { rename, editPallet, delete }

class CheckingListScreen extends StatefulWidget {
  const CheckingListScreen({super.key});

  @override
  State<CheckingListScreen> createState() => _CheckingListScreenState();
}

class _CheckingListScreenState extends State<CheckingListScreen> {
  @override
  Widget build(BuildContext context) {
    final lists = OutboundMemory.checkingLists;

    return Scaffold(
      appBar: AppBar(title: const Text('Checking List')),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Tambah'),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ImportPalletScreen()),
          ).then((_) => setState(() {}));
        },
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // MOBILE FIRST
            final isWide = constraints.maxWidth >= 600;

            if (lists.isEmpty) {
              return _EmptyState(
                onCreate: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ImportPalletScreen(),
                    ),
                  ).then((_) => setState(() {}));
                },
              );
            }

            return Padding(
              padding: const EdgeInsets.all(16),
              child: ListView.separated(
                itemCount: lists.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final cl = lists[index];
                  return _CheckingListCard(
                    checkingList: cl,
                    dense: !isWide,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              CheckingListDetailScreen(checkingList: cl),
                        ),
                      );
                    },
                    onAction: (action) {
                      if (action == CheckingListAction.rename) {
                        _showRenameDialog(cl);
                      } else if (action == CheckingListAction.editPallet) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ImportPalletScreen(editingList: cl),
                          ),
                        ).then((_) => setState(() {}));
                      } else if (action == CheckingListAction.delete) {
                        _showDeleteDialog(cl);
                      }
                    },
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  // =========================
  // RENAME
  // =========================
  void _showRenameDialog(CheckingList cl) {
    final controller = TextEditingController(text: cl.name);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Rename Checking List'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Nama checking list'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newName = controller.text.trim();
              if (newName.isEmpty) return;

              // simpan context sebelum async
              final navigator = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);

              try {
                setState(() {
                  cl.name = newName;
                });

                // 🔑 INI YANG SEBELUMNYA HILANG
                await OutboundMemory.updateCheckingList(cl);

                navigator.pop();
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('Nama checking list diperbarui'),
                  ),
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
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  // =========================
  // DELETE
  // =========================
  void _showDeleteDialog(CheckingList cl) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Checking List'),
        content: const Text('Checking list akan dihapus permanen. Lanjutkan?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);

              try {
                await OutboundMemory.deleteCheckingList(cl);
                setState(() {});
                navigator.pop();
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('Checking List berhasil dihapus'),
                  ),
                );
              } catch (e) {
                navigator.pop();
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(e.toString().replaceAll('Exception: ', '')),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}

/* =========================
   EMPTY STATE
   ========================= */

class _EmptyState extends StatelessWidget {
  final VoidCallback onCreate;

  const _EmptyState({required this.onCreate});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.list_alt, size: 56, color: Colors.white54),
            const SizedBox(height: 12),
            const Text('Belum ada checking list'),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Create Checking List'),
              onPressed: onCreate,
            ),
          ],
        ),
      ),
    );
  }
}

/* =========================
   CARD
   ========================= */

class _CheckingListCard extends StatelessWidget {
  final CheckingList checkingList;
  final VoidCallback onTap;
  final void Function(CheckingListAction) onAction;
  final bool dense;

  const _CheckingListCard({
    required this.checkingList,
    required this.onTap,
    required this.onAction,
    required this.dense,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(dense ? 16 : 20),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: dense ? 18 : 20,
              backgroundColor: Colors.black12,
              child: const Icon(Icons.list, color: Colors.black),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    checkingList.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${checkingList.pallets.length} pallet',
                    style: const TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ),
            PopupMenuButton<CheckingListAction>(
              onSelected: onAction,
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: CheckingListAction.rename,
                  child: Text('Rename'),
                ),
                PopupMenuItem(
                  value: CheckingListAction.editPallet,
                  child: Text('Edit Pallet'),
                ),
                PopupMenuItem(
                  value: CheckingListAction.delete,
                  child: Text('Delete'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
