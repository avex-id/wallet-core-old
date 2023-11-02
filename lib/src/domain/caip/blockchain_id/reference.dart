import 'namespace.dart';
import 'blockchain_reference/bip122_reference.dart';
import 'blockchain_reference/eip155_reference.dart';
import 'blockchain_reference/solana_reference.dart';

abstract class BlockchainReference {
  int get coinType;

  @override
  String toString();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BlockchainReference &&
          runtimeType == other.runtimeType &&
          toString() == other.toString();
}

mixin BlockchainReferenceMixin {
  static BlockchainReference fromString(
      BlockchainNamespace namespace, String reference) {
    switch (namespace) {
      case BlockchainNamespace.eip155:
        return Eip155ReferenceWrapper.fromString(reference);
      case BlockchainNamespace.solana:
        return SolanaReferenceWrapper.fromString(reference);
      case BlockchainNamespace.bip122:
        return Bip122ReferenceWrapper.fromString(reference);
    }
  }
}

class SolanaReferenceWrapper extends BlockchainReference {
  final SolanaReference value;

  SolanaReferenceWrapper(this.value);

  SolanaReferenceWrapper.fromString(String reference)
      : value = SolanaReferenceExtension.fromString(reference);

  @override
  int get coinType => value.coinType;

  @override
  String toString() => value.asString;
}

class Bip122ReferenceWrapper extends BlockchainReference {
  final Bip122Reference value;

  Bip122ReferenceWrapper(this.value);

  Bip122ReferenceWrapper.fromString(String reference)
      : value = Bip122ReferenceExtension.fromString(reference);

  @override
  int get coinType => value.coinType;

  @override
  String toString() => value.asString;
}

class Eip155ReferenceWrapper extends BlockchainReference {
  final Eip155Reference value;

  Eip155ReferenceWrapper(this.value);

  Eip155ReferenceWrapper.fromString(String reference)
      : value = Eip155ReferenceExtension.fromString(reference);

  @override
  int get coinType => value.coinType;

  @override
  String toString() => value.asString;
}
