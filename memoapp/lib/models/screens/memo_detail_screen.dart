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
        title: Text(widget.memo != null ? 'Edit Memo' : 'Add Memo'),
        actions: [
          IconButton(
            onPressed: () async {
              await _saveMemo();
            },
            icon: Icon(Icons.save),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _contentController,
              decoration: InputDecoration(labelText: 'Content'),
              maxLines: null,
            ),
          ],
        ),
      ),
    );
  }
}
