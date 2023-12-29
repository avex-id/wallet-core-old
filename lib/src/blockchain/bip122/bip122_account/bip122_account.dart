import 'package:coinlib/coinlib.dart';
import '../../../domain/common/blockchain_account/blockchain_account.dart';
import '../bip122_account_id/bip122_account_id.dart';
import '../bip122_blockchain_id/bip122_blockchain_id.dart';
import '../bip122_blockchain_id/bip122_blockchain_reference.dart';
import '../keypair/bip122_keypair.dart';

class Bip122BlockchainAccount
    implements BlockchainAccount<Bip122BlockchainAccountId> {
  @override
  final Bip122BlockchainAccountId blockchainAccountId;
  late final BlockchainAccountAuthenticator _authenticator;

  Bip122BlockchainAccount(Bip122Reference reference, Address accountAddress)
      : blockchainAccountId =
            Bip122BlockchainAccountId(reference, accountAddress);

  @override
  Future<String> authenticate(String message) {
    return _authenticator.authenticate(message);
  }

  @override
  void setAuthenticator(BlockchainAccountAuthenticator authenticator) {
    _authenticator = authenticator;
  }
}

class Bip122BlockchainAccountFactory
    implements
        BlockchainAccountFactory<Bip122BlockchainAccount,
            Bip122BlockchainAccountId, Address> {
  final Bip122BlockchainId blockchainId;
  late final BlockchainAccountGenerator<Bip122BlockchainAccount> _generator;

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
  void setGenerator(
      BlockchainAccountGenerator<Bip122BlockchainAccount> generator) {
    _generator = generator;
  }
}

class Bip122KeyPairBlockchainAccountStrategy
    implements KeyPairBlockchainAccountStrategy<Bip122BlockchainAccount> {
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
  Future<String> authenticate(String message) async {
    return _keyPair.signMessage(message);
  }
}

class Bip122KeyPairBlockchainAccountStrategyFactory
    implements
        KeyPairBlockchainAccountStrategyFactory<Bip122BlockchainAccount,
            Bip122KeyPair> {
  @override
  KeyPairBlockchainAccountStrategy<Bip122BlockchainAccount> createFromKeyPair(
      Bip122KeyPair keyPair) {
    return Bip122KeyPairBlockchainAccountStrategy.generateAccountFromKeyPair(
        keyPair);
  }
}
