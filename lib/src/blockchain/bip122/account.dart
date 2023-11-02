import 'dart:typed_data';
import 'package:coinlib/coinlib.dart';
import 'package:wallet_core/src/model/keypair.dart';

import '../../domain/bip_44/bip_44.dart';
import '../../domain/caip/blockchain_id/blockchain_id.dart';

class Bip122KeyPair extends KeyPair {
  final WIF secretKey;
  final P2WPKHAddress address;

  Bip122KeyPair(this.secretKey, this.address);

  static Bip122KeyPair fromPrivateKey(WIF key, String hrp) {
    P2WPKHAddress address = _bip122AccountFromPrivateKey(key, hrp);
    return Bip122KeyPair(key, address);
  }

  static Bip122KeyPair fromPrivateKeyString(
      String privateKey, int version, String hrp) {
    WIF secretKey = _bip122PrivateKeyFromString(privateKey, version);
    P2WPKHAddress address = _bip122AccountFromPrivateKey(secretKey, hrp);
    return Bip122KeyPair(secretKey, address);
  }

  static Bip122KeyPair fromSeed(Uint8List seed, BlockchainId blockchainId,
      int index, int version, String hrp) {
    WIF secretKey =
        _bip122PrivateKeyFromSeed(seed, blockchainId, index, version);
    P2WPKHAddress address = _bip122AccountFromPrivateKey(secretKey, hrp);
    return Bip122KeyPair(secretKey, address);
  }

  static WIF _bip122PrivateKeyFromSeed(
      Uint8List seed, BlockchainId blockchainId, int index, int version) {
    HDPrivateKey hdWallet = HDPrivateKey.fromSeed(seed);
    String path = DerivationPathManagerMixin.path(blockchainId, index);
    HDPrivateKey key = hdWallet.derivePath(path);
    return WIF(privkey: key.privateKey, version: version);
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

  MessageSignature bip122SignData(String message) {
    return MessageSignature.sign(
      key: secretKey.privkey,
      message: message,
      // Todo: Add Dynamic prefix
      prefix: "Bitcoin Signed Message:\n",
    );
  }

  @override
  String get privateKey => secretKey.toString();

  @override
  String get publicKey => address.toString();
}
