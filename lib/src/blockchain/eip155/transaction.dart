import 'dart:typed_data';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';

import '../../domain/caip/account_id/account_id.dart';
import '../../domain/caip/asset_id/asset_id.dart';
import '../../domain/caip/asset_id/asset_namespace/eip155_asset_namespace.dart';
import '../../domain/caip/asset_id/asset_type.dart';
import '../../model/transaction.dart';
import '../../utils/load_contract.dart';
import 'account.dart';
import 'rpc.dart';

abstract class Eip155TransactionWrapper
    implements
        TransactionWrapper<Transaction, Eip155KeyPair,
            Eip155BlockchainAccountId, Eip155BlockchainAssetType> {
  static const int _EIP1559_TRANSACTION_TYPE = 0x02;
  final Transaction transaction;

  @override
  final Eip155KeyPair keyPair;

  @override
  Transaction get innerRawTransaction => transaction;

  Eip155TransactionWrapper(this.transaction, this.keyPair);

  Eip155TransactionWrapper.transaction(EthereumAddress from, EthereumAddress to,
      BigInt value, Uint8List? data, Eip155KeyPair signer,
      {int? maxGas,
      BigInt? gasPrice,
      BigInt? maxFeePerGas,
      BigInt? maxPriorityFeePerGas,
      int? nonce})
      : this(
            _createTransaction(from, to, value, data, maxGas, gasPrice,
                maxFeePerGas, maxPriorityFeePerGas, nonce),
            signer);

  Eip155TransactionWrapper.contractTransaction(
      EthereumAddress from,
      DeployedContract contract,
      ContractFunction function,
      List<dynamic> params,
      BigInt? value,
      Eip155KeyPair signer,
      {int? maxGas,
      BigInt? gasPrice,
      BigInt? maxFeePerGas,
      BigInt? maxPriorityFeePerGas,
      int? nonce})
      : this(
            _createContractTransaction(from, contract, function, params, value,
                maxGas, gasPrice, maxFeePerGas, maxPriorityFeePerGas, nonce),
            signer);

  void updateTransaction(int? maxGas, BigInt? gasPrice, BigInt? maxFeePerGas,
      BigInt? maxPriorityFeePerGas, int? nonce) {
    transaction.copyWith(
        maxGas: maxGas,
        gasPrice: gasPrice != null
            ? EtherAmount.fromBigInt(EtherUnit.wei, gasPrice)
            : null,
        maxFeePerGas: maxFeePerGas != null
            ? EtherAmount.fromBigInt(EtherUnit.wei, maxFeePerGas)
            : null,
        maxPriorityFeePerGas: maxPriorityFeePerGas != null
            ? EtherAmount.fromBigInt(EtherUnit.wei, maxPriorityFeePerGas)
            : null,
        nonce: nonce);
  }

  static Transaction _createTransaction(
      EthereumAddress from,
      EthereumAddress to,
      BigInt value,
      Uint8List? data,
      int? maxGas,
      BigInt? gasPrice,
      BigInt? maxFeePerGas,
      BigInt? maxPriorityFeePerGas,
      int? nonce) {
    return Transaction(
        from: from,
        to: to,
        value: EtherAmount.fromBigInt(EtherUnit.wei, value),
        data: data ?? Uint8List(0),
        gasPrice: gasPrice != null
            ? EtherAmount.fromBigInt(EtherUnit.wei, gasPrice)
            : null,
        maxFeePerGas: maxFeePerGas != null
            ? EtherAmount.fromBigInt(EtherUnit.wei, maxFeePerGas)
            : null,
        maxPriorityFeePerGas: maxPriorityFeePerGas != null
            ? EtherAmount.fromBigInt(EtherUnit.wei, maxPriorityFeePerGas)
            : null,
        maxGas: maxGas,
        nonce: nonce);
  }

  static Transaction _createContractTransaction(
      EthereumAddress from,
      DeployedContract contract,
      ContractFunction function,
      List<dynamic> params,
      BigInt? value,
      int? maxGas,
      BigInt? gasPrice,
      BigInt? maxFeePerGas,
      BigInt? maxPriorityFeePerGas,
      int? nonce) {
    return _createTransaction(
        from,
        contract.address,
        value ?? BigInt.zero,
        function.encodeCall(params),
        maxGas,
        gasPrice,
        maxFeePerGas,
        maxPriorityFeePerGas,
        nonce);
  }

  BigInt calculateTransactionFee(
      BigInt? maxFeePerGas, BigInt? maxPriorityFeePerGas, BigInt? gasPrice) {
    if (transaction.maxGas == null) {
      return throw ArgumentError('maxGas must be set');
    }
    BigInt maxGas = BigInt.from(transaction.maxGas!);
    if (maxFeePerGas != null || maxPriorityFeePerGas != null) {
      return maxGas *
          ((maxFeePerGas ?? BigInt.zero) +
              (maxPriorityFeePerGas ?? BigInt.zero));
    } else if (gasPrice != null) {
      return maxGas * gasPrice;
    } else {
      throw ArgumentError(
          'Either maxFeePerGas or maxPriorityFeePerGas or gasPrice must be set');
    }
  }

  bool get isComplete =>
      transaction.maxGas != null &&
      transaction.nonce != null &&
      transaction.value != null &&
      transaction.data != null &&
      (transaction.gasPrice != null ||
          transaction.maxFeePerGas != null ||
          transaction.maxPriorityFeePerGas != null);

  Uint8List signRawTransaction() {
    Uint8List signedTransaction = signTransactionRaw(
        transaction, EthPrivateKey.fromHex(keyPair.privateKey.privateKeyHex()),
        chainId: int.parse(keyPair.blockchainId.reference.value));
    if (transaction.isEIP1559) {
      signedTransaction =
          prependTransactionType(_EIP1559_TRANSACTION_TYPE, signedTransaction);
    }
    return signedTransaction;
  }

  static String transactionHash(Uint8List transaction) {
    return bytesToHex(keccak256(transaction),
        include0x: true, padToEvenLength: true);
  }

  static String transactionHex(Uint8List transaction) {
    return bytesToHex(transaction, include0x: true, padToEvenLength: true);
  }
}

