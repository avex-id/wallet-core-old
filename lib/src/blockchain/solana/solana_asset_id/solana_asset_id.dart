import 'package:solana/solana.dart';

import '../../../domain/common/caip/blockchain_asset_id/asset_id.dart';
import '../solana_blockchain_id/solana_blockchain_reference.dart';
import 'solana_asset_namespace.dart';
import 'solana_asset_type.dart';

class SolanaBlockchainAssetId
    implements BlockchainAssetId<SolanaBlockchainAssetType> {
  @override
  final SolanaBlockchainAssetType assetType;

  @override
  final String? tokenId;

  SolanaBlockchainAssetId(
      SolanaReference blockchainReference,
      SolanaAssetNamespace assetNamespace,
      Ed25519HDPublicKey assetReference,
      this.tokenId)
      : assetType = SolanaBlockchainAssetType(
            blockchainReference, assetNamespace, assetReference);

  @override
  String toString() {
    return "${assetType.toString()}${tokenId != null ? '/$tokenId' : ''}";
  }
}

class SolanaBlockchainAssetIdFactory
    implements BlockchainAssetIdFactory<SolanaBlockchainAssetType> {
  final SolanaBlockchainAssetType assetType;

  SolanaBlockchainAssetIdFactory(SolanaReference blockchainReference,
      SolanaAssetNamespace assetNamespace, Ed25519HDPublicKey assetReference)
      : assetType = SolanaBlockchainAssetType(
            blockchainReference, assetNamespace, assetReference);

  @override
  SolanaBlockchainAssetId fromString(String assetId) {
    return SolanaBlockchainAssetId(assetType.blockchainId.reference,
        assetType.assetNamespace, assetType.assetReference, assetId);
  }
}
