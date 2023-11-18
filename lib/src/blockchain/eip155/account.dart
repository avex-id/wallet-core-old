import 'package:eth_sig_util/eth_sig_util.dart';
import 'package:eth_sig_util/util/utils.dart';
import 'package:web3dart/web3dart.dart';
import 'package:hex/hex.dart';
import 'package:bip32_bip44/dart_bip32_bip44.dart';

import '../../model/keypair.dart';
import '../../domain/bip_44/bip_44.dart';
import '../../domain/caip/blockchain_id/blockchain_id.dart';

import 'dart:typed_data';

class Eip155KeyPair implements KeyPair<EthereumAddress, ExtendedKey> {
  final EthereumAddress publicKey;
  final ExtendedKey privateKey;

  Eip155KeyPair(this.publicKey, this.privateKey);

  String signPersonalMessage(String message) {
    return EthSigUtil.signPersonalMessage(
      message: hexToBytes(message),
      privateKey: privateKey.privateKeyHex(),
    );
  }

  String signTypedData(String message) {
    return EthSigUtil.signTypedData(
        privateKey: privateKey.privateKeyHex(),
        jsonData: message,
        version: TypedDataVersion.V4);
  }

  @override
  String get public => publicKey.hexEip55;

  @override
  String get private => privateKey.privateKeyHex();
}

class Eip155KeyPairFactory
    extends KeyPairFactory<Eip155BlockchainId, EthereumAddress, ExtendedKey> {
  Eip155KeyPairFactory(Eip155BlockchainId blockchainId) : super(blockchainId);

  @override
  Eip155KeyPair fromPrivateKey(ExtendedKey privateKey) {
    return Eip155KeyPair(
        _eip155AccountFromPrivateKey(privateKey).address, privateKey);
  }

  @override
  Eip155KeyPair fromPrivateKeyString(String privateKey) {
    return Eip155KeyPair(_eip155AccountFromPrivateKeyHex(privateKey).address,
        ExtendedKey.deserialize(privateKey));
  }

  @override
  Future<Eip155KeyPair> fromSeed(Uint8List seed, int index) async {
    ExtendedKey secretKey =
        _eip155PrivateKeyFromSeed(seed, blockchainId, index);
    EthereumAddress accountAddress =
        _eip155AccountFromPrivateKey(secretKey).address;
    return Eip155KeyPair(accountAddress, secretKey);
  }

  static ExtendedKey _eip155PrivateKeyFromSeed(
      Uint8List seed, Eip155BlockchainId blockchainId, int index) {
    Chain chain = Chain.seed(HEX.encode(seed));
    String path = Eip155DerivationPath(blockchainId, addressIndex: index).path;
    return chain.forPath(path);
  }

  static Credentials _eip155AccountFromPrivateKey(ExtendedKey key) {
    return EthPrivateKey.fromHex(key.privateKeyHex());
  }

  static Credentials _eip155AccountFromPrivateKeyHex(String privateKeyHex) {
    return EthPrivateKey.fromHex(privateKeyHex);
  }
}
