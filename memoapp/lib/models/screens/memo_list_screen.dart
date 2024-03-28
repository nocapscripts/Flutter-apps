import 'package:flutter/material.dart';
import 'package:memoapp/models/memo.dart';
import 'package:memoapp/helpers/memo_database_helper.dart';
import 'package:memoapp/models/screens/memo_detail_screen.dart';

class MemoListScreen extends StatefulWidget {
  final String titleTranslation;
  final String notesTranslation;
  final String createdTranslation;

  const MemoListScreen({
    Key? key,
    required this.titleTranslation,
    required this.notesTranslation,
    required this.createdTranslation,
  }) : super(key: key);

  @override
  _MemoListScreenState createState() => _MemoListScreenState();
}

class _MemoListScreenState extends State<MemoListScreen> {
  late Future<List<Memo>> _futureMemos;

  @override
  void initState() {
    super.initState();
    _futureMemos = MemoDatabaseHelper().getMemos();
  }

  Future<void> refreshMemoList() async {
    setState(() {
      _futureMemos = MemoDatabaseHelper().getMemos();
    });
  }

  Future<void> _deleteMemo(int id) async {
    await MemoDatabaseHelper().deleteMemo(id);
    refreshMemoList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.titleTranslation,
        ),
      ),
      body: Container(
        color:
            const Color.fromARGB(255, 14, 14, 14), // Set gray background color
        child: RefreshIndicator(
          onRefresh: refreshMemoList,
          child: FutureBuilder<List<Memo>>(
            future: _futureMemos,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Viga: ${snapshot.error}'));
              } else {
                final memos = snapshot.data!;
                if (memos.isEmpty) {
                  return Center(
                    child: Text(
                      widget.notesTranslation,
                      style: TextStyle(
                          color: Colors.black), // Set text color to black
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: memos.length,
                  itemBuilder: (context, index) {
                    final memo = memos[index];
                    return Dismissible(
                      key: Key(memo.id.toString()),
                      onDismissed: (direction) {
                        _deleteMemo(memo.id);
                      },
                      background: Container(
                        color: const Color.fromARGB(255, 95, 6, 0),
                        alignment: Alignment.centerRight,
                        child: const Icon(Icons.delete, color: Colors.yellow),
                      ),
                      child: Card(
                        color:
                            Colors.white, // Set white background for list item
                        elevation: 2, // Add elevation for shadow effect
                        margin:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          title: Text(
                            memo.title,
                            style: TextStyle(
                                color: Colors.black), // Set text color to black
                          ),
                          subtitle: Text(
                            widget.createdTranslation.replaceAll(
                                '{createdAt}', memo.createdAt.toString()),
                            style: TextStyle(
                                color: Colors.black), // Set text color to black
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MemoDetailScreen(
                                  memo: memo,
                                  refreshMemoList: refreshMemoList,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                );
              }
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MemoDetailScreen(
                refreshMemoList: refreshMemoList,
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.teal,
      ),
    );
  }
}
