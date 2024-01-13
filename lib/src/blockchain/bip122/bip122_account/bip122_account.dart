import 'package:coinlib/coinlib.dart';
import '../../../domain/common/blockchain_account/blockchain_account.dart';
import '../bip122_account_id/bip122_account_id.dart';
import '../bip122_blockchain_id/bip122_blockchain_id.dart';
import '../bip122_blockchain_id/bip122_blockchain_reference.dart';
import '../keypair/bip122_keypair.dart';

typedef Bip122BlockchainAccountGeneratorType = BlockchainAccountGenerator<
    Bip122BlockchainAccount,
    Bip122BlockchainAccountId,
    Bip122BlockchainAccountSigner,
    Bip122BlockchainId,
    Address>;

typedef Bip122BlockchainAccountSignerType
    = BlockchainAccountSigner<Bip122BlockchainId>;

typedef Bip122BlockchainAccountType = BlockchainAccount<
    Bip122BlockchainAccountId,
    Bip122BlockchainAccountSigner,
    Bip122BlockchainId,
    Address>;
typedef Bip122BlockchainAccountFactoryType = BlockchainAccountFactory<
    Bip122BlockchainAccount,
    Bip122BlockchainAccountId,
    Bip122BlockchainAccountSigner,
    Bip122BlockchainAccountGenerator,
    Bip122BlockchainId,
    Address>;

typedef Bip122KeyPairBlockchainAccountStrategyType
    = KeyPairBlockchainAccountStrategy<
        Bip122BlockchainAccount,
        Bip122BlockchainAccountId,
        Bip122BlockchainAccountSigner,
        Bip122BlockchainId,
        Address>;

typedef Bip122BlockchainAccountStrategyFactoryType
    = KeyPairBlockchainAccountStrategyFactory<
        Bip122BlockchainAccount,
        Bip122BlockchainAccountId,
        Bip122BlockchainAccountSigner,
        Bip122BlockchainId,
        Address,
        ECPublicKey,
        Bip122PrivateKeyType,
        Bip122KeyPair,
        Bip122KeyPairSigner,
        Bip122KeyPairVerifier,
        Bip122KeyPairBlockchainAccountStrategyType>;

abstract class Bip122BlockchainAccountSigner
    implements Bip122BlockchainAccountSignerType {}

abstract class Bip122BlockchainAccountGenerator
    implements Bip122BlockchainAccountGeneratorType {}

class Bip122BlockchainAccount implements Bip122BlockchainAccountType {
  @override
  final Bip122BlockchainAccountId blockchainAccountId;
  late final Bip122BlockchainAccountSignerType _authenticator;

  Bip122BlockchainAccount(Bip122Reference reference, Address accountAddress)
      : blockchainAccountId =
            Bip122BlockchainAccountId(reference, accountAddress);

  @override
  Future<String> signMessage(String message) {
    return _authenticator.signMessage(message);
  }

  @override
  void setAccountSigner(Bip122BlockchainAccountSignerType authenticator) {
    _authenticator = authenticator;
  }
}

class Bip122BlockchainAccountFactory
    implements Bip122BlockchainAccountFactoryType {
  final Bip122BlockchainId blockchainId;
  late final Bip122BlockchainAccountGenerator _generator;

  Bip122BlockchainAccountFactory(Bip122Reference reference)
      : blockchainId = Bip122BlockchainId(reference);

  @override
  Bip122BlockchainAccount fromAddress(Address accountAddress) {
    return Bip122BlockchainAccount(blockchainId.reference, accountAddress);
  }

  @override
  Bip122BlockchainAccount fromString(String accountAddress) {
    return Bip122BlockchainAccount(
        blockchainId.reference,
        Address.fromString(
            accountAddress, blockchainId.reference.networkParams));
  }

  @override
  Future<Bip122BlockchainAccount> generate() {
    return _generator.generate();
  }

  @override
  void setGenerator(Bip122BlockchainAccountGenerator generator) {
    _generator = generator;
  }
}

class Bip122KeyPairBlockchainAccountStrategy
    implements
        Bip122KeyPairBlockchainAccountStrategyType,
        Bip122BlockchainAccountGenerator,
        Bip122BlockchainAccountSigner {
  final Bip122KeyPair _keyPair;

  Bip122KeyPairBlockchainAccountStrategy._(this._keyPair);

  factory Bip122KeyPairBlockchainAccountStrategy.generateAccountFromKeyPair(
      Bip122KeyPair keyPair) {
    return Bip122KeyPairBlockchainAccountStrategy._(keyPair);
  }

  @override
  Future<Bip122BlockchainAccount> generate() async {
    return Bip122BlockchainAccountFactory(_keyPair.blockchainId.reference)
        .fromAddress(P2WPKHAddress.fromPublicKey(
            await _keyPair.extractPublicKey(),
            hrp: _keyPair.blockchainId.reference.networkParams.bech32Hrp));
  }

  @override
  Future<String> signMessage(String message) async {
    return _keyPair.signMessage(message);
  }
}

class Bip122KeyPairBlockchainAccountStrategyFactory
    implements
        KeyPairBlockchainAccountStrategyFactory<
            Bip122BlockchainAccount,
            Bip122BlockchainAccountId,
            Bip122BlockchainAccountSigner,
            Bip122BlockchainId,
            Address,
            ECPublicKey,
            Bip122PrivateKeyType,
            Bip122KeyPair,
            Bip122KeyPairSigner,
            Bip122KeyPairVerifier,
            Bip122KeyPairBlockchainAccountStrategy> {
  @override
  Bip122KeyPairBlockchainAccountStrategy createFromKeyPair(
      Bip122KeyPair keyPair) {
    return Bip122KeyPairBlockchainAccountStrategy.generateAccountFromKeyPair(
        keyPair);
  }
}
