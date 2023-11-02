const p2pkhInSize = 148;
const p2pkhOutSize = 34;
const p2shOutSize = 32;
const p2shP2wshOutSize = 32;
const p2shP2wpkhOutSize = 32;
const p2shP2wpkhInSize = 90.75;
const p2wpkhInSize = 67.75;
const p2wpkhOutSize = 31;
const p2wshOutSize = 43;
const p2trOutSize = 43;
const p2trInSize = 57.25;
const pubkeySize = 33;
const signatureSize = 72;

class TransactionSize {
  final int txVBytes;
  final double txBytes;
  final int txWeight;

  TransactionSize({
    required this.txVBytes,
    required this.txBytes,
    required this.txWeight,
  });
}

int getSizeOfScriptLengthElement(int length) {
  if (length < 75) {
    return 1;
  } else if (length <= 255) {
    return 2;
  } else if (length <= 65535) {
    return 3;
  } else if (length <= 4294967295) {
    return 5;
  } else {
    throw Exception('Size of redeem script is too large');
  }
}

int getSizeOfVarInt(BigInt length) {
  if (length < BigInt.from(253)) {
    return 1;
  } else if (length < BigInt.from(65535)) {
    return 3;
  } else if (length < BigInt.from(4294967295)) {
    return 5;
  } else if (length < BigInt.parse("18446744073709551615")) {
    return 9;
  } else {
    throw Exception("Invalid var int");
  }
}

double getTxOverheadVBytes(
    String inputScript, int inputCount, int outputCount) {
  double witnessVBytes = 0.0;
  if (inputScript == "P2PKH" || inputScript == "P2SH") {
    witnessVBytes = 0;
  } else {
    witnessVBytes = 0.25 + 0.25 + (inputCount / 4);
  }
  return 4 +
      getSizeOfVarInt(BigInt.from(inputCount)) +
      getSizeOfVarInt(BigInt.from(outputCount)) +
      4 +
      witnessVBytes;
}

double getTxOverheadExtraRawBytes(String inputScript, int inputCount) {
  double witnessBytes = 0;

  if (inputScript == "P2PKH" || inputScript == "P2SH") {
    witnessBytes = 0;
  } else {
    witnessBytes = 0.25 + 0.25 + (inputCount / 4);
  }
  return witnessBytes * 3;
}

TransactionSize calculateTransactionSize({
  required int inputCount,
  String inputScriptType = "P2WPKH",
  int p2wpkhOutputCount = 0,
  int p2pkhOutputCount = 0,
  int p2shOutputCount = 0,
  int p2wshOutputCount = 0,
  int p2trOutputCount = 0,
  int p2shP2wpkhOutputCount = 0,
  int p2shP2wshOutputCount = 0,
  int signaturesPerInput = 1,
  int pubKeyPerInput = 1,
}) {
  final outputCount = p2pkhOutputCount +
      p2shOutputCount +
      p2shP2wpkhOutputCount +
      p2shP2wshOutputCount +
      p2wpkhOutputCount +
      p2wshOutputCount +
      p2trOutputCount;

  double inputSize = 0;
  int inputWitnessSize = 0;
  switch (inputScriptType) {
    case "P2PKH":
      inputSize = p2pkhInSize.toDouble();
      break;
    case "P2SH-P2WPKH":
      inputSize = p2shP2wpkhInSize;
      inputWitnessSize = 107;
      break;
    case "P2WPKH":
      inputSize = p2wpkhInSize;
      inputWitnessSize = 107;
      break;
    case "P2TR":
    case "P2Witness":
      inputSize = p2trInSize;
      inputWitnessSize = 65;
      break;
    case "P2SH":
      int redeemScriptSize = 1 + (pubKeyPerInput * (1 + pubkeySize)) + 1 + 1;
      int scriptSigSize = 1 +
          (signaturesPerInput * (1 + signatureSize)) +
          (getSizeOfScriptLengthElement(redeemScriptSize) + redeemScriptSize);
      inputSize = 32 +
          4 +
          getSizeOfVarInt(BigInt.from(scriptSigSize)) +
          scriptSigSize +
          4;
      break;
    case "P2SH-P2WSH":
    case "P2WSH":
      int redeemScriptSize = 1 + (pubKeyPerInput * (1 + pubkeySize)) + 1 + 1;
      inputWitnessSize = 1 +
          (signaturesPerInput * (1 + signatureSize)) +
          (getSizeOfScriptLengthElement(redeemScriptSize) + redeemScriptSize);
      inputSize = 36 + (inputWitnessSize / 4) + 4;
      if (inputScriptType == "P2SH-P2WSH") {
        inputSize += 32 + 3;
      }
  }
  double txVBytes =
      getTxOverheadVBytes(inputScriptType, inputCount, outputCount) +
          (inputSize * inputCount) +
          (p2pkhOutputCount * p2pkhOutSize) +
          (p2shOutputCount * p2shOutSize) +
          (p2shP2wpkhOutputCount * p2shP2wpkhOutSize) +
          (p2shP2wshOutputCount * p2shP2wshOutSize) +
          (p2wpkhOutputCount * p2wpkhOutSize) +
          (p2wshOutputCount * p2wshOutSize) +
          (p2trOutputCount * p2trOutSize);
  double txBytes = getTxOverheadExtraRawBytes(inputScriptType, inputCount) +
      txVBytes +
      ((inputWitnessSize * inputCount) * 3 / 4);
  int txWeight = txVBytes.ceil() * 4;
  return TransactionSize(
    txVBytes: txVBytes.ceil(),
    txBytes: txBytes,
    txWeight: txWeight,
  );
}
