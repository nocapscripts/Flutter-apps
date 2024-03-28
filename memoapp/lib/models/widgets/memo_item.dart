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
    return Card(
      elevation: 2, // Add elevation for a shadow effect
      margin: EdgeInsets.symmetric(
          vertical: 8, horizontal: 16), // Add margin for spacing
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), // Add rounded corners
      ),
      child: ListTile(
        contentPadding:
            EdgeInsets.symmetric(vertical: 16, horizontal: 16), // Add padding
        title: Text(
          memo.title,
          style: TextStyle(
            fontWeight: FontWeight.bold, // Make title bold
            fontSize: 18, // Adjust font size
          ),
        ),
        subtitle: Text(
          'Aeg: ${memo.createdAt}',
          style: TextStyle(
            color: Colors.grey, // Use grey color for subtitle
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
