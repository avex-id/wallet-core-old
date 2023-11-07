import 'blockchain_reference/bip122_reference.dart';
import 'blockchain_reference/eip155_reference.dart';
import 'blockchain_reference/solana_reference.dart';
import 'reference.dart';
import 'namespace.dart';

class BlockchainId<T extends BlockchainReference> {
  final BlockchainNamespace namespace;
  final T reference;

  BlockchainId(this.namespace, this.reference) {
    if (namespace == BlockchainNamespace.eip155) {
      if (reference is! Eip155Reference) {
        throw Exception(
            "Invalid Blockchain Reference for: ${namespace.toString()}");
      }
    }
    if (namespace == BlockchainNamespace.solana) {
      if (reference is! SolanaReference) {
        throw Exception(
            "Invalid Blockchain Reference for: ${namespace.toString()}");
      }
    }
    if (namespace == BlockchainNamespace.bip122) {
      if (reference is! Bip122Reference) {
        throw Exception(
            "Invalid Blockchain Reference for: ${namespace.toString()}");
      }
    }
  }

  static BlockchainId fromString(String blockchainId) {
    final parts = blockchainId.split(':');
    if (parts.length != 2) {
      throw Exception("Invalid Blockchain ID: $blockchainId");
    }
    final BlockchainReference reference;
    final namespace = BlockchainNamespace.fromString(parts[0]);
    if (namespace == BlockchainNamespace.eip155) {
      reference = Eip155Reference.fromString(parts[1]);
    } else if (namespace == BlockchainNamespace.solana) {
      reference = SolanaReference.fromString(parts[1]);
    } else if (namespace == BlockchainNamespace.bip122) {
      reference = Bip122Reference.fromString(parts[1]);
    } else {
      throw Exception("Invalid Blockchain ID: $blockchainId");
    }
    return BlockchainId(namespace, reference);
  }

  @override
  String toString() {
    return '${namespace.toString()}:${reference.toString()}';
  }
}
