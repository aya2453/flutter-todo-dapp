import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:http/http.dart';
import 'package:todo_dapp_front/smartcontract/todo_contract.g.dart';
import 'package:web3dart/web3dart.dart';
import 'package:web_socket_channel/io.dart';

part 'todo.freezed.dart';

const String _privateKey =
    '5c80dad0c2aa41ddccb09fa5fd438d3a97acf7f6608bba8f5095997a4d7729f2';
const String _rpcUrl = "http://192.168.11.10:7545";
const String _wsUrl = "ws://192.168.11.10:7545/";
final credentials = EthPrivateKey.fromHex(_privateKey);

final todosProvider =
    StateNotifierProvider<TodosNotifier, AsyncValue<List<Todo>>>((ref) {
  return TodosNotifier();
});

@freezed
class Todo with _$Todo {
  const factory Todo({
    required BigInt id,
    required String name,
    @Default(false) bool completed,
  }) = _Todo;
}

class TodosNotifier extends StateNotifier<AsyncValue<List<Todo>>> {
  late final Todo_contract _todoContract;
  final List<StreamSubscription> _subscriptions = [];
  List<Todo> _tmp = [];

  TodosNotifier() : super(const AsyncValue.loading()) {
    init();
  }

  Future<void> init() async {
    final client = Web3Client(_rpcUrl, Client(),
        socketConnector: () =>
            IOWebSocketChannel.connect(_wsUrl).cast<String>());
    final abiStringFile =
        await rootBundle.loadString('lib/smartcontract/todo_contract.abi.json');
    final jsonAbi = jsonDecode(abiStringFile);
    final contractAddress =
        EthereumAddress.fromHex(jsonAbi["networks"]["5777"]["address"]);
    _todoContract = Todo_contract(address: contractAddress, client: client);

    _getAllTodos();

    _subscribeEvent(() => _todoContract
            .taskCreatedEvents(toBlock: const BlockNum.genesis())
            .listen((event) {
          final todo = Todo(id: event.id, name: event.name);
          _updateState([todo, ..._tmp]);
        }));

    _subscribeEvent(() => _todoContract
            .taskDeletedEvents(toBlock: const BlockNum.genesis())
            .listen((event) {
          _updateState(_tmp
              .where((element) => element.id != event.id)
              .toList());
        }));

    _subscribeEvent(() => _todoContract
            .taskIsCompleteToggledEvents(toBlock: const BlockNum.genesis())
            .listen((event) {
          _updateState([
            for (final todo in _tmp)
              if (todo.id == event.id)
                todo.copyWith(completed: event.isComplete)
              else
                todo,
          ]);
        }));

    _subscribeEvent(() => _todoContract
            .taskUpdatedEvents(toBlock: const BlockNum.genesis())
            .listen((event) {
          _updateState([
            for (final todo in _tmp)
              if (todo.id == event.id)
                todo.copyWith(name: event.name)
              else
                todo,
          ]);
        }));
  }

  void add(String name) =>
      _execute(() => _todoContract.createTask(name, credentials: credentials));

  void update(Todo todo) => _execute(() =>
      _todoContract.updateTask(todo.id, todo.name, credentials: credentials));

  void toggle(BigInt id) => _execute(
      () => _todoContract.toggleTaskIsComplete(id, credentials: credentials));

  void remove(BigInt id) =>
      _execute(() => _todoContract.deleteTask(id, credentials: credentials));

  void _subscribeEvent(StreamSubscription Function() body) {
    _subscriptions.add(body());
  }

  void _getAllTodos() async {
    state = const AsyncData([]);
    final count = await _todoContract.totalTasksCount();
    final list = [for (var i = 0; i < count.toInt(); i++) await _getTodo(i)]
        .where((element) => element.name.isNotEmpty)
        .toList();
    state = AsyncData(list);
  }

  Future<Todo> _getTodo(int index) async {
    final masterTodo = await _todoContract.todos(BigInt.from(index));
    return Todo(
        id: masterTodo.id,
        name: masterTodo.name,
        completed: masterTodo.isComplete);
  }

  void _execute(Function body) async {
    if (state is AsyncLoading) return;
    try {
      _tmp = state.value ?? [];
      state = const AsyncValue.loading();
      await body();
    } catch (err, stack) {
      state = AsyncValue.error(err, stack);
    }
  }

  void _updateState(List<Todo> newTodos) {
    state = AsyncData(newTodos);
  }
}