class NativeEip155Transaction extends Eip155TransactionWrapper {
  static const _NATIVE_ETHEREUM_ADDRESS =
      '0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE';

  @override
  final Eip155BlockchainAccountId from;

  @override
  final Eip155BlockchainAccountId to;

  @override
  Eip155BlockchainAssetType get assetType => Eip155BlockchainAssetType(
      from.blockchainId,
      Eip155AssetNamespace.slip44,
      EthereumAddress.fromHex(_NATIVE_ETHEREUM_ADDRESS));

  NativeEip155Transaction.transfer(
      this.from, this.to, BigInt value, Eip155KeyPair signer)
      : super.transaction(
            from.accountAddress, to.accountAddress, value, null, signer);
}

class Erc20Eip155Transaction extends Eip155TransactionWrapper {
  @override
  final Eip155BlockchainAccountId from;

  @override
  final Eip155BlockchainAccountId to;

  @override
  Eip155BlockchainAssetType get assetType => Eip155BlockchainAssetType(
      from.blockchainId,
      Eip155AssetNamespace.erc20,
      EthereumAddress.fromHex(contract.address.hex));

  final DeployedContract contract;

  Erc20Eip155Transaction.transfer(
      this.contract, this.from, this.to, BigInt value, Eip155KeyPair signer)
      : super.contractTransaction(
            from.accountAddress,
            contract,
            contract.function('transfer'),
            [to.accountAddress, value],
            null,
            signer);

  Erc20Eip155Transaction.approve(
      this.contract, this.from, this.to, BigInt value, Eip155KeyPair signer)
      : super.contractTransaction(
            from.accountAddress,
            contract,
            contract.function('approve'),
            [to.accountAddress, value],
            null,
            signer);
}

class Erc721Eip155Transaction extends Eip155TransactionWrapper {
  @override
  final Eip155BlockchainAccountId from;

  @override
  final Eip155BlockchainAccountId to;

  @override
  Eip155BlockchainAssetType get assetType => Eip155BlockchainAssetType(
      from.blockchainId,
      Eip155AssetNamespace.erc721,
      EthereumAddress.fromHex(contract.address.hex));
  final DeployedContract contract;

