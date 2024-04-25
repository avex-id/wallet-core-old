import 'dart:typed_data';

import 'package:aptos/aptos.dart';
import 'package:ed25519_edwards/ed25519_edwards.dart' as ed25519;
import '../../../domain/common/keypair/keypair.dart';
import '../../../domain/common/keypair/strategy/private_key_strategy.dart';
import '../../../domain/common/keypair/strategy/seed_strategy.dart';
import '../bip44/bip44.dart';
import '../aptos_blockchain_id/aptos_blockchain_id.dart';
import '../aptos_blockchain_id/aptos_blockchain_reference.dart';

typedef AptosPublicKeyType = ed25519.PublicKey;

typedef AptosPrivateKeyType = ed25519.PrivateKey;

typedef AptosKeyPairGeneratorType = KeyPairGenerator<
    AptosPublicKeyType,
    AptosPrivateKeyType,
    AptosKeyPair,
    AptosKeyPairSigner,
    AptosKeyPairVerifier>;

typedef AptosKeyPairSignerType
    = KeyPairSigner<AptosPublicKeyType, AptosPrivateKeyType>;

typedef AptosKeyPairVerifierType
    = KeyPairVerifier<AptosPublicKeyType, AptosPrivateKeyType>;

typedef AptosKeyPairType = KeyPair<AptosPublicKeyType, AptosPrivateKeyType,
    AptosKeyPairSigner, AptosKeyPairVerifier>;

typedef AptosKeyPairFactoryType = KeyPairFactory<
    AptosPublicKeyType,
    AptosPrivateKeyType,
    AptosKeyPair,
    AptosKeyPairSigner,
    AptosKeyPairVerifier,
    AptosKeyPairGenerator>;

typedef AptosSeedKeyPairStrategyType = SeedKeyPairStrategy<
    AptosPublicKeyType,
    AptosPrivateKeyType,
    AptosKeyPair,
    AptosKeyPairSigner,
    AptosKeyPairVerifier,
    AptosKeyPairGenerator>;

typedef AptosSeedKeyPairStrategyFactoryType = SeedKeyPairStrategyFactory<
    AptosPublicKeyType,
    AptosPrivateKeyType,
    AptosKeyPair,
    AptosKeyPairSigner,
    AptosKeyPairVerifier,
    AptosKeyPairGenerator,
    AptosSeedKeyPairStrategy>;

typedef AptosPrivateKeyPairStrategyType = PrivateKeyPairStrategy<
    AptosPublicKeyType,
    AptosPrivateKeyType,
    AptosKeyPair,
    AptosKeyPairSigner,
    AptosKeyPairVerifier,
    AptosKeyPairGenerator>;

typedef AptosPrivateKeyPairStrategyFactoryType = PrivateKeyPairStrategyFactory<
    AptosPublicKeyType,
    AptosPrivateKeyType,
    AptosKeyPair,
    AptosKeyPairSigner,
    AptosKeyPairVerifier,
    AptosKeyPairGenerator,
    AptosPrivateKeyPairStrategy>;

abstract class AptosKeyPairSigner extends AptosKeyPairSignerType {}

abstract class AptosKeyPairVerifier extends AptosKeyPairVerifierType {}

abstract class AptosKeyPairGenerator extends AptosKeyPairGeneratorType {}

