import 'dart:typed_data';
import 'package:eip1559/eip1559.dart';
import 'package:http/http.dart';
import 'package:wallet_core/src/model/rpc.dart';
import 'package:web3dart/web3dart.dart';

class Eip155Rpc extends RpcWrapper {
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

  Future<List<dynamic>> readContract(DeployedContract contract,
          String functionName, List<dynamic> args) async =>
      client.call(
          contract: contract,
          function: contract.function(functionName),
          params: args);

  Future<String> sendRawTransaction(Uint8List signedTransaction) async =>
      client.sendRawTransaction(signedTransaction);
}

class Erc20Eip155Rpc extends Eip155Rpc {
  final DeployedContract contract;
  Erc20Eip155Rpc(Web3Client client, this.contract) : super(client);

  Future<BigInt> getAllowance(
      EthereumAddress owner, EthereumAddress spender) async {
    return client.call(
        contract: contract,
        function: contract.function('allowance'),
        params: [owner, spender]).then((value) => value.first);
  }

  Future<BigInt> getTokenBalance(
    EthereumAddress owner,
  ) {
    return readContract(contract, 'balanceOf', [owner])
        .then((value) => value.first);
  }
}

class Erc721Eip155Rpc extends Eip155Rpc {
  final DeployedContract contract;
  Erc721Eip155Rpc(Web3Client client, this.contract) : super(client);

  Future<List<EthereumAddress>> getApproval(
      EthereumAddress owner, BigInt tokenId) async {
    return readContract(contract, 'getApprove', [tokenId])
        .then((value) => value.map((e) => EthereumAddress(e)).toList());
  }

  Future<BigInt> getTokenBalance(
    EthereumAddress owner,
  ) {
    return readContract(contract, 'balanceOf', [owner])
        .then((value) => value.first);
  }

  Future<EthereumAddress> getOwnerOf(BigInt tokenId) async {
    return readContract(contract, 'ownerOf', [tokenId])
        .then((value) => EthereumAddress(value.first));
  }

  Future<bool> isApprovedForAll(
      EthereumAddress owner, EthereumAddress operator) {
    return readContract(contract, 'isApprovedForAll', [owner, operator])
        .then((value) => value.first);
  }
}

class Erc1155Eip155Rpc extends Eip155Rpc {
  final DeployedContract contract;
  Erc1155Eip155Rpc(Web3Client client, this.contract) : super(client);

  Future<BigInt> getTokenBalance(
    EthereumAddress owner,
    BigInt tokenId,
  ) {
    return readContract(contract, 'balanceOf', [owner, tokenId])
        .then((value) => value.first);
  }

  Future<List<BigInt>> getTokenBalances(
    EthereumAddress owner,
    List<BigInt> tokenIds,
  ) {
    return readContract(contract, 'balanceOfBatch', [owner, tokenIds])
        .then((value) => value.map((e) => e as BigInt).toList());
  }

  Future<bool> isApprovedForAll(
      EthereumAddress owner, EthereumAddress operator) {
    return readContract(
      contract,
      'isApprovedForAll',
      [owner, operator],
    ).then((value) => value.first);
  }
}