  Erc721Eip155Transaction.transfer(
      this.contract, this.from, this.to, BigInt tokenId, Eip155KeyPair signer)
      : super.contractTransaction(
            from.accountAddress,
            contract,
            contract.function('safeTransferFrom'),
            [from.accountAddress, to.accountAddress, tokenId],
            null,
            signer);

  Erc721Eip155Transaction.approve(
      this.contract, this.from, this.to, BigInt tokenId, Eip155KeyPair signer)
      : super.contractTransaction(
            from.accountAddress,
            contract,
            contract.function('approve'),
            [to.accountAddress, tokenId],
            null,
            signer);

  Erc721Eip155Transaction.approveAll(
      this.contract, this.from, this.to, bool approved, Eip155KeyPair signer)
      : super.contractTransaction(
            from.accountAddress,
            contract,
            contract.function('setApprovalForAll'),
            [to.accountAddress, approved],
            null,
            signer);
}

class Erc1155Eip155Transaction extends Eip155TransactionWrapper {
  static const String _EMPTY_DATA = '0x0';
  @override
  final Eip155BlockchainAccountId from;

  @override
  final Eip155BlockchainAccountId to;

  @override
  Eip155BlockchainAssetType get assetType => Eip155BlockchainAssetType(
      from.blockchainId,
      Eip155AssetNamespace.erc1155,
      EthereumAddress.fromHex(contract.address.hex));

  final DeployedContract contract;

  Erc1155Eip155Transaction.approve(
      this.contract, this.from, this.to, BigInt tokenId, Eip155KeyPair signer)
      : super.contractTransaction(
            from.accountAddress,
            contract,
            contract.function('isApprovedForAll'),
            [from.accountAddress, to.accountAddress],
            null,
            signer);

  Erc1155Eip155Transaction.approveAll(
      this.contract, this.from, this.to, bool approved, Eip155KeyPair signer)
      : super.contractTransaction(
            from.accountAddress,
            contract,
            contract.function('setApprovalForAll'),
            [to.accountAddress, approved],
            null,
            signer);

  Erc1155Eip155Transaction.batchTransfer(this.contract, this.from, this.to,
      List<BigInt> tokenIds, List<BigInt> amounts, Eip155KeyPair signer)
      : super.contractTransaction(
            from.accountAddress,
            contract,
            contract.function('safeBatchTransferFrom'),
            [
              from.accountAddress,
              to.accountAddress,
              tokenIds,
              amounts,
              _EMPTY_DATA
            ],
            null,
            signer);

  Erc1155Eip155Transaction.transfer(this.contract, this.from, this.to,
      BigInt tokenId, BigInt amount, Eip155KeyPair signer)
      : super.contractTransaction(
            from.accountAddress,
            contract,
            contract.function('safeTransferFrom'),
            [
              from.accountAddress,
              to.accountAddress,
              tokenId,
              amount,
              _EMPTY_DATA
            ],
            null,
            signer);
}

abstract class Eip155TransactionWrapperFactory
    implements
        TransactionWrapperFactory<
            Transaction,
            Eip155KeyPair,
            Eip155BlockchainAccountId,
            Eip155BlockchainAssetType,
            Eip155BlockchainAssetId,
            Eip155Rpc> {
  @override
  final Eip155BlockchainAssetId assetId;

  Eip155TransactionWrapperFactory(this.assetId);
}

class NativeEip155TransactionWrapperFactory
    extends Eip155TransactionWrapperFactory {
  NativeEip155TransactionWrapperFactory(Eip155BlockchainAssetId assetId)
      : super(assetId);

  @override
  Future<NativeEip155Transaction> createTransaction(
      Eip155Rpc rpc,
      Eip155KeyPair keyPair,
      Eip155BlockchainAccountId from,
      Eip155BlockchainAccountId to,
      int amount,
      int decimals,
      int transactionSpeed) async {
    return NativeEip155Transaction.transfer(
        from, to, BigInt.from(amount), keyPair);
  }
}

