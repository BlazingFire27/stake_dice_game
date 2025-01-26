import 'package:flutter/material.dart';

class HistoryList extends StatelessWidget {
  final List<String> history;

  const HistoryList({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: history.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(
            history[index],
            style: TextStyle(
              fontSize: 18,
              color: history[index].contains('Win') ? Colors.green : Colors.red,
            ),
          ),
        );
      },
    );
  }
}
