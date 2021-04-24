import 'package:flutter/material.dart';
import 'package:jinga/services/local_database.dart';

class ThemeBuilder extends StatefulWidget {
  final Widget Function(BuildContext context, Brightness brightness) builder;
  final Brightness defaultBrightness;

  ThemeBuilder({this.builder, this.defaultBrightness});

  @override
  _ThemeBuilderState createState() => _ThemeBuilderState();

  static _ThemeBuilderState of(BuildContext context) {
    return context.findAncestorStateOfType<_ThemeBuilderState>();
  }
}

class _ThemeBuilderState extends State<ThemeBuilder> {
  Brightness _brightness;

  @override
  void initState() {
    _brightness = widget.defaultBrightness;
    super.initState();
    if (mounted) setState(() {});
  }

  void _updataThemeData() async {
    Map<String, dynamic> row = {
      DatabaseHelper.colName: 'Dark Theme',
      DatabaseHelper.colValue: _brightness == Brightness.dark ? 'true' : 'false'
    };
    await DatabaseHelper.instance
        .update(DatabaseHelper.settingsTb, row, 'Dark Theme');
  }

  void changeTheme() {
    setState(() {
      _brightness =
          _brightness == Brightness.dark ? Brightness.light : Brightness.dark;
    });
    _updataThemeData();
  }

  Brightness getCurrentTheme() {
    return _brightness;
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _brightness);
  }
}
