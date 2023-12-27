import 'package:web3dart/web3dart.dart';

import '../../../domain/common/caip/blockchain_account_id/blockchain_account_id.dart';
import '../eip155_blockchain_id/eip155_blockchain_id.dart';
import '../eip155_blockchain_id/eip155_blockchain_reference.dart';

class Eip155BlockchainAccountId
    implements BlockchainAccountId<Eip155BlockchainId, EthereumAddress> {
  @override
  final Eip155BlockchainId blockchainId;

  @override
  final EthereumAddress accountAddress;

  Eip155BlockchainAccountId(Eip155Reference reference, this.accountAddress)
      : blockchainId = Eip155BlockchainId(reference);

  @override
  String get address => accountAddress.hexEip55;

  @override
  String toString() {
    return "${blockchainId.toString()}:$address";
  }
}

class Eip155BlockchainAccountIdFactory
    implements BlockchainAccountIdFactory<Eip155BlockchainId, EthereumAddress> {
  final Eip155BlockchainId blockchainId;

  Eip155BlockchainAccountIdFactory(Eip155Reference reference)
      : blockchainId = Eip155BlockchainId(reference);

  @override
  Eip155BlockchainAccountId fromString(String accountAddress) {
    return Eip155BlockchainAccountId(blockchainId.reference,
        EthereumAddress.fromHex(accountAddress, enforceEip55: true));
  }
}
