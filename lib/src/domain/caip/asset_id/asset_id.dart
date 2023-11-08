import '../blockchain_id/blockchain_id.dart';
import 'asset_type.dart';

abstract class BlockchainAssetId<T extends BlockchainAssetType> {
  static const String _INVALID_BLOCKCHAIN_ASSET_ID =
      'Invalid Blockchain Asset Id';
  T get assetType;
  String? get tokenId;

  static BlockchainAssetId parse(String assetId) {
    final parts = assetId.split('/');
    if (parts.length != 3) throw Exception(_INVALID_BLOCKCHAIN_ASSET_ID);
    final blockchainId = BlockchainId.parse(parts[0]);
    final assetTypeParts = parts[1].split(':');
    final assetType = BlockchainAssetTypeFactoryProducer.getFactory(
            blockchainId, assetTypeParts[0])
        .fromString(assetTypeParts[1]);
    return BlockchainAssetIdFactoryProducer.getFactory(assetType)
        .fromString(parts[2]);
  }
}

class Eip155BlockchainAssetId
    implements BlockchainAssetId<Eip155BlockchainAssetType> {
  @override
  final Eip155BlockchainAssetType assetType;

  @override
  final String? tokenId;

  Eip155BlockchainAssetId(this.assetType, this.tokenId);

  @override
  String toString() {
    return "${assetType.toString()}${tokenId != null ? '/$tokenId' : ''}";
  }
}

class SolanaBlockchainAssetId
    implements BlockchainAssetId<SolanaBlockchainAssetType> {
  @override
  final SolanaBlockchainAssetType assetType;

  @override
  final String? tokenId;

  SolanaBlockchainAssetId(this.assetType, this.tokenId);

  @override
  String toString() {
    return "${assetType.toString()}${tokenId != null ? '/$tokenId' : ''}";
  }
}

class Bip122BlockchainAssetId
    implements BlockchainAssetId<Bip122BlockchainAssetType> {
  @override
  final Bip122BlockchainAssetType assetType;

  @override
  final String? tokenId;

  Bip122BlockchainAssetId(this.assetType, this.tokenId);

  @override
  String toString() {
    return "${assetType.toString()}${tokenId != null ? '/$tokenId' : ''}";
  }
}

abstract class BlockchainAssetIdFactory<T extends BlockchainAssetType> {
  final T assetType;

  BlockchainAssetIdFactory(this.assetType);

  BlockchainAssetId<T> fromString(String assetId);
}

class Eip155BlockchainAssetIdFactory
    extends BlockchainAssetIdFactory<Eip155BlockchainAssetType> {
  Eip155BlockchainAssetIdFactory(
    Eip155BlockchainAssetType assetType,
  ) : super(assetType);

  @override
  Eip155BlockchainAssetId fromString(String assetId) {
    return Eip155BlockchainAssetId(assetType, assetId);
  }
}

class SolanaBlockchainAssetIdFactory
    extends BlockchainAssetIdFactory<SolanaBlockchainAssetType> {
  SolanaBlockchainAssetIdFactory(SolanaBlockchainAssetType assetType)
      : super(assetType);

  @override
  SolanaBlockchainAssetId fromString(String assetId) {
    return SolanaBlockchainAssetId(assetType, assetId);
  }
}

class Bip122BlockchainAssetIdFactory
    extends BlockchainAssetIdFactory<Bip122BlockchainAssetType> {
  Bip122BlockchainAssetIdFactory(Bip122BlockchainAssetType assetType)
      : super(assetType);

  @override
  Bip122BlockchainAssetId fromString(String assetId) {
    return Bip122BlockchainAssetId(assetType, assetId);
  }
}

class BlockchainAssetIdFactoryProducer {
  static BlockchainAssetIdFactory getFactory(BlockchainAssetType assetType) {
    if (assetType is Eip155BlockchainAssetType) {
      return Eip155BlockchainAssetIdFactory(assetType);
    } else if (assetType is SolanaBlockchainAssetType) {
      return SolanaBlockchainAssetIdFactory(assetType);
    } else if (assetType is Bip122BlockchainAssetType) {
      return Bip122BlockchainAssetIdFactory(assetType);
    } else {
      throw Exception('Invalid Blockchain Asset Type');
    }
  }
}
