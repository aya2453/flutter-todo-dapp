import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';
import 'package:web_socket_channel/io.dart';

const String _rpcUrl = "http://192.168.11.10:7545";
const String _wsUrl = "ws://192.168.11.10:7545/";

final web3ClientProvider = Provider<Web3Client>((ref) {
  return Web3Client(_rpcUrl, Client(),
      socketConnector: () => IOWebSocketChannel.connect(_wsUrl).cast<String>());
});
