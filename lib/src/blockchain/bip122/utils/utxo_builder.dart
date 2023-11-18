import 'package:coinlib/coinlib.dart';
import 'transaction_size.dart';
import '../../../api/mempool/api.dart';

class UtxoHelper {
  static const int _SEQUENCE = 0xfffffffd;
  List<Utxo> utxoList;

  UtxoHelper(this.utxoList);

  void sortUtxo() {
    utxoList.sort((a, b) {
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
    utxoList.removeWhere((utxo) => utxo.status.confirmed == false);
  }

  void toSpend(Address spenderAddress, Address receiverAddress,
      BigInt valueToSpend, int feeRate) {
    List<Utxo> utxoToSpend = [];
    BigInt utxoValueSum = BigInt.zero;
    BigInt fee = BigInt.zero;

    bool hasEnoughFunds() => utxoValueSum >= valueToSpend + fee;

    void processUtxoList(List<Utxo> list) {
      for (final utxo in list) {
        utxoToSpend.add(utxo);
        utxoValueSum += BigInt.from(utxo.value);
        fee = BigInt.from(feeRate *
            _calculateVirtualSize(utxoToSpend.length,
                [receiverAddress.program.runtimeType.toString()]));
        if (hasEnoughFunds()) break;
      }
    }

    processUtxoList(utxoList);

    if (!hasEnoughFunds()) {
      utxoToSpend.clear();
      utxoValueSum = BigInt.zero;
      fee = BigInt.zero;
      processUtxoList(utxoList);
    }

    if (!hasEnoughFunds()) utxoToSpend.clear();

    utxoList = List.from(utxoToSpend);
  }

  BigInt get totalUtxoValue =>
      utxoList.fold(BigInt.zero, (sum, utxo) => sum + BigInt.from(utxo.value));

  int get _utxoCount => utxoList.length;

  bool get isEmpty => utxoList.isEmpty;

  List<Input> generateInputs(ECPublicKey publicKey) {
    return utxoList.map((utxo) {
      final outPoint = _createOutPoint(utxo.txid, utxo.vout);
      return _createP2WPKHInput(outPoint, publicKey);
    }).toList();
  }

  List<Output> generateOutputs(
    Address sender,
    Address destination,
    BigInt amountToSend,
    int feeRate,
  ) {
    List<Output> outputs = [];
    BigInt minFee = BigInt.from(feeRate *
        _calculateVirtualSize(_utxoCount, [
          destination.program.runtimeType.toString(),
          sender.program.runtimeType.toString()
        ]));
    BigInt utxoValue = totalUtxoValue;
    if (utxoValue > amountToSend) {
      final change = utxoValue - amountToSend - minFee;
      if (change > BigInt.zero) {
        final changeOutput = _createOutput(change, sender);
        outputs.add(changeOutput);
      }
      final output = _createOutput(amountToSend, destination);
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
