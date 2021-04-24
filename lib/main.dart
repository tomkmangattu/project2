import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:jinga/screen/dashboard_screen.dart';
import 'package:jinga/screen/login_home.dart';
import 'package:jinga/screen/phone_number_auth.dart';
import 'package:jinga/services/local_database.dart';
import 'package:jinga/services/theme_changer.dart';

// import 'screen/map_screen.dart';
// import 'utilities/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Brightness brightness = await setThemeData();
  await Firebase.initializeApp();
  runApp(MyApp(
    brightness: brightness,
  ));
}

class MyApp extends StatelessWidget {
  final Brightness brightness;
  MyApp({@required this.brightness});
  @override
  Widget build(BuildContext context) {
    return ThemeBuilder(
      defaultBrightness: brightness,
      builder: (context, _brightness) {
        bool dark = _brightness == Brightness.dark;
        return MaterialApp(
          title: 'Jinga',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: dark ? Colors.blue : Colors.purple,
            brightness: _brightness,
          ),
          initialRoute: FirebaseAuth.instance.currentUser == null
              ? LoginHomeScreen.id
              : DashboardScreen.id,
          // : MaterialPageRoute(
          //     builder: (context) => MapScreen(
          //       process: Process.login,
          //     ),
          //   ),
          routes: {
            LoginHomeScreen.id: (context) => LoginHomeScreen(),
            PhoneNumberScreen.id: (context) => PhoneNumberScreen(),
            DashboardScreen.id: (context) => DashboardScreen(),
          },
        );
      },
    );
  }
}

Future<Brightness> setThemeData() async {
  List<Map<String, dynamic>> themedata = await DatabaseHelper.instance
      .query(DatabaseHelper.settingsTb, 'Dark Theme');

  if (themedata.isEmpty) {
    Map<String, dynamic> themeData = {
      DatabaseHelper.colName: 'Dark Theme',
      DatabaseHelper.colValue: 'false'
    };
    await DatabaseHelper.instance.insert(DatabaseHelper.settingsTb, themeData);
  } else {
    bool darkThemeEnabled = themedata[0]['value'] == 'true' ? true : false;
    debugPrint('darkThemeEnabled = ' + darkThemeEnabled.toString());
    if (darkThemeEnabled) {
      return Brightness.dark;
    }
  }

  var data = await DatabaseHelper.instance.queryAll(DatabaseHelper.settingsTb);
  debugPrint(data.toString());
  return Brightness.light;
}
