import '../../../types/common/caip/blockchain_id/blockchain_reference.dart';

enum SolanaReference implements BlockchainReference {
  solanaMainnet('mainnet', 'Solana Mainnet'),
  solanaTestnet('testnet', 'Solana Testnet'),
  solanaDevnet('devnet', 'Solana Devnet');

  const SolanaReference(this.value, this.name);

  @override
  final String value;

  @override
  final String name;

  @override
  String toString() => value;

  static SolanaReference fromString(String reference) {
    switch (reference) {
      case 'mainnet':
        return SolanaReference.solanaMainnet;
      case 'testnet':
        return SolanaReference.solanaTestnet;
      case 'devnet':
        return SolanaReference.solanaDevnet;
      default:
        throw Exception("Unknown Blockchain Reference: $reference");
    }
  }
}

extension SolanaCoinTypeExtension on SolanaReference {
  int get bip44CoinType {
    switch (this) {
      default:
        return 501;
    }
  }
}
