import '../keypair/eip155_keypair.dart';
import 'package:web3dart/credentials.dart';

import '../../../domain/common/blockchain_account/blockchain_account.dart';
import '../eip155_account_id/eip155_account_id.dart';
import '../eip155_blockchain_id/eip155_blockchain_id.dart';
import '../eip155_blockchain_id/eip155_blockchain_reference.dart';

typedef Eip155BlockchainAccountGeneratorType = BlockchainAccountGenerator<
    Eip155BlockchainAccount,
    Eip155BlockchainAccountId,
    Eip155BlockchainAccountSigner,
    Eip155BlockchainId,
    EthereumAddress>;

typedef Eip155BlockchainAccountSignerType
    = BlockchainAccountSigner<Eip155BlockchainId>;

typedef Eip155BlockchainAccountType = BlockchainAccount<
    Eip155BlockchainAccountId,
    Eip155BlockchainAccountSigner,
    Eip155BlockchainId,
    EthereumAddress>;

typedef Eip155BlockchainAccountFactoryType = BlockchainAccountFactory<
    Eip155BlockchainAccount,
    Eip155BlockchainAccountId,
    Eip155BlockchainAccountSigner,
    Eip155BlockchainAccountGenerator,
    Eip155BlockchainId,
    EthereumAddress>;

typedef Eip155KeyPairBlockchainAccountStrategyType
    = KeyPairBlockchainAccountStrategy<
        Eip155BlockchainAccount,
        Eip155BlockchainAccountId,
        Eip155BlockchainAccountSigner,
        Eip155BlockchainId,
        EthereumAddress>;

typedef Eip155BlockchainAccountStrategyFactoryType
    = KeyPairBlockchainAccountStrategyFactory<
        Eip155BlockchainAccount,
        Eip155BlockchainAccountId,
        Eip155BlockchainAccountSigner,
        Eip155BlockchainId,
        EthereumAddress,
        EthereumAddress,
        EthPrivateKey,
        Eip155KeyPair,
        Eip155KeyPairSigner,
        Eip155KeyPairVerifier,
        Eip155KeyPairBlockchainAccountStrategyType>;

abstract class Eip155BlockchainAccountSigner
    implements Eip155BlockchainAccountSignerType {
  Future<String> personalSign(String message);
  Future<String> ethSign(String message);
  Future<String> ethSignTypedData(String message);
  // Future<String> ethSignTransaction(Transaction transaction);
  // Future<String> ethSendTransaction(Transaction transaction);
}

abstract class Eip155BlockchainAccountGenerator
    implements Eip155BlockchainAccountGeneratorType {}

class Eip155BlockchainAccount
    implements Eip155BlockchainAccountType, Eip155BlockchainAccountSigner {
  @override
  final Eip155BlockchainAccountId blockchainAccountId;
  late final Eip155BlockchainAccountSigner _accountSigner;

  Eip155BlockchainAccount(
      Eip155Reference reference, EthereumAddress accountAddress)
      : blockchainAccountId =
            Eip155BlockchainAccountId(reference, accountAddress);

  @override
  Future<String> signMessage(String message) {
    return _accountSigner.signMessage(message);
  }

  @override
  Future<String> personalSign(String message) {
    return _accountSigner.personalSign(message);
  }

  @override
  Future<String> ethSign(String message) {
    return _accountSigner.ethSign(message);
  }

  @override
  Future<String> ethSignTypedData(String message) {
    return _accountSigner.ethSignTypedData(message);
  }

  @override
  void setAccountSigner(Eip155BlockchainAccountSigner accountSigner) {
    _accountSigner = accountSigner;
  }
}

class Eip155BlockchainAccountFactory
    implements Eip155BlockchainAccountFactoryType {
  final Eip155BlockchainId blockchainId;
  late final Eip155BlockchainAccountGenerator _generator;

  Eip155BlockchainAccountFactory(Eip155Reference reference)
      : blockchainId = Eip155BlockchainId(reference);

  @override
  Eip155BlockchainAccount fromAddress(EthereumAddress accountAddress) {
    return Eip155BlockchainAccount(blockchainId.reference, accountAddress);
  }

  @override
  Eip155BlockchainAccount fromString(String accountAddress) {
    return Eip155BlockchainAccount(
        blockchainId.reference, EthereumAddress.fromHex(accountAddress));
  }

  @override
  Future<Eip155BlockchainAccount> generate() {
    return _generator.generate();
  }

  @override
  void setGenerator(Eip155BlockchainAccountGenerator generator) {
    _generator = generator;
  }
}

class Eip155KeyPairBlockchainAccountStrategy
    implements
        Eip155KeyPairBlockchainAccountStrategyType,
        Eip155BlockchainAccountGenerator,
        Eip155BlockchainAccountSigner {
  final Eip155KeyPair _keyPair;

  Eip155KeyPairBlockchainAccountStrategy._(this._keyPair);

  factory Eip155KeyPairBlockchainAccountStrategy.generateAccountFromKeyPair(
      Eip155KeyPair keyPair) {
    return Eip155KeyPairBlockchainAccountStrategy._(keyPair);
  }

  @override
  Future<Eip155BlockchainAccount> generate() async {
    return Eip155BlockchainAccountFactory(_keyPair.blockchainId.reference)
        .fromAddress((await _keyPair.extractPublicKey()));
  }

  @override
  Future<String> signMessage(String message) async {
    return _keyPair.signMessage(message);
  }

  @override
  Future<String> personalSign(String message) async {
    return _keyPair.personalSign(message);
  }

  @override
  Future<String> ethSign(String message) async {
    return _keyPair.ethSign(message);
  }

  @override
  Future<String> ethSignTypedData(String message) async {
    return _keyPair.ethSignTypedData(message);
  }
}

class Eip155KeyPairBlockchainAccountStrategyFactory
    implements
        KeyPairBlockchainAccountStrategyFactory<
            Eip155BlockchainAccount,
            Eip155BlockchainAccountId,
            Eip155BlockchainAccountSigner,
            Eip155BlockchainId,
            EthereumAddress,
            EthereumAddress,
            EthPrivateKey,
            Eip155KeyPair,
            Eip155KeyPairSigner,
            Eip155KeyPairVerifier,
            Eip155KeyPairBlockchainAccountStrategy> {
  @override
  Eip155KeyPairBlockchainAccountStrategy createFromKeyPair(
      Eip155KeyPair keyPair) {
    return Eip155KeyPairBlockchainAccountStrategy.generateAccountFromKeyPair(
        keyPair);
  }
}
