import 'package:solana/solana.dart';
import '../../../domain/common/blockchain_account/blockchain_account.dart';
import '../keypair/solana_keypair.dart';
import '../solana_account_id/solana_account_id.dart';
import '../solana_blockchain_id/solana_blockchain_id.dart';
import '../solana_blockchain_id/solana_blockchain_reference.dart';

typedef SolanaBlockchainAccountGeneratorType = BlockchainAccountGenerator<
    SolanaBlockchainAccount,
    SolanaBlockchainAccountId,
    SolanaBlockchainAccountSigner,
    SolanaBlockchainId,
    Ed25519HDPublicKey>;

typedef SolanaBlockchainAccountSignerType
    = BlockchainAccountSigner<SolanaBlockchainId>;

typedef SolanaBlockchainAccountType = BlockchainAccount<
    SolanaBlockchainAccountId,
    SolanaBlockchainAccountSigner,
    SolanaBlockchainId,
    Ed25519HDPublicKey>;

typedef SolanaBlockchainAccountFactoryType = BlockchainAccountFactory<
    SolanaBlockchainAccount,
    SolanaBlockchainAccountId,
    SolanaBlockchainAccountSigner,
    SolanaBlockchainAccountGenerator,
    SolanaBlockchainId,
    Ed25519HDPublicKey>;

typedef SolanaKeyPairBlockchainAccountStrategyType
    = KeyPairBlockchainAccountStrategy<
        SolanaBlockchainAccount,
        SolanaBlockchainAccountId,
        SolanaBlockchainAccountSigner,
        SolanaBlockchainId,
        Ed25519HDPublicKey>;

typedef SolanaBlockchainAccountStrategyFactoryType
    = KeyPairBlockchainAccountStrategyFactory<
        SolanaBlockchainAccount,
        SolanaBlockchainAccountId,
        SolanaBlockchainAccountSigner,
        SolanaBlockchainId,
        Ed25519HDPublicKey,
        Ed25519HDPublicKey,
        Ed25519HDKeyPairData,
        SolanaKeyPair,
        SolanaKeyPairSigner,
        SolanaKeyPairVerifier,
        SolanaKeyPairBlockchainAccountStrategyType>;

abstract class SolanaBlockchainAccountSigner
    implements SolanaBlockchainAccountSignerType {}

abstract class SolanaBlockchainAccountGenerator
    implements SolanaBlockchainAccountGeneratorType {}

class SolanaBlockchainAccount implements SolanaBlockchainAccountType {
  @override
  final SolanaBlockchainAccountId blockchainAccountId;
  late final SolanaBlockchainAccountSignerType _authenticator;

  SolanaBlockchainAccount(
      SolanaReference reference, Ed25519HDPublicKey accountAddress)
      : blockchainAccountId =
            SolanaBlockchainAccountId(reference, accountAddress);

  @override
  Future<String> signMessage(String message) {
    return _authenticator.signMessage(message);
  }

  @override
  void setAccountSigner(SolanaBlockchainAccountSignerType authenticator) {
    _authenticator = authenticator;
  }
}

class SolanaBlockchainAccountFactory
    implements SolanaBlockchainAccountFactoryType {
  final SolanaBlockchainId blockchainId;
  late final SolanaBlockchainAccountGenerator _generator;

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
  void setGenerator(SolanaBlockchainAccountGenerator generator) {
    _generator = generator;
  }
}

class SolanaKeyPairBlockchainAccountStrategy
    implements
        SolanaKeyPairBlockchainAccountStrategyType,
        SolanaBlockchainAccountGenerator,
        SolanaBlockchainAccountSigner {
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
  Future<String> signMessage(String message) async {
    return _keyPair.signMessage(message);
  }
}

class SolanaKeyPairBlockchainAccountStrategyFactory
    implements
        KeyPairBlockchainAccountStrategyFactory<
            SolanaBlockchainAccount,
            SolanaBlockchainAccountId,
            SolanaBlockchainAccountSigner,
            SolanaBlockchainId,
            Ed25519HDPublicKey,
            Ed25519HDPublicKey,
            Ed25519HDKeyPairData,
            SolanaKeyPair,
            SolanaKeyPairSigner,
            SolanaKeyPairVerifier,
            SolanaKeyPairBlockchainAccountStrategy> {
  @override
  SolanaKeyPairBlockchainAccountStrategy createFromKeyPair(
      SolanaKeyPair keyPair) {
    return SolanaKeyPairBlockchainAccountStrategy.generateAccountFromKeyPair(
        keyPair);
  }
}
