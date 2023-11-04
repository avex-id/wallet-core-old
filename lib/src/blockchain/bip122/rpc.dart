import '../../api/mempool/api.dart';
import '../../model/rpc.dart';

class Bip122Rpc extends RpcWrapper {
  Future<List<int>> getFeeRates() async {
    RecommendedFees feeRate = await fetchRecommendedFees();
    return [
      feeRate.economyFee,
      feeRate.hourFee,
      feeRate.halfHourFee,
      feeRate.fastestFee
    ];
  }

  Future<String> broadcastTransaction(String transactionHex) async {
    return (await postTransactionHex(transactionHex)).txid;
  }
}
