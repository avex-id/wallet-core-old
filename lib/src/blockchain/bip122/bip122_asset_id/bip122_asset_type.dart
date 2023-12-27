import 'package:coinlib/coinlib.dart';

import '../../../domain/common/caip/blockchain_asset_id/asset_type.dart';
import '../bip122_blockchain_id/bip122_blockchain_id.dart';
import '../bip122_blockchain_id/bip122_blockchain_reference.dart';
import 'bip122_asset_namespace.dart';

class Bip122BlockchainAssetType
    implements
        BlockchainAssetType<Bip122BlockchainId, Bip122AssetNamespace, Address> {
  @override
  final Bip122BlockchainId blockchainId;

  @override
  final Bip122AssetNamespace assetNamespace;

  @override
  final Address assetReference;

  Bip122BlockchainAssetType(
      Bip122Reference reference, this.assetNamespace, this.assetReference)
      : blockchainId = Bip122BlockchainId(reference);

  @override
  String toString() {
    return "${blockchainId.toString()}/${assetNamespace.toString()}:${assetReference.toString()}";
  }
}

class Bip122BlockchainAssetTypeFactory
    implements
        BlockchainAssetTypeFactory<Bip122BlockchainId, Bip122AssetNamespace,
            Address> {
  final Bip122BlockchainId blockchainId;

  final Bip122AssetNamespace assetNamespace;

  Bip122BlockchainAssetTypeFactory(
      Bip122Reference reference, this.assetNamespace)
      : blockchainId = Bip122BlockchainId(reference);

  @override
  Bip122BlockchainAssetType fromString(String assetReference) {
    return Bip122BlockchainAssetType(
        blockchainId.reference,
        assetNamespace,
        Address.fromString(
            assetReference, blockchainId.reference.networkParams));
  }
}
