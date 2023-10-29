enum BlockchainNamespace { eip155, solana, bip122 }

extension BlockchainNamespaceExtension on BlockchainNamespace {
  String get asString {
    switch (this) {
      case BlockchainNamespace.eip155:
        return "eip155";
      case BlockchainNamespace.bip122:
        return "bip122";
      case BlockchainNamespace.solana:
        return "solana";
    }
  }

  static BlockchainNamespace fromString(String namespace) {
    switch (namespace) {
      case "eip155":
        return BlockchainNamespace.eip155;
      case "bip122":
        return BlockchainNamespace.bip122;
      case "solana":
        return BlockchainNamespace.solana;
      default:
        throw Exception("Unknown Blockchain Namespace: $namespace");
    }
  }
}
