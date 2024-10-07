import 'dart:typed_data';
import 'package:bip39/bip39.dart' as bip39;

class Mnemonic {
  Mnemonic._();

  static String fromEntropy(String entropy) {
    return bip39.entropyToMnemonic(entropy);
  }

  static String generateMnemonic({int strength = 128}) {
    return bip39.generateMnemonic(strength: strength);
  }

  static bool validatePhrase(String phrase) {
    return bip39.validateMnemonic(phrase);
  }

  static Uint8List toSeed(String phrase, {String passphrase = ''}) {
    if (!validatePhrase(phrase)) {
      throw ArgumentError('Invalid mnemonic phrase');
    }
    return bip39.mnemonicToSeed(phrase, passphrase: passphrase);
  }

  static String toSeedHex(String phrase, {String passphrase = ''}) {
    if (!validatePhrase(phrase)) {
      throw ArgumentError('Invalid mnemonic phrase');
    }
    return bip39.mnemonicToSeedHex(phrase, passphrase: passphrase);
  }
}