class AptosKeyPair
    implements AptosKeyPairType, AptosKeyPairSigner, AptosKeyPairVerifier {
  final AptosBlockchainId blockchainId;
  final AptosPublicKeyType _publicKey;
  final AptosPrivateKeyType? _privateKey;
  late final AptosKeyPairSigner _signer;
  late final AptosKeyPairVerifier _verifier;

  AptosKeyPair._(AptosReference reference, this._publicKey, this._privateKey)
      : blockchainId = AptosBlockchainId(reference);

  @override
  Future<AptosPublicKeyType> extractPublicKey() async {
    return _publicKey;
  }

  @override
  Future<AptosPrivateKeyType?> extractSecretKey() async {
    return _privateKey;
  }

  @override
  Future<String> sign(String message) async {
    return _signer.sign(message);
  }

  @override
  Future<bool> verifySignature(String message, String signature) async {
    return _verifier.verifySignature(message, signature);
  }

  @override
  set signer(AptosKeyPairSigner signer) => _signer = signer;

  @override
  set verifier(AptosKeyPairVerifier verifier) => _verifier = verifier;

  @override
  String get publicKey =>
      HexString.fromUint8Array(Uint8List.fromList(_publicKey.bytes)).hex();

  @override
  String get privateKey => (_privateKey == null)
      ? ''
      : HexString.fromUint8Array(
              Uint8List.fromList(_privateKey!.bytes.sublist(0, 32)))
          .hex();
}

class AptosKeyPairFactory implements AptosKeyPairFactoryType {
  final AptosBlockchainId blockchainId;
  late final AptosKeyPairGenerator _generator;

  AptosKeyPairFactory(AptosReference reference)
      : blockchainId = AptosBlockchainId(reference);

  @override
  Future<AptosKeyPair> fromPublicKey(AptosPublicKeyType publicKey) async {
    return AptosKeyPair._(blockchainId.reference, publicKey, null);
  }

  @override
  Future<AptosKeyPair> fromPrivateKey(AptosPrivateKeyType privateKey) async {
    final AptosPublicKeyType publicKey = ed25519.public(privateKey);
    return AptosKeyPair._(blockchainId.reference, publicKey, privateKey);
  }

  @override
  Future<AptosKeyPair> fromPublicKeyString(String publicKey) async {
    final AptosPublicKeyType publicKeyData = _fromPublicKeyHex(publicKey);
    return AptosKeyPair._(blockchainId.reference, publicKeyData, null);
  }

  @override
  Future<AptosKeyPair> fromPrivateKeyString(String privateKey) async {
    final AptosPrivateKeyType privateKeyData = _fromPrivateKeyHex(privateKey);
    final AptosPublicKeyType publicKey = _fromPrivateKey(privateKeyData);
    return AptosKeyPair._(blockchainId.reference, publicKey, privateKeyData);
  }

  @override
  Future<AptosKeyPair> generate() async {
    return _generator.generate();
  }

  @override
  set generator(AptosKeyPairGenerator generator) => _generator = generator;

  AptosPublicKeyType _fromPrivateKey(AptosPrivateKeyType privateKey) {
    return ed25519.public(privateKey);
  }

  AptosPublicKeyType _fromPublicKeyHex(String publicKey) {
    return AptosPublicKeyType(HexString(publicKey).toUint8Array());
  }

  AptosPrivateKeyType _fromPrivateKeyHex(String privateKey) {
    final List<int> prKey = HexString(privateKey).toUint8Array();
    final sk = ed25519.newKeyFromSeed(prKey as Uint8List);
    return sk;
  }
}

