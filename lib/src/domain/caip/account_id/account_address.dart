import 'package:coinlib/coinlib.dart';
import 'package:solana/solana.dart';
import 'package:web3dart/credentials.dart';

import '../blockchain_id/blockchain_id.dart';
import '../blockchain_id/blockchain_reference/bip122_reference.dart';
import '../blockchain_id/namespace.dart';
import '../blockchain_id/reference.dart';

abstract class BlockchainAccountAddress {
  @override
  String toString();
}

mixin AccountAddressMixin {
  static BlockchainAccountAddress fromString(BlockchainId blockchainId, String address) {
    switch (blockchainId.namespace) {
      case BlockchainNamespace.eip155:
        return Eip155AccountAddress.fromString(address);
      case BlockchainNamespace.solana:
        return SolanaAccountAddress.fromString(address);
      case BlockchainNamespace.bip122:
        switch (blockchainId.reference) {
          case Bip122BlockchainReference(value: Bip122Reference.BitcoinMainnet):
            return Bip122AccountAddress.fromString(
                Bip122Reference.BitcoinMainnet, address);
          case Bip122BlockchainReference(value: Bip122Reference.BitcoinTestnet):
            return Bip122AccountAddress.fromString(
                Bip122Reference.BitcoinTestnet, address);
          default:
            throw Exception('Invalid Blockchain Reference');
        }
      default:
        throw Exception('Invalid Blockchain Namespace');
    }
  }
}

class Eip155AccountAddress extends BlockchainAccountAddress with AccountAddressMixin {
  final EthereumAddress value;

  Eip155AccountAddress(this.value);

  Eip155AccountAddress.fromString(String address)
      : value = EthereumAddress.fromHex(address);

  @override
  String toString() => value.hexEip55;
}

class SolanaAccountAddress extends BlockchainAccountAddress with AccountAddressMixin {
  final Ed25519HDPublicKey value;

  SolanaAccountAddress(this.value);

  SolanaAccountAddress.fromString(String address)
      : value = Ed25519HDPublicKey.fromBase58(address);

  @override
  String toString() => value.toBase58();
}

class Bip122AccountAddress extends BlockchainAccountAddress with AccountAddressMixin {
  final Address value;

  Bip122AccountAddress(this.value);

  Bip122AccountAddress.fromString(Bip122Reference reference, String address)
      : value = Address.fromString(address, reference.networkParams);

  @override
  String toString() => value.toString();
}
