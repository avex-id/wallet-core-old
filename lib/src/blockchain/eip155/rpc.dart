import 'package:eip1559/eip1559.dart';
import 'package:http/http.dart';
import 'package:wallet_core/src/model/rpc.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';

class Eip155Rpc implements RpcWrapper {
  final Web3Client client;

  Eip155Rpc(this.client);

  Eip155Rpc.fromUrl(String url) : this(Web3Client(url, Client()));

  Future<List<Fee>> getFee() async => client.getGasInEIP1559();

  Future<EtherAmount> getGasPrice() async => client.getGasPrice();

  Future<BigInt> estimateFee(Transaction transaction) async =>
      client.estimateGas(
          sender: transaction.from,
          to: transaction.to,
          value: transaction.value,
          data: transaction.data);

  Future<int> getNonce(EthereumAddress address) async =>
      client.getTransactionCount(address, atBlock: BlockNum.pending());

  Future<EtherAmount> getBalance(EthereumAddress address) async =>
      client.getBalance(address);

  Future<List<dynamic>> _readContract(DeployedContract contract,
          String functionName, List<dynamic> args) async =>
      client.call(
          contract: contract,
          function: contract.function(functionName),
          params: args);

  @override
  Future<String> broadcastTransaction({required String transactionHex}) async =>
      client.sendRawTransaction(hexToBytes(transactionHex));

  Future<BigInt> getErc20Allowance(DeployedContract contract,
      EthereumAddress owner, EthereumAddress spender) async {
    return client.call(
        contract: contract,
        function: contract.function('allowance'),
        params: [owner, spender]).then((value) => value.first);
  }

  Future<BigInt> getErc20TokenBalance(
    DeployedContract contract,
    EthereumAddress owner,
  ) {
    return _readContract(contract, 'balanceOf', [owner])
        .then((value) => value.first);
  }

  Future<List<EthereumAddress>> getErc721Approval(
      DeployedContract contract, EthereumAddress owner, BigInt tokenId) async {
    return _readContract(contract, 'getApprove', [tokenId])
        .then((value) => value.map((e) => EthereumAddress(e)).toList());
  }

  Future<BigInt> getErc721TokenBalance(
    DeployedContract contract,
    EthereumAddress owner,
  ) {
    return _readContract(contract, 'balanceOf', [owner])
        .then((value) => value.first);
  }

  Future<EthereumAddress> getErc721OwnerOf(
      DeployedContract contract, BigInt tokenId) async {
    return _readContract(contract, 'ownerOf', [tokenId])
        .then((value) => EthereumAddress(value.first));
  }

  Future<bool> isErc721ApprovedForAll(DeployedContract contract,
      EthereumAddress owner, EthereumAddress operator) {
    return _readContract(contract, 'isApprovedForAll', [owner, operator])
        .then((value) => value.first);
  }

  Future<BigInt> getErc1155TokenBalance(
    DeployedContract contract,
    EthereumAddress owner,
    BigInt tokenId,
  ) {
    return _readContract(contract, 'balanceOf', [owner, tokenId])
        .then((value) => value.first);
  }

  Future<List<BigInt>> getErc1155TokenBalances(
    DeployedContract contract,
    EthereumAddress owner,
    List<BigInt> tokenIds,
  ) {
    return _readContract(contract, 'balanceOfBatch', [owner, tokenIds])
        .then((value) => value.map((e) => e as BigInt).toList());
  }

  Future<bool> isErc1155ApprovedForAll(DeployedContract contract,
      EthereumAddress owner, EthereumAddress operator) {
    return _readContract(
      contract,
      'isApprovedForAll',
      [owner, operator],
    ).then((value) => value.first);
  }
}
