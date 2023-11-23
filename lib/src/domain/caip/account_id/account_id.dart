import 'package:coinlib/coinlib.dart';
import 'package:solana/solana.dart';
import 'package:web3dart/web3dart.dart';

import '../blockchain_id/blockchain_reference/bip122_reference.dart';
import '../blockchain_id/blockchain_reference/eip155_reference.dart';
import '../blockchain_id/blockchain_reference/solana_reference.dart';
import '../blockchain_id/blockchain_id.dart';
import '../blockchain_id/namespace.dart';
import '../blockchain_id/reference.dart';

abstract class BlockchainAccountId<T extends BlockchainId, U> {
  static const String _INVALID_BLOCKCHAIN_ACCOUNT_ID = 'Invalid Blockchain Id';

  T get blockchainId;

  U get accountAddress;

  String get address;

  static BlockchainAccountId parse(String blockchainAccountId) {
    List<String> parts = blockchainAccountId.split(":");
    if (parts.length != 3) throw Exception(_INVALID_BLOCKCHAIN_ACCOUNT_ID);
    BlockchainId<BlockchainReference> blockchainId =
        BlockchainIdFactoryProducer.getFactory(
                BlockchainNamespace.fromString(parts[0]))
            .fromString(parts[1]);
    return BlockchainAccountIdFactoryProducer.getFactory(blockchainId.reference)
        .fromString(parts[2]);
  }
}

class SolanaBlockchainAccountId
    implements BlockchainAccountId<SolanaBlockchainId, Ed25519HDPublicKey> {
  final SolanaReference reference;

  @override
  SolanaBlockchainId get blockchainId => SolanaBlockchainId(reference);

  @override
  final Ed25519HDPublicKey accountAddress;

  SolanaBlockchainAccountId(this.reference, this.accountAddress);

  @override
  String get address => accountAddress.toBase58();

  @override
  String toString() {
    return "${blockchainId.toString()}:$address";
  }
}

class Eip155BlockchainAccountId
    implements BlockchainAccountId<Eip155BlockchainId, EthereumAddress> {
  final Eip155Reference reference;

  @override
  Eip155BlockchainId get blockchainId => Eip155BlockchainId(reference);

  @override
  final EthereumAddress accountAddress;

  Eip155BlockchainAccountId(this.reference, this.accountAddress);

  @override
  String get address => accountAddress.hexEip55;

  @override
  String toString() {
    return "${blockchainId.toString()}:$address";
  }
}

class Bip122BlockchainAccountId
    implements BlockchainAccountId<Bip122BlockchainId, Address> {
  final Bip122Reference reference;

  @override
  Bip122BlockchainId get blockchainId => Bip122BlockchainId(reference);

  @override
  final Address accountAddress;

  Bip122BlockchainAccountId(this.reference, this.accountAddress);

  @override
  String get address => accountAddress.toString();

  @override
  String toString() {
    return "${blockchainId.toString()}:$address";
  }
}

abstract class BlockchainAccountIdFactory<T extends BlockchainId, U> {
  T get blockchainId;

  BlockchainAccountId<T, U> fromString(String accountAddress);
}

class SolanaBlockchainAccountIdFactory
    implements
        BlockchainAccountIdFactory<SolanaBlockchainId, Ed25519HDPublicKey> {
  final SolanaReference reference;

  @override
  SolanaBlockchainId get blockchainId => SolanaBlockchainId(reference);

  SolanaBlockchainAccountIdFactory(this.reference);

  @override
  SolanaBlockchainAccountId fromString(String accountAddress) {
    return SolanaBlockchainAccountId(
        blockchainId.reference, Ed25519HDPublicKey.fromBase58(accountAddress));
  }
}

class Eip155BlockchainAccountIdFactory
    implements BlockchainAccountIdFactory<Eip155BlockchainId, EthereumAddress> {
  final Eip155Reference reference;

  @override
  Eip155BlockchainId get blockchainId => Eip155BlockchainId(reference);

  Eip155BlockchainAccountIdFactory(this.reference);

  @override
  Eip155BlockchainAccountId fromString(String accountAddress) {
    return Eip155BlockchainAccountId(blockchainId.reference,
        EthereumAddress.fromHex(accountAddress, enforceEip55: true));
  }
}

class Bip122BlockchainAccountIdFactory
    implements BlockchainAccountIdFactory<Bip122BlockchainId, Address> {
  final Bip122Reference reference;

  @override
  Bip122BlockchainId get blockchainId => Bip122BlockchainId(reference);

  Bip122BlockchainAccountIdFactory(this.reference);

  @override
  Bip122BlockchainAccountId fromString(String accountAddress) {
    return Bip122BlockchainAccountId(
        blockchainId.reference,
        Address.fromString(
            accountAddress, blockchainId.reference.networkParams));
  }
}

class BlockchainAccountIdFactoryProducer {
  static BlockchainAccountIdFactory getFactory(BlockchainReference reference) {
    if (reference is SolanaReference) {
      return SolanaBlockchainAccountIdFactory(reference);
    } else if (reference is Eip155Reference) {
      return Eip155BlockchainAccountIdFactory(reference);
    } else if (reference is Bip122Reference) {
      return Bip122BlockchainAccountIdFactory(reference);
    } else {
      throw Exception(BlockchainAccountId._INVALID_BLOCKCHAIN_ACCOUNT_ID);
    }
  }
}
