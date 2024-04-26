import 'dart:typed_data';

import 'package:solana/base58.dart';
import 'package:solana/solana.dart';
import '../../../domain/common/keypair/keypair.dart';
import '../../../domain/common/keypair/strategy/private_key_strategy.dart';
import '../../../domain/common/keypair/strategy/seed_strategy.dart';
import '../bip44/bip44.dart';
import '../solana_blockchain_id/solana_blockchain_id.dart';
import '../solana_blockchain_id/solana_blockchain_reference.dart';

typedef SolanaPublicKeyType = Ed25519HDPublicKey;

typedef SolanaPrivateKeyType = Ed25519HDKeyPairData;

typedef SolanaKeyPairGeneratorType = KeyPairGenerator<
    SolanaPublicKeyType,
    SolanaPrivateKeyType,
    SolanaKeyPair,
    SolanaKeyPairSigner,
    SolanaKeyPairVerifier>;

typedef SolanaKeyPairSignerType
    = KeyPairSigner<SolanaPublicKeyType, SolanaPrivateKeyType>;

typedef SolanaKeyPairVerifierType
    = KeyPairVerifier<SolanaPublicKeyType, SolanaPrivateKeyType>;

typedef SolanaKeyPairType = KeyPair<SolanaPublicKeyType, SolanaPrivateKeyType,
    SolanaKeyPairSigner, SolanaKeyPairVerifier>;

typedef SolanaKeyPairFactoryType = KeyPairFactory<
    SolanaPublicKeyType,
    SolanaPrivateKeyType,
    SolanaKeyPair,
    SolanaKeyPairSigner,
    SolanaKeyPairVerifier,
    SolanaKeyPairGenerator>;

typedef SolanaSeedKeyPairStrategyType = SeedKeyPairStrategy<
    SolanaPublicKeyType,
    SolanaPrivateKeyType,
    SolanaKeyPair,
    SolanaKeyPairSigner,
    SolanaKeyPairVerifier,
    SolanaKeyPairGenerator>;

typedef SolanaSeedKeyPairStrategyFactoryType = SeedKeyPairStrategyFactory<
    SolanaPublicKeyType,
    SolanaPrivateKeyType,
    SolanaKeyPair,
    SolanaKeyPairSigner,
    SolanaKeyPairVerifier,
    SolanaKeyPairGenerator,
    SolanaSeedKeyPairStrategy>;

typedef SolanaPrivateKeyPairStrategyType = PrivateKeyPairStrategy<
    SolanaPublicKeyType,
    SolanaPrivateKeyType,
    SolanaKeyPair,
    SolanaKeyPairSigner,
    SolanaKeyPairVerifier,
    SolanaKeyPairGenerator>;

typedef SolanaPrivateKeyPairStrategyFactoryType = PrivateKeyPairStrategyFactory<
    SolanaPublicKeyType,
    SolanaPrivateKeyType,
    SolanaKeyPair,
    SolanaKeyPairSigner,
    SolanaKeyPairVerifier,
    SolanaKeyPairGenerator,
    SolanaPrivateKeyPairStrategy>;

abstract class SolanaKeyPairSigner extends SolanaKeyPairSignerType {
  Future<String> signTransaction(String message);
  // Future<String> signCompiledMessage(CompiledMessage message);
  // Future<SignedTx> signCompiledMessageForTransaction(CompiledMessage message);
}

abstract class SolanaKeyPairVerifier extends SolanaKeyPairVerifierType {}

abstract class SolanaKeyPairGenerator extends SolanaKeyPairGeneratorType {}

class SolanaKeyPair
    implements SolanaKeyPairType, SolanaKeyPairSigner, SolanaKeyPairVerifier {
  final SolanaBlockchainId blockchainId;
  final SolanaPublicKeyType _publicKey;
  final SolanaPrivateKeyType? _privateKey;
  late SolanaKeyPairSigner _signer;
  late SolanaKeyPairVerifier _verifier;

  SolanaKeyPair._(SolanaReference reference, this._publicKey, this._privateKey)
      : blockchainId = SolanaBlockchainId(reference);

  @override
  Future<SolanaPublicKeyType> extractPublicKey() async {
    return _publicKey;
  }

  @override
  Future<SolanaPrivateKeyType?> extractSecretKey() async {
    return _privateKey;
  }

  @override
  Future<String> sign(String message) async {
    return _signer.sign(message);
  }

  @override
  Future<String> signTransaction(String message) async {
    return _signer.signTransaction(message);
  }

  // @override
  // Future<String> personalSign(String message) async {
  //   return _signer.sign(message);
  // }

  // @override
  // Future<String> signCompiledMessage(CompiledMessage message) async {
  //   return _signer.signCompiledMessage(message);
  // }

  // @override
  // Future<SignedTx> signCompiledMessageForTransaction(
  //     CompiledMessage message) async {
  //   return _signer.signCompiledMessageForTransaction(message);
  // }
  // @override
  // Future<String> signTransaction(String message) async {
  //   return _signer.signTransaction(message);
  // }

  @override
  Future<bool> verifySignature(String message, String signature) async {
    return _verifier.verifySignature(message, signature);
  }

  @override
  set signer(SolanaKeyPairSigner signer) => _signer = signer;

  @override
  set verifier(SolanaKeyPairVerifier verifier) => _verifier = verifier;

  @override
  String get publicKey => _publicKey.toBase58();

  @override
  String get privateKey => (_privateKey == null)
      ? ''
      : base58encode(_privateKey.bytes + _publicKey.bytes);
}

