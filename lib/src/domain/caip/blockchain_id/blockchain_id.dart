import 'package:wallet_core/src/domain/caip/blockchain_id/namespace.dart';
import 'package:wallet_core/src/domain/caip/blockchain_id/reference.dart';

class BlockchainId {
  final BlockchainNamespace namespace;
  final BlockchainReference reference;

  BlockchainId(this.namespace, this.reference);

  BlockchainId.eip155(Eip155BlockchainReference reference)
      : this(BlockchainNamespace.eip155, reference);

  BlockchainId.solana(SolanaBlockchainReference reference)
      : this(BlockchainNamespace.solana, reference);

  BlockchainId.bip122(Bip122BlockchainReference reference)
      : this(BlockchainNamespace.bip122, reference);

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
    return '${namespace.asString}:${reference.asString}';
  }
}
