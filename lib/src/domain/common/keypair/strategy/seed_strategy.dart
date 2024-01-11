import 'dart:typed_data';

import '../keypair.dart';

abstract class SeedKeyPairStrategy<
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

abstract class SeedKeyPairStrategyFactory<
    PublicKeyType,
    PrivateKeyType,
    KeyPairType extends KeyPair<PublicKeyType, PrivateKeyType,
        KeyPairSignerType, KeyPairVerifierType>,
    KeyPairSignerType extends KeyPairSigner<PublicKeyType, PrivateKeyType>,
    KeyPairVerifierType extends KeyPairVerifier<PublicKeyType, PrivateKeyType>,
    KeyPairGeneratorType extends KeyPairGenerator<PublicKeyType, PrivateKeyType,
        KeyPairType, KeyPairSignerType, KeyPairVerifierType>,
    KeyPairStrategyType extends SeedKeyPairStrategy<
        PublicKeyType,
        PrivateKeyType,
        KeyPairType,
        KeyPairSignerType,
        KeyPairVerifierType,
        KeyPairGeneratorType>> {
  KeyPairStrategyType createFromSeedAndIndex(Uint8List seed, int index);
}
