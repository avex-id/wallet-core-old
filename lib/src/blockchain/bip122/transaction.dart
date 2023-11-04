import 'package:coinlib/coinlib.dart';
import 'package:hex/hex.dart';
import '../../api/mempool/api.dart';
import '../../model/transaction.dart';
import 'utils/utxo_builder.dart';

class Bip122Transaction extends TransactionWrapper {
  static const int _TRANSACTION_VERSION = 2;
  final Transaction transaction;

  Bip122Transaction(this.transaction);

  Bip122Transaction.fromTransactionFromHex(String transactionHex)
      : this(Transaction.fromHex(transactionHex));

  Bip122Transaction.fromInputAndOutputList(
      List<Input> inputs, List<Output> outputs,
      {int version = _TRANSACTION_VERSION})
      : this(Transaction(inputs: inputs, outputs: outputs, version: version));

  void signInputs(WIF wif, List<Utxo> selectedUtxoList) {
    for (var i = 0; i < transaction.inputs.length; i++) {
      var id = HEX.encode(transaction.inputs[i].prevOut.hash.reversed.toList());
      var utxo = selectedUtxoList.firstWhere((element) => element.txid == id);
      _signTransaction(wif.privkey, BigInt.from(utxo.value), i);
    }
  }

  BigInt calculateTransactionFee(BigInt totalUtxoValue) {
    return totalUtxoValue - totalOutputValue;
  }

  void _signTransaction(ECPrivateKey key, BigInt value, int vin) {
    transaction.sign(inputN: vin, key: key, value: value);
  }

  BigInt get totalOutputValue =>
      transaction.outputs.fold(BigInt.zero, (sum, output) {
        return sum + output.value;
      });

  String get transactionId => transaction.txid;

  String get transactionHex => transaction.toHex();
}

class NativeBip122Transaction extends Bip122Transaction {
  NativeBip122Transaction() : super(Transaction(inputs: [], outputs: []));

  Bip122Transaction transfer(
    ECPublicKey publicKey,
    P2WPKHAddress segWitAccount,
    Address destination,
    BigInt amount,
    int feeRate,
    List<Utxo> selectedUtxoList,
  ) {
    var utxoList = UtxoHelper(selectedUtxoList);
    // ..sortUtxo()
    // ..filterUnConfirmedUtxo()
    // ..toSpend(segWitAccount, destination, amount, feeRate);
    if (utxoList.isEmpty) {
      throw Exception('Insufficient funds');
    }
    var inputs = utxoList.generateInputs(publicKey);
    var outputs = utxoList.generateOutputs(
      segWitAccount,
      destination,
      amount,
      feeRate,
    );
    return Bip122Transaction.fromInputAndOutputList(inputs, outputs);
  }
}
