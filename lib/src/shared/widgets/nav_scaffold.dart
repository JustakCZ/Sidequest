import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../features/quests/presentation/screens/the_board_screen.dart';
import '../../features/quests/presentation/screens/active_quests_screen.dart';
import '../../features/stats/presentation/screens/legacy_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import 'global_header.dart';
import 'background_gradient.dart';

class NavScaffold extends StatefulWidget {
  const NavScaffold({super.key});

  @override
  State<NavScaffold> createState() => _NavScaffoldState();
}

class _NavScaffoldState extends State<NavScaffold> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const TheBoardScreen(),
    const ActiveQuestsScreen(),
    const LegacyScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundGradient(
        child: SafeArea(
          child: Column(
            children: [
              GlobalHeader(
                onSettingsTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SettingsScreen()),
                  );
                },
              ),
              Expanded(
                child: IndexedStack(
                  index: _currentIndex,
                  children: _screens,
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        backgroundColor: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.square_list),
            activeIcon: Icon(CupertinoIcons.square_list_fill),
            label: 'Board',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.compass),
            activeIcon: Icon(CupertinoIcons.compass_fill),
            label: 'Active',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.graph_circle),
            activeIcon: Icon(CupertinoIcons.graph_circle_fill),
            label: 'Legacy',
          ),
        ],
      ),
    );
  }
}
