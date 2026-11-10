import 'package:flutter/material.dart';

import 'note_edit_screen.dart';

class NoteListScreen extends StatefulWidget {
  const NoteListScreen({super.key, required this.folderName});

  final String folderName;

  @override
  State<NoteListScreen> createState() => _NoteListScreenState();
}

class _NoteListScreenState extends State<NoteListScreen> {
  final List<String> notes = <String>['Список покупок', 'Идеи для проекта'];

  Future<void> _showCreateNoteDialog() async {
    final TextEditingController controller = TextEditingController();
    final String? title = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Новая заметка'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Название заметки',
              border: OutlineInputBorder(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Отмена'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.of(context).pop(controller.text.trim()),
              child: const Text('Создать'),
            ),
          ],
        );
      },
    );
    if (title != null && title.isNotEmpty) {
      setState(() {
        notes.add(title);
      });
    }
    controller.dispose();
  }

  Future<void> _showNoteOptionsDialog(int index) async {
    final String currentTitle = notes[index];
    final TextEditingController controller =
        TextEditingController(text: currentTitle);

    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(currentTitle),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Название заметки',
              border: OutlineInputBorder(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                setState(() {
                  notes.removeAt(index);
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
                final String newTitle = controller.text.trim();
                if (newTitle.isNotEmpty) {
                  setState(() {
                    notes[index] = newTitle;
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

  void _openNote(String noteTitle) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => NoteEditScreen(
          folderName: widget.folderName,
          noteTitle: noteTitle,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.folderName),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        itemCount: notes.length,
        itemBuilder: (BuildContext context, int index) {
          final String note = notes[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: ListTile(
              leading: const Icon(Icons.description_outlined),
              title: Text(note),
              subtitle: const Text('12.05.2024, 14:30'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _openNote(note),
              onLongPress: () => _showNoteOptionsDialog(index),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateNoteDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
