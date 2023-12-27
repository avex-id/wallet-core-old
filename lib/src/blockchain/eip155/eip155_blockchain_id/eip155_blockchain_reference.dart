import '../../../domain/common/caip/blockchain_id/blockchain_reference.dart';

enum Eip155Reference implements BlockchainReference {
  ethereumMainnet('1', 'Ethereum Mainnet'),
  ethereumGoerli('5', 'Ethereum Goerli'),
  // ethereumSepolia('11155111', 'Ethereum Sepolia'),
  // polygonMainnet('137', 'Polygon Mainnet'),
  // polygonMumbai('80001', 'Polygon Mumbai'),
  // polygonZkEvm('1101', 'Polygon ZK-EVM'),
  // polygonZkEvmTestnet('1442', 'Polygon ZK-EVM Testnet'),
  // arbitrumOne('42161', 'Arbitrum One'),
  // arbitrumNova('42170', 'Arbitrum Nova'),
  // arbitrumGoerli('421613', 'Arbitrum Goerli'),
  // arbitrumSepolia('421614', 'Arbitrum Sepolia'),
  // avalancheCChain('43114', 'Avalanche C-Chain'),
  // avalancheFuji('43113', 'Avalanche Fuji'),
  // baseMainnet('8453', 'Base Mainnet'),
  // baseGoerli('84531', 'Base Goerli'),
  // baseSepolia('84532', 'Base Sepolia'),
  // bnbSmartChainMainnet('56', 'BNB Smart Chain Mainnet'),
  // bnbSmartChainTestnet('97', 'BNB Smart Chain Testnet'),
  // optimismMainnet('10', 'Optimism Mainnet'),
  optimismGoerli('69', 'Optimism Kovan');

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
        return Eip155Reference.ethereumMainnet;
      case '5':
        return Eip155Reference.ethereumGoerli;
      // case '11155111':
      //   return Eip155Reference.ethereumSepolia;
      // case '137':
      //   return Eip155Reference.polygonMainnet;
      // case '80001':
      //   return Eip155Reference.polygonMumbai;
      // case '1101':
      //   return Eip155Reference.polygonZkEvm;
      // case '1442':
      //   return Eip155Reference.polygonZkEvmTestnet;
      // case '42161':
      //   return Eip155Reference.arbitrumOne;
      // case '42170':
      //   return Eip155Reference.arbitrumNova;
      // case '421613':
      //   return Eip155Reference.arbitrumGoerli;
      // case '421614':
      //   return Eip155Reference.arbitrumSepolia;
      // case '43114':
      //   return Eip155Reference.avalancheCChain;
      // case '43113':
      //   return Eip155Reference.avalancheFuji;
      // case '8453':
      //   return Eip155Reference.baseMainnet;
      // case '84531':
      //   return Eip155Reference.baseGoerli;
      // case '84532':
      //   return Eip155Reference.baseSepolia;
      // case '56':
      //   return Eip155Reference.bnbSmartChainMainnet;
      // case '97':
      //   return Eip155Reference.bnbSmartChainTestnet;
      // case '10':
      //   return Eip155Reference.optimismMainnet;
      case '69':
        return Eip155Reference.optimismGoerli;
      default:
        throw Exception("Unknown blockchain reference: $reference");
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
