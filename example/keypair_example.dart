// const accountAddress = "0xAe2011458cb51ab4c4dBE6139A5C94aA50E56F7F";
// const cryptoKitties =
//     "eip155:1/erc721:0x06012c8cf97BEaD5deAe237070F9587f8E7A266d/771769";
// Future<void> main() async {
//   await loadCoinlib();
//   BlockchainId<Eip155Reference> ethereum =
//       Eip155BlockchainId(Eip155Reference.ethereum);

// BlockchainId<Eip155Reference> ethereumTest =
// var ethereumTest = BlockchainId.fromString('eip155:1');
// var ether = BlockchainId.parse('eip155:1');
// print(ether);
// print(ethereumTest);
// print(ethereum.toString());
// print(ethereum.runtimeType);
// var ethereumAddress =
//     BlockchainAccountIdFactoryProducer.getFactory(ethereum.reference)
//         .fromString(accountAddress);

// var cryptoKittiesContract = BlockchainAssetTypeFactoryProducer.getFactory(
//         ethereum.reference, Eip155AssetNamespace.fromString('erc721'))
//     .fromString("0x06012c8cf97BEaD5deAe237070F9587f8E7A266d/771769");
// print(cryptoKittiesContract.toString());
// print(cryptoKittiesContract.assetNamespace.runtimeType);
// MnemonicManager manager = MnemonicManager();
// var seed = MnemonicManager.toSeed(
//     "early note outer elder gather attract material tourist runway fiber toy slender");
// print(seed);

// var test = KeyPairFactoryProducer.getFactory(ethereum)
//     .fromPrivateKey('privateKey' as ExtendedKey);
//   // KeyPair<EthereumAddress, ExtendedKey> key = await KeyPair.fromSeed(seed, ethereum, 0);
// print(ethereum.toString());
// var solana = BlockchainId.fromString('solana:mainnet');
// var bitcoin =
//     BlockchainId.fromString('bip122:000000000019d6689c085ae165831e93');
// var eip155Namespace = BlockchainNamespace.eip155;
// var ethereumReference = Eip155Reference.ethereum;
// BlockchainId<Eip155Reference> eip155BlockchainId =
//     BlockchainId(eip155Namespace, ethereumReference);
// print(eip155BlockchainId.toString());
// var ethereumKeyPair = await KeyPairMixin.fromSeed(seed, ethereum, 0);
// var solanaKeyPair = await KeyPairMixin.fromSeed(seed, solana, 0);
// var bitcoinKeyPair = await KeyPairMixin.fromSeed(seed, bitcoin, 0);

// print('Ethereum: ${ethereumKeyPair.publicKey}');
// print('Solana: ${solanaKeyPair.publicKey}');
// print('Bitcoin: ${bitcoinKeyPair.publicKey}');

// var rpcClient = Eip155Rpc.fromUrl("https://mainnet.infura.io/v3/");
// var erc20Contract = Erc20Eip155RpcHelper(rpcClient.client, contract);
// var allowance = await erc20Contract.getAllowance(to, from);
// var gasPrice = await rpcClient.getGasPrice();
// var nonce = await rpcClient.getNonce(from);
// if (allowance == BigInt.zero) {
//   var allowanceTx = Eip155Erc20TransactionHelper(contract).approve(to, from);
//   var maxGas = await rpcClient.estimateFee(allowanceTx.transaction);
//   allowanceTx
//     ..updateTransaction(maxGas.toInt(), gasPrice.getInWei, null, null, nonce);
//   var signature = allowanceTx.signRawTransaction(
//       ethereumKeyPair.privateKey, ethereumKeyPair.blockchainId.chainId);
//   rpcClient.sendRawTransaction(signature);
// }
// var nativeTransaction =
//     NativeEip155TransactionHelper.transfer(to, from, BigInt.from(1))
//       ..updateTransaction(1, BigInt.one, BigInt.one, BigInt.one, 12);
// var erc20ApprovalTransaction = Eip155Erc20TransactionHelper(contract)
//     .approve(to, from);
//     var upTx =
//     erc20ApprovalTransaction.updateTransaction(1, BigInt.two, BigInt.two, BigInt.two, 1);
// erc20ApprovalTransaction.
// erc20ApprovalTransaction.signRawTransaction(key, chainId)
// test.signRawTransaction(key, chainId)
//   var assetId = BlockchainAssetId.fromString(
//       "eip155:1/erc20:0x6b175474e89094c44da98b954eedeac495271d0f/0");
//   var accountId = BlockchainAccountId.fromString(
//       "eip155:1:0xab16a96D359eC26a11e2C2b3d8f8B8942d5Bfcdb");
//       print(accountId.runtimeType);
// }

import 'package:coinlib/coinlib.dart';
import 'package:wallet_core/wallet_core.dart';

const toBeSignedMessage = "Test";

Future<void> main() async {
  await loadCoinlib();
  final mnemonic = Mnemonic.generate();
  print("Generated mnemonic: $mnemonic\n");

  final secretShares = ShamirSecretManager(minimum: 2, shares: 3)
      .generate(secret: mnemonic.mnemonic);
  print("Generated secret shares:");
  for (var i = 0; i < secretShares.length; i++) {
    print("Share ${i + 1}: ${secretShares[i]}\n");
  }

  final ethereumKeyPair = await KeyPairFactoryProducer.getFactory(
          Eip155BlockchainId(Eip155Reference.ethereum))
      .fromSeed(mnemonic.toSeed, 0);
  print("Generated Ethereum key pair:");
  print("Public key: ${ethereumKeyPair.public}");
  print("Private key: ${ethereumKeyPair.private}");
  final ethSignedData = await ethereumKeyPair.signData(toBeSignedMessage);
  print("Signed Hash for message: $toBeSignedMessage: $ethSignedData\n");

  final solanaKeyPair = await KeyPairFactoryProducer.getFactory(
          SolanaBlockchainId(SolanaReference.solanaMainnet))
      .fromSeed(mnemonic.toSeed, 0);
  print("Generated Solana key pair:");
  print("Public key: ${solanaKeyPair.public}");
  print("Private key: ${solanaKeyPair.private}");
  final solSignedData = await solanaKeyPair.signData(toBeSignedMessage);
  print("Signed Hash for message: $toBeSignedMessage: $solSignedData\n");

  final bitcoinKeyPair = await KeyPairFactoryProducer.getFactory(
          Bip122BlockchainId(Bip122Reference.bitcoinMainnet))
      .fromSeed(mnemonic.toSeed, 0);
  print("Generated Bitcoin key pair:");
  print("Public key: ${bitcoinKeyPair.public}");
  print("Private key: ${bitcoinKeyPair.private}");
  final bitcoinSignedData = await bitcoinKeyPair.signData(toBeSignedMessage);
  print("Signed Hash for message: $toBeSignedMessage: $bitcoinSignedData\n");
}
