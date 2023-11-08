import '../blockchain_id/blockchain_id.dart';
import 'asset_namespace.dart';
import 'asset_namespace/bip122_asset_namespace.dart';
import 'asset_namespace/eip155_asset_namespace.dart';
import 'asset_namespace/solana_asset_namespace.dart';

abstract class BlockchainAssetType<T extends BlockchainId,
    U extends BlockchainAssetNamespace> {
  static const String _INVALID_BLOCKCHAIN_ASSET_TYPE =
      'Invalid Blockchain Asset Type';
  T get blockchainId;
  U get assetNamespace;
  String get assetReference;

  static BlockchainAssetType parse(String assetType) {
    final parts = assetType.split('/');
    if (parts.length != 2) throw Exception(_INVALID_BLOCKCHAIN_ASSET_TYPE);
    final assetTypeParts = parts[1].split(':');
    if (assetTypeParts.length != 2) {
      throw Exception(_INVALID_BLOCKCHAIN_ASSET_TYPE);
    }
    final blockchainId = BlockchainId.parse(parts[0]);
    return BlockchainAssetTypeFactoryProducer.getFactory(
            blockchainId, assetTypeParts[0])
        .fromString(assetTypeParts[1]);
  }
}

class Eip155BlockchainAssetType
    implements BlockchainAssetType<Eip155BlockchainId, Eip155AssetNamespace> {
  @override
  final Eip155BlockchainId blockchainId;

  @override
  final Eip155AssetNamespace assetNamespace;

  @override
  final String assetReference;

  Eip155BlockchainAssetType(
      this.blockchainId, this.assetNamespace, this.assetReference);

  @override
  String toString() {
    return "${blockchainId.toString()}/${assetNamespace.toString()}:$assetReference";
  }
}

class SolanaBlockchainAssetType
    implements BlockchainAssetType<SolanaBlockchainId, SolanaAssetNamespace> {
  @override
  final SolanaBlockchainId blockchainId;

  @override
  final SolanaAssetNamespace assetNamespace;

  @override
  final String assetReference;

  SolanaBlockchainAssetType(
      this.blockchainId, this.assetNamespace, this.assetReference);

  @override
  String toString() {
    return "${blockchainId.toString()}/${assetNamespace.toString()}:$assetReference";
  }
}

class Bip122BlockchainAssetType
    implements BlockchainAssetType<Bip122BlockchainId, Bip122AssetNamespace> {
  @override
  final Bip122BlockchainId blockchainId;

  @override
  final Bip122AssetNamespace assetNamespace;

  @override
  final String assetReference;

  Bip122BlockchainAssetType(
      this.blockchainId, this.assetNamespace, this.assetReference);

  @override
  String toString() {
    return "${blockchainId.toString()}/${assetNamespace.toString()}:$assetReference";
  }
}

abstract class BlockchainAssetTypeFactory<T extends BlockchainId,
    U extends BlockchainAssetNamespace> {
  final T blockchainId;
  final U assetNamespace;

  BlockchainAssetTypeFactory(this.blockchainId, this.assetNamespace);

  BlockchainAssetType<T, U> fromString(String assetReference);
}

class Eip155BlockchainAssetTypeFactory extends BlockchainAssetTypeFactory<
    Eip155BlockchainId, Eip155AssetNamespace> {
  Eip155BlockchainAssetTypeFactory(
      Eip155BlockchainId blockchainId, Eip155AssetNamespace assetNamespace)
      : super(blockchainId, assetNamespace);

  @override
  Eip155BlockchainAssetType fromString(String assetReference) {
    return Eip155BlockchainAssetType(
        blockchainId, assetNamespace, assetReference);
  }
}

class SolanaBlockchainAssetTypeFactory extends BlockchainAssetTypeFactory<
    SolanaBlockchainId, SolanaAssetNamespace> {
  SolanaBlockchainAssetTypeFactory(
      SolanaBlockchainId blockchainId, SolanaAssetNamespace assetNamespace)
      : super(blockchainId, assetNamespace);

  @override
  SolanaBlockchainAssetType fromString(String assetReference) {
    return SolanaBlockchainAssetType(
        blockchainId, assetNamespace, assetReference);
  }
}

class Bip122BlockchainAssetTypeFactory extends BlockchainAssetTypeFactory<
    Bip122BlockchainId, Bip122AssetNamespace> {
  Bip122BlockchainAssetTypeFactory(
      Bip122BlockchainId blockchainId, Bip122AssetNamespace assetNamespace)
      : super(blockchainId, assetNamespace);

  @override
  Bip122BlockchainAssetType fromString(String assetReference) {
    return Bip122BlockchainAssetType(
        blockchainId, assetNamespace, assetReference);
  }
}

class BlockchainAssetTypeFactoryProducer {
  static BlockchainAssetTypeFactory getFactory(
      BlockchainId blockchainId, String assetNamespace) {
    if (blockchainId is Eip155BlockchainId) {
      return Eip155BlockchainAssetTypeFactory(
          blockchainId, Eip155AssetNamespace.fromString(assetNamespace));
    } else if (blockchainId is SolanaBlockchainId) {
      return SolanaBlockchainAssetTypeFactory(
          blockchainId, SolanaAssetNamespace.fromString(assetNamespace));
    } else if (blockchainId is Bip122BlockchainId) {
      return Bip122BlockchainAssetTypeFactory(
          blockchainId, Bip122AssetNamespace.fromString(assetNamespace));
    } else {
      throw Exception('Invalid Blockchain Asset Type');
    }
  }
}
