import '../asset_namespace.dart';

enum Eip155AssetNamespace implements BlockchainAssetNamespace {
  slip44('slip44'),
  erc20('erc20'),
  erc721('erc721'),
  erc1155('erc1155');

  const Eip155AssetNamespace(this.value);

  final String value;

  @override
  String toString() => value;

  static Eip155AssetNamespace fromString(String namespace) {
    switch (namespace) {
      case 'slip44':
        return Eip155AssetNamespace.slip44;
      case 'erc20':
        return Eip155AssetNamespace.erc20;
      case 'erc721':
        return Eip155AssetNamespace.erc721;
      case 'erc1155':
        return Eip155AssetNamespace.erc1155;
      default:
        throw Exception("Unknown Asset Namespace: $namespace");
    }
  }
}
