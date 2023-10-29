enum SolanaAssetNamespace { Slip44, Spl }

extension SolanaAssetNamespaceExtension on SolanaAssetNamespace {
  String get asString {
    switch (this) {
      case SolanaAssetNamespace.Slip44:
        return 'slip44';
      case SolanaAssetNamespace.Spl:
        return 'spl';
    }
  }

  static SolanaAssetNamespace fromString(String namespace) {
    switch (namespace) {
      case 'slip44':
        return SolanaAssetNamespace.Slip44;
      case 'spl':
        return SolanaAssetNamespace.Spl;
      default:
        throw Exception("Unknown Asset Namespace: $namespace");
    }
  }
}
