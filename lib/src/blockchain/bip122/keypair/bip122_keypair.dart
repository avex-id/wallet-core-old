import 'dart:typed_data';
import 'package:coinlib/coinlib.dart';
import '../../../domain/common/keypair/keypair.dart';
import '../../../domain/common/keypair/strategy/private_key_strategy.dart';
import '../../../domain/common/keypair/strategy/seed_strategy.dart';
import '../bip122_blockchain_id/bip122_blockchain_id.dart';
import '../bip122_blockchain_id/bip122_blockchain_reference.dart';
import '../bip44/bip44.dart';

typedef Bip122PublicKeyType = ECPublicKey;

typedef Bip122PrivateKeyType = ECPrivateKey;

typedef Bip122KeyPairGeneratorType = KeyPairGenerator<
    Bip122PublicKeyType,
    Bip122PrivateKeyType,
    Bip122KeyPair,
    Bip122KeyPairSigner,
    Bip122KeyPairVerifier>;

typedef Bip122KeyPairSignerType
    = KeyPairSigner<Bip122PublicKeyType, Bip122PrivateKeyType>;

typedef Bip122KeyPairVerifierType
    = KeyPairVerifier<Bip122PublicKeyType, Bip122PrivateKeyType>;

typedef Bip122KeyPairType = KeyPair<Bip122PublicKeyType, Bip122PrivateKeyType,
    Bip122KeyPairSigner, Bip122KeyPairVerifier>;

typedef Bip122KeyPairFactoryType = KeyPairFactory<
    Bip122PublicKeyType,
    Bip122PrivateKeyType,
    Bip122KeyPair,
    Bip122KeyPairSigner,
    Bip122KeyPairVerifier,
    Bip122KeyPairGenerator>;

typedef Bip122SeedKeyPairStrategyType = SeedKeyPairStrategy<
    Bip122PublicKeyType,
    Bip122PrivateKeyType,
    Bip122KeyPair,
    Bip122KeyPairSigner,
    Bip122KeyPairVerifier,
    Bip122KeyPairGenerator>;

typedef Bip122SeedKeyPairStrategyFactoryType = SeedKeyPairStrategyFactory<
    Bip122PublicKeyType,
    Bip122PrivateKeyType,
    Bip122KeyPair,
    Bip122KeyPairSigner,
    Bip122KeyPairVerifier,
    Bip122KeyPairGenerator,
    Bip122SeedKeyPairStrategy>;

typedef Bip122PrivateKeyPairStrategyType = PrivateKeyPairStrategy<
    Bip122PublicKeyType,
    Bip122PrivateKeyType,
    Bip122KeyPair,
    Bip122KeyPairSigner,
    Bip122KeyPairVerifier,
    Bip122KeyPairGenerator>;

typedef Bip122PrivateKeyPairStrategyFactoryType = PrivateKeyPairStrategyFactory<
    Bip122PublicKeyType,
    Bip122PrivateKeyType,
    Bip122KeyPair,
    Bip122KeyPairSigner,
    Bip122KeyPairVerifier,
    Bip122KeyPairGenerator,
    Bip122PrivateKeyPairStrategy>;

abstract class Bip122KeyPairSigner extends Bip122KeyPairSignerType {}

abstract class Bip122KeyPairVerifier extends Bip122KeyPairVerifierType {}

abstract class Bip122KeyPairGenerator extends Bip122KeyPairGeneratorType {}

class Bip122KeyPair implements Bip122KeyPairType {
  final Bip122BlockchainId blockchainId;
  final Bip122PublicKeyType _publicKey;
  final Bip122PrivateKeyType? _privateKey;
  late final KeyPairSigner _signer;
  late final KeyPairVerifier _verifier;

  Bip122KeyPair._(Bip122Reference reference, this._publicKey, this._privateKey)
      : blockchainId = Bip122BlockchainId(reference);

  @override
  Future<Bip122PublicKeyType> extractPublicKey() async {
    return _publicKey;
  }

  @override
  Future<Bip122PrivateKeyType?> extractSecretKey() async {
    return _privateKey;
  }

  @override
  Future<String> signMessage(String message) async {
    return _signer.signMessage(message);
  }

  @override
  Future<String> signTransaction(String message) async {
    return _signer.signTransaction(message);
  }

  @override
  Future<bool> verify(String message, String signature) async {
    return _verifier.verify(message, signature);
  }

  @override
  void setSigner(KeyPairSigner signer) => _signer = signer;

  @override
  void setVerifier(KeyPairVerifier verifier) => _verifier = verifier;

  @override
  String get publicKey => _publicKey.hex;

  @override
  String get privateKey => (_privateKey == null)
      ? ''
      : WIF(
              privkey: _privateKey!,
              version: blockchainId.reference.networkParams.wifPrefix)
          .toString();
}

class Bip122KeyPairFactory implements Bip122KeyPairFactoryType {
  final Bip122BlockchainId blockchainId;
  late final Bip122KeyPairGenerator _generator;

  Bip122KeyPairFactory(Bip122Reference reference)
      : blockchainId = Bip122BlockchainId(reference);

  @override
  Future<Bip122KeyPair> fromPrivateKey(Bip122PrivateKeyType privateKey) async {
    final Bip122PublicKeyType publicKey = privateKey.pubkey;
    return Bip122KeyPair._(blockchainId.reference, publicKey, privateKey);
  }

  @override
  Future<Bip122KeyPair> fromPublicKey(Bip122PublicKeyType publicKey) async {
    return Bip122KeyPair._(blockchainId.reference, publicKey, null);
  }

