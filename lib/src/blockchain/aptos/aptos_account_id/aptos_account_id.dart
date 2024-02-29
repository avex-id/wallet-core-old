import 'package:aptos/aptos_types/account_address.dart';

import '../../../domain/common/caip/blockchain_account_id/blockchain_account_id.dart';
import '../aptos_blockchain_id/aptos_blockchain_id.dart';
import '../aptos_blockchain_id/aptos_blockchain_reference.dart';

class AptosBlockchainAccountId
    implements BlockchainAccountId<AptosBlockchainId, AccountAddress> {
  @override
  final AptosBlockchainId blockchainId;

  @override
  final AccountAddress accountAddress;

  AptosBlockchainAccountId(AptosReference reference, this.accountAddress)
      : blockchainId = AptosBlockchainId(reference);

  @override
  String get address => accountAddress.hexAddress();

  @override
  String toString() {
    return "${blockchainId.toString()}:$address";
  }
}

class AptosBlockchainAccountIdFactory
    implements BlockchainAccountIdFactory<AptosBlockchainId, AccountAddress> {
  final AptosBlockchainId blockchainId;

  AptosBlockchainAccountIdFactory(AptosReference reference)
      : blockchainId = AptosBlockchainId(reference);

  @override
  AptosBlockchainAccountId fromString(String accountAddress) {
    return AptosBlockchainAccountId(
        blockchainId.reference, AccountAddress.fromHex(accountAddress));
  }
}
