import 'dart:typed_data';
import '../blockchain/bip122/account.dart';
import '../blockchain/eip155/account.dart';
import '../blockchain/solana/account.dart';
import '../domain/caip/blockchain_id/blockchain_id.dart';

abstract class KeyPair<T extends BlockchainId, U, V> {
  String get public;
  String get private;
  Future<String> signData(String message);
}

abstract class KeyPairFactory<T extends BlockchainId, U, V> {
  final T blockchainId;

  KeyPairFactory(this.blockchainId);

  KeyPair<T, U, V> fromPrivateKey(V privateKey);
  KeyPair<T, U, V> fromPrivateKeyString(String privateKey);
  Future<KeyPair<T, U, V>> fromSeed(Uint8List seed, int index);
}

class KeyPairFactoryProducer {
  static KeyPairFactory getFactory(BlockchainId blockchainId) {
    if (blockchainId is Eip155BlockchainId) {
      return Eip155KeyPairFactory(blockchainId);
    } else if (blockchainId is SolanaBlockchainId) {
      return SolanaKeyPairFactory(blockchainId);
    } else if (blockchainId is Bip122BlockchainId) {
      return Bip122KeyPairFactory(blockchainId);
    } else {
      throw Exception('Invalid Blockchain Namespace');
    }
  }
}
