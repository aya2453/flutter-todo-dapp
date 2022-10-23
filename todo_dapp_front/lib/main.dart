import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:todo_dapp_front/logger.dart';
import 'package:todo_dapp_front/todo.dart';

Future main() async {
  await dotenv.load(fileName: '.env');
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
      home: const Home(),
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

class BottomSheetContent extends StatefulWidget {
  final String? defaultName;

  const BottomSheetContent({this.defaultName, Key? key}) : super(key: key);

  @override
  State<BottomSheetContent> createState() => _BottomSheetContentState();
}

class _BottomSheetContentState extends State<BottomSheetContent> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.defaultName);
  }

  @override
  Widget build(BuildContext context) {
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
              controller: _controller,
              autofocus: true,
              decoration: InputDecoration(
                  hintText: '新しいタスク',
                  suffixIcon: IconButton(
                    onPressed: () {
                      Navigator.pop(context, _controller.text);
                    },
                    icon: const Icon(Icons.send),
                  )),
            ),
            const SizedBox(height: 8),
          ]),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}

void showTodoBottomSheet(
    {String? defaultName,
    required BuildContext context,
    required Function(String?) callback}) async {
  String? name = await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      isScrollControlled: true,
      builder: (BuildContext context) =>
          BottomSheetContent(defaultName: defaultName));
  callback(name);
}

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
