enum Bip122AssetNamespace {
  Slip44,
}

extension Bip122AssetNamespaceExtension on Bip122AssetNamespace {
  String get asString {
    switch (this) {
      case Bip122AssetNamespace.Slip44:
        return 'slip44';
    }
  }

  static Bip122AssetNamespace fromString(String namespace) {
    switch (namespace) {
      case 'slip44':
        return Bip122AssetNamespace.Slip44;
      default:
        throw Exception("Unknown Asset Namespace: $namespace");
    }
  }
}