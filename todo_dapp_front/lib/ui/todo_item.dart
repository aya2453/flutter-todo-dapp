import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:todo_dapp_front/todo.dart';
import 'package:todo_dapp_front/ui/bottom_sheet.dart';

class TodoItem extends ConsumerStatefulWidget {
  final Todo item;

  const TodoItem({required this.item, Key? key}) : super(key: key);

  @override
  TodoItemState createState() => TodoItemState(isChecked: item.completed);
}

class TodoItemState extends ConsumerState<TodoItem> {
  bool isChecked;

  TodoItemState({required this.isChecked}) : super();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Slidable(
          endActionPane: ActionPane(motion: ScrollMotion(), children: [
            CustomSlidableAction(
              autoClose: true,
              onPressed: (_) {
                showTodoBottomSheet(
                    defaultName: widget.item.name,
                    context: context,
                    callback: (value) {
                      if (value == null ||
                          value.trim().isEmpty ||
                          value == widget.item.name) return;
                      return ref
                          .read(todosProvider.notifier)
                          .update(widget.item.copyWith(name: value));
                    });
              },
              backgroundColor: Theme.of(context).colorScheme.secondary,
              foregroundColor: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.edit),
                  Text('Edit', style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
            CustomSlidableAction(
              autoClose: true,
              onPressed: (_) {
                ref.read(todosProvider.notifier).remove(widget.item.id);
              },
              backgroundColor: Colors.red[600]!,
              foregroundColor: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.delete),
                  Text('Delete', style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
          ]),
          child: Container(
            decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(4)),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Checkbox(
                      activeColor: Theme.of(context).colorScheme.primary,
                      value: isChecked,
                      onChanged: (checked) {
                        final value = checked ?? isChecked;
                        setState(() {
                          isChecked = value;
                        });
                        ref.read(todosProvider.notifier).toggle(widget.item.id);
                      }),
                  Text(widget.item.name)
                ],
              ),
            ),
          )),
    );
  }
}
