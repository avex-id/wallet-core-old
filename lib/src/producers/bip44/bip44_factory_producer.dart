import '../../blockchain/bip122/bip122_blockchain_id/bip122_blockchain_reference.dart';
import '../../blockchain/bip122/bip44/bip44.dart';
import '../../blockchain/eip155/bip44/bip44.dart';
import '../../blockchain/eip155/eip155_blockchain_id/eip155_blockchain_reference.dart';
import '../../blockchain/solana/bip44/bip44.dart';
import '../../blockchain/solana/solana_blockchain_id/solana_blockchain_reference.dart';
import '../../domain/common/bip_44/bip_44.dart';
import '../../domain/common/caip/blockchain_id/blockchain_reference.dart';

class DerivationPathFactoryProducer {
  static DerivationPathFactory getFactory(BlockchainReference reference) {
    if (reference is Eip155Reference) {
      return Eip155DerivationPathFactory(reference);
    } else if (reference is Bip122Reference) {
      return Bip122DerivationPathFactory(reference);
    } else if (reference is SolanaReference) {
      return SolanaDerivationPathFactory(reference);
    } else {
      throw Exception("Unknown blockchain reference: ${reference.toString()}");
    }
  }
}
