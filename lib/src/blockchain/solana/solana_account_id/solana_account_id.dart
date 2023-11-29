import 'package:solana/solana.dart';

import '../../../types/common/caip/account_id/blockchain_account_id.dart';
import '../solana_blockchain_id/solana_blockchain_id.dart';
import '../solana_blockchain_id/solana_blockchain_reference.dart';

class SolanaBlockchainAccountId
    implements BlockchainAccountId<SolanaBlockchainId, Ed25519HDPublicKey> {
  @override
  final SolanaBlockchainId blockchainId;

  @override
  final Ed25519HDPublicKey accountAddress;

  SolanaBlockchainAccountId(SolanaReference reference, this.accountAddress)
      : blockchainId = SolanaBlockchainId(reference);

  @override
  String get address => accountAddress.toBase58();

  @override
  String toString() {
    return "${blockchainId.toString()}:$address";
  }
}

class SolanaBlockchainAccountIdFactory
    implements
        BlockchainAccountIdFactory<SolanaBlockchainId, Ed25519HDPublicKey> {
  final SolanaBlockchainId blockchainId;

  SolanaBlockchainAccountIdFactory(SolanaReference reference)
      : blockchainId = SolanaBlockchainId(reference);

  @override
  SolanaBlockchainAccountId fromString(String accountAddress) {
    return SolanaBlockchainAccountId(
        blockchainId.reference, Ed25519HDPublicKey.fromBase58(accountAddress));
  }
}
