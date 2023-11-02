import 'dart:typed_data';

import 'package:wallet_core/src/domain/caip/blockchain_id/blockchain_reference/bip122_reference.dart';
import 'package:wallet_core/src/domain/caip/blockchain_id/reference.dart';

import '../blockchain/bip122/account.dart';
import '../blockchain/eip155/account.dart';
import '../blockchain/solana/account.dart';
import '../domain/caip/blockchain_id/blockchain_id.dart';
import '../domain/caip/blockchain_id/namespace.dart';

abstract class KeyPair {
  String get publicKey;
  String get privateKey;
}

mixin KeyPairMixin {
  static KeyPair fromPrivateKeyString(
      BlockchainId blockchainId, String privateKey) {
    switch (blockchainId.namespace) {
      case BlockchainNamespace.eip155:
        return Eip155KeyPair.fromPrivateKeyString(privateKey);
      case BlockchainNamespace.solana:
        return SolanaKeyPair.fromPrivateKeyString(privateKey);
      case BlockchainNamespace.bip122:
        switch (blockchainId.reference) {
          case Bip122ReferenceWrapper(value: Bip122Reference.BitcoinMainnet):
            return Bip122KeyPair.fromPrivateKeyString(
                privateKey,
                Bip122Reference.BitcoinMainnet.networkParams.wifPrefix,
                Bip122Reference.BitcoinMainnet.networkParams.bech32Hrp);
          case Bip122ReferenceWrapper(value: Bip122Reference.BitcoinTestnet):
            return Bip122KeyPair.fromPrivateKeyString(
                privateKey,
                Bip122Reference.BitcoinTestnet.coinType,
                Bip122Reference.BitcoinTestnet.networkParams.bech32Hrp);
          default:
            throw Exception('Invalid Blockchain Reference');
        }
      default:
        throw Exception('Invalid Blockchain Namespace');
    }
  }

  static Future<KeyPair> fromSeed(
      Uint8List seed, BlockchainId blockchainId, int index) async {
    switch (blockchainId.namespace) {
      case BlockchainNamespace.eip155:
        return Eip155KeyPair.fromSeed(seed, blockchainId, index);
      case BlockchainNamespace.solana:
        return await SolanaKeyPair.fromSeed(seed, blockchainId, index);
      case BlockchainNamespace.bip122:
        switch (blockchainId.reference) {
          case Bip122ReferenceWrapper(value: Bip122Reference.BitcoinMainnet):
            return Bip122KeyPair.fromSeed(
                seed,
                blockchainId,
                index,
                Bip122Reference.BitcoinMainnet.coinType,
                Bip122Reference.BitcoinMainnet.networkParams.bech32Hrp);
          case Bip122ReferenceWrapper(value: Bip122Reference.BitcoinTestnet):
            return Bip122KeyPair.fromSeed(
              seed,
              blockchainId,
              index,
              Bip122Reference.BitcoinTestnet.coinType,
              Bip122Reference.BitcoinTestnet.networkParams.bech32Hrp,
            );
          default:
            throw Exception('Invalid Blockchain Reference');
        }
      default:
        throw Exception('Invalid Blockchain Namespace');
    }
  }
}
