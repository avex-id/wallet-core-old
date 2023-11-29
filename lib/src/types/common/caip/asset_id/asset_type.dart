import '../../../../producers/caip/blockchain_asset_id/blockchain_asset_type_factory_producer.dart';
import '../blockchain_id/blockchain_id.dart';
import 'asset_namespace.dart';

abstract class BlockchainAssetType<T extends BlockchainId,
    U extends BlockchainAssetNamespace, V> {
  static const String _INVALID_BLOCKCHAIN_ASSET_TYPE =
      'Invalid blockchain asset type';

  T get blockchainId;

  U get assetNamespace;

  V get assetReference;

  static BlockchainAssetType parse(String assetType) {
    final parts = assetType.split('/');
    if (parts.length != 2) throw Exception(_INVALID_BLOCKCHAIN_ASSET_TYPE);
    final assetTypeParts = parts[1].split(':');
    if (assetTypeParts.length != 2) {
      throw Exception(_INVALID_BLOCKCHAIN_ASSET_TYPE);
    }
    final blockchainId = BlockchainId.parse(parts[0]);
    return BlockchainAssetTypeFactoryProducer.getFactory(
            blockchainId.reference, assetTypeParts[0])
        .fromString(assetTypeParts[1]);
  }
}

abstract class BlockchainAssetTypeFactory<T extends BlockchainId,
    U extends BlockchainAssetNamespace, V> {
  BlockchainAssetType<T, U, V> fromString(String assetReference);
}
