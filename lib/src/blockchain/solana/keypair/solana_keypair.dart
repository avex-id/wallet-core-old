import 'dart:typed_data';

import 'package:solana/base58.dart';
import 'package:solana/solana.dart';
import '../../../domain/common/keypair/keypair.dart';
import '../bip44/bip44.dart';
import '../solana_blockchain_id/solana_blockchain_id.dart';
import '../solana_blockchain_id/solana_blockchain_reference.dart';

class SolanaKeyPair
    implements KeyPair<Ed25519HDPublicKey, Ed25519HDKeyPairData> {
  final SolanaBlockchainId blockchainId;
  final Ed25519HDPublicKey _publicKey;
  final Ed25519HDKeyPairData? _privateKey;
  late final KeyPairSigner _signer;
  late final KeyPairVerifier _verifier;

  SolanaKeyPair._(SolanaReference reference, this._publicKey, this._privateKey)
      : blockchainId = SolanaBlockchainId(reference);

  @override
  Future<Ed25519HDPublicKey> extractPublicKey() async {
    return _publicKey;
  }

  @override
  Future<Ed25519HDKeyPairData?> extractSecretKey() async {
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
  String get publicKey => _publicKey.toBase58();

  @override
  String get privateKey => (_privateKey == null)
      ? ''
      : base58encode(_privateKey!.bytes + _publicKey.bytes);
}

class SolanaKeyPairFactory
    implements
        KeyPairFactory<SolanaKeyPair, Ed25519HDPublicKey,
            Ed25519HDKeyPairData> {
  final SolanaBlockchainId blockchainId;
  late final KeyPairGenerator<SolanaKeyPair> _generator;

  SolanaKeyPairFactory(SolanaReference reference)
      : blockchainId = SolanaBlockchainId(reference);

  @override
  Future<SolanaKeyPair> fromPublicKey(Ed25519HDPublicKey publicKey) async {
    return SolanaKeyPair._(blockchainId.reference, publicKey, null);
  }

  @override
  Future<SolanaKeyPair> fromPrivateKey(Ed25519HDKeyPairData privateKey) async {
    final Ed25519HDPublicKey publicKey = privateKey.publicKey;
    return SolanaKeyPair._(blockchainId.reference, publicKey, privateKey);
  }

  @override
  Future<SolanaKeyPair> fromPublicKeyString(String publicKey) async {
    final Ed25519HDPublicKey publicKeyData = _fromPublicKeyBase58(publicKey);
    return SolanaKeyPair._(blockchainId.reference, publicKeyData, null);
  }

  @override
  Future<SolanaKeyPair> fromPrivateKeyString(String privateKey) async {
    final Ed25519HDKeyPairData privateKeyData =
        _fromPrivateKeyBase58(privateKey);
    final Ed25519HDPublicKey publicKey = _fromPrivateKey(privateKeyData);
    return SolanaKeyPair._(blockchainId.reference, publicKey, privateKeyData);
  }

  @override
  Future<SolanaKeyPair> generate() async {
    return _generator.generate();
  }

  @override
  void setGenerator(KeyPairGenerator<SolanaKeyPair> generator) =>
      _generator = generator;

  Ed25519HDPublicKey _fromPrivateKey(Ed25519HDKeyPairData privateKey) {
    return privateKey.publicKey;
  }

  Ed25519HDPublicKey _fromPublicKeyBase58(String publicKey) {
    return Ed25519HDPublicKey.fromBase58(publicKey);
  }

  Ed25519HDKeyPairData _fromPrivateKeyBase58(String privateKey) {
    final List<int> prKey = base58decode(privateKey);
    final Ed25519HDPublicKey publicKey = Ed25519HDPublicKey(prKey.sublist(32));
    return Ed25519HDKeyPairData(prKey.sublist(0, 32), publicKey: publicKey);
  }
}

class SolanaSeedKeyPairStrategy implements SeedKeyPairStrategy<SolanaKeyPair> {
  final SolanaReference reference;
  final Uint8List _seed;
  final int _index;
  late final SolanaKeyPair _keyPair;

  SolanaSeedKeyPairStrategy._(this.reference, this._seed, this._index);

  factory SolanaSeedKeyPairStrategy.generateKeyPairFromSeedAndIndex(
      SolanaReference reference, Uint8List seed, int index) {
    return SolanaSeedKeyPairStrategy._(reference, seed, index);
  }

  @override
  Future<SolanaKeyPair> generate() async {
    Ed25519HDKeyPair key = await _fromSeedAndIndex(_seed, _index);
    _keyPair = await SolanaKeyPairFactory(reference)
        .fromPrivateKey(await key.extract());
    return _keyPair;
  }

  @override
  Future<String> signMessage(String message) async {
    Ed25519HDKeyPairData? secretKey = await _keyPair.extractSecretKey();
    secretKey ??= (await (await _fromSeedAndIndex(_seed, _index)).extract());
    final Future<Ed25519HDKeyPair> signer =
        Ed25519HDKeyPair.fromPrivateKeyBytes(privateKey: secretKey.bytes);
    return (await (await signer).sign(message.codeUnits)).toBase58();
  }

  Future<Ed25519HDKeyPair> _fromSeedAndIndex(Uint8List seed, int index) async {
    String path = SolanaDerivationPath(reference, account: _index).path;
    return Ed25519HDKeyPair.fromSeedWithHdPath(seed: _seed, hdPath: path);
  }
}

class SolanaSeedKeyPairStrategyFactory
    implements SeedKeyPairStrategyFactory<SolanaKeyPair> {
  final SolanaReference reference;

  SolanaSeedKeyPairStrategyFactory(this.reference);

  @override
  SeedKeyPairStrategy<SolanaKeyPair> createFromSeedAndIndex(
      Uint8List seed, int index) {
    return SolanaSeedKeyPairStrategy.generateKeyPairFromSeedAndIndex(
        reference, seed, index);
  }
}

class SolanaPrivateKeyPairStrategy
    implements PrivateKeyPairStrategy<SolanaKeyPair> {
  final SolanaBlockchainId blockchainId;
  final String privateKey;
  late final SolanaKeyPair _keyPair;

  SolanaPrivateKeyPairStrategy._(SolanaReference reference, this.privateKey)
      : blockchainId = SolanaBlockchainId(reference);

  factory SolanaPrivateKeyPairStrategy.generateKeyPairFromPrivateKeyString(
      SolanaReference reference, String privateKey) {
    return SolanaPrivateKeyPairStrategy._(reference, privateKey);
  }

  @override
  Future<SolanaKeyPair> generate() async {
    _keyPair = await SolanaKeyPairFactory(blockchainId.reference)
        .fromPrivateKeyString(privateKey);
    return _keyPair;
  }

  @override
  Future<String> signMessage(String message) async {
    Ed25519HDKeyPairData? secretKey = await _keyPair.extractSecretKey();
    secretKey ??= _fromPrivateKeyBase58(privateKey);
    final Future<Ed25519HDKeyPair> signer =
        Ed25519HDKeyPair.fromPrivateKeyBytes(privateKey: secretKey.bytes);
    return (await (await signer).sign(message.codeUnits)).toBase58();
  }

  Ed25519HDKeyPairData _fromPrivateKeyBase58(String privateKey) {
    final List<int> prKey = base58decode(privateKey);
    final Ed25519HDPublicKey publicKey = Ed25519HDPublicKey(prKey.sublist(32));
    return Ed25519HDKeyPairData(prKey.sublist(0, 32), publicKey: publicKey);
  }
}

class SolanaPrivateKeyPairStrategyFactory
    implements PrivateKeyPairStrategyFactory<SolanaKeyPair> {
  final SolanaReference reference;

  SolanaPrivateKeyPairStrategyFactory(this.reference);

  @override
  PrivateKeyPairStrategy<SolanaKeyPair> createFromPrivateKeyString(
      String privateKey) {
    return SolanaPrivateKeyPairStrategy.generateKeyPairFromPrivateKeyString(
        reference, privateKey);
  }
}
