import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_dapp_front/logger.dart';
import 'package:todo_dapp_front/todo.dart';

void main() {
  runApp(
    ProviderScope(
      observers: [Logger()],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.pink),
      home: Home(),
    );
  }
}

class Home extends ConsumerWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AsyncValue<List<Todo>> todos = ref.watch(todosProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(
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
                    return Text('空なのでタスクを追加しましょう！');
                  }
                  return Text('データ！');
                },
                error: (err, stack) => Text('Error: $err'),
                loading: () => const CircularProgressIndicator()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showBottomSheet(context, (result) {
            if (result == null || result.isEmpty) return;
            ref.read(todosProvider.notifier).add(result);
          });
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void _showBottomSheet(
      BuildContext context, Function(String?) callback) async {
    final controller = TextEditingController();
    String? name = await showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
        ),
        isScrollControlled: true,
        builder: (BuildContext context) {
          return Padding(
            padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Wrap(
              children: [
                Column(children: [
                  TextField(
                    controller: controller,
                    autofocus: true,
                    decoration: InputDecoration(
                        hintText: '新しいタスク',
                        suffixIcon: IconButton(
                          onPressed: () {
                            Navigator.pop(context, controller.text);
                          },
                          icon: const Icon(Icons.send),
                        )),
                  ),
                  const SizedBox(height: 8),
                ]),
              ],
            ),
          );
        });
    callback(name);
  }
}
