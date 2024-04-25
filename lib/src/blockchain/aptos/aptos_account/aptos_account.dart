import 'dart:typed_data';

import 'package:aptos/aptos.dart';
import 'package:ed25519_edwards/ed25519_edwards.dart';
import '../../../domain/common/blockchain_account/blockchain_account.dart';
import '../../../domain/common/blockchain_account/strategy/keypair_strategy.dart';
import '../keypair/aptos_keypair.dart';
import '../aptos_account_id/aptos_account_id.dart';
import '../aptos_blockchain_id/aptos_blockchain_id.dart';
import '../aptos_blockchain_id/aptos_blockchain_reference.dart';

typedef AptosBlockchainAccountGeneratorType = BlockchainAccountGenerator<
    AptosBlockchainAccount,
    AptosBlockchainAccountId,
    AptosBlockchainAccountSigner,
    AptosBlockchainAccountVerifier,
    AptosBlockchainId,
    AccountAddress>;

typedef AptosBlockchainAccountSignerType
    = BlockchainAccountSigner<AptosBlockchainId>;

typedef AptosBlockchainAccountVerifierType
    = BlockchainAccountVerifier<AptosBlockchainId>;

typedef AptosBlockchainAccountType = BlockchainAccount<
    AptosBlockchainAccountId,
    AptosBlockchainAccountSigner,
    AptosBlockchainAccountVerifier,
    AptosBlockchainId,
    AccountAddress>;

typedef AptosBlockchainAccountFactoryType = BlockchainAccountFactory<
    AptosBlockchainAccount,
    AptosBlockchainAccountId,
    AptosBlockchainAccountSigner,
    AptosBlockchainAccountVerifier,
    AptosBlockchainAccountGenerator,
    AptosBlockchainId,
    AccountAddress>;

typedef AptosKeyPairBlockchainAccountStrategyType
    = KeyPairBlockchainAccountStrategy<
        AptosBlockchainAccount,
        AptosBlockchainAccountId,
        AptosBlockchainAccountSigner,
        AptosBlockchainAccountVerifier,
        AptosBlockchainId,
        AccountAddress>;

typedef AptosBlockchainAccountStrategyFactoryType
    = KeyPairBlockchainAccountStrategyFactory<
        AptosBlockchainAccount,
        AptosBlockchainAccountId,
        AptosBlockchainAccountSigner,
        AptosBlockchainAccountVerifier,
        AptosBlockchainId,
        AccountAddress,
        PublicKey,
        PrivateKey,
        AptosKeyPair,
        AptosKeyPairSigner,
        AptosKeyPairVerifier,
        AptosKeyPairBlockchainAccountStrategyType>;

abstract class AptosBlockchainAccountSigner
    implements AptosBlockchainAccountSignerType {}

abstract class AptosBlockchainAccountVerifier
    implements AptosBlockchainAccountVerifierType {}

abstract class AptosBlockchainAccountGenerator
    implements AptosBlockchainAccountGeneratorType {}

class AptosBlockchainAccount
    implements
        AptosBlockchainAccountType,
        AptosBlockchainAccountSigner,
        AptosBlockchainAccountVerifier {
  @override
  final AptosBlockchainAccountId blockchainAccountId;
  late AptosBlockchainAccountSignerType _accountSigner;
  late AptosBlockchainAccountVerifier _accountVerifier;

  AptosBlockchainAccount(
      AptosReference reference, AccountAddress accountAddress)
      : blockchainAccountId =
            AptosBlockchainAccountId(reference, accountAddress);

  @override
  Future<String> sign(String message) {
    return _accountSigner.sign(message);
  }

  @override
  Future<bool> verifySignature(String message, String signature) {
    return _accountVerifier.verifySignature(message, signature);
  }

  @override
  set signer(AptosBlockchainAccountSignerType accountSigner) {
    _accountSigner = accountSigner;
  }

  @override
  set verifier(AptosBlockchainAccountVerifier accountVerifier) {
    _accountVerifier = accountVerifier;
  }
}

class AptosBlockchainAccountFactory
    implements AptosBlockchainAccountFactoryType {
  final AptosBlockchainId blockchainId;
  late AptosBlockchainAccountGenerator _generator;

  AptosBlockchainAccountFactory(AptosReference reference)
      : blockchainId = AptosBlockchainId(reference);

  @override
  AptosBlockchainAccount fromAddress(AccountAddress accountAddress) {
    return AptosBlockchainAccount(blockchainId.reference, accountAddress);
  }

  @override
  AptosBlockchainAccount fromString(String accountAddress) {
    return AptosBlockchainAccount(
        blockchainId.reference, AccountAddress.fromHex(accountAddress));
  }

  @override
  Future<AptosBlockchainAccount> generate() {
    return _generator.generate();
  }

  @override
  set generator(AptosBlockchainAccountGenerator generator) {
    _generator = generator;
  }
}

class AptosKeyPairBlockchainAccountStrategy
    implements
        AptosKeyPairBlockchainAccountStrategyType,
        AptosBlockchainAccountGenerator,
        AptosBlockchainAccountSigner,
        AptosBlockchainAccountVerifier {
  final AptosKeyPair _keyPair;

  AptosKeyPairBlockchainAccountStrategy._(this._keyPair);

  factory AptosKeyPairBlockchainAccountStrategy.generateAccountFromKeyPair(
      AptosKeyPair keyPair) {
    return AptosKeyPairBlockchainAccountStrategy._(keyPair);
  }

  @override
  Future<AptosBlockchainAccount> generate() async {
    final authKey = AuthenticationKey.fromEd25519PublicKey(Ed25519PublicKey(
        (await _keyPair.extractPublicKey()).bytes as Uint8List));
    return AptosBlockchainAccountFactory(_keyPair.blockchainId.reference)
        .fromString(authKey.derivedAddress().hex());
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

class AptosKeyPairBlockchainAccountStrategyFactory
    implements
        KeyPairBlockchainAccountStrategyFactory<
            AptosBlockchainAccount,
            AptosBlockchainAccountId,
            AptosBlockchainAccountSigner,
            AptosBlockchainAccountVerifier,
            AptosBlockchainId,
            AccountAddress,
            PublicKey,
            PrivateKey,
            AptosKeyPair,
            AptosKeyPairSigner,
            AptosKeyPairVerifier,
            AptosKeyPairBlockchainAccountStrategy> {
  @override
  AptosKeyPairBlockchainAccountStrategy createFromKeyPair(
      AptosKeyPair keyPair) {
    return AptosKeyPairBlockchainAccountStrategy.generateAccountFromKeyPair(
        keyPair);
  }
}
