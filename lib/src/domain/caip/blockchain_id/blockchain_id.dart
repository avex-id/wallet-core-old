import 'namespace.dart';
import 'reference.dart';

class BlockchainId {
  final BlockchainNamespace namespace;
  final BlockchainReference reference;

  BlockchainId(this.namespace, this.reference);

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
