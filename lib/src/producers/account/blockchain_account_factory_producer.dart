import '../../blockchain/bip122/bip122_account/bip122_account.dart';
import '../../blockchain/bip122/bip122_blockchain_id/bip122_blockchain_reference.dart';
import '../../blockchain/eip155/eip155_account/eip155_account.dart';
import '../../blockchain/eip155/eip155_blockchain_id/eip155_blockchain_reference.dart';
import '../../blockchain/solana/solana_account/solana_account.dart';
import '../../blockchain/solana/solana_blockchain_id/solana_blockchain_reference.dart';
import '../../domain/common/caip/blockchain_id/blockchain_reference.dart';
import '../../domain/common/blockchain_account/blockchain_account.dart';

class BlockchainAccountFactoryProducer {
  static BlockchainAccountFactory getFactory(BlockchainReference reference) {
    if (reference is Eip155Reference) {
      return Eip155BlockchainAccountFactory(reference);
    } else if (reference is SolanaReference) {
      return SolanaBlockchainAccountFactory(reference);
    } else if (reference is Bip122Reference) {
      return Bip122BlockchainAccountFactory(reference);
    } else {
      throw Exception('Invalid blockchain reference: ${reference.toString()}');
    }
  }
}

class KeyPairBlockchainAccountStrategyProducer {
  static KeyPairBlockchainAccountStrategyFactory getFactory(
      BlockchainReference reference) {
    if (reference is Eip155Reference) {
      return Eip155KeyPairBlockchainAccountStrategyFactory();
    } else if (reference is SolanaReference) {
      return SolanaKeyPairBlockchainAccountStrategyFactory();
    } else if (reference is Bip122Reference) {
      return Bip122KeyPairBlockchainAccountStrategyFactory();
    } else {
      throw Exception('Invalid blockchain reference: ${reference.toString()}');
    }
  }
}
