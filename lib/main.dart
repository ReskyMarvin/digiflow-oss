import 'package:flutter/material.dart';
import 'screens/outbound_menu_screen.dart';
import 'data/outbound_memory.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await OutboundMemory.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // ===== MOBILE FIRST =====
            int crossAxisCount = 2;

            // Hook masa depan (tablet / desktop)
            if (constraints.maxWidth >= 600) {
              crossAxisCount = 3;
            }
            if (constraints.maxWidth >= 1024) {
              crossAxisCount = 4;
            }

            return Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.builder(
                itemCount: _menuItems.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.1,
                ),
                itemBuilder: (context, index) {
                  final item = _menuItems[index];
                  return _MenuCard(item: item);
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

final List<_MenuItem> _menuItems = [
  _MenuItem(title: 'Inbound', icon: Icons.input, onTap: () {}),
  _MenuItem(
    title: 'Outbound',
    icon: Icons.output,
    onTapBuilder: (context) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const OutboundMenuScreen()),
      );
    },
  ),
  _MenuItem(title: 'Staging', icon: Icons.inventory, onTap: () {}),
  _MenuItem(title: 'Transfer Lokasi', icon: Icons.swap_horiz, onTap: () {}),
];

/* =========================
   MENU CARD WIDGET
   ========================= */

class _MenuCard extends StatelessWidget {
  final _MenuItem item;

  const _MenuCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        if (item.onTapBuilder != null) {
          item.onTapBuilder!(context);
        } else {
          item.onTap?.call();
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(item.icon, size: 40, color: Colors.black),
            const SizedBox(height: 12),
            Text(
              item.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* =========================
   MENU MODEL
   ========================= */

class _MenuItem {
  final String title;
  final IconData icon;
  final VoidCallback? onTap;
  final void Function(BuildContext context)? onTapBuilder;

  _MenuItem({
    required this.title,
    required this.icon,
    this.onTap,
    this.onTapBuilder,
  });
}
