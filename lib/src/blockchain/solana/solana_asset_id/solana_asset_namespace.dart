import '../../../types/common/caip/asset_id/asset_namespace.dart';

enum SolanaAssetNamespace implements BlockchainAssetNamespace {
  slip44('slip44'),
  spl('spl');

  const SolanaAssetNamespace(this.value);

  final String value;

  @override
  String toString() => value;

  static SolanaAssetNamespace fromString(String namespace) {
    switch (namespace) {
      case 'slip44':
        return SolanaAssetNamespace.slip44;
      case 'spl':
        return SolanaAssetNamespace.spl;
      default:
        throw Exception("Unknown asset namespace: $namespace");
    }
  }
}
