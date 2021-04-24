import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:rive/rive.dart';

class PhoneAnim extends StatefulWidget {
  @override
  _PhoneAnimState createState() => _PhoneAnimState();
}

class _PhoneAnimState extends State<PhoneAnim> {
  Artboard _artboard;
  RiveAnimationController _controller;
  final rivefile = 'assets/anim/phone_anim.riv';

  void _loadRiveFile() async {
    final bytes = await rootBundle.load(rivefile);
    final file = RiveFile.import(bytes);
    setState(() {
      _artboard = file.mainArtboard
        ..addController(_controller = SimpleAnimation('dail'));
    });
  }

  void pause() {
    if (_controller.isActive) {
      setState(() {
        _controller.isActive = false;
      });
    }
  }

  @override
  void initState() {
    _loadRiveFile();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: _artboard == null
          ? SizedBox()
          : Rive(
              artboard: _artboard,
            ),
    );
  }
}
