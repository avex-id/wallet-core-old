class TransactionSize {
  static const int _P2PKH_INPUT_SIZE = 148;
  static const int _P2PKH_OUTPUT_SIZE = 34;
  static const int _P2SH_OUTPUT_SIZE = 32;
  static const int _P2SH_P2WSH_OUTPUT_SIZE = 32;
  static const int _P2SH_P2WPKH_OUTPUT_SIZE = 32;
  static const double _P2SH_P2WPKH_INPUT_SIZE = 90.75;
  static const double _P2WPKH_INPUT_SIZE = 67.75;
  static const int _P2WPKH_OUTPUT_SIZE = 31;
  static const int _P2WSH_OUTPUT_SIZE = 43;
  static const int _P2TR_OUTPUT_SIZE = 43;
  static const double _P2TR_INPUT_SIZE = 57.25;
  static const int _PUBKEY_SIZE = 33;
  static const int _SIGNATURE_SIZE = 72;

  final int txVBytes;
  final double txBytes;
  final int txWeight;

  TransactionSize({
    required this.txVBytes,
    required this.txBytes,
    required this.txWeight,
  });

  factory TransactionSize.calculate({
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
        inputSize = _P2PKH_INPUT_SIZE.toDouble();
        break;
      case "P2SH-P2WPKH":
        inputSize = _P2SH_P2WPKH_INPUT_SIZE;
        inputWitnessSize = 107;
        break;
      case "P2WPKH":
        inputSize = _P2WPKH_INPUT_SIZE;
        inputWitnessSize = 107;
        break;
      case "P2TR":
      case "P2Witness":
        inputSize = _P2TR_INPUT_SIZE;
        inputWitnessSize = 65;
        break;
      case "P2SH":
        int redeemScriptSize =
            1 + (pubKeyPerInput * (1 + _PUBKEY_SIZE)) + 1 + 1;
        int scriptSigSize = 1 +
            (signaturesPerInput * (1 + _SIGNATURE_SIZE)) +
            (_getSizeOfScriptLengthElement(redeemScriptSize) +
                redeemScriptSize);
        inputSize = 32 +
            4 +
            _getSizeOfVarInt(BigInt.from(scriptSigSize)) +
            scriptSigSize +
            4;
        break;
      case "P2SH-P2WSH":
      case "P2WSH":
        int redeemScriptSize =
            1 + (pubKeyPerInput * (1 + _PUBKEY_SIZE)) + 1 + 1;
        inputWitnessSize = 1 +
            (signaturesPerInput * (1 + _SIGNATURE_SIZE)) +
            (_getSizeOfScriptLengthElement(redeemScriptSize) +
                redeemScriptSize);
        inputSize = 36 + (inputWitnessSize / 4) + 4;
        if (inputScriptType == "P2SH-P2WSH") {
          inputSize += 32 + 3;
        }
    }
    final double txVBytes =
        _getTxOverheadVBytes(inputScriptType, inputCount, outputCount) +
            (inputSize * inputCount) +
            (p2pkhOutputCount * _P2PKH_OUTPUT_SIZE) +
            (p2shOutputCount * _P2SH_OUTPUT_SIZE) +
            (p2shP2wpkhOutputCount * _P2SH_P2WPKH_OUTPUT_SIZE) +
            (p2shP2wshOutputCount * _P2SH_P2WSH_OUTPUT_SIZE) +
            (p2wpkhOutputCount * _P2WPKH_OUTPUT_SIZE) +
            (p2wshOutputCount * _P2WSH_OUTPUT_SIZE) +
            (p2trOutputCount * _P2TR_OUTPUT_SIZE);
    final double txBytes =
        _getTxOverheadExtraRawBytes(inputScriptType, inputCount) +
            txVBytes +
            ((inputWitnessSize * inputCount) * 3 / 4);
    final int txWeight = txVBytes.ceil() * 4;

    return TransactionSize(
      txVBytes: txVBytes.ceil(),
      txBytes: txBytes,
      txWeight: txWeight,
    );
  }

  static int _getSizeOfScriptLengthElement(int length) {
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

  static int _getSizeOfVarInt(BigInt length) {
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

  static double _getTxOverheadVBytes(
      String inputScript, int inputCount, int outputCount) {
    double witnessVBytes = 0.0;
    if (inputScript == "P2PKH" || inputScript == "P2SH") {
      witnessVBytes = 0;
    } else {
      witnessVBytes = 0.25 + 0.25 + (inputCount / 4);
    }
    return 4 +
        _getSizeOfVarInt(BigInt.from(inputCount)) +
        _getSizeOfVarInt(BigInt.from(outputCount)) +
        4 +
        witnessVBytes;
  }

  static double _getTxOverheadExtraRawBytes(
      String inputScript, int inputCount) {
    double witnessBytes = 0;

    if (inputScript == "P2PKH" || inputScript == "P2SH") {
      witnessBytes = 0;
    } else {
      witnessBytes = 0.25 + 0.25 + (inputCount / 4);
    }
    return witnessBytes * 3;
  }
}
