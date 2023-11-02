import 'dart:typed_data';
import 'package:solana/base58.dart';
import 'package:solana/solana.dart';

import '../../domain/bip_44/bip_44.dart';
import '../../domain/caip/blockchain_id/blockchain_id.dart';
import '../../model/keypair.dart';

class SolanaKeyPair extends KeyPair {
  final List<int> secretKey;
  final Ed25519HDPublicKey address;

  SolanaKeyPair(this.secretKey, this.address);

  static SolanaKeyPair fromPrivateKey(List<int> key) {
    Ed25519HDPublicKey address =
        Ed25519HDPublicKey.fromBase58(base58encode(key.sublist(32)));
    return SolanaKeyPair(key, address);
  }

  static SolanaKeyPair fromPrivateKeyString(String privateKey) {
    List<int> secretKey = base58decode(privateKey);
    Ed25519HDPublicKey address =
        Ed25519HDPublicKey.fromBase58(base58encode(secretKey.sublist(32)));
    return SolanaKeyPair(secretKey, address);
  }

  static Future<SolanaKeyPair> fromSeed(
      Uint8List seed, BlockchainId blockchainId, int index) async {
    List<int> secretKey =
        await _solanaPrivateKeyFromSeed(seed, blockchainId, index);
    Ed25519HDPublicKey address =
        (await _solanaAccountFromPrivateKey(secretKey)).publicKey;
    return SolanaKeyPair(secretKey, address);
  }

  static Future<List<int>> _solanaPrivateKeyFromSeed(
      Uint8List seed, BlockchainId blockchainId, int index) async {
    String path = DerivationPathManagerMixin.path(blockchainId, index);
    Ed25519HDKeyPair key =
        await Ed25519HDKeyPair.fromSeedWithHdPath(seed: seed, hdPath: path);
    return (await key.extract()).bytes + (await key.extractPublicKey()).bytes;
  }

  static Future<Ed25519HDKeyPair> _solanaAccountFromPrivateKey(List<int> key) {
    return Ed25519HDKeyPair.fromPrivateKeyBytes(privateKey: key.sublist(0, 32));
  }

  static Future<Ed25519HDKeyPair> _solanaAccountFromPrivateKeyBase58(
      String privateKey) {
    return Ed25519HDKeyPair.fromPrivateKeyBytes(
        privateKey: base58decode(privateKey).sublist(0, 32));
  }

  Future<Signature> signPersonalMessage(
      String message, Ed25519HDKeyPair signer) async {
    return await signer.sign(message.codeUnits);
  }

  @override
  String get privateKey => base58encode(secretKey);

  @override
  String get publicKey => address.toBase58();
}
