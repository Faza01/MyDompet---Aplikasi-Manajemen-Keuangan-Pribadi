import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../main.dart';
import 'transactions/home_screen.dart';
import 'budgeting/budgeting_screen.dart';
import 'reports/reports_screen.dart';
import 'backup/settings_screen.dart';
import 'quick_input/quick_input_dialog.dart';

class MainNavigationHub extends ConsumerStatefulWidget {
  const MainNavigationHub({super.key});

  @override
  ConsumerState<MainNavigationHub> createState() => _MainNavigationHubState();
}

class _MainNavigationHubState extends ConsumerState<MainNavigationHub> {
  final List<Widget> _screens = const [
    HomeScreen(),
    BudgetingScreen(),
    SizedBox(), // Spacing dummy
    ReportsScreen(),
    SettingsScreen(),
  ];

  void _openQuickInput({bool startListeningImmediately = false}) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => QuickInputDialog(
        startListeningImmediately: startListeningImmediately,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final currentIndex = ref.watch(navigationIndexProvider);

    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: SizedBox(
        height: 120.0,
        child: Stack(
          children: [
            // Smooth gradient transparent navbar background (No Blur = 0ms GPU overhead)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      (isDarkMode ? const Color(0xFF0F1115) : const Color(0xFFF8F9FA)).withOpacity(0.0),
                      (isDarkMode ? const Color(0xFF0F1115) : const Color(0xFFF8F9FA)).withOpacity(0.95),
                    ],
                    stops: const [0.0, 0.8],
                  ),
                ),
              ),
            ),
            // Floating Navbar Capsule
            Align(
              alignment: Alignment.bottomCenter,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 280.0,
                        height: 64.0,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2C2C2C),
                          borderRadius: BorderRadius.circular(16.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.15),
                              blurRadius: 16.0,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildNavItem(0, Icons.home_outlined, currentIndex),
                            _buildNavItem(1, Icons.pie_chart_outline, currentIndex),
                            _buildCenterPlusButton(),
                            _buildNavItem(3, Icons.analytics_outlined, currentIndex),
                            _buildNavItem(4, Icons.settings_outlined, currentIndex),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, int currentIndex) {
    final isSelected = currentIndex == index;
    return GestureDetector(
      onTap: () {
        ref.read(navigationIndexProvider.notifier).setIndex(index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 46.0,
        height: 46.0,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Icon(
          icon,
          color: isSelected ? const Color(0xFF003434) : Colors.white70,
          size: 22.0,
        ),
      ),
    );
  }

  Widget _buildCenterPlusButton() {
    return GestureDetector(
      onTap: _openQuickInput,
      onLongPress: () => _openQuickInput(startListeningImmediately: true),
      child: Container(
        width: 46.0,
        height: 46.0,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: const Icon(
          Icons.add,
          color: Color(0xFF003434), // Core Ledger Deep Teal
          size: 28.0,
        ),
      ),
    );
  }
}
