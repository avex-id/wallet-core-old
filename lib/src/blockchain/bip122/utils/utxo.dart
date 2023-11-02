import 'package:coinlib/coinlib.dart';
import './size.dart';
import '../../../api/mempool/api.dart';

List<Utxo> sortUtxo(List<Utxo> utxoList) {
  utxoList.sort((a, b) {
    if (a.status.confirmed && !b.status.confirmed) {
      return -1;
    } else if (!a.status.confirmed && b.status.confirmed) {
      return 1;
    } else {
      return b.value.compareTo(a.value);
    }
  });
  return utxoList;
}

int calculateVirtualSize(int inputCount, List<String> outputTypes) {
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
  return calculateTransactionSize(
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

List<Utxo> selectUtxoToSpend(List<Utxo> utxoList, Address receiverAddress,
    Address spenderAddress, BigInt valueToSpend, int feeRate) {
  List<Utxo> utxoToSpend = [];
  BigInt utxoValueSum = BigInt.zero;
  BigInt fee = BigInt.zero;
  final sortedUtxoList = sortUtxo(utxoList);
  final confirmedTransactionList =
      sortedUtxoList.where((utxo) => utxo.status.confirmed).toList();
  for (int i = 0; i < confirmedTransactionList.length; i++) {
    final utxo = confirmedTransactionList[i];
    utxoToSpend.add(utxo);
    utxoValueSum += BigInt.from(utxo.value);
    fee = BigInt.from(feeRate *
        calculateVirtualSize(utxoToSpend.length,
            [receiverAddress.program.runtimeType.toString()]));
    if (utxoValueSum >= valueToSpend + fee) {
      break;
    }
  }
  if (utxoValueSum < valueToSpend + fee) {
    utxoToSpend = [];
    utxoValueSum = BigInt.zero;
    fee = BigInt.zero;
    for (int i = 0; i < sortedUtxoList.length; i++) {
      final utxo = sortedUtxoList[i];
      utxoToSpend.add(utxo);
      utxoValueSum += BigInt.from(utxo.value);
      fee = BigInt.from(feeRate *
          calculateVirtualSize(utxoToSpend.length,
              [receiverAddress.program.runtimeType.toString()]));
      if (utxoValueSum >= valueToSpend + fee) {
        break;
      }
    }
  }
  if (utxoValueSum < valueToSpend + fee) {
    utxoToSpend = [];
  }
  return utxoToSpend;
}
