import 'dart:typed_data';
import 'package:coinlib/coinlib.dart';
import '../../../types/common/keypair/keypair.dart';
import '../bip122_blockchain_id/bip122_blockchain_id.dart';
import '../bip122_blockchain_id/bip122_blockchain_reference.dart';
import '../bip44/bip44.dart';

class Bip122KeyPair implements KeyPair<Bip122BlockchainId, Address, WIF> {
  @override
  final Bip122BlockchainId blockchainId;

  @override
  final P2WPKHAddress publicKey;

  @override
  final WIF privateKey;

  Bip122KeyPair(Bip122Reference reference, this.publicKey, this.privateKey)
      : blockchainId = Bip122BlockchainId(reference);

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
    implements KeyPairFactory<Bip122BlockchainId, Address, WIF> {
  final Bip122BlockchainId blockchainId;

  Bip122KeyPairFactory(Bip122Reference reference)
      : blockchainId = Bip122BlockchainId(reference);

  @override
  Bip122KeyPair fromPrivateKey(WIF privateKey) {
    return Bip122KeyPair(
        blockchainId.reference,
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
    return Bip122KeyPair(blockchainId.reference, publicKey, key);
  }

  @override
  Future<Bip122KeyPair> fromSeed(Uint8List seed, int index) async {
    WIF privateKey = _bip122PrivateKeyFromSeed(seed, blockchainId.reference,
        index, blockchainId.reference.networkParams.wifPrefix);
    P2WPKHAddress publicKey = _bip122AccountFromPrivateKey(
        privateKey, blockchainId.reference.networkParams.bech32Hrp);
    return Bip122KeyPair(blockchainId.reference, publicKey, privateKey);
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
      Uint8List seed, Bip122Reference reference, int index, int version) {
    HDPrivateKey hdWallet = HDPrivateKey.fromSeed(seed);
    String path = Bip122DerivationPath(reference, addressIndex: index).path;
    HDPrivateKey key = hdWallet.derivePath(path);
    return WIF(privkey: key.privateKey, version: version);
  }
}
