import 'package:flutter/material.dart';
import '../data/outbound_memory.dart';
import 'stuffing_control_detail_screen.dart';

class StuffingControlScreen extends StatelessWidget {
  const StuffingControlScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = OutboundMemory.stuffingControls;

    return Scaffold(
      appBar: AppBar(title: const Text('Stuffing Control')),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 600;

            if (items.isEmpty) {
              return const _EmptyState();
            }

            return Padding(
              padding: const EdgeInsets.all(16),
              child: ListView.separated(
                itemCount: items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final s = items[index];
                  final checkingList = s.getSourceCheckingList(
                    OutboundMemory.checkingListBox,
                  );

                  return _StuffingControlCard(
                    title: checkingList?.name ?? 'Unknown',
                    stuffedCount: s.stuffedPallets.length,
                    dense: !isWide,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              StuffingControlDetailScreen(stuffing: s),
                        ),
                      );
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
}

/* =========================
   EMPTY STATE
   ========================= */

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.inventory_2_outlined, size: 56, color: Colors.white54),
            SizedBox(height: 12),
            Text('Belum ada Stuffing Control'),
          ],
        ),
      ),
    );
  }
}

/* =========================
   CARD
   ========================= */

class _StuffingControlCard extends StatelessWidget {
  final String title;
  final int stuffedCount;
  final VoidCallback onTap;
  final bool dense;

  const _StuffingControlCard({
    required this.title,
    required this.stuffedCount,
    required this.onTap,
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
              child: const Icon(Icons.inventory, color: Colors.black),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
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
                    'Stuffed: $stuffedCount pallet',
                    style: const TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.black54),
          ],
        ),
      ),
    );
  }
}
