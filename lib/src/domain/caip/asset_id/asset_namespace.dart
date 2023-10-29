import 'asset_namespace/bip122_asset_namespace.dart';
import 'asset_namespace/eip155_asset_namespace.dart';
import 'asset_namespace/solana_asset_namespace.dart';
import '../blockchain_id/blockchain_id.dart';
import '../blockchain_id/namespace.dart';

abstract class BlockchainAssetNamespace {
  @override
  String toString();
}

mixin BlockchainAssetNamespaceMixin {
  static BlockchainAssetNamespace fromString(
      BlockchainId blockchainId, String namespace) {
    switch (blockchainId.namespace) {
      case BlockchainNamespace.eip155:
        return Eip155BlockchainAssetNamespace.fromString(namespace);
      case BlockchainNamespace.solana:
        return SolanaBlockchainAssetNamespace.fromString(namespace);
      case BlockchainNamespace.bip122:
        return Bip122BlockchainAssetNamespace.fromString(namespace);
    }
  }
}

class Bip122BlockchainAssetNamespace extends BlockchainAssetNamespace {
  final Bip122AssetNamespace value;

  Bip122BlockchainAssetNamespace(this.value);

  Bip122BlockchainAssetNamespace.fromString(String namespace)
      : value = Bip122AssetNamespaceExtension.fromString(namespace);

  @override
  String toString() => value.asString;
}

class Eip155BlockchainAssetNamespace extends BlockchainAssetNamespace {
  final Eip155AssetNamespace value;

  Eip155BlockchainAssetNamespace(this.value);

  Eip155BlockchainAssetNamespace.fromString(String namespace)
      : value = Eip155AssetNamespaceExtension.fromString(namespace);

  @override
  String toString() => value.asString;
}

class SolanaBlockchainAssetNamespace extends BlockchainAssetNamespace {
  final SolanaAssetNamespace value;

  SolanaBlockchainAssetNamespace(this.value);

  SolanaBlockchainAssetNamespace.fromString(String namespace)
      : value = SolanaAssetNamespaceExtension.fromString(namespace);

  @override
  String toString() => value.asString;
}
