import 'account_address.dart';
import '../blockchain_id/blockchain_id.dart';

class BlockchainAccountId {
  final BlockchainId blockchainId;
  final BlockchainAccountAddress accountAddress;

  BlockchainAccountId(this.blockchainId, this.accountAddress);

  static BlockchainAccountId fromString(String accountId) {
    final parts = accountId.split(':');
    if (parts.length != 3) {
      throw Exception('Invalid account id');
    }
    final blockchainId = BlockchainId.fromString('${parts[0]}:${parts[1]}');
    final accountAddress =
        AccountAddressMixin.fromString(blockchainId, parts[2]);
    return BlockchainAccountId(blockchainId, accountAddress);
  }

  @override
  String toString() {
    return "${blockchainId.toString()}:${accountAddress.toString()}";
  }
}
