import '../../../../producers/caip/blockchain_asset_id/blockchain_asset_id_factory_producer.dart';
import '../../../../producers/caip/blockchain_asset_id/blockchain_asset_type_factory_producer.dart';
import '../blockchain_id/blockchain_id.dart';
import 'asset_type.dart';

abstract class BlockchainAssetId<T extends BlockchainAssetType> {
  static const String _INVALID_BLOCKCHAIN_ASSET_ID =
      'Invalid blockchain asset id';

  T get assetType;

  String? get tokenId;

  static BlockchainAssetId parse(String assetId) {
    final parts = assetId.split('/');
    if (parts.length != 3) throw Exception(_INVALID_BLOCKCHAIN_ASSET_ID);
    final blockchainId = BlockchainId.parse(parts[0]);
    final assetTypeParts = parts[1].split(':');
    final assetType = BlockchainAssetTypeFactoryProducer.getFactory(
            blockchainId.reference, assetTypeParts[0])
        .fromString(assetTypeParts[1]);
    return BlockchainAssetIdFactoryProducer.getFactory(assetType)
        .fromString(parts[2]);
  }
}

abstract class BlockchainAssetIdFactory<T extends BlockchainAssetType> {
  BlockchainAssetId<T> fromString(String assetId);
}
