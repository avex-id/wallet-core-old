import 'dart:typed_data';

import 'package:bip32_bip44/dart_bip32_bip44.dart';
import 'package:eth_sig_util/eth_sig_util.dart';
import 'package:eth_sig_util/util/utils.dart';
import 'package:hex/hex.dart';
import 'package:web3dart/web3dart.dart';
import '../../../domain/common/keypair/keypair.dart';
import '../../../domain/common/keypair/strategy/private_key_strategy.dart';
import '../../../domain/common/keypair/strategy/seed_strategy.dart';
import '../bip44/bip44.dart';
import '../eip155_blockchain_id/eip155_blockchain_id.dart';
import '../eip155_blockchain_id/eip155_blockchain_reference.dart';

typedef Eip155PublicKeyType = EthereumAddress;

typedef Eip155PrivateKeyType = EthPrivateKey;

typedef Eip155KeyPairGeneratorType = KeyPairGenerator<
    Eip155PublicKeyType,
    Eip155PrivateKeyType,
    Eip155KeyPair,
    Eip155KeyPairSigner,
    Eip155KeyPairVerifier>;

typedef Eip155KeyPairSignerType
    = KeyPairSigner<Eip155PublicKeyType, Eip155PrivateKeyType>;

typedef Eip155KeyPairVerifierType
    = KeyPairVerifier<Eip155PublicKeyType, Eip155PrivateKeyType>;

typedef Eip155KeyPairType = KeyPair<Eip155PublicKeyType, Eip155PrivateKeyType,
    Eip155KeyPairSigner, Eip155KeyPairVerifier>;

typedef Eip155KeyPairFactoryType = KeyPairFactory<
    Eip155PublicKeyType,
    Eip155PrivateKeyType,
    Eip155KeyPair,
    Eip155KeyPairSigner,
    Eip155KeyPairVerifier,
    Eip155KeyPairGenerator>;

typedef Eip155SeedKeyPairStrategyType = SeedKeyPairStrategy<
    Eip155PublicKeyType,
    Eip155PrivateKeyType,
    Eip155KeyPair,
    Eip155KeyPairSigner,
    Eip155KeyPairVerifier,
    Eip155KeyPairGenerator>;

typedef Eip155SeedKeyPairStrategyFactoryType = SeedKeyPairStrategyFactory<
    Eip155PublicKeyType,
    Eip155PrivateKeyType,
    Eip155KeyPair,
    Eip155KeyPairSigner,
    Eip155KeyPairVerifier,
    Eip155KeyPairGenerator,
    Eip155SeedKeyPairStrategy>;

typedef Eip155PrivateKeyPairStrategyType = PrivateKeyPairStrategy<
    Eip155PublicKeyType,
    Eip155PrivateKeyType,
    Eip155KeyPair,
    Eip155KeyPairSigner,
    Eip155KeyPairVerifier,
    Eip155KeyPairGenerator>;

typedef Eip155PrivateKeyPairStrategyFactoryType = PrivateKeyPairStrategyFactory<
    Eip155PublicKeyType,
    Eip155PrivateKeyType,
    Eip155KeyPair,
    Eip155KeyPairSigner,
    Eip155KeyPairVerifier,
    Eip155KeyPairGenerator,
    Eip155PrivateKeyPairStrategy>;

abstract class Eip155KeyPairSigner implements Eip155KeyPairSignerType {
  // // Future<String> personalSign(String message);
  // Future<String> ethSign(String message);
  // // Future<String> ethSignTransaction(String message);
  // Future<String> ethSignTypedData(String message);
  // Future<String> ethSendTransaction(String message);
}

abstract class Eip155KeyPairVerifier implements Eip155KeyPairVerifierType {}

abstract class Eip155KeyPairGenerator implements Eip155KeyPairGeneratorType {}

class Eip155KeyPair implements Eip155KeyPairType {
  final Eip155BlockchainId blockchainId;
  final Eip155PublicKeyType _publicKey;
  final Eip155PrivateKeyType? _privateKey;
  late final Eip155KeyPairSigner _signer;
  late final Eip155KeyPairVerifier _verifier;

  Eip155KeyPair._(Eip155Reference reference, this._publicKey, this._privateKey)
      : blockchainId = Eip155BlockchainId(reference);

  @override
  Future<Eip155PublicKeyType> extractPublicKey() async {
    return _publicKey;
  }

  @override
  Future<Eip155PrivateKeyType?> extractSecretKey() async {
    if (_privateKey == null) {
      return null;
    }
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

  // Future<String> ethSign(String message) async {
  //   return _signer.signMessage(message);
  // }

  // Future<String> ethSignTypedData(String message) async {
  //   return _signer.ethSignTypedData(message);
  // }

  // Future<String> ethSendTransaction(String message) async {
  //   return _signer.ethSendTransaction(message);
  // }

  @override
  void setSigner(Eip155KeyPairSigner signer) => _signer = signer;

  @override
  void setVerifier(Eip155KeyPairVerifier verifier) => _verifier = verifier;

  @override
  String get publicKey => _publicKey.hexEip55;

  @override
  String get privateKey =>
      (_privateKey == null) ? '' : bytesToHex(_privateKey!.privateKey);
}

class Eip155KeyPairFactory implements Eip155KeyPairFactoryType {
  final Eip155BlockchainId blockchainId;
  late final Eip155KeyPairGenerator _generator;

  Eip155KeyPairFactory(Eip155Reference reference)
      : blockchainId = Eip155BlockchainId(reference);

  @override
  Future<Eip155KeyPair> fromPublicKey(Eip155PublicKeyType publicKey) async {
    return Eip155KeyPair._(blockchainId.reference, publicKey, null);
  }

