import '../caip/blockchain_id/blockchain_id.dart';
import '../caip/blockchain_id/namespace.dart';

abstract class DerivationPathManager {
  final int purpose;
  final int coinType;
  final int account;
  final int change;
  final int? addressIndex;

  DerivationPathManager({
    required this.purpose,
    required this.coinType,
    required this.account,
    required this.change,
    this.addressIndex,
  });

  String get path;

  @override
  String toString() {
    return path;
  }
}

mixin DerivationPathManagerMixin {
  static String path(BlockchainId blockchainId, int addressIndex) {
    switch (blockchainId.namespace) {
      case BlockchainNamespace.eip155:
        return Eip155DerivationPathManager(
          coinType: blockchainId.reference.coinType,
          addressIndex: addressIndex,
        ).path;
      case BlockchainNamespace.solana:
        return SolanaDerivationPathManager(
          coinType: blockchainId.reference.coinType,
          account: addressIndex,
        ).path;
      case BlockchainNamespace.bip122:
        return Bip122DerivationPathManager(
          coinType: blockchainId.reference.coinType,
          addressIndex: addressIndex,
        ).path;
    }
  }
}

class Eip155DerivationPathManager extends DerivationPathManager {
  Eip155DerivationPathManager({
    required int coinType,
    int account = 0,
    int change = 0,
    required int addressIndex,
  }) : super(
          purpose: 44,
          coinType: coinType,
          account: account,
          change: change,
          addressIndex: addressIndex,
        );

  @override
  String get path => "m/$purpose'/$coinType'/$account'/$change/$addressIndex";
}

class Bip122DerivationPathManager extends DerivationPathManager {
  Bip122DerivationPathManager({
    required int coinType,
    int account = 0,
    int change = 0,
    required int addressIndex,
  }) : super(
          purpose: 84,
          coinType: coinType,
          account: account,
          change: change,
          addressIndex: addressIndex,
        );

  @override
  String get path => "m/$purpose'/$coinType'/$account'/$change/$addressIndex";
}

class SolanaDerivationPathManager extends DerivationPathManager {
  SolanaDerivationPathManager(
      {required int coinType, required int account, int change = 0})
      : super(
            purpose: 44, coinType: coinType, account: account, change: change);

  @override
  String get path => "m/$purpose'/$coinType'/$account'/$change'";
}
