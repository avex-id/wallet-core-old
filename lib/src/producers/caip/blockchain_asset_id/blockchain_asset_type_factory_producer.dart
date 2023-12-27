import '../../../blockchain/bip122/bip122_asset_id/bip122_asset_namespace.dart';
import '../../../blockchain/bip122/bip122_asset_id/bip122_asset_type.dart';
import '../../../blockchain/bip122/bip122_blockchain_id/bip122_blockchain_reference.dart';
import '../../../blockchain/eip155/eip155_asset_id/eip155_asset_namespace.dart';
import '../../../blockchain/eip155/eip155_asset_id/eip155_asset_type.dart';
import '../../../blockchain/eip155/eip155_blockchain_id/eip155_blockchain_reference.dart';
import '../../../blockchain/solana/solana_asset_id/solana_asset_namespace.dart';
import '../../../blockchain/solana/solana_asset_id/solana_asset_type.dart';
import '../../../blockchain/solana/solana_blockchain_id/solana_blockchain_reference.dart';
import '../../../domain/common/caip/blockchain_asset_id/asset_type.dart';
import '../../../domain/common/caip/blockchain_id/blockchain_reference.dart';

class BlockchainAssetTypeFactoryProducer {
  static BlockchainAssetTypeFactory getFactory(
      BlockchainReference reference, String assetNamespace) {
    if (reference is Eip155Reference) {
      return Eip155BlockchainAssetTypeFactory(
          reference, Eip155AssetNamespace.fromString(assetNamespace));
    } else if (reference is SolanaReference) {
      return SolanaBlockchainAssetTypeFactory(
          reference, SolanaAssetNamespace.fromString(assetNamespace));
    } else if (reference is Bip122Reference) {
      return Bip122BlockchainAssetTypeFactory(
          reference, Bip122AssetNamespace.fromString(assetNamespace));
    } else {
      throw Exception("Unknown blockchain reference");
    }
  }
}
