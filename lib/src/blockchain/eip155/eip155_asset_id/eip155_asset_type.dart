import 'package:web3dart/web3dart.dart';

import '../../../types/common/caip/asset_id/asset_type.dart';
import '../eip155_blockchain_id/eip155_blockchain_id.dart';
import '../eip155_blockchain_id/eip155_blockchain_reference.dart';
import 'eip155_asset_namespace.dart';

class Eip155BlockchainAssetType
    implements
        BlockchainAssetType<Eip155BlockchainId, Eip155AssetNamespace,
            EthereumAddress> {
  @override
  final Eip155BlockchainId blockchainId;

  @override
  final Eip155AssetNamespace assetNamespace;

  @override
  final EthereumAddress assetReference;

  Eip155BlockchainAssetType(
      Eip155Reference reference, this.assetNamespace, this.assetReference)
      : blockchainId = Eip155BlockchainId(reference);

  @override
  String toString() {
    return "${blockchainId.toString()}/${assetNamespace.toString()}:${assetReference.hexEip55}";
  }
}

class Eip155BlockchainAssetTypeFactory
    implements
        BlockchainAssetTypeFactory<Eip155BlockchainId, Eip155AssetNamespace,
            EthereumAddress> {
  final Eip155BlockchainId blockchainId;

  final Eip155AssetNamespace assetNamespace;

  Eip155BlockchainAssetTypeFactory(
      Eip155Reference reference, this.assetNamespace)
      : blockchainId = Eip155BlockchainId(reference);

  @override
  Eip155BlockchainAssetType fromString(String assetReference) {
    return Eip155BlockchainAssetType(blockchainId.reference, assetNamespace,
        EthereumAddress.fromHex(assetReference));
  }
}
