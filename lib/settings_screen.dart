import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Box? _box;
  bool _loading = true;
  bool _autoDateName = false;

  @override
  void initState() {
    super.initState();
    _openBox();
  }

  Future<void> _openBox() async {
    final Box box = await Hive.openBox('settings_box');
    final dynamic stored = box.get('auto_date_name', defaultValue: false);
    setState(() {
      _box = box;
      _autoDateName = stored is bool ? stored : false;
      _loading = false;
    });
  }

  Future<void> _toggleAutoDateName(bool value) async {
    setState(() {
      _autoDateName = value;
    });
    if (_box != null) {
      await _box!.put('auto_date_name', value);
    }
  }

  Future<void> _showGoogleAccountDialog() async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('В разработке'),
          content: const Text(
            'Подключение Google Аккаунта появится в одном из следующих обновлений.',
          ),
          actions: <Widget>[
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: <Widget>[
                SwitchListTile(
                  title: const Text(
                    'Автоматически называть новые заметки датой',
                  ),
                  value: _autoDateName,
                  onChanged: _toggleAutoDateName,
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.account_circle_outlined),
                  title: const Text('Подключить Google Аккаунт'),
                  subtitle: const Text('Для резервного копирования'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _showGoogleAccountDialog,
                ),
              ],
            ),
    );
  }
}
