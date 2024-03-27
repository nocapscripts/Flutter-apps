import 'package:flutter/material.dart';
import 'package:memoapp/models/memo.dart';

class MemoItem extends StatelessWidget {
  final Memo memo;
  final VoidCallback onTap;

  const MemoItem({
    Key? key,
    required this.memo,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(memo.title),
      subtitle: Text('Created: ${memo.createdAt}'),
      onTap: onTap,
    );
  }
}