class SolanaKeyPairFactory implements SolanaKeyPairFactoryType {
  final SolanaBlockchainId blockchainId;
  late SolanaKeyPairGenerator _generator;

  SolanaKeyPairFactory(SolanaReference reference)
      : blockchainId = SolanaBlockchainId(reference);

  @override
  Future<SolanaKeyPair> fromPublicKey(SolanaPublicKeyType publicKey) async {
    return SolanaKeyPair._(blockchainId.reference, publicKey, null);
  }

  @override
  Future<SolanaKeyPair> fromPrivateKey(SolanaPrivateKeyType privateKey) async {
    final SolanaPublicKeyType publicKey = privateKey.publicKey;
    return SolanaKeyPair._(blockchainId.reference, publicKey, privateKey);
  }

  @override
  Future<SolanaKeyPair> fromPublicKeyString(String publicKey) async {
    final SolanaPublicKeyType publicKeyData = _fromPublicKeyBase58(publicKey);
    return SolanaKeyPair._(blockchainId.reference, publicKeyData, null);
  }

  @override
  Future<SolanaKeyPair> fromPrivateKeyString(String privateKey) async {
    final SolanaPrivateKeyType privateKeyData =
        _fromPrivateKeyBase58(privateKey);
    final SolanaPublicKeyType publicKey = _fromPrivateKey(privateKeyData);
    return SolanaKeyPair._(blockchainId.reference, publicKey, privateKeyData);
  }

  @override
  Future<SolanaKeyPair> generate() async {
    return _generator.generate();
  }

  @override
  set generator(SolanaKeyPairGenerator generator) => _generator = generator;

  SolanaPublicKeyType _fromPrivateKey(SolanaPrivateKeyType privateKey) {
    return privateKey.publicKey;
  }

  SolanaPublicKeyType _fromPublicKeyBase58(String publicKey) {
    return SolanaPublicKeyType.fromBase58(publicKey);
  }

  SolanaPrivateKeyType _fromPrivateKeyBase58(String privateKey) {
    final List<int> prKey = base58decode(privateKey);
    final SolanaPublicKeyType publicKey =
        SolanaPublicKeyType(prKey.sublist(32));
    return SolanaPrivateKeyType(prKey.sublist(0, 32), publicKey: publicKey);
  }
}

class SolanaSeedKeyPairStrategy
    implements
        SolanaSeedKeyPairStrategyType,
        SolanaKeyPairGenerator,
        SolanaKeyPairSigner,
        SolanaKeyPairVerifier {
  final SolanaReference reference;
  final Uint8List _seed;
  final int _index;
  late SolanaKeyPair _keyPair;

  SolanaSeedKeyPairStrategy._(this.reference, this._seed, this._index);

  factory SolanaSeedKeyPairStrategy.generateKeyPairFromSeedAndIndex(
      SolanaReference reference, Uint8List seed, int index) {
    return SolanaSeedKeyPairStrategy._(reference, seed, index);
  }

  // * Generation
  @override
  Future<SolanaKeyPair> generate() async {
    Ed25519HDKeyPair key = await _fromSeedAndIndex(_seed, _index);
    _keyPair = await SolanaKeyPairFactory(reference)
        .fromPrivateKey(await key.extract());
    return _keyPair;
  }

  // * Signature
  @override
  Future<String> sign(String message) async {
    SolanaPrivateKeyType? secretKey = await _keyPair.extractSecretKey();
    secretKey ??= (await (await _fromSeedAndIndex(_seed, _index)).extract());
    final Future<Ed25519HDKeyPair> signer =
        Ed25519HDKeyPair.fromPrivateKeyBytes(privateKey: secretKey.bytes);
    return (await (await signer).sign(message.codeUnits)).toBase58();
  }

  // // * Transaction
  // @override
  // Future<String> signCompiledMessage(CompiledMessage message) async {
  //   SolanaPrivateKeyType? secretKey = await _keyPair.extractSecretKey();
  //   secretKey ??= (await (await _fromSeedAndIndex(_seed, _index)).extract());
  //   final Future<Ed25519HDKeyPair> signer =
  //       Ed25519HDKeyPair.fromPrivateKeyBytes(privateKey: secretKey.bytes);
  //   return (await (await signer).sign(message.toByteArray())).toBase58();
  // }

  // @override
  // Future<SignedTx> signCompiledMessageForTransaction(
  //     CompiledMessage message) async {
  //   SolanaPrivateKeyType? secretKey = await _keyPair.extractSecretKey();
  //   secretKey ??= (await (await _fromSeedAndIndex(_seed, _index)).extract());
  //   final Future<Ed25519HDKeyPair> signer =
  //       Ed25519HDKeyPair.fromPrivateKeyBytes(privateKey: secretKey.bytes);
  //   final signedTransaction =
  //       (await (await signer).sign(message.toByteArray()));
  //   return SignedTx(
  //     signatures: [signedTransaction],
  //     compiledMessage: message,
  //   );
  // }
  @override
  Future<String> signTransaction(String message) async {
    throw UnimplementedError();
  }

  // * Verification
  @override
  Future<bool> verifySignature(String message, String signature) async {
    throw UnimplementedError();
  }

  Future<Ed25519HDKeyPair> _fromSeedAndIndex(Uint8List seed, int index) async {
    String path = SolanaDerivationPath(reference, account: _index).path;
    return Ed25519HDKeyPair.fromSeedWithHdPath(seed: _seed, hdPath: path);
  }
}

