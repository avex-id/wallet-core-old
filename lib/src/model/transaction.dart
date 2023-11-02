// import 'package:eip1559/eip1559.dart';
// import 'package:wallet_core/src/blockchain/eip155/account.dart';
// import 'package:wallet_core/src/blockchain/eip155/rpc.dart';
// import 'package:wallet_core/src/blockchain/eip155/transaction.dart';
// import 'package:wallet_core/src/domain/caip/account_id/account_address.dart';
// import 'package:wallet_core/src/domain/caip/blockchain_id/namespace.dart';
// import 'package:wallet_core/wallet_core.dart';
// import 'package:web3dart/credentials.dart';

import 'dart:typed_data';

import 'package:wallet_core/src/model/keypair.dart';
import 'package:wallet_core/wallet_core.dart';

abstract class TransactionWrapper {

  // Uint8List signRawTransaction(KeyPair keyPair);

  // KeyPair keyPair;
  // BlockchainAccountId to;
  // BlockchainAssetId assetId;

  // TransactionWrapper(this.keyPair, this.to, this.assetId);
}

// mixin TransactionMixin {
//   static Future<Transaction> nativeTransfer(KeyPair from,
//       BlockchainAccountId to, BlockchainAssetId assetId, BigInt value) async {
//     switch (assetId.assetType.blockchainId.namespace) {
//       case BlockchainNamespace.eip155:
//         {
//           Eip155KeyPair source = from as Eip155KeyPair;
//           Eip155AccountAddress destination =
//               to.accountAddress as Eip155AccountAddress;
//           var tx = Eip155Transaction.transfer(source.address, destination.value,
//               value, null, null, null, null, null);
//           var rpc = Eip155Rpc.fromUrl("https://mainnet.infura.io/v3/");
//           var maxGas = await rpc.estimateFee(tx.transaction);
//           List<Fee> gasFee = await rpc.getFee();
//           BigInt maxFeePerGas = gasFee[1].maxFeePerGas;
//           BigInt maxPriorityFeePerGas = gasFee[1].maxPriorityFeePerGas;
//           var nonce = await rpc.getNonce(source.address);
//         }

//       default:
//         throw ArgumentError('Asset $assetId is not supported');
//     }
//   }
// }
