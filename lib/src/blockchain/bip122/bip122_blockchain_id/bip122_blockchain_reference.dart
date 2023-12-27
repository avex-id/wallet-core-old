import 'package:coinlib/coinlib.dart';

import '../../../domain/common/caip/blockchain_id/blockchain_reference.dart';

enum Bip122Reference implements BlockchainReference {
  bitcoinMainnet('000000000019d6689c085ae165831e93', 'Bitcoin Mainnet'),
  bitcoinTestnet('000000000933ea01ad0ee984209779ba', 'Bitcoin Testnet');

  const Bip122Reference(this.value, this.name);

  @override
  final String value;

  @override
  final String name;

  @override
  String toString() => value;

  static Bip122Reference fromString(String reference) {
    switch (reference) {
      case '000000000019d6689c085ae165831e93':
        return Bip122Reference.bitcoinMainnet;
      case '000000000933ea01ad0ee984209779ba':
        return Bip122Reference.bitcoinTestnet;
      default:
        throw Exception("Unknown blockchain reference: $reference");
    }
  }
}

extension Bip122CoinTypeExtension on Bip122Reference {
  int get bip44CoinType {
    switch (this) {
      case Bip122Reference.bitcoinMainnet:
        return 0;
      case Bip122Reference.bitcoinTestnet:
        return 1;
    }
  }
}

extension Bip122NetworkParamsExtension on Bip122Reference {
  NetworkParams get networkParams {
    switch (this) {
      case Bip122Reference.bitcoinMainnet:
        return NetworkParams(
          wifPrefix: 0x80,
          p2pkhPrefix: 0x00,
          p2shPrefix: 0x05,
          privHDPrefix: 0x0488ade4,
          pubHDPrefix: 0x0488b21e,
          bech32Hrp: "bc",
          messagePrefix: "Bitcoin Signed Message:\n",
        );
      case Bip122Reference.bitcoinTestnet:
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
