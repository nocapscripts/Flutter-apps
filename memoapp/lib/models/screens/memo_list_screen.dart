import 'package:flutter/material.dart';
import 'package:memoapp/models/memo.dart';
import 'package:memoapp/helpers/memo_database_helper.dart';
import 'package:memoapp/models/screens/memo_detail_screen.dart';
import 'package:memoapp/l10n/locales.dart';

class MemoListScreen extends StatefulWidget {
  const MemoListScreen({Key? key}) : super(key: key);

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
          AppLocalizations.of(context).translate('title') ?? 'Notes',
        ),
      ),
      body: RefreshIndicator(
        onRefresh: refreshMemoList,
        child: FutureBuilder<List<Memo>>(
          future: _futureMemos,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              final memos = snapshot.data!;
              if (memos.isEmpty) {
                return Center(
                  child: Text(
                    AppLocalizations.of(context).translate('title') ??
                        'Memo Notes',
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
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      child: const Icon(Icons.delete, color: Colors.yellow),
                    ),
                    child: ListTile(
                      title: Text(memo.title),
                      subtitle: Text(
                        AppLocalizations.of(context).translate('created') ??
                            "Created: '${memo.createdAt}'",
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
                  );
                },
              );
            }
          },
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
      ),
    );
  }
}
