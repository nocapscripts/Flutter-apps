import 'package:flutter/material.dart';
import 'package:memoapp/models/memo.dart';
import 'package:memoapp/helpers/memo_database_helper.dart';

class MemoDetailScreen extends StatefulWidget {
  final Memo? memo; // Memo to display/edit
  final Function refreshMemoList;

  const MemoDetailScreen({
    Key? key,
    required this.refreshMemoList,
    this.memo,
  }) : super(key: key);

  @override
  _MemoDetailScreenState createState() => _MemoDetailScreenState();
}

class _MemoDetailScreenState extends State<MemoDetailScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.memo?.title ?? '');
    _contentController =
        TextEditingController(text: widget.memo?.content ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _saveMemo() async {
    // Save or update memo code
    final newMemo = Memo(
      id: widget.memo?.id ?? 0, // Use 0 for new memo
      title: _titleController.text,
      content: _contentController.text,
      createdAt: DateTime.now(),
      lastModifiedAt: DateTime.now(),
    );

    if (widget.memo != null) {
      await MemoDatabaseHelper().updateMemo(newMemo);
    } else {
      await MemoDatabaseHelper().insertMemo(newMemo);
    }

    // Call refreshMemoList to refresh the memo list
    widget.refreshMemoList();

    // Navigate back to the MemoListScreen
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.memo != null ? 'Muuda märget' : 'Lisa uus märge'),
        actions: [
          IconButton(
            onPressed: () async {
              await _saveMemo();
            },
            icon: Icon(Icons.save),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                'Pealkiri',
                style: TextStyle(color: Colors.green),
              ),
            ),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Color.fromARGB(255, 95, 95, 95),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
              ),
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 16.0),
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                'Kirjeldus',
                style: TextStyle(color: Colors.green),
              ),
            ),
            TextField(
              controller: _contentController,
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color.fromARGB(255, 95, 95, 95),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
              ),
              style: TextStyle(color: Colors.white),
              maxLines: 10,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
            ),
          ],
        ),
      ),
    );
  }
}
