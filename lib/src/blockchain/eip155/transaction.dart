import 'dart:typed_data';
import 'package:bip32_bip44/dart_bip32_bip44.dart';
import 'package:wallet_core/src/model/transaction.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';

class Eip155Transaction extends TransactionWrapper {
  static const int _EIP1559_TRANSACTION_TYPE = 0x02;
  final Transaction transaction;

  Eip155Transaction(this.transaction);

  Eip155Transaction.transaction(
      EthereumAddress from, EthereumAddress to, BigInt value, Uint8List? data,
      {int? maxGas,
      BigInt? gasPrice,
      BigInt? maxFeePerGas,
      BigInt? maxPriorityFeePerGas,
      int? nonce})
      : this(_createTransaction(from, to, value, data, maxGas, gasPrice,
            maxFeePerGas, maxPriorityFeePerGas, nonce));

  Eip155Transaction.contractTransaction(
      EthereumAddress from,
      DeployedContract contract,
      ContractFunction function,
      List<dynamic> params,
      BigInt? value,
      {int? maxGas,
      BigInt? gasPrice,
      BigInt? maxFeePerGas,
      BigInt? maxPriorityFeePerGas,
      int? nonce})
      : this(_createContractTransaction(from, contract, function, params, value,
            maxGas, gasPrice, maxFeePerGas, maxPriorityFeePerGas, nonce));

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
    return Transaction(
        from: from,
        to: contract.address,
        value: value != null
            ? EtherAmount.fromBigInt(EtherUnit.wei, value)
            : EtherAmount.zero(),
        data: function.encodeCall(params),
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

  Uint8List signRawTransaction(ExtendedKey key, int chainId) {
    Uint8List signedTransaction = signTransactionRaw(
        transaction, EthPrivateKey.fromHex(key.privateKeyHex()),
        chainId: chainId);
    if (transaction.isEIP1559) {
      signedTransaction =
          prependTransactionType(_EIP1559_TRANSACTION_TYPE, signedTransaction);
    }
    return signedTransaction;
  }

  String transactionHash(Uint8List transaction) {
    return bytesToHex(keccak256(transaction),
        include0x: true, padToEvenLength: true);
  }

  String transactionHex(Uint8List transaction) {
    return bytesToHex(transaction, include0x: true, padToEvenLength: true);
  }
}

class NativeEip155TransactionHelper extends Eip155Transaction {
  NativeEip155TransactionHelper(Transaction transaction) : super(transaction);

  NativeEip155TransactionHelper.transfer(
      EthereumAddress from, EthereumAddress to, BigInt value)
      : super.transaction(from, to, value, null);
}

class Eip155Erc20TransactionHelper extends Eip155Transaction {
  final DeployedContract contract;

  Eip155Erc20TransactionHelper(this.contract) : super(Transaction());

  Eip155Transaction approve(EthereumAddress owner, EthereumAddress spender) {
    ContractFunction function = contract.function('approve');
    return Eip155Transaction.contractTransaction(
        owner, contract, function, [spender], null);
  }

  Eip155Transaction transfer(
    EthereumAddress from,
    EthereumAddress to,
    BigInt amount,
  ) {
    ContractFunction function = contract.function('transfer');
    return Eip155Transaction.contractTransaction(
        from, contract, function, [to, amount], null);
  }
}

class Eip155Erc721TransactionHelper extends Eip155Transaction {
  final DeployedContract contract;

  Eip155Erc721TransactionHelper(this.contract) : super(Transaction());

  Eip155Transaction approve(
    DeployedContract contract,
    EthereumAddress owner,
    EthereumAddress spender,
    BigInt tokenId,
  ) {
    ContractFunction function = contract.function('approve');
    return Eip155Transaction.contractTransaction(
        owner, contract, function, [spender, tokenId], null);
  }

  Eip155Transaction transfer(
    DeployedContract contract,
    EthereumAddress to,
    EthereumAddress from,
    BigInt tokenId,
  ) {
    ContractFunction function = contract.function('safeTransferFrom');
    return Eip155Transaction.contractTransaction(
        to, contract, function, [to, from, tokenId], null);
  }

  Eip155Transaction approveAll(
    DeployedContract contract,
    bool approved,
    EthereumAddress to,
    EthereumAddress from,
    BigInt tokenId,
  ) {
    ContractFunction function = contract.function('setApprovalForAll');
    return Eip155Transaction.contractTransaction(
        to, contract, function, [to, approved], null);
  }
}

class Eip155Erc1155TransactionHelper extends Eip155Transaction {
  static const String _EMPTY_DATA = '0x0';
  final DeployedContract contract;

  Eip155Erc1155TransactionHelper(this.contract) : super(Transaction());

  Eip155Transaction approve(
    DeployedContract contract,
    EthereumAddress owner,
    EthereumAddress spender,
    BigInt tokenId,
  ) {
    ContractFunction function = contract.function('isApprovedForAll');
    return Eip155Transaction.contractTransaction(
        owner, contract, function, [owner, spender], null);
  }

  Eip155Transaction approveAll(
    DeployedContract contract,
    bool approved,
    EthereumAddress owner,
    EthereumAddress spender,
    BigInt tokenId,
  ) {
    ContractFunction function = contract.function('setApprovalForAll');
    return Eip155Transaction.contractTransaction(
        owner, contract, function, [spender, approved], null);
  }

  Eip155Transaction transfer(
    DeployedContract contract,
    EthereumAddress to,
    EthereumAddress from,
    BigInt tokenId,
    BigInt amount,
  ) {
    ContractFunction function = contract.function('safeTransferFrom');
    return Eip155Transaction.contractTransaction(
        to, contract, function, [from, to, tokenId, amount, _EMPTY_DATA], null);
  }

  Eip155Transaction batchTransfer(
    DeployedContract contract,
    EthereumAddress to,
    EthereumAddress from,
    List<BigInt> tokenIds,
    List<BigInt> amounts,
  ) {
    ContractFunction function = contract.function('safeBatchTransferFrom');
    return Eip155Transaction.contractTransaction(
      to,
      contract,
      function,
      [from, to, tokenIds, amounts, _EMPTY_DATA],
      null,
    );
  }
}
