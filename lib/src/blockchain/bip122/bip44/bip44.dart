import '../../../domain/common/caip/blockchain_id/blockchain_namespace.dart';
import '../../../domain/common/bip_44/bip_44.dart';
import '../bip122_blockchain_id/bip122_blockchain_id.dart';
import '../bip122_blockchain_id/bip122_blockchain_reference.dart';

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

  Bip122DerivationPath(Bip122Reference reference,
      {this.account = _ACCOUNT,
      this.change = _CHANGE,
      required this.addressIndex})
      : blockchainId = Bip122BlockchainId(reference);

  @override
  String get path => "m/$purpose'/$coinType'/$account'/$change/$addressIndex";
}

class Bip122DerivationPathFactory
    implements DerivationPathFactory<Bip122BlockchainId> {
  final Bip122BlockchainId blockchainId;

  Bip122DerivationPathFactory(Bip122Reference reference)
      : blockchainId = Bip122BlockchainId(reference);

  @override
  DerivationPath<Bip122BlockchainId> getAddressAtPath({required int index}) {
    return Bip122DerivationPath(
      blockchainId.reference,
      addressIndex: index,
    );
  }
}
