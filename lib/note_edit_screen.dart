import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

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
