import '../../../domain/common/caip/blockchain_id/blockchain_id.dart';
import '../../../domain/common/caip/blockchain_id/blockchain_namespace.dart';
import 'solana_blockchain_reference.dart';

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

class SolanaBlockchainIdFactory
    implements BlockchainIdFactory<SolanaReference> {
  @override
  SolanaBlockchainId fromString(String reference) {
    return SolanaBlockchainId(SolanaReference.fromString(reference));
  }
}
