import 'package:web3dart/web3dart.dart';
import 'files.dart';

Future<DeployedContract> loadContract(
    String contractAbi, String contractName, String contractAddress) async {
  return DeployedContract(ContractAbi.fromJson(contractAbi, contractName),
      EthereumAddress.fromHex(contractAddress));
}

Future<DeployedContract> loadErc20Contract(EthereumAddress tokenAddress) async {
  return loadContract(await getErc20Abi(), "ERC20", tokenAddress.hex);
}

Future<DeployedContract> loadErc721Contract(
    EthereumAddress tokenAddress) async {
  return loadContract(await getErc721Abi(), "ERC721", tokenAddress.hex);
}

Future<DeployedContract> loadErc1155Contract(
    EthereumAddress tokenAddress) async {
  return loadContract(await getErc1155Abi(), "ERC1155", tokenAddress.hex);
}
