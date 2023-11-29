import '../../blockchain/bip122/bip122_blockchain_id/bip122_blockchain_id.dart';
import '../../blockchain/eip155/eip155_blockchain_id/eip155_blockchain_id.dart';
import '../../blockchain/solana/solana_blockchain_id/solana_blockchain_id.dart';
import '../../types/common/caip/blockchain_id/blockchain_id.dart';
import '../../types/common/caip/blockchain_id/blockchain_namespace.dart';

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
        throw Exception('Invalid blockchain namespace');
    }
  }
}
