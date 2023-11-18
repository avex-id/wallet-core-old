import '../caip/blockchain_id/blockchain_reference/eip155_reference.dart';
import '../caip/blockchain_id/blockchain_reference/solana_reference.dart';
import '../caip/blockchain_id/blockchain_reference/bip122_reference.dart';
import '../caip/blockchain_id/blockchain_id.dart';
import '../caip/blockchain_id/namespace.dart';

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

  @override
  final Eip155BlockchainId blockchainId;

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

  Eip155DerivationPath(this.blockchainId,
      {this.account = _ACCOUNT,
      this.change = _CHANGE,
      required this.addressIndex});

  @override
  String get path => "m/$purpose'/$coinType'/$account'/$change/$addressIndex";
}

class Bip122DerivationPath implements DerivationPath<Bip122BlockchainId> {
  static const int _ACCOUNT = 0;
  static const int _CHANGE = 0;

  @override
  final Bip122BlockchainId blockchainId;

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

  Bip122DerivationPath(this.blockchainId,
      {this.account = _ACCOUNT,
      this.change = _CHANGE,
      required this.addressIndex});

  @override
  String get path => "m/$purpose'/$coinType'/$account'/$change/$addressIndex";
}

class SolanaDerivationPath implements DerivationPath<SolanaBlockchainId> {
  static const int _ACCOUNT = 0;
  static const int _CHANGE = 0;

  @override
  final SolanaBlockchainId blockchainId;

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

  SolanaDerivationPath(this.blockchainId,
      {this.account = _ACCOUNT, this.change = _CHANGE});

  @override
  String get path => "m/$purpose'/$coinType'/$account'/$change'";
}

abstract class DerivationPathFactory<T extends BlockchainId> {
  final T blockchainId;

  DerivationPathFactory(this.blockchainId);

  DerivationPath<T> getAddressAtPath({
    int account = 0,
    int change = 0,
    required int addressIndex,
  });
}

class Eip155DerivationPathFactory
    implements DerivationPathFactory<Eip155BlockchainId> {
  @override
  final Eip155BlockchainId blockchainId;

  Eip155DerivationPathFactory(this.blockchainId);

  @override
  DerivationPath<Eip155BlockchainId> getAddressAtPath(
      {int account = 0, int change = 0, required int addressIndex}) {
    return Eip155DerivationPath(
      blockchainId,
      account: account,
      change: change,
      addressIndex: addressIndex,
    );
  }
}

class Bip122DerivationPathFactory
    implements DerivationPathFactory<Bip122BlockchainId> {
  @override
  final Bip122BlockchainId blockchainId;

  Bip122DerivationPathFactory(this.blockchainId);

  @override
  DerivationPath<Bip122BlockchainId> getAddressAtPath(
      {int account = 0, int change = 0, required int addressIndex}) {
    return Bip122DerivationPath(
      blockchainId,
      account: account,
      change: change,
      addressIndex: addressIndex,
    );
  }
}

class SolanaDerivationPathFactory
    implements DerivationPathFactory<SolanaBlockchainId> {
  @override
  final SolanaBlockchainId blockchainId;

  SolanaDerivationPathFactory(this.blockchainId);

  @override
  DerivationPath<SolanaBlockchainId> getAddressAtPath(
      {int account = 0, int change = 0, required int addressIndex}) {
    return SolanaDerivationPath(
      blockchainId,
      account: addressIndex,
      change: change,
    );
  }
}

class DerivationPathFactoryProducer {
  static DerivationPathFactory getFactory(BlockchainId blockchainId) {
    switch (blockchainId.namespace) {
      case BlockchainNamespace.eip155:
        return Eip155DerivationPathFactory(blockchainId as Eip155BlockchainId);
      case BlockchainNamespace.bip122:
        return Bip122DerivationPathFactory(blockchainId as Bip122BlockchainId);
      case BlockchainNamespace.solana:
        return SolanaDerivationPathFactory(blockchainId as SolanaBlockchainId);
      default:
        throw Exception("Unknown Blockchain Namespace: $blockchainId");
    }
  }
}
