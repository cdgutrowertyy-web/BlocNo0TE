import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'folder_list_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  runApp(const Blocno0teApp());
}

class Blocno0teApp extends StatelessWidget {
  const Blocno0teApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'blocno0te',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),
      themeMode: ThemeMode.system,
      home: const FolderListScreen(),
    );
  }
}
