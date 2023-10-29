import 'asset_namespace.dart';
import '../blockchain_id/blockchain_id.dart';

class BlockchainAssetType {
  final BlockchainId blockchainId;
  final BlockchainAssetNamespace namespace;
  final String reference;

  BlockchainAssetType(this.blockchainId, this.namespace, this.reference);

  static BlockchainAssetType fromString(String assetType) {
    final parts = assetType.split('/');
    if (parts.length != 2) {
      throw Exception('Invalid asset type');
    }
    final blockchainId = BlockchainId.fromString(parts[0]);
    final additionalParts = parts[1].split(':');
    if (additionalParts.length != 2) {
      throw ArgumentError(
          'Invalid asset namespace and reference format: ${parts[1]}');
    }
    final assetNamespace = BlockchainAssetNamespaceMixin.fromString(
        blockchainId, additionalParts[0]);
    return BlockchainAssetType(
        blockchainId, assetNamespace, additionalParts[1]);
  }

  @override
  String toString() {
    return "${blockchainId.toString()}/${namespace.toString()}:$reference";
  }
}
