import 'package:eth_sig_util/eth_sig_util.dart';
import 'package:eth_sig_util/util/utils.dart';

import '../../model/keypair.dart';
import '../../domain/bip_44/bip_44.dart';
import '../../domain/caip/blockchain_id/blockchain_id.dart';
import 'package:web3dart/web3dart.dart';
import 'package:bip32_bip44/dart_bip32_bip44.dart';
import 'package:convert/convert.dart';
import 'dart:typed_data';

class Eip155KeyPair extends KeyPair {
  final ExtendedKey secretKey;
  final EthereumAddress address;

  Eip155KeyPair(this.secretKey, this.address);

  static Eip155KeyPair fromPrivateKey(ExtendedKey key) {
    EthereumAddress address = _eip155AccountFromPrivateKey(key).address;
    return Eip155KeyPair(key, address);
  }

  static Eip155KeyPair fromPrivateKeyString(String privateKey) {
    ExtendedKey secretKey = ExtendedKey.deserialize(privateKey);
    EthereumAddress address =
        _eip155AccountFromPrivateKeyHex(privateKey).address;
    return Eip155KeyPair(secretKey, address);
  }

  static Eip155KeyPair fromSeed(
      Uint8List seed, BlockchainId blockchainId, int index) {
    ExtendedKey secretKey =
        _eip155PrivateKeyFromSeed(seed, blockchainId, index);
    EthereumAddress address = _eip155AccountFromPrivateKey(secretKey).address;
    return Eip155KeyPair(secretKey, address);
  }

  static ExtendedKey _eip155PrivateKeyFromSeed(
      Uint8List seed, BlockchainId blockchainId, int index) {
    Chain chain = Chain.seed(hex.encode(seed));
    String path = DerivationPathManagerMixin.path(blockchainId, index);
    return chain.forPath(path);
  }

  static Credentials _eip155AccountFromPrivateKey(ExtendedKey key) {
    return EthPrivateKey.fromHex(key.privateKeyHex());
  }

  static Credentials _eip155AccountFromPrivateKeyHex(String privateKeyHex) {
    return EthPrivateKey.fromHex(privateKeyHex);
  }

  String signPersonalMessage(String message) {
    return EthSigUtil.signPersonalMessage(
      message: hexToBytes(message),
      privateKey: privateKey,
    );
  }

  String signTypedData(String message) {
    return EthSigUtil.signTypedData(
        privateKey: privateKey,
        jsonData: message,
        version: TypedDataVersion.V4);
  }

  @override
  String get privateKey => secretKey.privateKeyHex();

  @override
  String get publicKey => address.hexEip55;
}
