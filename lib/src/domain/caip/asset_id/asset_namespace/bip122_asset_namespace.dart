import '../asset_namespace.dart';

enum Bip122AssetNamespace implements BlockchainAssetNamespace {
  slip44('slip44');

  const Bip122AssetNamespace(this.value);

  final String value;

  @override
  String toString() => value;

  static Bip122AssetNamespace fromString(String namespace) {
    switch (namespace) {
      case 'slip44':
        return Bip122AssetNamespace.slip44;
      default:
        throw Exception("Unknown Asset Namespace: $namespace");
    }
  }
}
