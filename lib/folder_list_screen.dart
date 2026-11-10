import 'package:flutter/material.dart';

import 'note_list_screen.dart';

class FolderListScreen extends StatefulWidget {
  const FolderListScreen({super.key});

  @override
  State<FolderListScreen> createState() => _FolderListScreenState();
}

class _FolderListScreenState extends State<FolderListScreen> {
  final List<String> folders = <String>['Личное', 'Работа'];
  bool _isDark = false;

  void _toggleTheme() {
    setState(() {
      _isDark = !_isDark;
    });
    final MaterialApp app = context.findAncestorWidgetOfExactType<MaterialApp>()!;
    app.themeMode;
  }

  Future<void> _showCreateFolderDialog() async {
    final TextEditingController controller = TextEditingController();
    final String? name = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Новая папка'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Имя папки',
              border: OutlineInputBorder(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Отмена'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(controller.text.trim()),
              child: const Text('Создать'),
            ),
          ],
        );
      },
    );
    if (name != null && name.isNotEmpty) {
      setState(() {
        folders.add(name);
      });
    }
    controller.dispose();
  }

  Future<void> _showFolderOptionsDialog(int index) async {
    final String currentName = folders[index];
    final TextEditingController controller =
        TextEditingController(text: currentName);

    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(currentName),
          content: TextField(
            controller: controller,
            autofocus: false,
            decoration: const InputDecoration(
              labelText: 'Имя папки',
              border: OutlineInputBorder(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                setState(() {
                  folders.removeAt(index);
                });
                Navigator.of(context).pop();
              },
              child: const Text(
                'Удалить',
                style: TextStyle(color: Colors.red),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Отмена'),
            ),
            FilledButton(
              onPressed: () {
                final String newName = controller.text.trim();
                if (newName.isNotEmpty) {
                  setState(() {
                    folders[index] = newName;
                  });
                }
                Navigator.of(context).pop();
              },
              child: const Text('Сохранить'),
            ),
          ],
        );
      },
    );
    controller.dispose();
  }

  void _openFolder(String folderName) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) =>
            NoteListScreen(folderName: folderName),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: _isDark
          ? ThemeData.dark(useMaterial3: true)
          : ThemeData.light(useMaterial3: true),
      child: Builder(
        builder: (BuildContext context) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('BlocNo0TE'),
              actions: <Widget>[
                IconButton(
                  icon: Icon(_isDark ? Icons.light_mode : Icons.dark_mode),
                  tooltip: _isDark
                      ? 'Переключить на светлую тему'
                      : 'Переключить на темную тему',
                  onPressed: () {
                    setState(() {
                      _isDark = !_isDark;
                    });
                  },
                ),
              ],
            ),
            body: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              itemCount: folders.length,
              itemBuilder: (BuildContext context, int index) {
                final String folder = folders[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    leading: const Icon(Icons.folder),
                    title: Text(folder),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _openFolder(folder),
                    onLongPress: () => _showFolderOptionsDialog(index),
                  ),
                );
              },
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: _showCreateFolderDialog,
              child: const Icon(Icons.add),
            ),
          );
        },
      ),
    );
  }
}
