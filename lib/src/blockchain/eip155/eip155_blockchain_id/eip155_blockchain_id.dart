import '../../../domain/common/caip/blockchain_id/blockchain_id.dart';
import '../../../domain/common/caip/blockchain_id/blockchain_namespace.dart';
import 'eip155_blockchain_reference.dart';

class Eip155BlockchainId implements BlockchainId<Eip155Reference> {
  @override
  final BlockchainNamespace namespace = BlockchainNamespace.eip155;

  @override
  final Eip155Reference reference;

  Eip155BlockchainId(this.reference);

  @override
  String toString() {
    return '${namespace.toString()}:${reference.toString()}';
  }
}

class Eip155BlockchainIdFactory
    implements BlockchainIdFactory<Eip155Reference> {
  @override
  Eip155BlockchainId fromString(String reference) {
    return Eip155BlockchainId(Eip155Reference.fromString(reference));
  }
}
