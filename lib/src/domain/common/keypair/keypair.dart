abstract class KeyPairSigner<PublicKeyType, PrivateKeyType> {
  Future<String> signMessage(String message);
  // Future<String> signTransaction(String message);
}

abstract class KeyPairVerifier<PublicKeyType, PrivateKeyType> {
  Future<bool> verify(String message, String signature);
}

abstract class KeyPairGenerator<
    PublicKeyType,
    PrivateKeyType,
    KeyPairType extends KeyPair<PublicKeyType, PrivateKeyType,
        KeyPairSignerType, KeyPairVerifierType>,
    KeyPairSignerType extends KeyPairSigner<PublicKeyType, PrivateKeyType>,
    KeyPairVerifierType extends KeyPairVerifier<PublicKeyType,
        PrivateKeyType>> {
  Future<KeyPairType> generate();
}

abstract class KeyPair<
        PublicKeyType,
        PrivateKeyType,
        KeyPairSignerType extends KeyPairSigner<PublicKeyType, PrivateKeyType>,
        KeyPairVerifierType extends KeyPairVerifier<PublicKeyType,
            PrivateKeyType>>
    implements
        KeyPairSigner<PublicKeyType, PrivateKeyType>,
        KeyPairVerifier<PublicKeyType, PrivateKeyType> {
  Future<PublicKeyType> extractPublicKey();
  Future<PrivateKeyType?> extractSecretKey();
  String get publicKey;
  String get privateKey;
  void setSigner(KeyPairSignerType signer);
  void setVerifier(KeyPairVerifierType verifier);
}

abstract class KeyPairFactory<
        PublicKeyType,
        PrivateKeyType,
        KeyPairType extends KeyPair<PublicKeyType, PrivateKeyType,
            KeyPairSignerType, KeyPairVerifierType>,
        KeyPairSignerType extends KeyPairSigner<PublicKeyType, PrivateKeyType>,
        KeyPairVerifierType extends KeyPairVerifier<PublicKeyType, PrivateKeyType>,
        KeyPairGeneratorType extends KeyPairGenerator<
            PublicKeyType,
            PrivateKeyType,
            KeyPairType,
            KeyPairSignerType,
            KeyPairVerifierType>>
    implements
        KeyPairGenerator<PublicKeyType, PrivateKeyType, KeyPairType,
            KeyPairSignerType, KeyPairVerifierType> {
  Future<KeyPairType> fromPrivateKey(PrivateKeyType privateKey);
  Future<KeyPairType> fromPrivateKeyString(String privateKey);
  Future<KeyPairType> fromPublicKey(PublicKeyType publicKey);
  Future<KeyPairType> fromPublicKeyString(String privateKey);
  void setGenerator(KeyPairGeneratorType generator);
}
