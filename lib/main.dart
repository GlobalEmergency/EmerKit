import 'package:flutter/material.dart';
import 'app.dart';
import 'shared/di/register_services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  registerServices();
  runApp(const NavajaSuizaApp());
}
