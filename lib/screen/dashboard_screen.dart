import 'package:flutter/material.dart';
import 'package:jinga/utilities/constants.dart';
import 'home_screen.dart';
import 'settings_page.dart';

class DashboardScreen extends StatefulWidget {
  static String id = 'dash_board_screen';
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _pageIndex = 0;
  PageController _pageController;

  List<Widget> tabPages = [
    HomeScreen(),
    Screen2(),
    Screen3(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    _pageController = PageController(initialPage: _pageIndex);
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _pageIndex,
        onTap: onTabTapped,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
        selectedLabelStyle: kBBSTextStyle,
        unselectedLabelStyle: kBBUTextStyle,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'home',
            tooltip: 'home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_offer),
            label: 'bookings',
            tooltip: 'bookings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on),
            label: 'near me',
            tooltip: 'near me',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'settings',
            tooltip: 'settings',
          ),
        ],
      ),
      body: SafeArea(
        child: PageView(
          children: tabPages,
          onPageChanged: onPageChanged,
          controller: _pageController,
        ),
      ),
    );
  }

  void onPageChanged(int page) {
    setState(() {
      this._pageIndex = page;
    });
  }

  void onTabTapped(int index) {
    if (_pageIndex == index + 1 || _pageIndex == index - 1) {
      this._pageController.animateToPage(index,
          duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
    } else {
      this._pageController.jumpToPage(index);
    }
  }
}

class Screen2 extends StatefulWidget {
  @override
  _Screen2State createState() => _Screen2State();
}

class _Screen2State extends State<Screen2> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(child: Text('booking')),
    );
  }
}

class Screen3 extends StatefulWidget {
  @override
  _Screen3State createState() => _Screen3State();
}

class _Screen3State extends State<Screen3> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(child: Text('near me')),
    );
  }
}
