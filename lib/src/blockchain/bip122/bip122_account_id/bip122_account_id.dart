import 'package:coinlib/coinlib.dart';

import '../../../domain/common/caip/blockchain_account_id/blockchain_account_id.dart';
import '../bip122_blockchain_id/bip122_blockchain_id.dart';
import '../bip122_blockchain_id/bip122_blockchain_reference.dart';

class Bip122BlockchainAccountId
    implements BlockchainAccountId<Bip122BlockchainId, Address> {
  @override
  final Bip122BlockchainId blockchainId;

  @override
  final Address accountAddress;

  Bip122BlockchainAccountId(Bip122Reference reference, this.accountAddress)
      : blockchainId = Bip122BlockchainId(reference);

  @override
  String get address => accountAddress.toString();

  @override
  String toString() {
    return "${blockchainId.toString()}:$address";
  }
}

class Bip122BlockchainAccountIdFactory
    implements BlockchainAccountIdFactory<Bip122BlockchainId, Address> {
  final Bip122BlockchainId blockchainId;

  Bip122BlockchainAccountIdFactory(Bip122Reference reference)
      : blockchainId = Bip122BlockchainId(reference);

  @override
  Bip122BlockchainAccountId fromString(String accountAddress) {
    return Bip122BlockchainAccountId(
        blockchainId.reference,
        Address.fromString(
            accountAddress, blockchainId.reference.networkParams));
  }
}
