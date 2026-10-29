import 'package:flutter/material.dart';

import 'app/app.dart';
import 'app/app_dependencies.dart';

void main() {
  // Platform plugins (e.g. text-to-speech) need the engine binding before
  // any of their objects are created.
  WidgetsFlutterBinding.ensureInitialized();
  runApp(CuriousBuddyApp(dependencies: AppDependencies.defaults()));
}
