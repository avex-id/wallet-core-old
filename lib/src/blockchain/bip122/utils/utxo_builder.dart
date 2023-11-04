import 'package:coinlib/coinlib.dart';
import 'transaction_size.dart';
import '../../../api/mempool/api.dart';

class UtxoHelper {
  static const int _SEQUENCE = 0xfffffffd;
  final List<Utxo> _utxoList;

  UtxoHelper(this._utxoList);

  void sortUtxo() {
    _utxoList.sort((a, b) {
      if (a.status.confirmed && !b.status.confirmed) {
        return -1;
      } else if (!a.status.confirmed && b.status.confirmed) {
        return 1;
      } else {
        return b.value.compareTo(a.value);
      }
    });
  }

  void filterUnConfirmedUtxo() {
    _utxoList.removeWhere((utxo) => utxo.status.confirmed == false);
  }

  void toSpend(Address spenderAddress, Address receiverAddress,
      BigInt valueToSpend, int feeRate) {
    List<Utxo> utxoToSpend = [];
    BigInt utxoValueSum = BigInt.zero;
    BigInt fee = BigInt.zero;

    for (int i = 0; i < _utxoList.length; i++) {
      final utxo = _utxoList[i];
      utxoToSpend.add(utxo);
      utxoValueSum += BigInt.from(utxo.value);
      fee = BigInt.from(feeRate *
          _calculateVirtualSize(utxoToSpend.length,
              [receiverAddress.program.runtimeType.toString()]));
      if (utxoValueSum >= valueToSpend + fee) {
        break;
      }
    }

    if (utxoValueSum < valueToSpend + fee) {
      utxoToSpend = [];
      utxoValueSum = BigInt.zero;
      fee = BigInt.zero;
      for (int i = 0; i < _utxoList.length; i++) {
        final utxo = _utxoList[i];
        utxoToSpend.add(utxo);
        utxoValueSum += BigInt.from(utxo.value);
        fee = BigInt.from(feeRate *
            _calculateVirtualSize(utxoToSpend.length,
                [receiverAddress.program.runtimeType.toString()]));
        if (utxoValueSum >= valueToSpend + fee) {
          break;
        }
      }
    }

    if (utxoValueSum < valueToSpend + fee) {
      utxoToSpend = [];
    }

    _utxoList.clear();
    _utxoList.addAll(utxoToSpend);
  }

  BigInt get totalUtxoValue => _utxoList.fold(BigInt.zero, (sum, utxo) {
        return sum + BigInt.from(utxo.value);
      });

  int get _utxoCount => _utxoList.length;

  bool get isEmpty => _utxoList.isEmpty;

  List<Input> generateInputs(ECPublicKey publicKey) {
    List<Input> inputs = [];
    for (Utxo utxo in _utxoList) {
      var outPoint = _createOutPoint(utxo.txid, utxo.vout);
      var input = _createP2WPKHInput(outPoint, publicKey);
      inputs.add(input);
    }
    return inputs;
  }

  List<Output> generateOutputs(
    Address sender,
    Address destination,
    BigInt amountToSend,
    int feeRate,
  ) {
    List<Output> outputs = [];
    BigInt minFee = BigInt.zero;
    BigInt utxoValue = totalUtxoValue;
    if (utxoValue > amountToSend) {
      minFee = BigInt.from(feeRate *
          _calculateVirtualSize(_utxoCount, [
            destination.program.runtimeType.toString(),
            sender.program.runtimeType.toString()
          ]));
      var change = utxoValue - amountToSend - minFee;
      if (change > BigInt.zero) {
        var changeOutput = _createOutput(change, sender);
        outputs.add(changeOutput);
      }
      var output = _createOutput(amountToSend, destination);
      outputs.add(output);
    }
    return outputs;
  }

  Output _createOutput(BigInt amount, Address address) =>
      Output.fromAddress(amount, address);

  OutPoint _createOutPoint(String txId, int vout) =>
      OutPoint.fromHex(txId, vout);

  P2WPKHInput _createP2WPKHInput(OutPoint outPoint, ECPublicKey publicKey) =>
      P2WPKHInput(prevOut: outPoint, publicKey: publicKey, sequence: _SEQUENCE);

  int _calculateVirtualSize(int inputCount, List<String> outputTypes) {
    int p2wpkhOutputCount = 0;
    int p2pkhOutputCount = 0;
    int p2shOutputCount = 0;
    int p2wshOutputCount = 0;
    int p2trOutputCount = 0;
    int p2shP2wpkhOutputCount = 0;
    int p2shP2wshOutputCount = 0;
    for (int i = 0; i < outputTypes.length; i++) {
      switch (outputTypes[i]) {
        case "P2PKH":
          p2pkhOutputCount++;
          break;
        case "P2SH":
          p2shOutputCount++;
          break;
        case "P2WPKH":
          p2wpkhOutputCount++;
          break;
        case "P2WSH":
          p2wshOutputCount++;
          break;
        case "P2Witness":
          p2trOutputCount++;
          break;
        default:
          break;
      }
    }
    return TransactionSize.calculate(
            inputCount: inputCount,
            p2pkhOutputCount: p2pkhOutputCount,
            p2shOutputCount: p2shOutputCount,
            p2wpkhOutputCount: p2wpkhOutputCount,
            p2wshOutputCount: p2wshOutputCount,
            p2trOutputCount: p2trOutputCount,
            p2shP2wpkhOutputCount: p2shP2wpkhOutputCount,
            p2shP2wshOutputCount: p2shP2wshOutputCount)
        .txVBytes
        .ceil();
  }
}
