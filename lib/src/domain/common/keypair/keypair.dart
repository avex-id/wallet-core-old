abstract class KeyPairSigner<PublicKeyType, PrivateKeyType> {
  Future<String> sign(String message);
}

abstract class KeyPairVerifier<PublicKeyType, PrivateKeyType> {
  Future<bool> verifySignature(String message, String signature);
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
  set signer(KeyPairSignerType signer);
  set verifier(KeyPairVerifierType verifier);
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
  set generator(KeyPairGeneratorType generator);
}
