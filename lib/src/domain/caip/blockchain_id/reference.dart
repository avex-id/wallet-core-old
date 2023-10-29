import 'package:wallet_core/src/domain/caip/blockchain_id/namespace.dart';

import 'blockchain_reference/bip122_reference.dart';
import 'blockchain_reference/eip155_reference.dart';
import 'blockchain_reference/solana_reference.dart';

abstract class BlockchainReference {
  String get asString;
}

mixin BlockchainReferenceMixin {
  static BlockchainReference fromString(
      BlockchainNamespace namespace, String reference) {
    switch (namespace) {
      case BlockchainNamespace.eip155:
        return Eip155BlockchainReference._(
            Eip155ReferenceExtension.fromString(reference));
      case BlockchainNamespace.solana:
        return SolanaBlockchainReference._(
            SolanaReferenceExtension.fromString(reference));
      case BlockchainNamespace.bip122:
        return Bip122BlockchainReference._(
            Bip122ReferenceExtension.fromString(reference));
    }
  }
}

class SolanaBlockchainReference extends BlockchainReference
    with BlockchainReferenceMixin {
  SolanaBlockchainReference._(this._value);

  final SolanaReference _value;

  @override
  String get asString => _value.asString;
}

class Bip122BlockchainReference extends BlockchainReference
    with BlockchainReferenceMixin {
  Bip122BlockchainReference._(this._value);

  final Bip122Reference _value;

  @override
  String get asString => _value.asString;
}

class Eip155BlockchainReference extends BlockchainReference
    with BlockchainReferenceMixin {
  Eip155BlockchainReference._(this._value);

  final Eip155Reference _value;

  @override
  String get asString => _value.asString;
}
