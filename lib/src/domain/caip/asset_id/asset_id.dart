import 'asset_type.dart';

class BlockchainAssetId {
  final BlockchainAssetType assetType;
  final String? tokenId;

  BlockchainAssetId(this.assetType, this.tokenId);

  static BlockchainAssetId fromString(String assetId) {
    final parts = assetId.split('/');
    if (parts.length != 3) {
      throw Exception('Invalid asset id');
    }
    final assetType = BlockchainAssetType.fromString('${parts[0]}/${parts[1]}');
    return BlockchainAssetId(assetType, parts[2]);
  }

  @override
  String toString() {
    return "${assetType.toString()}${tokenId != null ? '/$tokenId' : ''}";
  }
}
