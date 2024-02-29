import '../../../domain/common/caip/blockchain_id/blockchain_reference.dart';

enum AptosReference implements BlockchainReference {
  aptosMainnet('1', 'Aptos Mainnet'),
  aptosTestnet('2', 'Aptos Testnet');

  const AptosReference(this.value, this.name);

  @override
  final String value;

  @override
  final String name;

  @override
  String toString() => value;

  static AptosReference fromString(String reference) {
    switch (reference) {
      case 'mainnet':
        return AptosReference.aptosMainnet;
      case 'testnet':
        return AptosReference.aptosTestnet;
      default:
        throw Exception("Unknown blockchain reference: $reference");
    }
  }
}

extension AptosCoinTypeExtension on AptosReference {
  int get bip44CoinType {
    switch (this) {
      default:
        return 637;
    }
  }
}
