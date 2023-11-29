import 'package:web3dart/credentials.dart';

import '../../../types/common/caip/asset_id/asset_id.dart';
import '../eip155_blockchain_id/eip155_blockchain_reference.dart';
import 'eip155_asset_namespace.dart';
import 'eip155_asset_type.dart';

class Eip155BlockchainAssetId
    implements BlockchainAssetId<Eip155BlockchainAssetType> {
  @override
  final Eip155BlockchainAssetType assetType;

  @override
  final String? tokenId;

  Eip155BlockchainAssetId(
      Eip155Reference blockchainReference,
      Eip155AssetNamespace assetNamespace,
      EthereumAddress assetReference,
      this.tokenId)
      : assetType = Eip155BlockchainAssetType(
            blockchainReference, assetNamespace, assetReference);

  @override
  String toString() {
    return "${assetType.toString()}${tokenId != null ? '/$tokenId' : ''}";
  }
}

class Eip155BlockchainAssetIdFactory
    implements BlockchainAssetIdFactory<Eip155BlockchainAssetType> {
  final Eip155BlockchainAssetType assetType;

  Eip155BlockchainAssetIdFactory(Eip155Reference blockchainReference,
      Eip155AssetNamespace assetNamespace, EthereumAddress assetReference)
      : assetType = Eip155BlockchainAssetType(
            blockchainReference, assetNamespace, assetReference);

  @override
  Eip155BlockchainAssetId fromString(String assetId) {
    return Eip155BlockchainAssetId(assetType.blockchainId.reference,
        assetType.assetNamespace, assetType.assetReference, assetId);
  }
}
