import 'dart:typed_data';
import 'package:bip39/bip39.dart';

class Mnemonic {
  static const int _BITS_128 = 128;
  static const int _BITS_256 = 256;
  static const String _INVALID_MNEMONIC = 'Invalid mnemonic phrase';
  static const String _INVALID_STRENGTH = 'Invalid strength';

  final String _mnemonic;

  Mnemonic._(this._mnemonic);

  factory Mnemonic.fromString(String mnemonic) {
    if (!validateMnemonic(mnemonic)) {
      throw ArgumentError(_INVALID_MNEMONIC);
    }
    return Mnemonic._(mnemonic);
  }

  factory Mnemonic.generate({int strength = _BITS_256}) {
    if (strength != _BITS_128 && strength != _BITS_256) {
      throw ArgumentError(_INVALID_STRENGTH);
    }
    return Mnemonic._(generateMnemonic(strength: strength));
  }

  String get toSeedHex => mnemonicToSeedHex(_mnemonic);
  Uint8List get toSeed => mnemonicToSeed(_mnemonic);

  @override
  String toString() {
    return _mnemonic;
  }
}
