import 'package:wallet_core/src/domain/caip/blockchain_id/blockchain_id.dart';

class AccountId {
  final BlockchainId blockchainId;
  final String accountAddress;

  AccountId(this.blockchainId, this.accountAddress);

  static AccountId fromString(String accountId) {
    final parts = accountId.split(':');
    if (parts.length != 3) {
      throw Exception('Invalid account id');
    }
    final chainId = BlockchainId.fromString('${parts[0]}:${parts[1]}');
    final accountAddress = parts[2];
    // TODO: validate account address
    return AccountId(chainId, accountAddress);
  }

  @override
  String toString() {
    return "${blockchainId.toString()}:$accountAddress";
  }
}
