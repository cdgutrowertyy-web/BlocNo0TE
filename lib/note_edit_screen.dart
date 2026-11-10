import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class NoteEditScreen extends StatefulWidget {
  const NoteEditScreen({
    super.key,
    required this.folderName,
    required this.noteTitle,
  });

  final String folderName;
  final String noteTitle;

  @override
  State<NoteEditScreen> createState() => _NoteEditScreenState();
}

class _NoteEditScreenState extends State<NoteEditScreen>
    with WidgetsBindingObserver {
  final TextEditingController _controller = TextEditingController();
  Box? _box;
  bool _loading = true;

  String get _key => '${widget.folderName}_${widget.noteTitle}';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _openBox();
  }

  Future<void> _openBox() async {
    final Box box = await Hive.openBox('notes_content_box');
    final dynamic stored = box.get(_key);
    _box = box;
    _controller.text = stored is String ? stored : '';
    _controller.addListener(_onTextChanged);
    setState(() {
      _loading = false;
    });
  }

  void _onTextChanged() {
    _save();
  }

  Future<void> _save() async {
    if (_box == null) return;
    await _box!.put(_key, _controller.text);
  }

  Future<void> _exportNote() async {
    final String text = _controller.text;
    String safeName = widget.noteTitle
        .replaceAll(RegExp(r'[\\/:*?"<>|]'), '_')
        .trim();
    if (safeName.isEmpty) {
      safeName = 'note';
    }
    final Directory dir = await getTemporaryDirectory();
    final File file = File('${dir.path}/$safeName.txt');
    await file.writeAsString(text);
    await Share.shareXFiles(
      <XFile>[XFile(file.path, mimeType: 'text/plain')],
      subject: widget.noteTitle,
      text: widget.noteTitle,
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached ||
        state == AppLifecycleState.hidden) {
      _save();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _save();
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.noteTitle),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Экспорт в .txt',
            onPressed: _loading ? null : _exportNote,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _controller,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                keyboardType: TextInputType.multiline,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Начните писать...',
                ),
              ),
            ),
    );
  }
}
