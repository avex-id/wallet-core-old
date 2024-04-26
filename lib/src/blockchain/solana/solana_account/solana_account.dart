import 'package:solana/solana.dart';
import '../../../domain/common/blockchain_account/blockchain_account.dart';
import '../../../domain/common/blockchain_account/strategy/keypair_strategy.dart';
import '../keypair/solana_keypair.dart';
import '../solana_account_id/solana_account_id.dart';
import '../solana_blockchain_id/solana_blockchain_id.dart';
import '../solana_blockchain_id/solana_blockchain_reference.dart';

typedef SolanaBlockchainAccountGeneratorType = BlockchainAccountGenerator<
    SolanaBlockchainAccount,
    SolanaBlockchainAccountId,
    SolanaBlockchainAccountSigner,
    SolanaBlockchainAccountVerifier,
    SolanaBlockchainId,
    Ed25519HDPublicKey>;

typedef SolanaBlockchainAccountSignerType
    = BlockchainAccountSigner<SolanaBlockchainId>;

typedef SolanaBlockchainAccountVerifierType
    = BlockchainAccountVerifier<SolanaBlockchainId>;

typedef SolanaBlockchainAccountType = BlockchainAccount<
    SolanaBlockchainAccountId,
    SolanaBlockchainAccountSigner,
    SolanaBlockchainAccountVerifier,
    SolanaBlockchainId,
    Ed25519HDPublicKey>;

typedef SolanaBlockchainAccountFactoryType = BlockchainAccountFactory<
    SolanaBlockchainAccount,
    SolanaBlockchainAccountId,
    SolanaBlockchainAccountSigner,
    SolanaBlockchainAccountVerifier,
    SolanaBlockchainAccountGenerator,
    SolanaBlockchainId,
    Ed25519HDPublicKey>;

typedef SolanaKeyPairBlockchainAccountStrategyType
    = KeyPairBlockchainAccountStrategy<
        SolanaBlockchainAccount,
        SolanaBlockchainAccountId,
        SolanaBlockchainAccountSigner,
        SolanaBlockchainAccountVerifier,
        SolanaBlockchainId,
        Ed25519HDPublicKey>;

typedef SolanaBlockchainAccountStrategyFactoryType
    = KeyPairBlockchainAccountStrategyFactory<
        SolanaBlockchainAccount,
        SolanaBlockchainAccountId,
        SolanaBlockchainAccountSigner,
        SolanaBlockchainAccountVerifier,
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

abstract class SolanaBlockchainAccountVerifier
    implements SolanaBlockchainAccountVerifierType {}

abstract class SolanaBlockchainAccountGenerator
    implements SolanaBlockchainAccountGeneratorType {}

class SolanaBlockchainAccount
    implements
        SolanaBlockchainAccountType,
        SolanaBlockchainAccountSigner,
        SolanaBlockchainAccountVerifier {
  @override
  final SolanaBlockchainAccountId blockchainAccountId;
  late SolanaBlockchainAccountSignerType _accountSigner;
  late SolanaBlockchainAccountVerifierType _accountVerifier;

  SolanaBlockchainAccount(
      SolanaReference reference, Ed25519HDPublicKey accountAddress)
      : blockchainAccountId =
            SolanaBlockchainAccountId(reference, accountAddress);

  @override
  Future<String> sign(String message) {
    return _accountSigner.sign(message);
  }

  @override
  Future<bool> verifySignature(String message, String signature) {
    return _accountVerifier.verifySignature(message, signature);
  }

  @override
  set signer(SolanaBlockchainAccountSignerType accountSigner) {
    _accountSigner = accountSigner;
  }

  @override
  set verifier(SolanaBlockchainAccountVerifierType accountVerifier) {
    _accountVerifier = accountVerifier;
  }
}

class SolanaBlockchainAccountFactory
    implements SolanaBlockchainAccountFactoryType {
  final SolanaBlockchainId blockchainId;
  late SolanaBlockchainAccountGenerator _generator;

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
  set generator(SolanaBlockchainAccountGenerator generator) {
    _generator = generator;
  }
}

class SolanaKeyPairBlockchainAccountStrategy
    implements
        SolanaKeyPairBlockchainAccountStrategyType,
        SolanaBlockchainAccountGenerator,
        SolanaBlockchainAccountSigner,
        SolanaBlockchainAccountVerifier {
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
  Future<String> sign(String message) async {
    return _keyPair.sign(message);
  }

  @override
  Future<bool> verifySignature(String message, String signature) async {
    return _keyPair.verifySignature(message, signature);
  }
}

class SolanaKeyPairBlockchainAccountStrategyFactory
    implements
        KeyPairBlockchainAccountStrategyFactory<
            SolanaBlockchainAccount,
            SolanaBlockchainAccountId,
            SolanaBlockchainAccountSigner,
            SolanaBlockchainAccountVerifier,
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
