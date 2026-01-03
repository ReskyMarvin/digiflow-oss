import 'package:flutter/material.dart';
import 'checking_list_screen.dart';
import 'stuffing_control_screen.dart';

class OutboundMenuScreen extends StatelessWidget {
  const OutboundMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Outbound')),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // MOBILE FIRST
            int crossAxisCount = 1;

            // Hook masa depan
            if (constraints.maxWidth >= 600) {
              crossAxisCount = 2;
            }

            return Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.builder(
                itemCount: _menuItems.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 2.8, // Card tinggi & nyaman di-tap
                ),
                itemBuilder: (context, index) {
                  final item = _menuItems[index];
                  return _OutboundMenuCard(item: item);
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
   MENU DATA
   ========================= */

final List<_OutboundMenuItem> _menuItems = [
  _OutboundMenuItem(
    title: 'Checking List',
    icon: Icons.list_alt,
    onTapBuilder: (context) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const CheckingListScreen()),
      );
    },
  ),
  _OutboundMenuItem(
    title: 'Stuffing Control',
    icon: Icons.inventory_2_outlined,
    onTapBuilder: (context) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const StuffingControlScreen()),
      );
    },
  ),
];

/* =========================
   MENU CARD
   ========================= */

class _OutboundMenuCard extends StatelessWidget {
  final _OutboundMenuItem item;

  const _OutboundMenuCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => item.onTapBuilder(context),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(item.icon, size: 36, color: Colors.black),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                item.title,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.black54),
          ],
        ),
      ),
    );
  }
}

/* =========================
   MENU MODEL
   ========================= */

class _OutboundMenuItem {
  final String title;
  final IconData icon;
  final void Function(BuildContext context) onTapBuilder;

  _OutboundMenuItem({
    required this.title,
    required this.icon,
    required this.onTapBuilder,
  });
}
