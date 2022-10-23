import 'package:flutter/material.dart';
import 'package:todo_dapp_front/todo.dart';
import 'package:todo_dapp_front/ui/todo_item.dart';

class TodoList extends StatelessWidget {
  final List<Todo> items;

  const TodoList({required this.items, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
          itemCount: items.length,
          itemBuilder: (BuildContext context, int index) {
            return TodoItem(
              item: items[index],
              key: ValueKey(items[index].id),
            );
          }),
    );
  }
}