class SolanaSeedKeyPairStrategyFactory
    implements SolanaSeedKeyPairStrategyFactoryType {
  final SolanaReference reference;

  SolanaSeedKeyPairStrategyFactory(this.reference);

  @override
  SolanaSeedKeyPairStrategy createFromSeedAndIndex(Uint8List seed, int index) {
    return SolanaSeedKeyPairStrategy.generateKeyPairFromSeedAndIndex(
        reference, seed, index);
  }
}

class SolanaPrivateKeyPairStrategy
    implements
        SolanaPrivateKeyPairStrategyType,
        SolanaKeyPairGenerator,
        SolanaKeyPairSigner,
        SolanaKeyPairVerifier {
  final SolanaBlockchainId blockchainId;
  final String privateKey;
  late SolanaKeyPair _keyPair;

  SolanaPrivateKeyPairStrategy._(SolanaReference reference, this.privateKey)
      : blockchainId = SolanaBlockchainId(reference);

  factory SolanaPrivateKeyPairStrategy.generateKeyPairFromPrivateKeyString(
      SolanaReference reference, String privateKey) {
    return SolanaPrivateKeyPairStrategy._(reference, privateKey);
  }

  // * Generation
  @override
  Future<SolanaKeyPair> generate() async {
    _keyPair = await SolanaKeyPairFactory(blockchainId.reference)
        .fromPrivateKeyString(privateKey);
    return _keyPair;
  }

  // * Signature
  @override
  Future<String> sign(String message) async {
    SolanaPrivateKeyType? secretKey = await _keyPair.extractSecretKey();
    secretKey ??= _fromPrivateKeyBase58(privateKey);
    final Future<Ed25519HDKeyPair> signer =
        Ed25519HDKeyPair.fromPrivateKeyBytes(privateKey: secretKey.bytes);
    return (await (await signer).sign(message.codeUnits)).toBase58();
  }

  // // * Transaction
  // @override
  // Future<String> signCompiledMessage(CompiledMessage message) async {
  //   SolanaPrivateKeyType? secretKey = await _keyPair.extractSecretKey();
  //   secretKey ??= _fromPrivateKeyBase58(privateKey);
  //   final Future<Ed25519HDKeyPair> signer =
  //       Ed25519HDKeyPair.fromPrivateKeyBytes(privateKey: secretKey.bytes);
  //   return (await (await signer).sign(message.toByteArray())).toBase58();
  // }

  // @override
  // Future<SignedTx> signCompiledMessageForTransaction(
  //     CompiledMessage message) async {
  //   SolanaPrivateKeyType? secretKey = await _keyPair.extractSecretKey();
  //   secretKey ??= _fromPrivateKeyBase58(privateKey);
  //   final Future<Ed25519HDKeyPair> signer =
  //       Ed25519HDKeyPair.fromPrivateKeyBytes(privateKey: secretKey.bytes);
  //   final signedTransaction =
  //       (await (await signer).sign(message.toByteArray()));
  //   return SignedTx(
  //     signatures: [signedTransaction],
  //     compiledMessage: message,
  //   );
  // }

  @override
  Future<String> signTransaction(String message) async {
    throw UnimplementedError();
  }

  // * Verification
  @override
  Future<bool> verifySignature(String message, String signature) async {
    throw UnimplementedError();
  }

  SolanaPrivateKeyType _fromPrivateKeyBase58(String privateKey) {
    final List<int> prKey = base58decode(privateKey);
    final SolanaPublicKeyType publicKey =
        SolanaPublicKeyType(prKey.sublist(32));
    return SolanaPrivateKeyType(prKey.sublist(0, 32), publicKey: publicKey);
  }
}

class SolanaPrivateKeyPairStrategyFactory
    implements SolanaPrivateKeyPairStrategyFactoryType {
  final SolanaReference reference;

  SolanaPrivateKeyPairStrategyFactory(this.reference);

  @override
  SolanaPrivateKeyPairStrategy createFromPrivateKeyString(String privateKey) {
    return SolanaPrivateKeyPairStrategy.generateKeyPairFromPrivateKeyString(
        reference, privateKey);
  }
}
