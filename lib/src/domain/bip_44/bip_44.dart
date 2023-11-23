import '../caip/blockchain_id/blockchain_reference/eip155_reference.dart';
import '../caip/blockchain_id/blockchain_reference/solana_reference.dart';
import '../caip/blockchain_id/blockchain_reference/bip122_reference.dart';
import '../caip/blockchain_id/blockchain_id.dart';
import '../caip/blockchain_id/namespace.dart';
import '../caip/blockchain_id/reference.dart';

abstract class DerivationPath<T extends BlockchainId> {
  T get blockchainId;
  int get purpose;
  int get coinType;
  int get account;
  int get change;
  int? get addressIndex;

  String get path;

  @override
  String toString() {
    return path;
  }
}

class Eip155DerivationPath implements DerivationPath<Eip155BlockchainId> {
  static const int _ACCOUNT = 0;
  static const int _CHANGE = 0;

  final Eip155Reference reference;

  @override
  Eip155BlockchainId get blockchainId => Eip155BlockchainId(reference);

  @override
  int get purpose => blockchainId.namespace.bip44Purpose;

  @override
  int get coinType => reference.bip44CoinType;

  @override
  final int account;

  @override
  final int change;

  @override
  final int addressIndex;

  Eip155DerivationPath(this.reference,
      {this.account = _ACCOUNT,
      this.change = _CHANGE,
      required this.addressIndex});

  @override
  String get path => "m/$purpose'/$coinType'/$account'/$change/$addressIndex";
}

class Bip122DerivationPath implements DerivationPath<Bip122BlockchainId> {
  static const int _ACCOUNT = 0;
  static const int _CHANGE = 0;

  final Bip122Reference reference;

  @override
  Bip122BlockchainId get blockchainId => Bip122BlockchainId(reference);

  @override
  int get purpose => blockchainId.namespace.bip44Purpose;

  @override
  int get coinType => blockchainId.reference.bip44CoinType;

  @override
  final int account;

  @override
  final int change;

  @override
  final int addressIndex;

  Bip122DerivationPath(this.reference,
      {this.account = _ACCOUNT,
      this.change = _CHANGE,
      required this.addressIndex});

  @override
  String get path => "m/$purpose'/$coinType'/$account'/$change/$addressIndex";
}

class SolanaDerivationPath implements DerivationPath<SolanaBlockchainId> {
  static const int _ACCOUNT = 0;
  static const int _CHANGE = 0;

  final SolanaReference reference;

  @override
  SolanaBlockchainId get blockchainId => SolanaBlockchainId(reference);

  @override
  int get purpose => blockchainId.namespace.bip44Purpose;

  @override
  int get coinType => blockchainId.reference.bip44CoinType;

  @override
  final int account;

  @override
  final int change;

  @override
  int? get addressIndex => null;

  SolanaDerivationPath(this.reference,
      {this.account = _ACCOUNT, this.change = _CHANGE});

  @override
  String get path => "m/$purpose'/$coinType'/$account'/$change'";
}

abstract class DerivationPathFactory<T extends BlockchainId> {
  T get blockchainId;

  DerivationPath<T> getAddressAtPath({
    int account = 0,
    int change = 0,
    required int addressIndex,
  });
}

class Eip155DerivationPathFactory
    implements DerivationPathFactory<Eip155BlockchainId> {
  final Eip155Reference reference;

  @override
  Eip155BlockchainId get blockchainId => Eip155BlockchainId(reference);

  Eip155DerivationPathFactory(this.reference);

  @override
  DerivationPath<Eip155BlockchainId> getAddressAtPath(
      {int account = 0, int change = 0, required int addressIndex}) {
    return Eip155DerivationPath(
      reference,
      account: account,
      change: change,
      addressIndex: addressIndex,
    );
  }
}

class Bip122DerivationPathFactory
    implements DerivationPathFactory<Bip122BlockchainId> {
  final Bip122Reference reference;

  @override
  Bip122BlockchainId get blockchainId => Bip122BlockchainId(reference);

  Bip122DerivationPathFactory(this.reference);

  @override
  DerivationPath<Bip122BlockchainId> getAddressAtPath(
      {int account = 0, int change = 0, required int addressIndex}) {
    return Bip122DerivationPath(
      reference,
      account: account,
      change: change,
      addressIndex: addressIndex,
    );
  }
}

class SolanaDerivationPathFactory
    implements DerivationPathFactory<SolanaBlockchainId> {
  final SolanaReference reference;

  @override
  SolanaBlockchainId get blockchainId => SolanaBlockchainId(reference);

  SolanaDerivationPathFactory(this.reference);

  @override
  DerivationPath<SolanaBlockchainId> getAddressAtPath(
      {int account = 0, int change = 0, required int addressIndex}) {
    return SolanaDerivationPath(
      reference,
      account: addressIndex,
      change: change,
    );
  }
}

class DerivationPathFactoryProducer {
  static DerivationPathFactory getFactory(BlockchainReference reference) {
    if (reference is Eip155Reference) {
      return Eip155DerivationPathFactory(reference);
    } else if (reference is Bip122Reference) {
      return Bip122DerivationPathFactory(reference);
    } else if (reference is SolanaReference) {
      return SolanaDerivationPathFactory(reference);
    } else {
      throw Exception("Unknown Blockchain Reference: ${reference.toString()}");
    }
  }
}
