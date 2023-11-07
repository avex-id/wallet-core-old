import 'package:coinlib/coinlib.dart';
import 'package:solana/solana.dart';
import 'package:web3dart/web3dart.dart';

import '../blockchain_id/blockchain_reference/bip122_reference.dart';
import '../blockchain_id/namespace.dart';
import '../blockchain_id/blockchain_id.dart';

class BlockchainAccountId<T> {
  final BlockchainId blockchainId;
  final T accountAddress;

  BlockchainAccountId(this.blockchainId, this.accountAddress) {
    if (blockchainId.namespace == BlockchainNamespace.eip155) {
      if (accountAddress is! EthereumAddress) {
        throw Exception(
            "Invalid Account Address for: ${blockchainId.toString()}");
      }
    }
    if (blockchainId.namespace == BlockchainNamespace.solana) {
      if (accountAddress is! Ed25519HDPublicKey) {
        throw Exception(
            "Invalid Account Address for: ${blockchainId.toString()}");
      }
    }
    if (blockchainId.namespace == BlockchainNamespace.bip122) {
      if (accountAddress is! Address) {
        throw Exception(
            "Invalid Account Address for: ${blockchainId.toString()}");
      }
    }
  }

  static BlockchainAccountId fromString(String accountId) {
    final parts = accountId.split(':');
    if (parts.length != 3) {
      throw Exception('Invalid account id');
    }
    final blockchainId = BlockchainId.fromString('${parts[0]}:${parts[1]}');
    if (blockchainId.namespace == BlockchainNamespace.eip155) {
      return BlockchainAccountId<EthereumAddress>(
          blockchainId, EthereumAddress.fromHex(parts[2]));
    } else if (blockchainId.namespace == BlockchainNamespace.solana) {
      return BlockchainAccountId<Ed25519HDPublicKey>(
          blockchainId, Ed25519HDPublicKey.fromBase58(parts[2]));
    } else if (blockchainId.namespace == BlockchainNamespace.bip122) {
      return BlockchainAccountId<Address>(
          blockchainId,
          Address.fromString(parts[2],
              (blockchainId.reference as Bip122Reference).networkParams));
    } else {
      throw Exception("Invalid Blockchain ID: $blockchainId");
    }
  }

  T get address => accountAddress;

  @override
  String toString() {
    switch (this.accountAddress.runtimeType) {
      case EthereumAddress:
        return "${blockchainId.toString()}:${(accountAddress as EthereumAddress).hexEip55}";
      case Ed25519HDPublicKey:
        return "${blockchainId.toString()}:${(accountAddress as Ed25519HDPublicKey).toBase58()}";
      case Address:
        return "${blockchainId.toString()}:${(accountAddress as Address).toString()}";
      default:
        throw Exception("Invalid Blockchain ID: $blockchainId");
    }
  }
}
