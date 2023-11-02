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
        return Eip155AssetNamespaceWrapper.fromString(namespace);
      case BlockchainNamespace.solana:
        return SolanaAssetNamespaceWrapper.fromString(namespace);
      case BlockchainNamespace.bip122:
        return Bip122AssetNamespaceWrapper.fromString(namespace);
    }
  }
}

class Bip122AssetNamespaceWrapper extends BlockchainAssetNamespace {
  final Bip122AssetNamespace value;

  Bip122AssetNamespaceWrapper(this.value);

  Bip122AssetNamespaceWrapper.fromString(String namespace)
      : value = Bip122AssetNamespaceExtension.fromString(namespace);

  @override
  String toString() => value.asString;
}

class Eip155AssetNamespaceWrapper extends BlockchainAssetNamespace {
  final Eip155AssetNamespace value;

  Eip155AssetNamespaceWrapper(this.value);

  Eip155AssetNamespaceWrapper.fromString(String namespace)
      : value = Eip155AssetNamespaceExtension.fromString(namespace);

  @override
  String toString() => value.asString;
}

class SolanaAssetNamespaceWrapper extends BlockchainAssetNamespace {
  final SolanaAssetNamespace value;

  SolanaAssetNamespaceWrapper(this.value);

  SolanaAssetNamespaceWrapper.fromString(String namespace)
      : value = SolanaAssetNamespaceExtension.fromString(namespace);

  @override
  String toString() => value.asString;
}
