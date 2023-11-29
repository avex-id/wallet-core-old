import 'dart:typed_data';

import '../caip/blockchain_id/blockchain_id.dart';

abstract class KeyPair<T extends BlockchainId, U, V> {
  T get blockchainId;
  U get publicKey;
  V get privateKey;
  String get public;
  String get private;
  Future<String> signData(String message);
}

abstract class KeyPairFactory<T extends BlockchainId, U, V> {
  KeyPair<T, U, V> fromPrivateKey(V privateKey);
  KeyPair<T, U, V> fromPrivateKeyString(String privateKey);
  Future<KeyPair<T, U, V>> fromSeed(Uint8List seed, int index);
}
