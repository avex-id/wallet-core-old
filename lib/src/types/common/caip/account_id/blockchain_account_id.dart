import '../blockchain_id/blockchain_id.dart';
import '../blockchain_id/blockchain_namespace.dart';
import '../blockchain_id/blockchain_reference.dart';
import '../../../../producers/caip/blockchain_account_id_factory_producer.dart';
import '../../../../producers/caip/blockchain_id_factory_producer.dart';

abstract class BlockchainAccountId<T extends BlockchainId, U> {
  static const String _INVALID_BLOCKCHAIN_ACCOUNT_ID =
      'Invalid blockchain account id';

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

abstract class BlockchainAccountIdFactory<T extends BlockchainId, U> {
  BlockchainAccountId<T, U> fromString(String accountAddress);
}
