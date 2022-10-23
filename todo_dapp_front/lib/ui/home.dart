import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_dapp_front/todo.dart';
import 'package:todo_dapp_front/ui/bottom_sheet.dart';
import 'package:todo_dapp_front/ui/todo_list.dart';

class Home extends ConsumerWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AsyncValue<List<Todo>> todos = ref.watch(todosProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Flutter Todo dApp ❤️',
        ),
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            todos.when(
                data: (todos) {
                  if (todos.isEmpty) {
                    return const Text('Add new tasks!!!');
                  }
                  return TodoList(items: todos);
                },
                error: (err, stack) => Text('Error: $err'),
                loading: () => const CircularProgressIndicator()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showTodoBottomSheet(
              context: context,
              callback: (result) {
                if (result == null || result.trim().isEmpty) return;
                ref.read(todosProvider.notifier).add(result);
              });
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
