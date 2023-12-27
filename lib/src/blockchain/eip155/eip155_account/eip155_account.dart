import '../keypair/eip155_keypair.dart';
import 'package:web3dart/credentials.dart';

import '../../../domain/common/blockchain_account/blockchain_account.dart';
import '../eip155_account_id/eip155_account_id.dart';
import '../eip155_blockchain_id/eip155_blockchain_id.dart';
import '../eip155_blockchain_id/eip155_blockchain_reference.dart';

class Eip155BlockchainAccount
    implements BlockchainAccount<Eip155BlockchainAccountId> {
  @override
  final Eip155BlockchainAccountId blockchainAccountId;
  late final BlockchainAccountAuthenticator _authenticator;

  Eip155BlockchainAccount(
      Eip155Reference reference, EthereumAddress accountAddress)
      : blockchainAccountId =
            Eip155BlockchainAccountId(reference, accountAddress);

  @override
  Future<String> authenticate(String message) {
    return _authenticator.authenticate(message);
  }

  @override
  void setAuthenticator(BlockchainAccountAuthenticator authenticator) {
    _authenticator = authenticator;
  }
}

class Eip155BlockchainAccountFactory
    implements
        BlockchainAccountFactory<Eip155BlockchainAccount,
            Eip155BlockchainAccountId, EthereumAddress> {
  final Eip155BlockchainId blockchainId;
  late final BlockchainAccountGenerator<Eip155BlockchainAccount> _generator;

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
  void setGenerator(
      BlockchainAccountGenerator<Eip155BlockchainAccount> generator) {
    _generator = generator;
  }
}

class Eip155KeyPairKeyPairBlockchainAccountGeneratorStrategy
    implements
        KeyPairKeyPairBlockchainAccountGeneratorStrategy<
            Eip155BlockchainAccount> {
  final Eip155KeyPair _keyPair;

  Eip155KeyPairKeyPairBlockchainAccountGeneratorStrategy._(this._keyPair);

  factory Eip155KeyPairKeyPairBlockchainAccountGeneratorStrategy.generateAccountFromKeyPair(
      Eip155KeyPair keyPair) {
    return Eip155KeyPairKeyPairBlockchainAccountGeneratorStrategy._(keyPair);
  }

  @override
  Future<Eip155BlockchainAccount> generate() async {
    return Eip155BlockchainAccountFactory(_keyPair.blockchainId.reference)
        .fromAddress((await _keyPair.extractPublicKey()));
  }
}

class Eip155KeyPairKeyPairBlockchainAccountGeneratorStrategyFactory
    implements
        KeyPairKeyPairBlockchainAccountGeneratorStrategyFactory<
            Eip155BlockchainAccount, Eip155KeyPair> {
  @override
  KeyPairKeyPairBlockchainAccountGeneratorStrategy<Eip155BlockchainAccount>
      createFromKeyPair(Eip155KeyPair keyPair) {
    return Eip155KeyPairKeyPairBlockchainAccountGeneratorStrategy
        .generateAccountFromKeyPair(keyPair);
  }
}
