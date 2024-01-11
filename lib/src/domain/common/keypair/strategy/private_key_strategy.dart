
import '../keypair.dart';


abstract class PrivateKeyPairStrategy<
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
        KeyPairSigner<PublicKeyType, PrivateKeyType>,
        KeyPairVerifier<PublicKeyType, PrivateKeyType>,
        KeyPairGenerator<PublicKeyType, PrivateKeyType, KeyPairType,
            KeyPairSignerType, KeyPairVerifierType> {}

abstract class PrivateKeyPairStrategyFactory<
    PublicKeyType,
    PrivateKeyType,
    KeyPairType extends KeyPair<PublicKeyType, PrivateKeyType,
        KeyPairSignerType, KeyPairVerifierType>,
    KeyPairSignerType extends KeyPairSigner<PublicKeyType, PrivateKeyType>,
    KeyPairVerifierType extends KeyPairVerifier<PublicKeyType, PrivateKeyType>,
    KeyPairGeneratorType extends KeyPairGenerator<PublicKeyType, PrivateKeyType,
        KeyPairType, KeyPairSignerType, KeyPairVerifierType>,
    KeyPairStrategyType extends PrivateKeyPairStrategy<
        PublicKeyType,
        PrivateKeyType,
        KeyPairType,
        KeyPairSignerType,
        KeyPairVerifierType,
        KeyPairGeneratorType>> {
  KeyPairStrategyType createFromPrivateKeyString(String privateKey);
}