  @override
  Future<Eip155KeyPair> fromPrivateKey(Eip155PrivateKeyType privateKey) async {
    final Eip155PublicKeyType publicKey = _fromPrivateKey(privateKey).address;
    return Eip155KeyPair._(blockchainId.reference, publicKey, privateKey);
  }

  @override
  Future<Eip155KeyPair> fromPublicKeyString(String publicKeyHex) async {
    final Eip155PublicKeyType publicKey = _fromPublicKeyHex(publicKeyHex);
    return Eip155KeyPair._(blockchainId.reference, publicKey, null);
  }

  @override
  Future<Eip155KeyPair> fromPrivateKeyString(String privateKeyHex) async {
    final Eip155PublicKeyType publicKey =
        _fromPrivateKeyHex(privateKeyHex).address;
    return Eip155KeyPair._(blockchainId.reference, publicKey,
        Eip155PrivateKeyType.fromHex(privateKeyHex));
  }

  @override
  Future<Eip155KeyPair> generate() {
    return _generator.generate();
  }

  @override
  void setGenerator(Eip155KeyPairGenerator generator) => _generator = generator;

  Credentials _fromPrivateKey(Eip155PrivateKeyType key) {
    return key;
  }

  Eip155PublicKeyType _fromPublicKeyHex(String publicKeyHex) {
    return Eip155PublicKeyType.fromHex(publicKeyHex);
  }

  Credentials _fromPrivateKeyHex(String privateKeyHex) {
    return Eip155PrivateKeyType.fromHex(privateKeyHex);
  }
}

class Eip155SeedKeyPairStrategy
    implements
        Eip155SeedKeyPairStrategyType,
        Eip155KeyPairGenerator,
        Eip155KeyPairSigner,
        Eip155KeyPairVerifier {
  final Eip155Reference reference;
  final Uint8List _seed;
  final int _index;
  late final Eip155KeyPair _keyPair;

  Eip155SeedKeyPairStrategy._(this.reference, this._seed, this._index);

  factory Eip155SeedKeyPairStrategy.generateKeyPairFromSeedAndIndex(
      Eip155Reference reference, Uint8List seed, int index) {
    return Eip155SeedKeyPairStrategy._(reference, seed, index);
  }

  @override
  Future<Eip155KeyPair> generate() async {
    Eip155PrivateKeyType extendedKey = _fromSeedAndIndex(_seed, _index);
    _keyPair =
        await Eip155KeyPairFactory(reference).fromPrivateKey(extendedKey);
    return _keyPair;
  }

  @override
  Future<String> signMessage(String message) async {
    Eip155PrivateKeyType? secretKey = await _keyPair.extractSecretKey();
    secretKey ??= _fromSeedAndIndex(_seed, _index);
    return EthSigUtil.signPersonalMessage(
        message: hexToBytes(HEX.encode(message.codeUnits)),
        privateKey: bytesToHex(secretKey.privateKey));
  }

  @override
  Future<String> signTransaction(String message) async {
    throw UnimplementedError();
  }

  @override
  Future<bool> verify(String message, String signature) async {
    throw UnimplementedError();
  }

  Eip155PrivateKeyType _fromSeedAndIndex(Uint8List seed, int index) {
    final Chain chain = Chain.seed(HEX.encode(seed));
    String path = Eip155DerivationPath(reference, addressIndex: index).path;
    return Eip155PrivateKeyType.fromHex(chain.forPath(path).privateKeyHex());
  }
}

class Eip155SeedKeyPairStrategyFactory
    implements Eip155SeedKeyPairStrategyFactoryType {
  final Eip155Reference reference;

  Eip155SeedKeyPairStrategyFactory(this.reference);

  @override
  Eip155SeedKeyPairStrategy createFromSeedAndIndex(Uint8List seed, int index) {
    return Eip155SeedKeyPairStrategy.generateKeyPairFromSeedAndIndex(
        reference, seed, index);
  }
}

class Eip155PrivateKeyPairStrategy
    implements
        Eip155PrivateKeyPairStrategyType,
        Eip155KeyPairGenerator,
        Eip155KeyPairSigner,
        Eip155KeyPairVerifier {
  final Eip155BlockchainId blockchainId;
  final String privateKey;
  late final Eip155KeyPair _keyPair;

  Eip155PrivateKeyPairStrategy._(Eip155Reference reference, this.privateKey)
      : blockchainId = Eip155BlockchainId(reference);

  factory Eip155PrivateKeyPairStrategy.generateKeyPairFromPrivateKeyString(
      Eip155Reference reference, String privateKey) {
    return Eip155PrivateKeyPairStrategy._(reference, privateKey);
  }

  @override
  Future<Eip155KeyPair> generate() async {
    _keyPair = await Eip155KeyPairFactory(blockchainId.reference)
        .fromPrivateKeyString(privateKey);
    return _keyPair;
  }

  @override
  Future<String> signMessage(String message) async {
    Eip155PrivateKeyType? secretKey = await _keyPair.extractSecretKey();
    secretKey ??= Eip155PrivateKeyType.fromHex(privateKey);
    return EthSigUtil.signPersonalMessage(
        message: hexToBytes(HEX.encode(message.codeUnits)),
        privateKey: privateKey);
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

class Eip155PrivateKeyPairStrategyFactory
    implements Eip155PrivateKeyPairStrategyFactoryType {
  final Eip155Reference reference;

  Eip155PrivateKeyPairStrategyFactory(this.reference);

  @override
  Eip155PrivateKeyPairStrategy createFromPrivateKeyString(String privateKey) {
    return Eip155PrivateKeyPairStrategy.generateKeyPairFromPrivateKeyString(
        reference, privateKey);
  }
}
