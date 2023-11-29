import '../../../types/common/caip/blockchain_id/blockchain_namespace.dart';
import '../../../types/common/bip_44/bip_44.dart';
import '../solana_blockchain_id/solana_blockchain_id.dart';
import '../solana_blockchain_id/solana_blockchain_reference.dart';

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

  SolanaDerivationPath(SolanaReference reference,
      {this.account = _ACCOUNT, this.change = _CHANGE})
      : blockchainId = SolanaBlockchainId(reference);

  @override
  String get path => "m/$purpose'/$coinType'/$account'/$change'";
}

class SolanaDerivationPathFactory
    implements DerivationPathFactory<SolanaBlockchainId> {
  final SolanaBlockchainId blockchainId;

  SolanaDerivationPathFactory(SolanaReference reference)
      : blockchainId = SolanaBlockchainId(reference);

  @override
  DerivationPath<SolanaBlockchainId> getAddressAtPath(
      {int account = 0, int change = 0, required int addressIndex}) {
    return SolanaDerivationPath(
      blockchainId.reference,
      account: addressIndex,
      change: change,
    );
  }
}
