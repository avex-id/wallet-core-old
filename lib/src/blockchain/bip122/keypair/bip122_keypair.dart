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
}

class Bip122SeedKeyPairStrategy implements SeedKeyPairStrategy<Bip122KeyPair> {
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
    ECPrivateKey? secretKey = await _keyPair.extractSecretKey();
    secretKey ??= _fromSeedAndIndex(_seed, _index).privateKey;
    return MessageSignature.sign(
            key: secretKey,
            message: message,
            prefix: _keyPair.blockchainId.reference.networkParams.messagePrefix)
        .toString();
  }

  HDPrivateKey _fromSeedAndIndex(Uint8List seed, int index) {
    HDPrivateKey hdWallet = HDPrivateKey.fromSeed(seed);
    String path = Bip122DerivationPath(reference, addressIndex: index).path;
    return hdWallet.derivePath(path);
  }
}

class Bip122SeedKeyPairStrategyFactory
    implements SeedKeyPairStrategyFactory<Bip122KeyPair> {
  final Bip122Reference reference;

  Bip122SeedKeyPairStrategyFactory(this.reference);

  @override
  SeedKeyPairStrategy<Bip122KeyPair> createFromSeedAndIndex(
      Uint8List seed, int index) {
    return Bip122SeedKeyPairStrategy.generateKeyPairFromSeedAndIndex(
        reference, seed, index);
  }
}