class Erc20Eip155TransactionWrapperFactory
    extends Eip155TransactionWrapperFactory {
  Erc20Eip155TransactionWrapperFactory(Eip155BlockchainAssetId assetId)
      : super(assetId);

  @override
  Future<Erc20Eip155Transaction> createTransaction(
      Eip155Rpc rpc,
      Eip155KeyPair keyPair,
      Eip155BlockchainAccountId from,
      Eip155BlockchainAccountId to,
      int amount,
      int decimals,
      int transactionSpeed) async {
    final fee = await rpc.getFee();
    final maxPriorityFeePerGas = fee[transactionSpeed].maxPriorityFeePerGas;
    final maxFeePerGas = fee[transactionSpeed].maxFeePerGas;
    final nonce = await rpc.getNonce(keyPair.publicKey);
    DeployedContract contract =
        await loadErc20Contract(assetId.assetType.assetReference);
    final tx = Erc20Eip155Transaction.transfer(
        contract, from, to, BigInt.from(amount), keyPair);
    final estimatedFee = await rpc.estimateFee(tx.transaction);
    return tx
      ..updateTransaction(estimatedFee.toInt(), null, maxFeePerGas,
          maxPriorityFeePerGas, nonce);
  }
}

class Erc721Eip155TransactionWrapperFactory
    extends Eip155TransactionWrapperFactory {
  Erc721Eip155TransactionWrapperFactory(Eip155BlockchainAssetId assetId)
      : super(assetId);

  @override
  Future<Erc721Eip155Transaction> createTransaction(
      Eip155Rpc rpc,
      Eip155KeyPair keyPair,
      Eip155BlockchainAccountId from,
      Eip155BlockchainAccountId to,
      int amount,
      int decimals,
      int transactionSpeed) async {
    final fee = await rpc.getFee();
    final maxPriorityFeePerGas = fee[transactionSpeed].maxPriorityFeePerGas;
    final maxFeePerGas = fee[transactionSpeed].maxFeePerGas;
    final nonce = await rpc.getNonce(keyPair.publicKey);
    DeployedContract contract =
        await loadErc721Contract(assetId.assetType.assetReference);
    final tx = Erc721Eip155Transaction.transfer(
        contract, from, to, BigInt.parse(assetId.tokenId!), keyPair);
    final estimatedFee = await rpc.estimateFee(tx.transaction);
    return tx
      ..updateTransaction(estimatedFee.toInt(), null, maxFeePerGas,
          maxPriorityFeePerGas, nonce);
  }
}

class Erc1155Eip155TransactionWrapperFactory
    extends Eip155TransactionWrapperFactory {
  Erc1155Eip155TransactionWrapperFactory(Eip155BlockchainAssetId assetId)
      : super(assetId);

  @override
  Future<Erc1155Eip155Transaction> createTransaction(
      Eip155Rpc rpc,
      Eip155KeyPair keyPair,
      Eip155BlockchainAccountId from,
      Eip155BlockchainAccountId to,
      int amount,
      int decimals,
      int transactionSpeed) async {
    final fee = await rpc.getFee();
    final maxPriorityFeePerGas = fee[transactionSpeed].maxPriorityFeePerGas;
    final maxFeePerGas = fee[transactionSpeed].maxFeePerGas;
    final nonce = await rpc.getNonce(keyPair.publicKey);
    DeployedContract contract =
        await loadErc1155Contract(assetId.assetType.assetReference);
    final tx = Erc1155Eip155Transaction.transfer(contract, from, to,
        BigInt.parse(assetId.tokenId!), BigInt.from(amount), keyPair);
    final estimatedFee = await rpc.estimateFee(tx.transaction);
    return tx
      ..updateTransaction(estimatedFee.toInt(), null, maxFeePerGas,
          maxPriorityFeePerGas, nonce);
  }
}

class Eip155TransactionWrapperFactoryProducer {
  static Eip155TransactionWrapperFactory getFactory(
      Eip155BlockchainAssetId assetId) {
    if (assetId.assetType.assetNamespace == Eip155AssetNamespace.slip44) {
      return NativeEip155TransactionWrapperFactory(assetId);
    } else if (assetId.assetType.assetNamespace == Eip155AssetNamespace.erc20) {
      return Erc20Eip155TransactionWrapperFactory(assetId);
    } else if (assetId.assetType.assetNamespace ==
        Eip155AssetNamespace.erc721) {
      return Erc721Eip155TransactionWrapperFactory(assetId);
    } else if (assetId.assetType.assetNamespace ==
        Eip155AssetNamespace.erc1155) {
      return Erc1155Eip155TransactionWrapperFactory(assetId);
    } else {
      throw Exception("Unsupported asset namespace");
    }
  }
}
