import 'package:coinlib/coinlib.dart';
import 'package:solana/solana.dart';
import 'package:web3dart/web3dart.dart';

import '../blockchain_id/blockchain_reference/bip122_reference.dart';
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
    return BlockchainAccountIdFactoryProducer.getFactory(blockchainId)
        .fromString(parts[2]);
  }
}

class SolanaBlockchainAccountId
    implements BlockchainAccountId<SolanaBlockchainId, Ed25519HDPublicKey> {
  @override
  final SolanaBlockchainId blockchainId;

  @override
  final Ed25519HDPublicKey accountAddress;

  SolanaBlockchainAccountId(this.blockchainId, this.accountAddress);

  @override
  String get address => accountAddress.toBase58();

  @override
  String toString() {
    return "${blockchainId.toString()}:$address";
  }
}

class Eip155BlockchainAccountId
    implements BlockchainAccountId<Eip155BlockchainId, EthereumAddress> {
  @override
  final Eip155BlockchainId blockchainId;
  @override
  final EthereumAddress accountAddress;

  Eip155BlockchainAccountId(this.blockchainId, this.accountAddress);

  @override
  String get address => accountAddress.hexEip55;

  @override
  String toString() {
    return "${blockchainId.toString()}:$address";
  }
}

class Bip122BlockchainAccountId
    implements BlockchainAccountId<Bip122BlockchainId, Address> {
  @override
  final Bip122BlockchainId blockchainId;
  @override
  final Address accountAddress;

  Bip122BlockchainAccountId(this.blockchainId, this.accountAddress);

  @override
  String get address => accountAddress.toString();

  @override
  String toString() {
    return "${blockchainId.toString()}:$address";
  }
}

abstract class BlockchainAccountIdFactory<T extends BlockchainId, U> {
  final T blockchainId;

  BlockchainAccountIdFactory(this.blockchainId);

  BlockchainAccountId<T, U> fromString(String accountAddress);
}

class SolanaBlockchainAccountIdFactory
    extends BlockchainAccountIdFactory<SolanaBlockchainId, Ed25519HDPublicKey> {
  SolanaBlockchainAccountIdFactory(SolanaBlockchainId blockchainId)
      : super(blockchainId);

  @override
  SolanaBlockchainAccountId fromString(String accountAddress) {
    return SolanaBlockchainAccountId(
        blockchainId, Ed25519HDPublicKey.fromBase58(accountAddress));
  }
}

class Eip155BlockchainAccountIdFactory
    extends BlockchainAccountIdFactory<Eip155BlockchainId, EthereumAddress> {
  Eip155BlockchainAccountIdFactory(Eip155BlockchainId blockchainId)
      : super(blockchainId);

  @override
  Eip155BlockchainAccountId fromString(String accountAddress) {
    return Eip155BlockchainAccountId(blockchainId,
        EthereumAddress.fromHex(accountAddress, enforceEip55: true));
  }
}

class Bip122BlockchainAccountIdFactory
    extends BlockchainAccountIdFactory<Bip122BlockchainId, Address> {
  Bip122BlockchainAccountIdFactory(Bip122BlockchainId blockchainId)
      : super(blockchainId);

  @override
  Bip122BlockchainAccountId fromString(String accountAddress) {
    return Bip122BlockchainAccountId(
        blockchainId,
        Address.fromString(
            accountAddress, blockchainId.reference.networkParams));
  }
}

class BlockchainAccountIdFactoryProducer {
  static BlockchainAccountIdFactory getFactory(BlockchainId blockchainId) {
    if (blockchainId is SolanaBlockchainId) {
      return SolanaBlockchainAccountIdFactory(blockchainId);
    } else if (blockchainId is Eip155BlockchainId) {
      return Eip155BlockchainAccountIdFactory(blockchainId);
    } else if (blockchainId is Bip122BlockchainId) {
      return Bip122BlockchainAccountIdFactory(blockchainId);
    } else {
      throw Exception(BlockchainAccountId._INVALID_BLOCKCHAIN_ACCOUNT_ID);
    }
  }
}
