import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart';
import 'package:path/path.dart' as p;
import 'package:todo_dapp_front/todo_list_page_state.dart';
import 'package:web3dart/web3dart.dart';
import 'package:web_socket_channel/io.dart';

const String _privateKey = '85d2242ae1b7759934d4b0d4f0d62d666cf7d73e21dbd09d73c7de266b72a25a';
const String _rpcUrl = "http://127.0.0.1:7545";
const String _wsUrl = "ws://127.0.0.1:7545/";
final File abiFile = File(p.join(p.dirname(Platform.script.path), 'abi.json'));

class TodoListViewModel extends StateNotifier<TodoListPageState?> {
  TodoListViewModel() : super(null);

  late Web3Client _client;

  Future<void> init() async {
    _client = Web3Client(_rpcUrl, Client(), socketConnector: () => IOWebSocketChannel.connect(_wsUrl).cast());
  }

  Future<void> getAbi() async {
    final adbStringFile = await rootBundle.loadString("smartcontract/TodoContract.json");
    final jsonAbi = jsonDecode(adbStringFile);
    final abiCode = jsonEncode(jsonAbi["abi"]);
    final contractAddress = EthereumAddress.fromHex(jsonAbi["networks"]["5777"]["address"]);
  }

  Future<void> getCredentials() async {
    final credentials = await EthPrivateKey.fromHex(_privateKey);
    final ownAddress = await credentials.extractAddress();
  }

  Future<void> getDeployedContact() async {
    final adbStringFile = await abiFile.readAsString();
    final jsonAbi = jsonDecode(adbStringFile);
    final contractAddress = EthereumAddress.fromHex(jsonAbi["networks"]["5777"]["address"]);
    final contract = DeployedContract(ContractAbi.fromJson(adbStringFile, 'MetaCoin'), contractAddress);
  }
}
