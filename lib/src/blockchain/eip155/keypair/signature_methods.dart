import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:eth_sig_util/eth_sig_util.dart';
import 'package:web3dart/web3dart.dart';


// class EVMService {
//     final wallet = _web3WalletService.getWeb3Wallet();
//     // Supported events
//     final supportedEvents = [
//       'chainChanged',
//       'accountsChanged'
//     ]; // add whatever event you want to support
//     for (final String event in supportedEvents) {
//       print('Supported event ${chainSupported.chain()} $event');
//       wallet.registerEventEmitter(
//         chainId: chainSupported.chain(),
//         event: event,
//       );
//     }
//     // Supported methods
//     Map<String, dynamic Function(String, dynamic)> methodsHandlers = {
//       'personal_sign': personalSign,
//       'eth_sign': ethSign,
//       'eth_signTransaction': ethSignTransaction,
//       'eth_signTypedData': ethSignTypedData,
//       'eth_sendTransaction': ethSignTransaction,
//       // add whatever method/handler you want to support
//       // 'eth_signTypedData_v4': ethSignTypedDataV4,
//     };

//     for (var handler in methodsHandlers.entries) {
//       wallet.registerRequestHandler(
//         chainId: chainSupported.chain(),
//         method: handler.key,
//         handler: handler.value,
//       );
//     }
//   }

//   Future<String?> personalSign(String topic, dynamic parameters) async {
//     print('received personal sign request: $parameters');

//     // final String message = EthUtils.getUtf8Message(parameters[0]);

//     // final String? authAcquired = await requestAuthorization(message);
//     // if (authAcquired != null) {
//     //   return authAcquired;
//     // }

//     try {
//       final Credentials credentials = EthPrivateKey.fromHex(keys[0].privateKey);

//       final String signature = hex.encode(
//         credentials.signPersonalMessageToUint8List(
//           Uint8List.fromList(
//             utf8.encode(message),
//           ),
//         ),
//       );

//       return '0x$signature';
//     } catch (e) {
//       print(e);
//       return 'Failed';
//     }
//   }

//   Future<String?> ethSign(String topic, dynamic parameters) async {
//     print('received eth sign request: $parameters');

//     final String message = EthUtils.getUtf8Message(parameters[1]);

//     final String? authAcquired = await requestAuthorization(message);
//     if (authAcquired != null) {
//       return authAcquired;
//     }

//     try {
//       // Load the private key
//       final List<ChainKey> keys = GetIt.I<IKeyService>().getKeysForChain(
//         chainSupported.chain(),
//       );
//       // print('private key');
//       // print(keys[0].privateKey);

//       // final String signature = EthSigUtil.signMessage(
//       //   message: Uint8List.fromList(
//       //     utf8.encode(message),
//       //   ),
//       //   privateKey: keys[0].privateKey,
//       // );
//       final EthPrivateKey credentials = EthPrivateKey.fromHex(
//         keys[0].privateKey,
//       );
//       final String signature = hex.encode(
//         credentials.signPersonalMessageToUint8List(
//           Uint8List.fromList(
//             utf8.encode(message),
//           ),
//         ),
//       );
//       print(signature);

//       return '0x$signature';
//     } catch (e) {
//       print('error:');
//       print(e);
//       return 'Failed';
//     }
//   }

//   Future<String?> ethSignTransaction(String topic, dynamic parameters) async {
//     print('received eth sign transaction request: $parameters');
//     final String? authAcquired = await requestAuthorization(
//       jsonEncode(
//         parameters[0],
//       ),
//     );
//     if (authAcquired != null) {
//       return authAcquired;
//     }

//     // Load the private key
//     final List<ChainKey> keys = GetIt.I<IKeyService>().getKeysForChain(
//       chainSupported.chain(),
//     );
//     final Credentials credentials = EthPrivateKey.fromHex(
//       '0x${keys[0].privateKey}',
//     );

//     EthereumTransaction ethTransaction = EthereumTransaction.fromJson(
//       parameters[0],
//     );

//     // Construct a transaction from the EthereumTransaction object
//     final transaction = Transaction(
//       from: EthereumAddress.fromHex(ethTransaction.from),
//       to: EthereumAddress.fromHex(ethTransaction.to),
//       value: EtherAmount.fromBigInt(
//         EtherUnit.wei,
//         BigInt.tryParse(ethTransaction.value) ?? BigInt.zero,
//       ),
//       gasPrice: ethTransaction.gasPrice != null
//           ? EtherAmount.fromBigInt(
//               EtherUnit.wei,
//               BigInt.tryParse(ethTransaction.gasPrice!) ?? BigInt.zero,
//             )
//           : null,
//       maxFeePerGas: ethTransaction.maxFeePerGas != null
//           ? EtherAmount.fromBigInt(
//               EtherUnit.wei,
//               BigInt.tryParse(ethTransaction.maxFeePerGas!) ?? BigInt.zero,
//             )
//           : null,
//       maxPriorityFeePerGas: ethTransaction.maxPriorityFeePerGas != null
//           ? EtherAmount.fromBigInt(
//               EtherUnit.wei,
//               BigInt.tryParse(ethTransaction.maxPriorityFeePerGas!) ??
//                   BigInt.zero,
//             )
//           : null,
//       maxGas: int.tryParse(ethTransaction.gasLimit ?? ''),
//       nonce: int.tryParse(ethTransaction.nonce ?? ''),
//       data: (ethTransaction.data != null && ethTransaction.data != '0x')
//           ? Uint8List.fromList(hex.decode(ethTransaction.data!))
//           : null,
//     );

//     try {
//       final Uint8List sig = await ethClient.signTransaction(
//         credentials,
//         transaction,
//       );

//       // Sign the transaction
//       final String signedTx = hex.encode(sig);

//       // Return the signed transaction as a hexadecimal string
//       return '0x$signedTx';
//     } catch (e) {
//       print(e);
//       return 'Failed';
//     }
//   }

//   Future<String?> ethSignTypedData(String topic, dynamic parameters) async {
//     print('received eth sign typed data request: $parameters');
//     final String data = parameters[1];
//     final String? authAcquired = await requestAuthorization(data);
//     if (authAcquired != null) {
//       return authAcquired;
//     }

//     final List<ChainKey> keys = GetIt.I<IKeyService>().getKeysForChain(
//       chainSupported.chain(),
//     );

//     // EthPrivateKey credentials = EthPrivateKey.fromHex(keys[0].privateKey);
//     // credentials.

//     return EthSigUtil.signTypedData(
//       privateKey: keys[0].privateKey,
//       jsonData: data,
//       version: TypedDataVersion.V4,
//     );
//   }
