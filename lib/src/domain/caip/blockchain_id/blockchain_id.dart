import 'package:wallet_core/src/domain/caip/blockchain_id/blockchain_reference/eip155_reference.dart';
import 'package:wallet_core/src/domain/caip/blockchain_id/blockchain_reference/solana_reference.dart';
import 'package:wallet_core/src/domain/caip/blockchain_id/blockchain_reference/bip122_reference.dart';
import 'package:wallet_core/src/domain/caip/blockchain_id/namespace.dart';

class BlockchainId {
  final BlockchainNamespace namespace;
  final String reference;

  BlockchainId(this.namespace, this.reference) {
    if (!_isValidReference(namespace, reference)) {
      throw ArgumentError(
          "Unknown ${namespace.asString} Reference: $reference");
    }
  }

  BlockchainId.eip155(Eip155Reference reference)
      : this(BlockchainNamespace.eip155, reference.asString);

  BlockchainId.solana(SolanaReference reference)
      : this(BlockchainNamespace.solana, reference.asString);

  BlockchainId.bip122(Bip122Reference reference)
      : this(BlockchainNamespace.bip122, reference.asString);

  bool _isValidReference(BlockchainNamespace namespace, String reference) {
    switch (namespace) {
      case BlockchainNamespace.eip155:
        return Eip155Reference.values
            .contains(Eip155ReferenceExtension.fromString(reference));
      case BlockchainNamespace.solana:
        return SolanaReference.values
            .contains(SolanaReferenceExtension.fromString(reference));
      case BlockchainNamespace.bip122:
        return Bip122Reference.values
            .contains(Bip122ReferenceExtension.fromString(reference));
      default:
        return false;
    }
  }

  static BlockchainId fromString(String blockchainId) {
    final parts = blockchainId.split(':');
    if (parts.length != 2) {
      throw Exception("Invalid Blockchain ID: $blockchainId");
    }
    final namespace = BlockchainNamespaceExtension.fromString(parts[0]);
    final reference = parts[1];
    return BlockchainId(namespace, reference);
  }

  @override
  String toString() {
    return '$namespace.asString:$reference';
  }
}
