import '../reference.dart';

enum Eip155Reference implements BlockchainReference {
  ethereum('1', 'Ethereum Mainnet'),
  ethereumGoerli('5', 'Ethereum Goerli'),
  ethereumSepolia('11155111', 'Ethereum Sepolia'),
  polygon('137', 'Polygon Mainnet'),
  polygonMumbai('80001', 'Polygon Mumbai');

  const Eip155Reference(this.value, this.name);

  @override
  final String value;

  @override
  final String name;

  @override
  String toString() => value;

  static Eip155Reference fromString(String reference) {
    switch (reference) {
      case '1':
        return Eip155Reference.ethereum;
      case '5':
        return Eip155Reference.ethereumGoerli;
      case '11155111':
        return Eip155Reference.ethereumSepolia;
      case '137':
        return Eip155Reference.polygon;
      case '80001':
        return Eip155Reference.polygonMumbai;
      default:
        throw Exception("Unknown Blockchain Reference: $reference");
    }
  }
}

extension Eip155CoinTypeExtension on Eip155Reference {
  int get bip44CoinType {
    switch (this) {
      default:
        return 60;
    }
  }
}
