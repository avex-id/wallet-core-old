import 'dart:typed_data';

abstract class KeyPairSigner {
  Future<String> signMessage(String message);
  // Future<String> signTransaction(String message);
}

abstract class KeyPairVerifier {
  Future<bool> verify(String message, String signature);
}

abstract class KeyPairGenerator<U extends KeyPair> {
  Future<U> generate();
}

abstract class KeyPair<U, V> implements KeyPairSigner, KeyPairVerifier {
  Future<U> extractPublicKey();
  Future<V?> extractSecretKey();
  String get publicKey;
  String get privateKey;
  void setSigner(KeyPairSigner signer);
  void setVerifier(KeyPairVerifier verifier);
}

abstract class KeyPairFactory<T extends KeyPair<U, V>, U, V>
    implements KeyPairGenerator<T> {
  Future<T> fromPrivateKey(V privateKey);
  Future<T> fromPublicKey(U publicKey);
  Future<T> fromPrivateKeyString(String privateKey);
  Future<T> fromPublicKeyString(String privateKey);
  void setGenerator(KeyPairGenerator<T> generator);
}

abstract class SeedKeyPairGeneratorStrategy<U extends KeyPair>
    implements KeyPairGenerator<U> {}

abstract class SeedKeyPairGeneratorStrategyFactory<U extends KeyPair> {
  SeedKeyPairGeneratorStrategy<U> createFromSeedAndIndex(
      Uint8List seed, int index);
}

abstract class KeyPairSignerStrategy<U extends KeyPair>
    implements KeyPairSigner {}

abstract class KeyPairSignerStrategyFactory<U extends KeyPair> {
  KeyPairSignerStrategy<U> createFromKeyPair(U keyPair);
}
