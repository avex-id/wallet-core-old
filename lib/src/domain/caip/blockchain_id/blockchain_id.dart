import 'blockchain_reference/bip122_reference.dart';
import 'blockchain_reference/eip155_reference.dart';
import 'blockchain_reference/solana_reference.dart';
import 'reference.dart';
import 'namespace.dart';

abstract class BlockchainId<T extends BlockchainReference> {
  static const String _INVALID_BLOCKCHAIN_ID = 'Invalid Blockchain Id';

  BlockchainNamespace get namespace;

  T get reference;

  static BlockchainId parse(String blockchainId) {
    final parts = blockchainId.split(':');
    if (parts.length != 2) throw Exception(_INVALID_BLOCKCHAIN_ID);
    return BlockchainIdFactoryProducer.getFactory(
            BlockchainNamespace.fromString(parts[0]))
        .fromString(parts[1]);
  }
}

class Eip155BlockchainId implements BlockchainId<Eip155Reference> {
  @override
  final BlockchainNamespace namespace = BlockchainNamespace.eip155;

  @override
  final Eip155Reference reference;

  Eip155BlockchainId(this.reference);

  @override
  String toString() {
    return '${namespace.toString()}:${reference.toString()}';
  }
}

class SolanaBlockchainId implements BlockchainId<SolanaReference> {
  @override
  final BlockchainNamespace namespace = BlockchainNamespace.solana;

  @override
  final SolanaReference reference;

  SolanaBlockchainId(this.reference);

  @override
  String toString() {
    return '${namespace.toString()}:${reference.toString()}';
  }
}

class Bip122BlockchainId implements BlockchainId<Bip122Reference> {
  @override
  final BlockchainNamespace namespace = BlockchainNamespace.bip122;

  @override
  final Bip122Reference reference;

  Bip122BlockchainId(this.reference);

  @override
  String toString() {
    return '${namespace.toString()}:${reference.toString()}';
  }
}

abstract class BlockchainIdFactory<T extends BlockchainReference> {
  BlockchainId<T> fromString(String reference);
}

class SolanaBlockchainIdFactory
    implements BlockchainIdFactory<SolanaReference> {
  @override
  SolanaBlockchainId fromString(String reference) {
    return SolanaBlockchainId(SolanaReference.fromString(reference));
  }
}

class Eip155BlockchainIdFactory
    implements BlockchainIdFactory<Eip155Reference> {
  @override
  Eip155BlockchainId fromString(String reference) {
    return Eip155BlockchainId(Eip155Reference.fromString(reference));
  }
}

class Bip122BlockchainIdFactory
    implements BlockchainIdFactory<Bip122Reference> {
  @override
  Bip122BlockchainId fromString(String reference) {
    return Bip122BlockchainId(Bip122Reference.fromString(reference));
  }
}

class BlockchainIdFactoryProducer {
  static BlockchainIdFactory getFactory(BlockchainNamespace namespace) {
    switch (namespace) {
      case BlockchainNamespace.eip155:
        return Eip155BlockchainIdFactory();
      case BlockchainNamespace.solana:
        return SolanaBlockchainIdFactory();
      case BlockchainNamespace.bip122:
        return Bip122BlockchainIdFactory();
      default:
        throw Exception('Invalid Blockchain Namespace');
    }
  }
}
