enum Eip155AssetNamespace {
  Slip44,
  Erc20,
  Erc721,
  Erc1155,
}

extension Eip155AssetNamespaceExtension on Eip155AssetNamespace {
  String get asString {
    switch (this) {
      case Eip155AssetNamespace.Slip44:
        return 'slip44';
      case Eip155AssetNamespace.Erc20:
        return 'erc20';
      case Eip155AssetNamespace.Erc721:
        return 'erc721';
      case Eip155AssetNamespace.Erc1155:
        return 'erc1155';
    }
  }

  static Eip155AssetNamespace fromString(String namespace) {
    switch (namespace) {
      case 'slip44':
        return Eip155AssetNamespace.Slip44;
      case 'erc20':
        return Eip155AssetNamespace.Erc20;
      case 'erc721':
        return Eip155AssetNamespace.Erc721;
      case 'erc1155':
        return Eip155AssetNamespace.Erc1155;
      default:
        throw Exception("Unknown Asset Namespace: $namespace");
    }
  }
}