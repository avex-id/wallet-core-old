import '../blockchain_id/namespace.dart';
import '../blockchain_id/blockchain_id.dart';
import 'asset_namespace.dart';
import 'asset_namespace/bip122_asset_namespace.dart';
import 'asset_namespace/eip155_asset_namespace.dart';
import 'asset_namespace/solana_asset_namespace.dart';

class BlockchainAssetType<T extends BlockchainAssetNamespace> {
  final BlockchainId blockchainId;
  final T namespace;
  final String reference;

  BlockchainAssetType(this.blockchainId, this.namespace, this.reference) {
    if (blockchainId.namespace == BlockchainNamespace.eip155) {
      if (namespace is! Eip155AssetNamespace) {
        throw Exception(
            "Invalid Asset Namespace for: ${blockchainId.toString()}");
      }
    }
    if (blockchainId.namespace == BlockchainNamespace.solana) {
      if (namespace is! SolanaAssetNamespace) {
        throw Exception(
            "Invalid Asset Namespace for: ${blockchainId.toString()}");
      }
    }
    if (blockchainId.namespace == BlockchainNamespace.bip122) {
      if (namespace is! Bip122AssetNamespace) {
        throw Exception(
            "Invalid Asset Namespace for: ${blockchainId.toString()}");
      }
    }
  }

  static BlockchainAssetType fromString(String assetType) {
    final parts = assetType.split('/');
    if (parts.length != 2) {
      throw Exception('Invalid asset type');
    }
    final blockchainId = BlockchainId.fromString(parts[0]);
    final BlockchainAssetNamespace assetNamespace;
    final additionalParts = parts[1].split(':');
    if (additionalParts.length != 2) {
      throw ArgumentError(
          'Invalid asset namespace and reference format: ${parts[1]}');
    }
    if (blockchainId.namespace == BlockchainNamespace.eip155) {
      assetNamespace = Eip155AssetNamespace.fromString(additionalParts[0]);
    } else if (blockchainId.namespace == BlockchainNamespace.solana) {
      assetNamespace = SolanaAssetNamespace.fromString(additionalParts[0]);
    } else if (blockchainId.namespace == BlockchainNamespace.bip122) {
      assetNamespace = Bip122AssetNamespace.fromString(additionalParts[0]);
    } else {
      throw Exception(
          "Invalid Asset Namespace for: ${blockchainId.toString()}");
    }
    return BlockchainAssetType(
        blockchainId, assetNamespace, additionalParts[1]);
  }

  @override
  String toString() {
    return "${blockchainId.toString()}/${namespace.toString()}:$reference";
  }
}
