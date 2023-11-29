import 'package:eth_sig_util/eth_sig_util.dart';
import 'package:eth_sig_util/util/utils.dart';
import 'package:web3dart/web3dart.dart';
import 'package:hex/hex.dart';
import 'package:bip32_bip44/dart_bip32_bip44.dart';

import 'dart:typed_data';

import '../bip44/bip44.dart';
import '../eip155_blockchain_id/eip155_blockchain_id.dart';
import '../eip155_blockchain_id/eip155_blockchain_reference.dart';
import '../../../types/common/keypair/keypair.dart';

class Eip155KeyPair
    implements KeyPair<Eip155BlockchainId, EthereumAddress, ExtendedKey> {
  @override
  final Eip155BlockchainId blockchainId;

  @override
  final EthereumAddress publicKey;

  @override
  final ExtendedKey privateKey;

  Eip155KeyPair(Eip155Reference reference, this.publicKey, this.privateKey)
      : blockchainId = Eip155BlockchainId(reference);

  @override
  Future<String> signData(String message) async {
    return EthSigUtil.signPersonalMessage(
      message: hexToBytes(HEX.encode(message.codeUnits)),
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
    implements
        KeyPairFactory<Eip155BlockchainId, EthereumAddress, ExtendedKey> {
  final Eip155BlockchainId blockchainId;

  Eip155KeyPairFactory(Eip155Reference reference)
      : blockchainId = Eip155BlockchainId(reference);

  @override
  Eip155KeyPair fromPrivateKey(ExtendedKey privateKey) {
    return Eip155KeyPair(blockchainId.reference,
        _eip155AccountFromPrivateKey(privateKey).address, privateKey);
  }

  @override
  Eip155KeyPair fromPrivateKeyString(String privateKey) {
    return Eip155KeyPair(
        blockchainId.reference,
        _eip155AccountFromPrivateKeyHex(privateKey).address,
        ExtendedKey.deserialize(privateKey));
  }

  @override
  Future<Eip155KeyPair> fromSeed(Uint8List seed, int index) async {
    ExtendedKey secretKey =
        _eip155PrivateKeyFromSeed(seed, blockchainId.reference, index);
    EthereumAddress accountAddress =
        _eip155AccountFromPrivateKey(secretKey).address;
    return Eip155KeyPair(blockchainId.reference, accountAddress, secretKey);
  }

  static ExtendedKey _eip155PrivateKeyFromSeed(
      Uint8List seed, Eip155Reference reference, int index) {
    Chain chain = Chain.seed(HEX.encode(seed));
    String path = Eip155DerivationPath(reference, addressIndex: index).path;
    return chain.forPath(path);
  }

  static Credentials _eip155AccountFromPrivateKey(ExtendedKey key) {
    return EthPrivateKey.fromHex(key.privateKeyHex());
  }

  static Credentials _eip155AccountFromPrivateKeyHex(String privateKeyHex) {
    return EthPrivateKey.fromHex(privateKeyHex);
  }
}
