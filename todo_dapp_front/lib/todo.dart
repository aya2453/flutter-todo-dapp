import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:todo_dapp_front/smartcontract/todo_contract.g.dart';
import 'package:web3dart/web3dart.dart';
import 'package:web_socket_channel/io.dart';
import 'package:path/path.dart' as p;

part 'todo.freezed.dart';

const String _privateKey = '85d2242ae1b7759934d4b0d4f0d62d666cf7d73e21dbd09d73c7de266b72a25a';
const String _rpcUrl = "http://127.0.0.1:7545";
const String _wsUrl = "ws://127.0.0.1:7545/";
final File abiFile = File(p.join(p.dirname(Platform.script.path), 'abi.json'));
final credentials = EthPrivateKey.fromHex(_privateKey);

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
  List<Todo> get _currentTodos => state.value ?? [];

  TodosNotifier() : super(const AsyncValue.loading()) {
    init();
  }

  Future<void> init() async {
    final client =
        Web3Client(_rpcUrl, Client(), socketConnector: () => IOWebSocketChannel.connect(_wsUrl).cast<String>());
    final adbStringFile = await abiFile.readAsString();
    final jsonAbi = jsonDecode(adbStringFile);
    final contractAddress = EthereumAddress.fromHex(jsonAbi["networks"]["5777"]["address"]);
    _todoContract = Todo_contract(address: contractAddress, client: client);

    _subscribeEvent(() => _todoContract.taskCreatedEvents().listen((event) {
          final todo = Todo(id: event.id, name: event.name);
          _updateState([..._currentTodos, todo]);
        }));

    _subscribeEvent(() => _todoContract.taskDeletedEvents().listen((event) {
          _updateState(_currentTodos.where((element) => element.id != event.id).toList());
        }));

    _subscribeEvent(() => _todoContract.taskIsCompleteToggledEvents().listen((event) {
          _updateState([
            for (final todo in _currentTodos)
              if (todo.id == event.id) todo.copyWith(completed: event.isComplete) else todo,
          ]);
        }));

    _subscribeEvent(() => _todoContract.taskUpdatedEvents().listen((event) {
          _updateState([
            for (final todo in _currentTodos)
              if (todo.id == event.id) todo.copyWith(name: event.name) else todo,
          ]);
        }));
  }

  void add(Todo todo) => _execute(() => _todoContract.createTask(todo.name, credentials: credentials));
  void update(Todo todo) =>
      _execute(() => _todoContract.updateTask(todo.id, todo.name, credentials: credentials));
  void toggle(BigInt id) => _execute(() => _todoContract.toggleTaskIsComplete(id, credentials: credentials));
  void remove(BigInt id) => _execute(() => _todoContract.deleteTask(id, credentials: credentials));


  void _subscribeEvent(StreamSubscription Function() body) {
    _subscriptions.add(body());
  }

  void _execute(Function body) async {
    try {
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
