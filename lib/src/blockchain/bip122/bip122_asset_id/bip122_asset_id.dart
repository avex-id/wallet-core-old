import 'package:coinlib/coinlib.dart';

import '../../../types/common/caip/asset_id/asset_id.dart';
import '../bip122_blockchain_id/bip122_blockchain_reference.dart';
import 'bip122_asset_namespace.dart';
import 'bip122_asset_type.dart';

class Bip122BlockchainAssetId
    implements BlockchainAssetId<Bip122BlockchainAssetType> {
  @override
  final Bip122BlockchainAssetType assetType;

  @override
  final String? tokenId;

  Bip122BlockchainAssetId(Bip122Reference blockchainReference,
      Bip122AssetNamespace assetNamespace, Address assetReference, this.tokenId)
      : assetType = Bip122BlockchainAssetType(
            blockchainReference, assetNamespace, assetReference);

  @override
  String toString() {
    return "${assetType.toString()}${tokenId != null ? '/$tokenId' : ''}";
  }
}

class Bip122BlockchainAssetIdFactory
    implements BlockchainAssetIdFactory<Bip122BlockchainAssetType> {
  final Bip122BlockchainAssetType assetType;

  Bip122BlockchainAssetIdFactory(Bip122Reference blockchainReference,
      Bip122AssetNamespace assetNamespace, Address assetReference)
      : assetType = Bip122BlockchainAssetType(
            blockchainReference, assetNamespace, assetReference);

  @override
  Bip122BlockchainAssetId fromString(String assetId) {
    return Bip122BlockchainAssetId(assetType.blockchainId.reference,
        assetType.assetNamespace, assetType.assetReference, assetId);
  }
}
