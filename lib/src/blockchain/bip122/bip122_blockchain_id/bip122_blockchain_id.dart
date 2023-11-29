import '../../../types/common/caip/blockchain_id/blockchain_id.dart';
import '../../../types/common/caip/blockchain_id/blockchain_namespace.dart';
import 'bip122_blockchain_reference.dart';

class Bip122BlockchainId implements BlockchainId<Bip122Reference> {
  @override
  final BlockchainNamespace namespace = BlockchainNamespace.bip122;

  @override
  final Bip122Reference reference;

  Bip122BlockchainId(this.reference);

  @override
  String toString() {
    return '${namespace.toString()}:${reference.toString()}';
  }
}

class Bip122BlockchainIdFactory
    implements BlockchainIdFactory<Bip122Reference> {
  @override
  Bip122BlockchainId fromString(String reference) {
    return Bip122BlockchainId(Bip122Reference.fromString(reference));
  }
}
