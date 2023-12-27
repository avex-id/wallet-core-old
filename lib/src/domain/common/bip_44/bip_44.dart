import '../caip/blockchain_id/blockchain_id.dart';

abstract class DerivationPath<T extends BlockchainId> {
  T get blockchainId;
  int get purpose;
  int get coinType;
  int get account;
  int get change;
  int? get addressIndex;

  String get path;

  @override
  String toString() {
    return path;
  }
}

abstract class DerivationPathFactory<T extends BlockchainId> {
  DerivationPath<T> getAddressAtPath({
    required int index,
  });
}
