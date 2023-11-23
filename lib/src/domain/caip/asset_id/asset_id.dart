import 'package:coinlib/coinlib.dart';
import 'package:solana/solana.dart';
import 'package:web3dart/web3dart.dart';

import '../blockchain_id/blockchain_id.dart';
import '../blockchain_id/blockchain_reference/bip122_reference.dart';
import '../blockchain_id/blockchain_reference/eip155_reference.dart';
import '../blockchain_id/blockchain_reference/solana_reference.dart';
import 'asset_namespace/eip155_asset_namespace.dart';
import 'asset_namespace/bip122_asset_namespace.dart';
import 'asset_namespace/solana_asset_namespace.dart';
import 'asset_type.dart';

abstract class BlockchainAssetId<T extends BlockchainAssetType> {
  static const String _INVALID_BLOCKCHAIN_ASSET_ID =
      'Invalid Blockchain Asset Id';

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

class Eip155BlockchainAssetId
    implements BlockchainAssetId<Eip155BlockchainAssetType> {
  final Eip155Reference blockchainReference;

  final Eip155AssetNamespace assetNamespace;

  final EthereumAddress assetReference;

  @override
  Eip155BlockchainAssetType get assetType => Eip155BlockchainAssetType(
      blockchainReference, assetNamespace, assetReference);

  @override
  final String? tokenId;

  Eip155BlockchainAssetId(this.blockchainReference, this.assetNamespace,
      this.assetReference, this.tokenId);

  @override
  String toString() {
    return "${assetType.toString()}${tokenId != null ? '/$tokenId' : ''}";
  }
}

class SolanaBlockchainAssetId
    implements BlockchainAssetId<SolanaBlockchainAssetType> {
  final SolanaReference blockchainReference;

  final SolanaAssetNamespace assetNamespace;

  final Ed25519HDPublicKey assetReference;

  @override
  SolanaBlockchainAssetType get assetType => SolanaBlockchainAssetType(
      blockchainReference, assetNamespace, assetReference);

  @override
  final String? tokenId;

  SolanaBlockchainAssetId(this.blockchainReference, this.assetNamespace,
      this.assetReference, this.tokenId);

  @override
  String toString() {
    return "${assetType.toString()}${tokenId != null ? '/$tokenId' : ''}";
  }
}

class Bip122BlockchainAssetId
    implements BlockchainAssetId<Bip122BlockchainAssetType> {
  final Bip122Reference blockchainReference;

  final Bip122AssetNamespace assetNamespace;

  final Address assetReference;

  @override
  Bip122BlockchainAssetType get assetType => Bip122BlockchainAssetType(
      blockchainReference, assetNamespace, assetReference);

  @override
  final String? tokenId;

  Bip122BlockchainAssetId(this.blockchainReference, this.assetNamespace,
      this.assetReference, this.tokenId);

  @override
  String toString() {
    return "${assetType.toString()}${tokenId != null ? '/$tokenId' : ''}";
  }
}

abstract class BlockchainAssetIdFactory<T extends BlockchainAssetType> {
  T get assetType;

  BlockchainAssetId<T> fromString(String assetId);
}

class Eip155BlockchainAssetIdFactory
    implements BlockchainAssetIdFactory<Eip155BlockchainAssetType> {
  final Eip155Reference blockchainReference;

  final Eip155AssetNamespace assetNamespace;

  final EthereumAddress assetReference;

  @override
  Eip155BlockchainAssetType get assetType => Eip155BlockchainAssetType(
      blockchainReference, assetNamespace, assetReference);

  Eip155BlockchainAssetIdFactory(
      this.blockchainReference, this.assetNamespace, this.assetReference);

  @override
  Eip155BlockchainAssetId fromString(String assetId) {
    return Eip155BlockchainAssetId(
        blockchainReference, assetNamespace, assetReference, assetId);
  }
}

class SolanaBlockchainAssetIdFactory
    implements BlockchainAssetIdFactory<SolanaBlockchainAssetType> {
  final SolanaReference blockchainReference;

  final SolanaAssetNamespace assetNamespace;

  final Ed25519HDPublicKey assetReference;

  @override
  SolanaBlockchainAssetType get assetType => SolanaBlockchainAssetType(
      blockchainReference, assetNamespace, assetReference);

  SolanaBlockchainAssetIdFactory(
      this.blockchainReference, this.assetNamespace, this.assetReference);

  @override
  SolanaBlockchainAssetId fromString(String assetId) {
    return SolanaBlockchainAssetId(
        blockchainReference, assetNamespace, assetReference, assetId);
  }
}

class Bip122BlockchainAssetIdFactory
    implements BlockchainAssetIdFactory<Bip122BlockchainAssetType> {
  final Bip122Reference blockchainReference;

  final Bip122AssetNamespace assetNamespace;

  final Address assetReference;

  @override
  Bip122BlockchainAssetType get assetType => Bip122BlockchainAssetType(
      blockchainReference, assetNamespace, assetReference);

  Bip122BlockchainAssetIdFactory(
      this.blockchainReference, this.assetNamespace, this.assetReference);

  @override
  Bip122BlockchainAssetId fromString(String assetId) {
    return Bip122BlockchainAssetId(
        blockchainReference, assetNamespace, assetReference, assetId);
  }
}

class BlockchainAssetIdFactoryProducer {
  static BlockchainAssetIdFactory getFactory(BlockchainAssetType assetType) {
    if (assetType is Eip155BlockchainAssetType) {
      return Eip155BlockchainAssetIdFactory(assetType.reference,
          assetType.assetNamespace, assetType.assetReference);
    } else if (assetType is SolanaBlockchainAssetType) {
      return SolanaBlockchainAssetIdFactory(assetType.reference,
          assetType.assetNamespace, assetType.assetReference);
    } else if (assetType is Bip122BlockchainAssetType) {
      return Bip122BlockchainAssetIdFactory(assetType.reference,
          assetType.assetNamespace, assetType.assetReference);
    } else {
      throw Exception(BlockchainAssetId._INVALID_BLOCKCHAIN_ASSET_ID);
    }
  }
}
