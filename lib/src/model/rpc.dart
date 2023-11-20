import '../blockchain/bip122/rpc.dart';
import '../blockchain/eip155/rpc.dart';
import '../blockchain/solana/rpc.dart';
import '../domain/caip/blockchain_id/blockchain_id.dart';
import '../domain/caip/blockchain_id/namespace.dart';

abstract class RpcWrapper {
  Future<String> broadcastTransaction({required String transactionHex});
}

mixin RpcWrapperMixin {
  static RpcWrapper fromBlockchainId(BlockchainId blockchainId) {
    final url = "https://mainnet.infura.io/v3/";
    switch (blockchainId.namespace) {
      case BlockchainNamespace.eip155:
        return Eip155Rpc.fromUrl(url);
      case BlockchainNamespace.solana:
        return SolanaRpc.fromUrl(url);
      case BlockchainNamespace.bip122:
        return Bip122Rpc();
      default:
        throw Exception('Invalid Blockchain Namespace');
    }
  }
}
