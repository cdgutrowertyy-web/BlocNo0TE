import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import 'note_edit_screen.dart';

class NoteListScreen extends StatefulWidget {
  const NoteListScreen({super.key, required this.folderName});

  final String folderName;

  @override
  State<NoteListScreen> createState() => _NoteListScreenState();
}

class _NoteListScreenState extends State<NoteListScreen> {
  List<String> notes = <String>[];
  Box? _box;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _openBox();
  }

  Future<void> _openBox() async {
    final Box box = await Hive.openBox('notes_list_box');
    final dynamic stored = box.get(widget.folderName);
    final List<String> loaded = stored is List
        ? stored.map((dynamic e) => e.toString()).toList()
        : <String>[];
    setState(() {
      _box = box;
      notes = loaded;
      _loading = false;
    });
  }

  Future<void> _save() async {
    if (_box == null) return;
    await _box!.put(widget.folderName, notes);
  }

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
      await _save();
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
              onPressed: () async {
                setState(() {
                  notes.removeAt(index);
                });
                await _save();
                if (context.mounted) Navigator.of(context).pop();
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
              onPressed: () async {
                final String newTitle = controller.text.trim();
                if (newTitle.isNotEmpty) {
                  setState(() {
                    notes[index] = newTitle;
                  });
                  await _save();
                }
                if (context.mounted) Navigator.of(context).pop();
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
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding:
                  const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
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
        onPressed: _loading ? null : _showCreateNoteDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
