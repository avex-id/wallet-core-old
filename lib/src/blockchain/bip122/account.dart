import 'dart:typed_data';
import 'package:coinlib/coinlib.dart';
import 'package:wallet_core/src/domain/caip/blockchain_id/blockchain_reference/bip122_reference.dart';
import 'package:wallet_core/src/model/keypair.dart';

import '../../domain/bip_44/bip_44.dart';
import '../../domain/caip/blockchain_id/blockchain_id.dart';

class Bip122KeyPair implements KeyPair<Bip122BlockchainId, Address, WIF> {
  final Bip122BlockchainId blockchainId;
  final P2WPKHAddress publicKey;
  final WIF privateKey;

  Bip122KeyPair(this.blockchainId, this.publicKey, this.privateKey);

  @override
  Future<String> signData(String message) async {
    final MessageSignature signedData = MessageSignature.sign(
        key: privateKey.privkey,
        message: message,
        prefix: blockchainId.reference.networkParams.messagePrefix);
    return signedData.toString();
  }

  @override
  String get public => publicKey.toString();

  @override
  String get private => privateKey.toString();
}

class Bip122KeyPairFactory
    extends KeyPairFactory<Bip122BlockchainId, Address, WIF> {
  Bip122KeyPairFactory(Bip122BlockchainId blockchainId) : super(blockchainId);
  @override
  Bip122KeyPair fromPrivateKey(WIF privateKey) {
    return Bip122KeyPair(
        blockchainId,
        _bip122AccountFromPrivateKey(
            privateKey, blockchainId.reference.networkParams.bech32Hrp),
        privateKey);
  }

  @override
  Bip122KeyPair fromPrivateKeyString(String privateKey) {
    WIF key = _bip122PrivateKeyFromString(
        privateKey, blockchainId.reference.networkParams.wifPrefix);
    P2WPKHAddress publicKey = _bip122AccountFromPrivateKey(
        key, blockchainId.reference.networkParams.bech32Hrp);
    return Bip122KeyPair(blockchainId, publicKey, key);
  }

  @override
  Future<Bip122KeyPair> fromSeed(Uint8List seed, int index) async {
    WIF privateKey = _bip122PrivateKeyFromSeed(seed, blockchainId, index,
        blockchainId.reference.networkParams.wifPrefix);
    P2WPKHAddress publicKey = _bip122AccountFromPrivateKey(
        privateKey, blockchainId.reference.networkParams.bech32Hrp);
    return Bip122KeyPair(blockchainId, publicKey, privateKey);
  }

  static P2WPKHAddress _bip122AccountFromPrivateKey(WIF wif, String hrp) {
    return P2WPKHAddress.fromPublicKey(
      wif.privkey.pubkey,
      hrp: hrp,
    );
  }

  static WIF _bip122PrivateKeyFromString(String privateKey, int version) {
    return WIF.fromString(privateKey, version: version);
  }

  static WIF _bip122PrivateKeyFromSeed(
      Uint8List seed, Bip122BlockchainId blockchainId, int index, int version) {
    HDPrivateKey hdWallet = HDPrivateKey.fromSeed(seed);
    String path = Bip122DerivationPath(blockchainId, addressIndex: index).path;
    HDPrivateKey key = hdWallet.derivePath(path);
    return WIF(privkey: key.privateKey, version: version);
  }
}
