import '../../../types/common/caip/blockchain_id/blockchain_namespace.dart';
import '../../../types/common/bip_44/bip_44.dart';
import '../eip155_blockchain_id/eip155_blockchain_id.dart';
import '../eip155_blockchain_id/eip155_blockchain_reference.dart';

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

  Eip155DerivationPath(Eip155Reference reference,
      {this.account = _ACCOUNT,
      this.change = _CHANGE,
      required this.addressIndex})
      : blockchainId = Eip155BlockchainId(reference);

  @override
  String get path => "m/$purpose'/$coinType'/$account'/$change/$addressIndex";
}

class Eip155DerivationPathFactory
    implements DerivationPathFactory<Eip155BlockchainId> {
  final Eip155BlockchainId blockchainId;

  Eip155DerivationPathFactory(Eip155Reference reference)
      : blockchainId = Eip155BlockchainId(reference);

  @override
  DerivationPath<Eip155BlockchainId> getAddressAtPath(
      {int account = 0, int change = 0, required int addressIndex}) {
    return Eip155DerivationPath(
      blockchainId.reference,
      account: account,
      change: change,
      addressIndex: addressIndex,
    );
  }
}
