import 'dart:typed_data';

import 'package:bip32_bip44/dart_bip32_bip44.dart';
import 'package:eth_sig_util/eth_sig_util.dart';
import 'package:eth_sig_util/util/utils.dart';
import 'package:hex/hex.dart';
import 'package:web3dart/web3dart.dart';
import '../../../domain/common/keypair/keypair.dart';
import '../bip44/bip44.dart';
import '../eip155_blockchain_id/eip155_blockchain_id.dart';
import '../eip155_blockchain_id/eip155_blockchain_reference.dart';

class Eip155KeyPair implements KeyPair<EthereumAddress, EthPrivateKey> {
  final Eip155BlockchainId blockchainId;
  final EthereumAddress _publicKey;
  final EthPrivateKey? _privateKey;
  late final KeyPairSigner _signer;
  late final KeyPairVerifier _verifier;

  Eip155KeyPair._(Eip155Reference reference, this._publicKey, this._privateKey)
      : blockchainId = Eip155BlockchainId(reference);

  @override
  Future<EthereumAddress> extractPublicKey() async {
    return _publicKey;
  }

  @override
  Future<EthPrivateKey?> extractSecretKey() async {
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
  Future<bool> verify(String message, String signature) async {
    return _verifier.verify(message, signature);
  }

  @override
  void setSigner(KeyPairSigner signer) => _signer = signer;

  @override
  void setVerifier(KeyPairVerifier verifier) => _verifier = verifier;

  @override
  String get publicKey => _publicKey.hexEip55;

  @override
  String get privateKey =>
      (_privateKey == null) ? '' : bytesToHex(_privateKey!.privateKey);
}

class Eip155KeyPairFactory
    implements KeyPairFactory<Eip155KeyPair, EthereumAddress, EthPrivateKey> {
  final Eip155BlockchainId blockchainId;
  late final KeyPairGenerator<Eip155KeyPair> _generator;

  Eip155KeyPairFactory(Eip155Reference reference)
      : blockchainId = Eip155BlockchainId(reference);

  @override
  Future<Eip155KeyPair> fromPublicKey(EthereumAddress publicKey) async {
    return Eip155KeyPair._(blockchainId.reference, publicKey, null);
  }

  @override
  Future<Eip155KeyPair> fromPrivateKey(EthPrivateKey privateKey) async {
    final EthereumAddress publicKey = _fromPrivateKey(privateKey).address;
    return Eip155KeyPair._(blockchainId.reference, publicKey, privateKey);
  }

  @override
  Future<Eip155KeyPair> fromPublicKeyString(String publicKeyHex) async {
    final EthereumAddress publicKey = _fromPublicKeyHex(publicKeyHex);
    return Eip155KeyPair._(blockchainId.reference, publicKey, null);
  }

  @override
  Future<Eip155KeyPair> fromPrivateKeyString(String privateKeyHex) async {
    final EthereumAddress publicKey = _fromPrivateKeyHex(privateKeyHex).address;
    return Eip155KeyPair._(blockchainId.reference, publicKey,
        EthPrivateKey.fromHex(privateKeyHex));
  }

  @override
  Future<Eip155KeyPair> generate() {
    return _generator.generate();
  }

  @override
  void setGenerator(KeyPairGenerator<Eip155KeyPair> generator) =>
      _generator = generator;

  Credentials _fromPrivateKey(EthPrivateKey key) {
    return key;
  }

  EthereumAddress _fromPublicKeyHex(String publicKeyHex) {
    return EthereumAddress.fromHex(publicKeyHex);
  }

  Credentials _fromPrivateKeyHex(String privateKeyHex) {
    return EthPrivateKey.fromHex(privateKeyHex);
  }
}

class Eip155SeedKeyPairStrategy implements SeedKeyPairStrategy<Eip155KeyPair> {
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
    EthPrivateKey extendedKey = _fromSeedAndIndex(_seed, _index);
    _keyPair =
        await Eip155KeyPairFactory(reference).fromPrivateKey(extendedKey);
    return _keyPair;
  }

  @override
  Future<String> signMessage(String message) async {
    EthPrivateKey? secretKey = await _keyPair.extractSecretKey();
    secretKey ??= _fromSeedAndIndex(_seed, _index);
    return EthSigUtil.signPersonalMessage(
        message: hexToBytes(HEX.encode(message.codeUnits)),
        privateKey: bytesToHex(secretKey.privateKey));
  }

