import 'dart:typed_data';
import 'package:solana/base58.dart';
import 'package:solana/solana.dart';

import '../../domain/bip_44/bip_44.dart';
import '../../domain/caip/blockchain_id/blockchain_id.dart';
import '../../model/keypair.dart';

class SolanaKeyPair
    implements KeyPair<SolanaBlockchainId, Ed25519HDPublicKey, List<int>> {
  final SolanaBlockchainId blockchainId;
  final Ed25519HDPublicKey publicKey;
  final List<int> privateKey;

  SolanaKeyPair(this.blockchainId, this.publicKey, this.privateKey);

  @override
  Future<String> signData(String message) async {
    final signer = await Ed25519HDKeyPair.fromPrivateKeyBytes(
        privateKey: privateKey.sublist(0, 32));
    final Signature signedData = await signer.sign(message.codeUnits);
    return signedData.toBase58();
  }

  @override
  String get public => publicKey.toBase58();

  @override
  String get private => base58encode(privateKey);
}

class SolanaKeyPairFactory
    extends KeyPairFactory<SolanaBlockchainId, Ed25519HDPublicKey, List<int>> {
  SolanaKeyPairFactory(SolanaBlockchainId blockchainId) : super(blockchainId);

  @override
  SolanaKeyPair fromPrivateKey(List<int> privateKey) {
    Ed25519HDPublicKey address =
        Ed25519HDPublicKey.fromBase58(base58encode(privateKey.sublist(32)));
    return SolanaKeyPair(blockchainId, address, privateKey);
  }

  @override
  SolanaKeyPair fromPrivateKeyString(String privateKey) {
    List<int> secretKey = base58decode(privateKey);
    Ed25519HDPublicKey address =
        Ed25519HDPublicKey.fromBase58(base58encode(secretKey.sublist(32)));
    return SolanaKeyPair(blockchainId, address, secretKey);
  }

  @override
  Future<SolanaKeyPair> fromSeed(Uint8List seed, int index) async {
    List<int> secretKey =
        await _solanaPrivateKeyFromSeed(seed, blockchainId, index);
    Ed25519HDPublicKey address =
        (await _solanaAccountFromPrivateKey(secretKey)).publicKey;
    return SolanaKeyPair(blockchainId, address, secretKey);
  }

  static Future<Ed25519HDKeyPair> _solanaAccountFromPrivateKey(List<int> key) {
    return Ed25519HDKeyPair.fromPrivateKeyBytes(privateKey: key.sublist(0, 32));
  }

  static Future<Ed25519HDKeyPair> _solanaAccountFromPrivateKeyBase58(
      String privateKey) {
    return Ed25519HDKeyPair.fromPrivateKeyBytes(
        privateKey: base58decode(privateKey).sublist(0, 32));
  }

  static Future<List<int>> _solanaPrivateKeyFromSeed(
      Uint8List seed, SolanaBlockchainId blockchainId, int index) async {
    String path = SolanaDerivationPath(blockchainId).path;
    Ed25519HDKeyPair key =
        await Ed25519HDKeyPair.fromSeedWithHdPath(seed: seed, hdPath: path);
    return (await key.extract()).bytes + (await key.extractPublicKey()).bytes;
  }
}
