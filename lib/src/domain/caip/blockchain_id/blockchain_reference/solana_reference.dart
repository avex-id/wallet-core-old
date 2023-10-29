enum SolanaReference {
  SolanaMainnet,
  SolanaTestnet,
  SolanaDevnet,
}

extension SolanaReferenceExtension on SolanaReference {
  String get asString {
    switch (this) {
      case SolanaReference.SolanaMainnet:
        return "mainnet";
      case SolanaReference.SolanaTestnet:
        return "testnet";
      case SolanaReference.SolanaDevnet:
        return "devnet";
    }
  }

  static SolanaReference fromString(String reference) {
    switch (reference) {
      case "mainnet":
        return SolanaReference.SolanaMainnet;
      case "testnet":
        return SolanaReference.SolanaTestnet;
      case "devnet":
        return SolanaReference.SolanaDevnet;
      default:
        throw Exception("Unknown Blockchain Reference: $reference");
    }
  }
}
