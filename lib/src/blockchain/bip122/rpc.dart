import '../../api/mempool/api.dart';
import '../../model/rpc.dart';

class Bip122Rpc extends RpcWrapper {
  Future<List<int>> getFeeRates() async {
    RecommendedFees feeRate = await fetchRecommendedFees();
    return [feeRate.economyFee, feeRate.hourFee, feeRate.halfHourFee];
  }

  Future<String> broadcastTransaction(String signedTransactionHex) async {
    return (await postTransactionHex(signedTransactionHex)).txid;
  }
}
