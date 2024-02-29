import '../../../domain/common/caip/blockchain_id/blockchain_namespace.dart';
import '../../../domain/common/bip_44/bip_44.dart';
import '../aptos_blockchain_id/aptos_blockchain_id.dart';
import '../aptos_blockchain_id/aptos_blockchain_reference.dart';

class AptosDerivationPath implements DerivationPath<AptosBlockchainId> {
  static const int _ADDRESS_INDEX = 0;
  static const int _CHANGE = 0;

  @override
  final AptosBlockchainId blockchainId;

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

  AptosDerivationPath(AptosReference reference,
      {required this.account,
      this.change = _CHANGE,
      this.addressIndex = _ADDRESS_INDEX})
      : blockchainId = AptosBlockchainId(reference);

  @override
  String get path => "m/$purpose'/$coinType'/$account'/$change'/$addressIndex'";
}

class AptosDerivationPathFactory
    implements DerivationPathFactory<AptosBlockchainId> {
  final AptosBlockchainId blockchainId;

  AptosDerivationPathFactory(AptosReference reference)
      : blockchainId = AptosBlockchainId(reference);

  @override
  DerivationPath<AptosBlockchainId> getAddressAtPath({required int index}) {
    return AptosDerivationPath(
      blockchainId.reference,
      account: index,
    );
  }
}
