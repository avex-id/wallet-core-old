import 'package:coinlib/coinlib.dart';
import 'package:solana/solana.dart';
import 'package:web3dart/web3dart.dart';

import 'asset_namespace.dart';
import 'asset_namespace/bip122_asset_namespace.dart';
import 'asset_namespace/eip155_asset_namespace.dart';
import 'asset_namespace/solana_asset_namespace.dart';
import '../blockchain_id/blockchain_reference/bip122_reference.dart';
import '../blockchain_id/blockchain_reference/eip155_reference.dart';
import '../blockchain_id/blockchain_reference/solana_reference.dart';
import '../blockchain_id/blockchain_id.dart';
import '../blockchain_id/reference.dart';

abstract class BlockchainAssetType<T extends BlockchainId,
    U extends BlockchainAssetNamespace, V> {
  static const String _INVALID_BLOCKCHAIN_ASSET_TYPE =
      'Invalid Blockchain Asset Type';

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

class Eip155BlockchainAssetType
    implements
        BlockchainAssetType<Eip155BlockchainId, Eip155AssetNamespace,
            EthereumAddress> {
  final Eip155Reference reference;

  @override
  Eip155BlockchainId get blockchainId => Eip155BlockchainId(reference);

  @override
  final Eip155AssetNamespace assetNamespace;

  @override
  final EthereumAddress assetReference;

  Eip155BlockchainAssetType(
      this.reference, this.assetNamespace, this.assetReference);

  @override
  String toString() {
    return "${blockchainId.toString()}/${assetNamespace.toString()}:${assetReference.hexEip55}";
  }
}

class SolanaBlockchainAssetType
    implements
        BlockchainAssetType<SolanaBlockchainId, SolanaAssetNamespace,
            Ed25519HDPublicKey> {
  final SolanaReference reference;

  @override
  SolanaBlockchainId get blockchainId => SolanaBlockchainId(reference);

  @override
  final SolanaAssetNamespace assetNamespace;

  @override
  final Ed25519HDPublicKey assetReference;

  SolanaBlockchainAssetType(
      this.reference, this.assetNamespace, this.assetReference);

  @override
  String toString() {
    return "${blockchainId.toString()}/${assetNamespace.toString()}:${assetReference.toBase58()}";
  }
}

class Bip122BlockchainAssetType
    implements
        BlockchainAssetType<Bip122BlockchainId, Bip122AssetNamespace, Address> {
  final Bip122Reference reference;

  @override
  Bip122BlockchainId get blockchainId => Bip122BlockchainId(reference);

  @override
  final Bip122AssetNamespace assetNamespace;

  @override
  final Address assetReference;

  Bip122BlockchainAssetType(
      this.reference, this.assetNamespace, this.assetReference);

  @override
  String toString() {
    return "${blockchainId.toString()}/${assetNamespace.toString()}:${assetReference.toString()}";
  }
}

abstract class BlockchainAssetTypeFactory<T extends BlockchainId,
    U extends BlockchainAssetNamespace, V> {
  T get blockchainId;

  U get assetNamespace;

  BlockchainAssetType<T, U, V> fromString(String assetReference);
}

class Eip155BlockchainAssetTypeFactory
    implements
        BlockchainAssetTypeFactory<Eip155BlockchainId, Eip155AssetNamespace,
            EthereumAddress> {
  final Eip155Reference reference;

  @override
  final Eip155AssetNamespace assetNamespace;

  @override
  Eip155BlockchainId get blockchainId => Eip155BlockchainId(reference);

  Eip155BlockchainAssetTypeFactory(this.reference, this.assetNamespace);

  @override
  Eip155BlockchainAssetType fromString(String assetReference) {
    return Eip155BlockchainAssetType(blockchainId.reference, assetNamespace,
        EthereumAddress.fromHex(assetReference));
  }
}

class SolanaBlockchainAssetTypeFactory
    implements
        BlockchainAssetTypeFactory<SolanaBlockchainId, SolanaAssetNamespace,
            Ed25519HDPublicKey> {
  final SolanaReference reference;

  @override
  final SolanaAssetNamespace assetNamespace;

  @override
  SolanaBlockchainId get blockchainId => SolanaBlockchainId(reference);

  SolanaBlockchainAssetTypeFactory(this.reference, this.assetNamespace);

  @override
  SolanaBlockchainAssetType fromString(String assetReference) {
    return SolanaBlockchainAssetType(blockchainId.reference, assetNamespace,
        Ed25519HDPublicKey.fromBase58(assetReference));
  }
}

class Bip122BlockchainAssetTypeFactory
    implements
        BlockchainAssetTypeFactory<Bip122BlockchainId, Bip122AssetNamespace,
            Address> {
  final Bip122Reference reference;

  @override
  final Bip122AssetNamespace assetNamespace;

  @override
  Bip122BlockchainId get blockchainId => Bip122BlockchainId(reference);

  Bip122BlockchainAssetTypeFactory(this.reference, this.assetNamespace);

  @override
  Bip122BlockchainAssetType fromString(String assetReference) {
    return Bip122BlockchainAssetType(
        blockchainId.reference,
        assetNamespace,
        Address.fromString(
            assetReference, blockchainId.reference.networkParams));
  }
}

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
      throw Exception(BlockchainAssetType._INVALID_BLOCKCHAIN_ASSET_TYPE);
    }
  }
}
