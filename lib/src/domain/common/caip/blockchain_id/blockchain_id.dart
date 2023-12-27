import 'blockchain_namespace.dart';
import 'blockchain_reference.dart';
import '../../../../producers/caip/blockchain_id_factory_producer.dart';

abstract class BlockchainId<T extends BlockchainReference> {
  static const String _INVALID_BLOCKCHAIN_ID = 'Invalid blockchain id';

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

abstract class BlockchainIdFactory<T extends BlockchainReference> {
  BlockchainId<T> fromString(String reference);
}
