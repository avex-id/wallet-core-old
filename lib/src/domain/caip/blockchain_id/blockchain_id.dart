import 'namespace.dart';
import 'reference.dart';

class BlockchainId {
  final BlockchainNamespace namespace;
  final BlockchainReference reference;

  BlockchainId(this.namespace, this.reference) {
    if (namespace == BlockchainNamespace.eip155) {
      if (reference is! Eip155ReferenceWrapper) {
        throw Exception(
            "Invalid Blockchain ID: ${namespace.asString}:$reference. Expected Eip155ReferenceWrapper");
      }
    }
    if (namespace == BlockchainNamespace.solana) {
      if (reference is! SolanaReferenceWrapper) {
        throw Exception(
            "Invalid Blockchain ID: ${namespace.asString}:$reference. Expected SolanaReferenceWrapper");
      }
    }
    if (namespace == BlockchainNamespace.bip122) {
      if (reference is! Bip122ReferenceWrapper) {
        throw Exception(
            "Invalid Blockchain ID: ${namespace.asString}:$reference. Expected Bip122ReferenceWrapper");
      }
    }
  }

  static BlockchainId fromString(String blockchainId) {
    final parts = blockchainId.split(':');
    if (parts.length != 2) {
      throw Exception("Invalid Blockchain ID: $blockchainId");
    }
    final namespace = BlockchainNamespaceExtension.fromString(parts[0]);
    final reference = BlockchainReferenceMixin.fromString(namespace, parts[1]);
    return BlockchainId(namespace, reference);
  }

  @override
  String toString() {
    return '${namespace.asString}:${reference.toString()}';
  }
}
