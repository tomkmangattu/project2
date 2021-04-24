import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jinga/screen/login_home.dart';
import 'package:jinga/screen/map_screen.dart';
import 'package:jinga/services/theme_changer.dart';
import 'package:jinga/utilities/constants.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    bool _darkThemeEnabled =
        ThemeBuilder.of(context).getCurrentTheme() == Brightness.dark;
    return Container(
      child: ListView(
        children: [
          Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _signOutButtonPressed,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Sign Out'),
                    Icon(Icons.logout),
                  ],
                ),
              )),
          Divider(
            height: 4,
          ),
          SwitchListTile(
            title: Text('Enable dark theme'),
            value: _darkThemeEnabled,
            onChanged: (value) {
              setState(() {
                _darkThemeEnabled = value;
              });
              ThemeBuilder.of(context).changeTheme();
            },
          ),
          Divider(
            height: 4,
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MapScreen(
                      process: MapProcess.change,
                    ),
                  ));
            },
            child: Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.all(8),
              child: Text(
                'Change location',
              ),
            ),
          )
        ],
      ),
    );
  }

  void _signOutButtonPressed() async {
    await FirebaseAuth.instance.signOut();
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacementNamed(context, LoginHomeScreen.id);
    }
  }
}
