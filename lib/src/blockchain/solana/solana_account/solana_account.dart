import 'package:solana/solana.dart';
import '../../../domain/common/blockchain_account/blockchain_account.dart';
import '../keypair/solana_keypair.dart';
import '../solana_account_id/solana_account_id.dart';
import '../solana_blockchain_id/solana_blockchain_id.dart';
import '../solana_blockchain_id/solana_blockchain_reference.dart';

class SolanaBlockchainAccount
    implements BlockchainAccount<SolanaBlockchainAccountId> {
  @override
  final SolanaBlockchainAccountId blockchainAccountId;
  late final BlockchainAccountAuthenticator _authenticator;

  SolanaBlockchainAccount(
      SolanaReference reference, Ed25519HDPublicKey accountAddress)
      : blockchainAccountId =
            SolanaBlockchainAccountId(reference, accountAddress);

  @override
  Future<String> authenticate(String message) {
    return _authenticator.authenticate(message);
  }

  @override
  void setAuthenticator(BlockchainAccountAuthenticator authenticator) {
    _authenticator = authenticator;
  }
}

class SolanaBlockchainAccountFactory
    implements
        BlockchainAccountFactory<SolanaBlockchainAccount,
            SolanaBlockchainAccountId, Ed25519HDPublicKey> {
  final SolanaBlockchainId blockchainId;
  late final BlockchainAccountGenerator<SolanaBlockchainAccount> _generator;

  SolanaBlockchainAccountFactory(SolanaReference reference)
      : blockchainId = SolanaBlockchainId(reference);

  @override
  SolanaBlockchainAccount fromAddress(Ed25519HDPublicKey accountAddress) {
    return SolanaBlockchainAccount(blockchainId.reference, accountAddress);
  }

  @override
  SolanaBlockchainAccount fromString(String accountAddress) {
    return SolanaBlockchainAccount(
        blockchainId.reference, Ed25519HDPublicKey.fromBase58(accountAddress));
  }

  @override
  Future<SolanaBlockchainAccount> generate() {
    return _generator.generate();
  }

  @override
  void setGenerator(
      BlockchainAccountGenerator<SolanaBlockchainAccount> generator) {
    _generator = generator;
  }
}

class SolanaKeyPairBlockchainAccountStrategy
    implements KeyPairBlockchainAccountStrategy<SolanaBlockchainAccount> {
  final SolanaKeyPair _keyPair;

  SolanaKeyPairBlockchainAccountStrategy._(this._keyPair);

  factory SolanaKeyPairBlockchainAccountStrategy.generateAccountFromKeyPair(
      SolanaKeyPair keyPair) {
    return SolanaKeyPairBlockchainAccountStrategy._(keyPair);
  }

  @override
  Future<SolanaBlockchainAccount> generate() async {
    return SolanaBlockchainAccountFactory(_keyPair.blockchainId.reference)
        .fromAddress((await _keyPair.extractPublicKey()));
  }

  @override
  Future<String> authenticate(String message) async {
    return _keyPair.signMessage(message);
  }
}

class SolanaKeyPairBlockchainAccountStrategyFactory
    implements
        KeyPairBlockchainAccountStrategyFactory<
            SolanaBlockchainAccount,
            Ed25519HDPublicKey,
            Ed25519HDKeyPairData,
            SolanaKeyPair,
            SolanaKeyPairSigner,
            SolanaKeyPairVerifier> {
  @override
  KeyPairBlockchainAccountStrategy<SolanaBlockchainAccount> createFromKeyPair(
      SolanaKeyPair keyPair) {
    return SolanaKeyPairBlockchainAccountStrategy.generateAccountFromKeyPair(
        keyPair);
  }
}
