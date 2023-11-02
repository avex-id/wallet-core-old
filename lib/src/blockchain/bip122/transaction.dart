import 'dart:typed_data';

import 'package:coinlib/coinlib.dart';

import '../../api/mempool/api.dart';
import '../../model/transaction.dart';
import 'utils/utxo.dart';

class Bip122Transaction extends TransactionWrapper {
  final Transaction transaction;

  Bip122Transaction(this.transaction);

  Bip122Transaction.fromTransactionFromHex(String transactionHex)
      : this(Transaction.fromHex(transactionHex));

  Bip122Transaction.fromInputAndOutputList(
      List<Input> inputs, List<Output> outputs,
      {int version = 2})
      : this(Transaction(inputs: inputs, outputs: outputs, version: version));

  List<P2WPKHInput> _createTransactionInputList(
      List<Utxo> selectedUtxoList, ECPublicKey publicKey) {
    List<P2WPKHInput> inputs = [];
    for (var utxo in selectedUtxoList) {
      var outPoint = _createOutPoint(
          Uint8List.fromList(hexToBytes(utxo.txid).reversed.toList()),
          utxo.vout);
      var input = _createP2WPKHInput(outPoint, publicKey);
      inputs.add(input);
    }
    return inputs;
  }

  List<Output> _createTransactionOutputList(
      BigInt totalUtxoValue,
      int utxoCount,
      BigInt amountToSend,
      int feeRate,
      P2WPKHAddress segWitAccount,
      Address destination) {
    List<Output> outputs = [];
    BigInt minFee = BigInt.zero;
    if (totalUtxoValue > amountToSend) {
      minFee = BigInt.from(feeRate *
          calculateVirtualSize(utxoCount, [
            destination.program.runtimeType.toString(),
            segWitAccount.program.runtimeType.toString()
          ]));
      var change = totalUtxoValue - amountToSend - minFee;
      if (change > BigInt.zero) {
        var changeOutput = _createOutput(change, segWitAccount);
        outputs.add(changeOutput);
      }
      var output = _createOutput(amountToSend, destination);
      outputs.add(output);
    }
    return outputs;
  }

  Transaction signTransaction(ECPrivateKey key, BigInt value, int vin) {
    return transaction.sign(inputN: vin, key: key, value: value);
  }

  OutPoint _createOutPoint(Uint8List txHash, int vout) =>
      OutPoint(txHash, vout);

  P2WPKHInput _createP2WPKHInput(OutPoint prevOut, ECPublicKey key) =>
      P2WPKHInput(prevOut: prevOut, publicKey: key, sequence: 0xfffffffd);

  Output _createOutput(BigInt amount, Address address) =>
      Output.fromAddress(amount, address);
}

class NativeBip122Transaction extends Bip122Transaction {
  NativeBip122Transaction(Transaction transaction) : super(transaction);

  Bip122Transaction transfer(
    ECPublicKey publicKey,
    P2WPKHAddress segWitAccount,
    Address destination,
    BigInt amount,
    int feeRate,
    List<Utxo> utxoList,
  ) {
    List<Utxo> selectedUtxoList = selectUtxoToSpend(
      utxoList,
      destination,
      segWitAccount,
      amount,
      feeRate,
    );
    if (selectedUtxoList.isEmpty) {
      throw Exception('Insufficient funds');
    }
    BigInt totalUtxoValue = BigInt.zero;
    BigInt totalOutputValue = BigInt.zero;
    for (var utxo in selectedUtxoList) {
      totalUtxoValue += BigInt.from(utxo.value);
    }
    List<P2WPKHInput> inputs =
        _createTransactionInputList(selectedUtxoList, publicKey);
    List<Output> outputs = _createTransactionOutputList(totalUtxoValue,
        selectedUtxoList.length, amount, feeRate, segWitAccount, destination);
    for (var output in outputs) {
      totalOutputValue += output.value;
    }
    return Bip122Transaction.fromInputAndOutputList(inputs, outputs);
    // for (var i = 0; i < inputs.length; i++) {
    //   var signedTransaction = signTransaction(
    //       wif.privkey, transaction, BigInt.from(selectedUtxoList[i].value), i);
    //   transaction = signedTransaction;
    // }
  }
}
