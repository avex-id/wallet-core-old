enum BlockchainNamespace {
  eip155('eip155'),
  solana('solana'),
  bip122('bip122');

  const BlockchainNamespace(this.value);

  final String value;

  @override
  String toString() => value;

  static BlockchainNamespace fromString(String namespace) {
    switch (namespace) {
      case 'eip155':
        return BlockchainNamespace.eip155;
      case 'solana':
        return BlockchainNamespace.solana;
      case 'bip122':
        return BlockchainNamespace.bip122;
      default:
        throw Exception("Unknown blockchain namespace: $namespace");
    }
  }
}

extension Bip44PurposeExtension on BlockchainNamespace {
  int get bip44Purpose {
    switch (this) {
      case BlockchainNamespace.eip155:
        return 44;
      case BlockchainNamespace.solana:
        return 44;
      case BlockchainNamespace.bip122:
        return 84;
    }
  }
}
