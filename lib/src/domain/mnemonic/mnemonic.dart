import 'dart:typed_data';
import 'package:bip39/bip39.dart';

class MnemonicManager {
  static const int _BITS_128 = 128;
  static const int _BITS_256 = 256;
  static const String _INVALID_MNEMONIC = 'Invalid mnemonic phrase';
  static const String _INVALID_STRENGTH = 'Invalid strength';

  final int strength;

  MnemonicManager({this.strength = _BITS_256}) {
    if (strength != _BITS_128 && strength != _BITS_256) {
      throw ArgumentError(_INVALID_STRENGTH);
    }
  }

  String generate() => generateMnemonic(strength: strength);

  bool validate(String mnemonic) => validateMnemonic(mnemonic);

  String toSeedHex(String mnemonic) {
    _validateMnemonic(mnemonic);
    return mnemonicToSeedHex(mnemonic);
  }

  Uint8List toSeed(String mnemonic) {
    _validateMnemonic(mnemonic);
    return mnemonicToSeed(mnemonic);
  }

  void _validateMnemonic(String mnemonic) {
    if (!validateMnemonic(mnemonic)) {
      throw ArgumentError(_INVALID_MNEMONIC);
    }
  }
}
