import 'package:solana/solana.dart';

import '../../../domain/common/caip/blockchain_asset_id/asset_type.dart';
import '../solana_blockchain_id/solana_blockchain_id.dart';
import '../solana_blockchain_id/solana_blockchain_reference.dart';
import 'solana_asset_namespace.dart';

class SolanaBlockchainAssetType
    implements
        BlockchainAssetType<SolanaBlockchainId, SolanaAssetNamespace,
            Ed25519HDPublicKey> {
  @override
  final SolanaBlockchainId blockchainId;

  @override
  final SolanaAssetNamespace assetNamespace;

  @override
  final Ed25519HDPublicKey assetReference;

  SolanaBlockchainAssetType(
      SolanaReference reference, this.assetNamespace, this.assetReference)
      : blockchainId = SolanaBlockchainId(reference);

  @override
  String toString() {
    return "${blockchainId.toString()}/${assetNamespace.toString()}:${assetReference.toBase58()}";
  }
}

class SolanaBlockchainAssetTypeFactory
    implements
        BlockchainAssetTypeFactory<SolanaBlockchainId, SolanaAssetNamespace,
            Ed25519HDPublicKey> {
  final SolanaBlockchainId blockchainId;

  final SolanaAssetNamespace assetNamespace;

  SolanaBlockchainAssetTypeFactory(
      SolanaReference reference, this.assetNamespace)
      : blockchainId = SolanaBlockchainId(reference);

  @override
  SolanaBlockchainAssetType fromString(String assetReference) {
    return SolanaBlockchainAssetType(blockchainId.reference, assetNamespace,
        Ed25519HDPublicKey.fromBase58(assetReference));
  }
}
