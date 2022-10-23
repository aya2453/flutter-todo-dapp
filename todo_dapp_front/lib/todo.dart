import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:todo_dapp_front/smartcontract/todo_contract.g.dart';
import 'package:todo_dapp_front/web3client_provider.dart';
import 'package:web3dart/web3dart.dart';

part 'todo.freezed.dart';

final todosProvider =
    StateNotifierProvider.autoDispose<TodosNotifier, AsyncValue<List<Todo>>>(
        (ref) {
  final todosNotifier = TodosNotifier(ref.read(web3ClientProvider));
  ref.onDispose(() {
    todosNotifier.unsubscribe();
  });
  return todosNotifier;
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
  final _credentials = EthPrivateKey.fromHex(dotenv.env['PRIVATE_KEY']!);
  late final Todo_contract _todoContract;
  final List<StreamSubscription> _subscriptions = [];
  final Web3Client _client;
  List<Todo> _tmp = [];

  TodosNotifier(this._client) : super(const AsyncValue.loading()) {
    init();
  }

  Future<void> init() async {
    final abiStringFile =
        await rootBundle.loadString('lib/smartcontract/todo_contract.abi.json');
    final jsonAbi = jsonDecode(abiStringFile);
    final contractAddress =
        EthereumAddress.fromHex(jsonAbi["networks"]["5777"]["address"]);
    _todoContract = Todo_contract(address: contractAddress, client: _client);

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
          _updateState(
              _tmp.where((element) => element.id != event.id).toList());
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
      _execute(() => _todoContract.createTask(name, credentials: _credentials));

  void update(Todo todo) => _execute(
      showLoading: false,
      () => _todoContract.updateTask(todo.id, todo.name,
          credentials: _credentials));

  void toggle(BigInt id) => _execute(
      showLoading: false,
      () => _todoContract.toggleTaskIsComplete(id, credentials: _credentials));

  void remove(BigInt id) =>
      _execute(() => _todoContract.deleteTask(id, credentials: _credentials));

  void _subscribeEvent(StreamSubscription Function() body) {
    _subscriptions.add(body());
  }

  void unsubscribe() {
    _subscriptions.forEach((element) {
      element.cancel();
    });
    _client.dispose();
  }

  void _getAllTodos() async {
    state = const AsyncData([]);
    _execute(() async {
      final count = await _todoContract.totalTasksCount();
      final list = [for (var i = 0; i < count.toInt(); i++) await _getTodo(i)]
          .where((element) => element.name.isNotEmpty)
          .toList();
      state = AsyncData(list);
    });
  }

  Future<Todo> _getTodo(int index) async {
    final masterTodo = await _todoContract.todos(BigInt.from(index));
    return Todo(
        id: masterTodo.id,
        name: masterTodo.name,
        completed: masterTodo.isComplete);
  }

  void _execute(Function body, {bool showLoading = true}) async {
    if (state.isLoading) return;
    try {
      _tmp = state.value ?? [];
      if (showLoading) {
        state = const AsyncValue.loading();
      }
      await body();
    } catch (err, stack) {
      state = AsyncValue.error(err, stack);
    }
  }

  void _updateState(List<Todo> newTodos) {
    state = AsyncData(newTodos);
  }
}
