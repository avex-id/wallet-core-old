import '../../api/mempool/api.dart';
import '../../model/rpc.dart';

class Bip122Rpc implements RpcWrapper {
  Future<List<int>> getFeeRates() async {
    RecommendedFees feeRate = await fetchRecommendedFees();
    return [
      feeRate.economyFee,
      feeRate.hourFee,
      feeRate.halfHourFee,
      feeRate.fastestFee
    ];
  }

  Future<List<Utxo>> getUtxoList(String address) async {
    return await fetchUtxoList(address);
  }

  @override
  Future<String> broadcastTransaction({required String transactionHex}) async {
    return (await postTransactionHex(transactionHex)).txid;
  }
}
