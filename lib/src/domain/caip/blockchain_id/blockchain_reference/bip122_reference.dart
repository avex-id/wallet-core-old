import 'package:coinlib/coinlib.dart';

enum Bip122Reference { BitcoinMainnet, BitcoinTestnet }

extension Bip122ReferenceExtension on Bip122Reference {
  String get asString {
    switch (this) {
      case Bip122Reference.BitcoinMainnet:
        return '"000000000019d6689c085ae165831e93';
      case Bip122Reference.BitcoinTestnet:
        return '000000000933ea01ad0ee984209779ba';
    }
  }

  static Bip122Reference fromString(String reference) {
    switch (reference) {
      case '000000000019d6689c085ae165831e93':
        return Bip122Reference.BitcoinMainnet;
      case '000000000933ea01ad0ee984209779ba':
        return Bip122Reference.BitcoinTestnet;
      default:
        throw Exception("Unknown Blockchain Reference: $reference");
    }
  }
}

extension Bip122NetworkParamsExtension on Bip122Reference {
  NetworkParams get networkParams {
    switch (this) {
      case Bip122Reference.BitcoinMainnet:
        return NetworkParams(
          wifPrefix: 0x80,
          p2pkhPrefix: 0x00,
          p2shPrefix: 0x05,
          privHDPrefix: 0x0488ade4,
          pubHDPrefix: 0x0488b21e,
          bech32Hrp: "bc",
          messagePrefix: "Bitcoin Signed Message:\n",
        );
      case Bip122Reference.BitcoinTestnet:
        return NetworkParams(
          wifPrefix: 0xef,
          p2pkhPrefix: 0x6f,
          p2shPrefix: 0xc4,
          privHDPrefix: 0x04358394,
          pubHDPrefix: 0x043587cf,
          bech32Hrp: "tb",
          messagePrefix: "Bitcoin Signed Message:\n",
        );
    }
  }
}
