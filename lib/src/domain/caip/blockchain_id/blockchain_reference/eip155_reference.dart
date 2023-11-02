enum Eip155Reference {
  Ethereum,
  EthereumGoerli,
  EthereumSepolia,
  Polygon,
  PolygonMumbai,
  Arbitrum,
  ArbitrumNova,
  ArbitrumGoerli,
  AvalancheChain,
  AvalancheFuji,
  Base,
  BaseGoerli,
  BinanceSmartChain,
  BinanceSmartChainTestnet,
  Optimism,
  OptimismGoerli,
  Zora,
  ZoraTestnet,
  Palm,
  PalmTestnet,
  PolygonZkEvmTestnet,
}

extension Eip155ReferenceExtension on Eip155Reference {
  String get asString {
    switch (this) {
      case Eip155Reference.Ethereum:
        return "1";
      case Eip155Reference.EthereumGoerli:
        return "5";
      case Eip155Reference.EthereumSepolia:
        return "11155111";
      case Eip155Reference.Polygon:
        return "137";
      case Eip155Reference.PolygonMumbai:
        return "80001";
      case Eip155Reference.Arbitrum:
        return "42161";
      case Eip155Reference.ArbitrumNova:
        return "42170";
      case Eip155Reference.ArbitrumGoerli:
        return "421613";
      case Eip155Reference.AvalancheChain:
        return "43114";
      case Eip155Reference.AvalancheFuji:
        return "43113";
      case Eip155Reference.Base:
        return "8453";
      case Eip155Reference.BaseGoerli:
        return "84531";
      case Eip155Reference.BinanceSmartChain:
        return "56";
      case Eip155Reference.BinanceSmartChainTestnet:
        return "97";
      case Eip155Reference.Optimism:
        return "10";
      case Eip155Reference.OptimismGoerli:
        return "420";
      case Eip155Reference.Zora:
        return "7777777";
      case Eip155Reference.ZoraTestnet:
        return "999";
      case Eip155Reference.Palm:
        return "11297108109";
      case Eip155Reference.PalmTestnet:
        return "11297108099";
      case Eip155Reference.PolygonZkEvmTestnet:
        return "1442";
    }
  }

  static Eip155Reference fromString(String reference) {
    switch (reference) {
      case "1":
        return Eip155Reference.Ethereum;
      case "5":
        return Eip155Reference.EthereumGoerli;
      case "11155111":
        return Eip155Reference.EthereumSepolia;
      case "137":
        return Eip155Reference.Polygon;
      case "80001":
        return Eip155Reference.PolygonMumbai;
      case "42161":
        return Eip155Reference.Arbitrum;
      case "42170":
        return Eip155Reference.ArbitrumNova;
      case "421613":
        return Eip155Reference.ArbitrumGoerli;
      case "43114":
        return Eip155Reference.AvalancheChain;
      case "43113":
        return Eip155Reference.AvalancheFuji;
      case "8453":
        return Eip155Reference.Base;
      case "84531":
        return Eip155Reference.BaseGoerli;
      case "56":
        return Eip155Reference.BinanceSmartChain;
      case "97":
        return Eip155Reference.BinanceSmartChainTestnet;
      case "10":
        return Eip155Reference.Optimism;
      case "420":
        return Eip155Reference.OptimismGoerli;
      case "7777777":
        return Eip155Reference.Zora;
      case "999":
        return Eip155Reference.ZoraTestnet;
      case "11297108109":
        return Eip155Reference.Palm;
      case "11297108099":
        return Eip155Reference.PalmTestnet;
      case "1442":
        return Eip155Reference.PolygonZkEvmTestnet;
      default:
        throw Exception("Unknown Blockchain Reference: $reference");
    }
  }
}

extension Eip155CoinTypeExtension on Eip155Reference {
  int get coinType {
    switch (this) {
      default:
        return 60;
    }
  }
}