class AptosSeedKeyPairStrategy
    implements
        AptosSeedKeyPairStrategyType,
        AptosKeyPairGenerator,
        AptosKeyPairSigner,
        AptosKeyPairVerifier {
  final AptosReference reference;
  final Uint8List _seed;
  final int _index;
  late final AptosKeyPair _keyPair;

  AptosSeedKeyPairStrategy._(this.reference, this._seed, this._index);

  factory AptosSeedKeyPairStrategy.generateKeyPairFromSeedAndIndex(
      AptosReference reference, Uint8List seed, int index) {
    return AptosSeedKeyPairStrategy._(reference, seed, index);
  }

  // * Generation
  @override
  Future<AptosKeyPair> generate() async {
    AptosPrivateKeyType key = await _fromSeedAndIndex(_seed, _index);
    _keyPair = await AptosKeyPairFactory(reference).fromPrivateKey(key);
    return _keyPair;
  }

  // * Signature
  @override
  Future<String> sign(String message) async {
    AptosPrivateKeyType? secretKey = await _keyPair.extractSecretKey();
    secretKey ??= await _fromSeedAndIndex(_seed, _index);
    final signature = ed25519.sign(secretKey, (message.codeUnits as Uint8List));
    return HexString.fromUint8Array(signature.sublist(0, 64)).hex();
  }

  // * Verification
  @override
  Future<bool> verifySignature(String message, String signature) async {
    AptosPublicKeyType publicKey = await _keyPair.extractPublicKey();
    return ed25519.verify(publicKey, (message.codeUnits as Uint8List),
        (signature.codeUnits as Uint8List));
  }

  Future<AptosPrivateKeyType> _fromSeedAndIndex(
      Uint8List seed, int index) async {
    String path = AptosDerivationPath(reference, account: _index).path;
    final keys = derivePath(path, HexString.fromUint8Array(seed).noPrefix());
    final sk = ed25519.newKeyFromSeed(keys.key!);
    return sk;
  }
}

class AptosSeedKeyPairStrategyFactory
    implements AptosSeedKeyPairStrategyFactoryType {
  final AptosReference reference;

  AptosSeedKeyPairStrategyFactory(this.reference);

  @override
  AptosSeedKeyPairStrategy createFromSeedAndIndex(Uint8List seed, int index) {
    return AptosSeedKeyPairStrategy.generateKeyPairFromSeedAndIndex(
        reference, seed, index);
  }
}

class AptosPrivateKeyPairStrategy
    implements
        AptosPrivateKeyPairStrategyType,
        AptosKeyPairGenerator,
        AptosKeyPairSigner,
        AptosKeyPairVerifier {
  final AptosBlockchainId blockchainId;
  final String privateKey;
  late final AptosKeyPair _keyPair;

  AptosPrivateKeyPairStrategy._(AptosReference reference, this.privateKey)
      : blockchainId = AptosBlockchainId(reference);

  factory AptosPrivateKeyPairStrategy.generateKeyPairFromPrivateKeyString(
      AptosReference reference, String privateKey) {
    return AptosPrivateKeyPairStrategy._(reference, privateKey);
  }

  // * Generation
  @override
  Future<AptosKeyPair> generate() async {
    _keyPair = await AptosKeyPairFactory(blockchainId.reference)
        .fromPrivateKeyString(privateKey);
    return _keyPair;
  }

  // * Signature
  @override
  Future<String> sign(String message) async {
    AptosPrivateKeyType? secretKey = await _keyPair.extractSecretKey();
    secretKey ??= _fromPrivateKeyHex(privateKey);
    final signature = ed25519.sign(secretKey, (message.codeUnits as Uint8List));
    return HexString.fromUint8Array(signature.sublist(0, 64)).hex();
  }

  // * Verification
  @override
  Future<bool> verifySignature(String message, String signature) async {
    AptosPublicKeyType publicKey = await _keyPair.extractPublicKey();
    return ed25519.verify(publicKey, (message.codeUnits as Uint8List),
        (signature.codeUnits as Uint8List));
  }

  AptosPrivateKeyType _fromPrivateKeyHex(String privateKey) {
    final List<int> prKey = HexString(privateKey).toUint8Array();
    final sk = ed25519.newKeyFromSeed(prKey as Uint8List);
    return sk;
  }
}

class AptosPrivateKeyPairStrategyFactory
    implements AptosPrivateKeyPairStrategyFactoryType {
  final AptosReference reference;

  AptosPrivateKeyPairStrategyFactory(this.reference);

  @override
  AptosPrivateKeyPairStrategy createFromPrivateKeyString(String privateKey) {
    return AptosPrivateKeyPairStrategy.generateKeyPairFromPrivateKeyString(
        reference, privateKey);
  }
}
