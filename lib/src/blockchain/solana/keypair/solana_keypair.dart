import 'dart:typed_data';
import 'package:solana/base58.dart';
import 'package:solana/solana.dart';

import '../../../types/common/keypair/keypair.dart';
import '../bip44/bip44.dart';
import '../solana_blockchain_id/solana_blockchain_id.dart';
import '../solana_blockchain_id/solana_blockchain_reference.dart';

class SolanaKeyPair
    implements KeyPair<SolanaBlockchainId, Ed25519HDPublicKey, List<int>> {
  @override
  final SolanaBlockchainId blockchainId;

  @override
  final Ed25519HDPublicKey publicKey;

  @override
  final List<int> privateKey;

  SolanaKeyPair(SolanaReference reference, this.publicKey, this.privateKey)
      : blockchainId = SolanaBlockchainId(reference);

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
    implements
        KeyPairFactory<SolanaBlockchainId, Ed25519HDPublicKey, List<int>> {
  final SolanaBlockchainId blockchainId;

  SolanaKeyPairFactory(SolanaReference reference)
      : blockchainId = SolanaBlockchainId(reference);

  @override
  SolanaKeyPair fromPrivateKey(List<int> privateKey) {
    Ed25519HDPublicKey address =
        Ed25519HDPublicKey.fromBase58(base58encode(privateKey.sublist(32)));
    return SolanaKeyPair(blockchainId.reference, address, privateKey);
  }

  @override
  SolanaKeyPair fromPrivateKeyString(String privateKey) {
    List<int> secretKey = base58decode(privateKey);
    Ed25519HDPublicKey address =
        Ed25519HDPublicKey.fromBase58(base58encode(secretKey.sublist(32)));
    return SolanaKeyPair(blockchainId.reference, address, secretKey);
  }

  @override
  Future<SolanaKeyPair> fromSeed(Uint8List seed, int index) async {
    List<int> secretKey =
        await _solanaPrivateKeyFromSeed(seed, blockchainId.reference, index);
    Ed25519HDPublicKey address =
        (await _solanaAccountFromPrivateKey(secretKey)).publicKey;
    return SolanaKeyPair(blockchainId.reference, address, secretKey);
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
      Uint8List seed, SolanaReference reference, int index) async {
    String path = SolanaDerivationPath(reference).path;
    Ed25519HDKeyPair key =
        await Ed25519HDKeyPair.fromSeedWithHdPath(seed: seed, hdPath: path);
    return (await key.extract()).bytes + (await key.extractPublicKey()).bytes;
  }
}
