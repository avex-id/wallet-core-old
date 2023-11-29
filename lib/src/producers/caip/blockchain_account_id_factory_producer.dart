import '../../blockchain/bip122/bip122_account_id/bip122_account_id.dart';
import '../../blockchain/bip122/bip122_blockchain_id/bip122_blockchain_reference.dart';
import '../../blockchain/eip155/eip155_account_id/eip155_account_id.dart';
import '../../blockchain/eip155/eip155_blockchain_id/eip155_blockchain_reference.dart';
import '../../blockchain/solana/solana_account_id/solana_account_id.dart';
import '../../blockchain/solana/solana_blockchain_id/solana_blockchain_reference.dart';
import '../../types/common/caip/account_id/blockchain_account_id.dart';
import '../../types/common/caip/blockchain_id/blockchain_reference.dart';

class BlockchainAccountIdFactoryProducer {
  static BlockchainAccountIdFactory getFactory(BlockchainReference reference) {
    if (reference is SolanaReference) {
      return SolanaBlockchainAccountIdFactory(reference);
    } else if (reference is Eip155Reference) {
      return Eip155BlockchainAccountIdFactory(reference);
    } else if (reference is Bip122Reference) {
      return Bip122BlockchainAccountIdFactory(reference);
    } else {
      throw Exception("Unknown blockchain reference");
    }
  }
}
