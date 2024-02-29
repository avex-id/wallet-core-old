import '../../../domain/common/caip/blockchain_id/blockchain_id.dart';
import '../../../domain/common/caip/blockchain_id/blockchain_namespace.dart';
import 'aptos_blockchain_reference.dart';

class AptosBlockchainId implements BlockchainId<AptosReference> {
  @override
  final BlockchainNamespace namespace = BlockchainNamespace.aptos;

  @override
  final AptosReference reference;

  AptosBlockchainId(this.reference);

  @override
  String toString() {
    return '${namespace.toString()}:${reference.toString()}';
  }
}

class AptosBlockchainIdFactory implements BlockchainIdFactory<AptosReference> {
  @override
  AptosBlockchainId fromString(String reference) {
    return AptosBlockchainId(AptosReference.fromString(reference));
  }
}