  @override
  Future<Bip122KeyPair> fromPublicKeyString(String publicKey) async {
    final Bip122PublicKeyType ecPublicKey = _fromPublicKeyString(publicKey);
    return Bip122KeyPair._(blockchainId.reference, ecPublicKey, null);
  }

  @override
  Future<Bip122KeyPair> fromPrivateKeyString(String privateKey) async {
    final WIF wif = _fromPrivateKeyString(
        privateKey, blockchainId.reference.networkParams.wifPrefix);
    final Bip122PublicKeyType publicKey = _fromPrivateKey(wif);
    return Bip122KeyPair._(blockchainId.reference, publicKey, wif.privkey);
  }

  @override
  Future<Bip122KeyPair> generate() {
    return _generator.generate();
  }

  @override
  void setGenerator(Bip122KeyPairGenerator generator) => _generator = generator;

  Bip122PublicKeyType _fromPrivateKey(WIF wif) {
    return wif.privkey.pubkey;
  }

  Bip122PublicKeyType _fromPublicKeyString(String publicKey) {
    return Bip122PublicKeyType.fromHex(publicKey);
  }

  WIF _fromPrivateKeyString(String privateKey, int version) {
    return WIF.fromString(privateKey, version: version);
  }
}

class Bip122SeedKeyPairStrategy
    implements
        Bip122SeedKeyPairStrategyType,
        Bip122KeyPairGenerator,
        Bip122KeyPairSigner,
        Bip122KeyPairVerifier {
  final Bip122Reference reference;
  final Uint8List _seed;
  final int _index;
  late final Bip122KeyPair _keyPair;

  Bip122SeedKeyPairStrategy._(this.reference, this._seed, this._index);

  factory Bip122SeedKeyPairStrategy.generateKeyPairFromSeedAndIndex(
      Bip122Reference reference, Uint8List seed, int index) {
    return Bip122SeedKeyPairStrategy._(reference, seed, index);
  }

  @override
  Future<Bip122KeyPair> generate() async {
    HDPrivateKey hdKey = _fromSeedAndIndex(_seed, _index);
    _keyPair =
        await Bip122KeyPairFactory(reference).fromPrivateKey(hdKey.privateKey);
    return _keyPair;
  }

  @override
  Future<String> signMessage(String message) async {
    Bip122PrivateKeyType? secretKey = await _keyPair.extractSecretKey();
    secretKey ??= _fromSeedAndIndex(_seed, _index).privateKey;
    return MessageSignature.sign(
            key: secretKey,
            message: message,
            prefix: _keyPair.blockchainId.reference.networkParams.messagePrefix)
        .toString();
  }

  @override
  Future<String> signTransaction(String message) async {
    throw UnimplementedError();
  }

  @override
  Future<bool> verify(String message, String signature) async {
    throw UnimplementedError();
  }

  HDPrivateKey _fromSeedAndIndex(Uint8List seed, int index) {
    HDPrivateKey hdWallet = HDPrivateKey.fromSeed(seed);
    String path = Bip122DerivationPath(reference, addressIndex: index).path;
    return hdWallet.derivePath(path);
  }
}

class Bip122SeedKeyPairStrategyFactory
    implements Bip122SeedKeyPairStrategyFactoryType {
  final Bip122Reference reference;

  Bip122SeedKeyPairStrategyFactory(this.reference);

  @override
  Bip122SeedKeyPairStrategy createFromSeedAndIndex(Uint8List seed, int index) {
    return Bip122SeedKeyPairStrategy.generateKeyPairFromSeedAndIndex(
        reference, seed, index);
  }
}

class Bip122PrivateKeyPairStrategy
    implements
        Bip122PrivateKeyPairStrategyType,
        Bip122KeyPairGenerator,
        Bip122KeyPairSigner,
        Bip122KeyPairVerifier {
  final Bip122BlockchainId blockchainId;
  final String privateKey;
  late final Bip122KeyPair _keyPair;

  Bip122PrivateKeyPairStrategy._(Bip122Reference reference, this.privateKey)
      : blockchainId = Bip122BlockchainId(reference);

  factory Bip122PrivateKeyPairStrategy.generateKeyPairFromPrivateKeyString(
      Bip122Reference reference, String privateKey) {
    return Bip122PrivateKeyPairStrategy._(reference, privateKey);
  }

  @override
  Future<Bip122KeyPair> generate() async {
    _keyPair = await Bip122KeyPairFactory(blockchainId.reference)
        .fromPrivateKeyString(privateKey);
    return _keyPair;
  }

  @override
  Future<String> signMessage(String message) async {
    Bip122PrivateKeyType? secretKey = await _keyPair.extractSecretKey();
    secretKey ??= WIF.fromString(privateKey).privkey;
    return MessageSignature.sign(
            key: secretKey,
            message: message,
            prefix: _keyPair.blockchainId.reference.networkParams.messagePrefix)
        .toString();
  }

  @override
  Future<String> signTransaction(String message) async {
    throw UnimplementedError();
  }

  @override
  Future<bool> verify(String message, String signature) async {
    throw UnimplementedError();
  }
}

class Bip122PrivateKeyPairStrategyFactory
    implements Bip122PrivateKeyPairStrategyFactoryType {
  final Bip122Reference reference;

  Bip122PrivateKeyPairStrategyFactory(this.reference);

  @override
  Bip122PrivateKeyPairStrategy createFromPrivateKeyString(String privateKey) {
    return Bip122PrivateKeyPairStrategy.generateKeyPairFromPrivateKeyString(
        reference, privateKey);
  }
}