  EthPrivateKey _fromSeedAndIndex(Uint8List seed, int index) {
    final Chain chain = Chain.seed(HEX.encode(seed));
    String path = Eip155DerivationPath(reference, addressIndex: index).path;
    return EthPrivateKey.fromHex(chain.forPath(path).privateKeyHex());
  }
}

class Eip155SeedKeyPairStrategyFactory
    implements SeedKeyPairStrategyFactory<Eip155KeyPair> {
  final Eip155Reference reference;

  Eip155SeedKeyPairStrategyFactory(this.reference);

  @override
  SeedKeyPairStrategy<Eip155KeyPair> createFromSeedAndIndex(
      Uint8List seed, int index) {
    return Eip155SeedKeyPairStrategy.generateKeyPairFromSeedAndIndex(
        reference, seed, index);
  }
}

class Eip155PrivateKeyPairStrategy
    implements PrivateKeyPairStrategy<Eip155KeyPair> {
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
    EthPrivateKey? secretKey = await _keyPair.extractSecretKey();
    secretKey ??= EthPrivateKey.fromHex(privateKey);
    return EthSigUtil.signPersonalMessage(
        message: hexToBytes(HEX.encode(message.codeUnits)),
        privateKey: privateKey);
  }
}

class Eip155PrivateKeyPairStrategyFactory
    implements PrivateKeyPairStrategyFactory<Eip155KeyPair> {
  final Eip155Reference reference;

  Eip155PrivateKeyPairStrategyFactory(this.reference);

  @override
  PrivateKeyPairStrategy<Eip155KeyPair> createFromPrivateKeyString(
      String privateKey) {
    return Eip155PrivateKeyPairStrategy.generateKeyPairFromPrivateKeyString(
        reference, privateKey);
  }
}
// class Eip155SeedKeyPairGeneratorStrategy
//     implements SeedKeyPairGeneratorStrategy<Eip155KeyPair> {
//   final Eip155Reference reference;
//   final Uint8List _seed;
//   final int _index;

//   Eip155SeedKeyPairGeneratorStrategy._(this.reference, this._seed, this._index);

//   factory Eip155SeedKeyPairGeneratorStrategy.generateKeyPairFromSeedAndIndex(
//       Eip155Reference reference, Uint8List seed, int index) {
//     return Eip155SeedKeyPairGeneratorStrategy._(reference, seed, index);
//   }

//   @override
//   Future<Eip155KeyPair> generate() async {
//     final Chain chain = Chain.seed(HEX.encode(_seed));
//     String path = Eip155DerivationPath(reference, addressIndex: _index).path;
//     EthPrivateKey extendedKey = chain.forPath(path);
//     return Eip155KeyPairFactory(reference).fromPrivateKey(extendedKey);
//   }
// }

// class Eip155SeedKeyPairGeneratorStrategyFactory
//     implements SeedKeyPairGeneratorStrategyFactory<Eip155KeyPair> {
//   final Eip155Reference reference;

//   Eip155SeedKeyPairGeneratorStrategyFactory(this.reference);

//   @override
//   SeedKeyPairGeneratorStrategy<Eip155KeyPair> createFromSeedAndIndex(
//       Uint8List seed, int index) {
//     return Eip155SeedKeyPairGeneratorStrategy.generateKeyPairFromSeedAndIndex(
//         reference, seed, index);
//   }
// }

// class Eip155KeyPairSignerStrategy
//     implements KeyPairSignerStrategy<Eip155KeyPair> {
//   final Eip155KeyPair _keyPair;

//   Eip155KeyPairSignerStrategy._(this._keyPair);

//   factory Eip155KeyPairSignerStrategy.fromKeyPair(Eip155KeyPair keyPair) {
//     return Eip155KeyPairSignerStrategy._(keyPair);
//   }

//   @override
//   Future<String> signMessage(String message) async {
//     final EthPrivateKey? secretKey = await _keyPair.extractSecretKey();
//     if (secretKey == null) {
//       throw Exception('Cannot sign message without secret key');
//     }
//     return EthSigUtil.signPersonalMessage(
//         message: hexToBytes(HEX.encode(message.codeUnits)),
//         privateKey: secretKey.privateKeyHex());
//   }
// }

// class Eip155KeyPairSignerStrategyFactory
//     implements KeyPairSignerStrategyFactory<Eip155KeyPair> {
//   @override
//   KeyPairSignerStrategy<Eip155KeyPair> createFromKeyPair(
//       Eip155KeyPair keyPair) {
//     return Eip155KeyPairSignerStrategy.fromKeyPair(keyPair);
//   }
// }
