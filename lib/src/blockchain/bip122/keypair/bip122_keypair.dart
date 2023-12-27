import 'dart:typed_data';
import 'package:coinlib/coinlib.dart';
import '../../../domain/common/keypair/keypair.dart';
import '../bip122_blockchain_id/bip122_blockchain_id.dart';
import '../bip122_blockchain_id/bip122_blockchain_reference.dart';
import '../bip44/bip44.dart';

class Bip122KeyPair implements KeyPair<ECPublicKey, ECPrivateKey> {
  final Bip122BlockchainId blockchainId;
  final ECPublicKey _publicKey;
  final ECPrivateKey? _privateKey;
  late final KeyPairSigner _signer;
  late final KeyPairVerifier _verifier;

  Bip122KeyPair._(Bip122Reference reference, this._publicKey, this._privateKey)
      : blockchainId = Bip122BlockchainId(reference);

  @override
  Future<ECPublicKey> extractPublicKey() async {
    return _publicKey;
  }

  @override
  Future<ECPrivateKey?> extractSecretKey() async {
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
  String get publicKey => _publicKey.hex;

  @override
  String get privateKey => (_privateKey == null)
      ? ''
      : WIF(
              privkey: _privateKey!,
              version: blockchainId.reference.networkParams.wifPrefix)
          .toString();
}

class Bip122KeyPairFactory
    implements KeyPairFactory<Bip122KeyPair, ECPublicKey, ECPrivateKey> {
  final Bip122BlockchainId blockchainId;
  late final KeyPairGenerator<Bip122KeyPair> _generator;

  Bip122KeyPairFactory(Bip122Reference reference)
      : blockchainId = Bip122BlockchainId(reference);

  @override
  Future<Bip122KeyPair> fromPrivateKey(ECPrivateKey privateKey) async {
    final ECPublicKey publicKey = privateKey.pubkey;
    return Bip122KeyPair._(blockchainId.reference, publicKey, privateKey);
  }

  @override
  Future<Bip122KeyPair> fromPublicKey(ECPublicKey publicKey) async {
    return Bip122KeyPair._(blockchainId.reference, publicKey, null);
  }

  @override
  Future<Bip122KeyPair> fromPublicKeyString(String publicKey) async {
    final ECPublicKey ecPublicKey = _fromPublicKeyString(publicKey);
    return Bip122KeyPair._(blockchainId.reference, ecPublicKey, null);
  }

  @override
  Future<Bip122KeyPair> fromPrivateKeyString(String privateKey) async {
    final WIF wif = _fromPrivateKeyString(
        privateKey, blockchainId.reference.networkParams.wifPrefix);
    final ECPublicKey publicKey = _fromPrivateKey(wif);
    return Bip122KeyPair._(blockchainId.reference, publicKey, wif.privkey);
  }

  @override
  Future<Bip122KeyPair> generate() {
    return _generator.generate();
  }

  @override
  void setGenerator(KeyPairGenerator<Bip122KeyPair> generator) =>
      _generator = generator;

  ECPublicKey _fromPrivateKey(WIF wif) {
    return wif.privkey.pubkey;
  }

  ECPublicKey _fromPublicKeyString(String publicKey) {
    return ECPublicKey.fromHex(publicKey);
  }

  WIF _fromPrivateKeyString(String privateKey, int version) {
    return WIF.fromString(privateKey, version: version);
  }

  // static WIF _bip122PrivateKeyFromSeed(
  //     Uint8List seed, Bip122Reference reference, int index, int version) {
  //   HDPrivateKey hdWallet = HDPrivateKey.fromSeed(seed);
  //   String path = Bip122DerivationPath(reference, addressIndex: index).path;
  //   HDPrivateKey key = hdWallet.derivePath(path);
  //   return WIF(privkey: key.privateKey, version: version);
  // }
}

class Bip122SeedKeyPairGeneratorStrategy
    implements SeedKeyPairGeneratorStrategy<Bip122KeyPair> {
  final Bip122Reference reference;
  final Uint8List _seed;
  final int _index;

  Bip122SeedKeyPairGeneratorStrategy._(this.reference, this._seed, this._index);

  factory Bip122SeedKeyPairGeneratorStrategy.generateKeyPairFromSeedAndIndex(
      Bip122Reference reference, Uint8List seed, int index) {
    return Bip122SeedKeyPairGeneratorStrategy._(reference, seed, index);
  }

  @override
  Future<Bip122KeyPair> generate() async {
    final HDPrivateKey hdWallet = HDPrivateKey.fromSeed(_seed);
    String path = Bip122DerivationPath(reference, addressIndex: _index).path;
    HDPrivateKey hdKey = hdWallet.derivePath(path);
    return Bip122KeyPairFactory(reference).fromPrivateKey(hdKey.privateKey);
  }
}

class Bip122SeedKeyPairGeneratorStrategyFactory
    implements SeedKeyPairGeneratorStrategyFactory<Bip122KeyPair> {
  final Bip122Reference reference;

  Bip122SeedKeyPairGeneratorStrategyFactory(this.reference);

  @override
  SeedKeyPairGeneratorStrategy<Bip122KeyPair> createFromSeedAndIndex(
      Uint8List seed, int index) {
    return Bip122SeedKeyPairGeneratorStrategy.generateKeyPairFromSeedAndIndex(
        reference, seed, index);
  }
}

class Bip122KeyPairSignerStrategy
    implements KeyPairSignerStrategy<Bip122KeyPair> {
  final Bip122KeyPair _keyPair;

  Bip122KeyPairSignerStrategy._(this._keyPair);

  factory Bip122KeyPairSignerStrategy.fromKeyPair(Bip122KeyPair keyPair) {
    return Bip122KeyPairSignerStrategy._(keyPair);
  }

  @override
  Future<String> signMessage(String message) async {
    final ECPrivateKey? secretKey = await _keyPair.extractSecretKey();
    if (secretKey == null) {
      throw Exception('Cannot sign message without secret key');
    }
    return MessageSignature.sign(
            key: secretKey,
            message: message,
            prefix: _keyPair.blockchainId.reference.networkParams.messagePrefix)
        .toString();
  }
}

class Bip122KeyPairSignerStrategyFactory
    implements KeyPairSignerStrategyFactory<Bip122KeyPair> {
  @override
  KeyPairSignerStrategy<Bip122KeyPair> createFromKeyPair(
      Bip122KeyPair keyPair) {
    return Bip122KeyPairSignerStrategy.fromKeyPair(keyPair);
  }
}
