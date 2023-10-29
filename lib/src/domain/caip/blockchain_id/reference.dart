import 'namespace.dart';
import 'blockchain_reference/bip122_reference.dart';
import 'blockchain_reference/eip155_reference.dart';
import 'blockchain_reference/solana_reference.dart';

abstract class BlockchainReference {
  @override
  String toString();
}

mixin BlockchainReferenceMixin {
  static BlockchainReference fromString(
      BlockchainNamespace namespace, String reference) {
    switch (namespace) {
      case BlockchainNamespace.eip155:
        return Eip155BlockchainReference.fromReference(reference);
      case BlockchainNamespace.solana:
        return SolanaBlockchainReference.fromReference(reference);
      case BlockchainNamespace.bip122:
        return Bip122BlockchainReference.fromReference(reference);
    }
  }
}

class SolanaBlockchainReference extends BlockchainReference {
  final SolanaReference value;

  SolanaBlockchainReference(this.value);

  factory SolanaBlockchainReference.fromReference(String reference) {
    return SolanaBlockchainReference(
        SolanaReferenceExtension.fromString(reference));
  }

  @override
  String toString() {
    return value.asString;
  }
}

class Bip122BlockchainReference extends BlockchainReference {
  final Bip122Reference value;

  Bip122BlockchainReference(this.value);

  factory Bip122BlockchainReference.fromReference(String reference) {
    return Bip122BlockchainReference(
        Bip122ReferenceExtension.fromString(reference));
  }

  @override
  String toString() {
    return value.asString;
  }
}

class Eip155BlockchainReference extends BlockchainReference {
  final Eip155Reference value;

  Eip155BlockchainReference(this.value);

  factory Eip155BlockchainReference.fromReference(String reference) {
    return Eip155BlockchainReference(
        Eip155ReferenceExtension.fromString(reference));
  }

  @override
  String toString() {
    return value.asString;
  }
}
