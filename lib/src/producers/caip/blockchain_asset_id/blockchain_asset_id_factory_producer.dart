import '../../../blockchain/bip122/bip122_asset_id/bip122_asset_id.dart';
import '../../../blockchain/bip122/bip122_asset_id/bip122_asset_type.dart';
import '../../../blockchain/eip155/eip155_asset_id/eip155_asset_id.dart';
import '../../../blockchain/eip155/eip155_asset_id/eip155_asset_type.dart';
import '../../../blockchain/solana/solana_asset_id/solana_asset_id.dart';
import '../../../blockchain/solana/solana_asset_id/solana_asset_type.dart';
import '../../../types/common/caip/asset_id/asset_id.dart';
import '../../../types/common/caip/asset_id/asset_type.dart';

class BlockchainAssetIdFactoryProducer {
  static BlockchainAssetIdFactory getFactory(BlockchainAssetType assetType) {
    if (assetType is Eip155BlockchainAssetType) {
      return Eip155BlockchainAssetIdFactory(assetType.blockchainId.reference,
          assetType.assetNamespace, assetType.assetReference);
    } else if (assetType is SolanaBlockchainAssetType) {
      return SolanaBlockchainAssetIdFactory(assetType.blockchainId.reference,
          assetType.assetNamespace, assetType.assetReference);
    } else if (assetType is Bip122BlockchainAssetType) {
      return Bip122BlockchainAssetIdFactory(assetType.blockchainId.reference,
          assetType.assetNamespace, assetType.assetReference);
    } else {
      throw Exception("Unknown blockchain asset type");
    }
  }
}
