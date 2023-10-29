enum Bip122Reference {
  BitcoinMainnet,
  BitcoinTestnet,
}

extension Bip122ReferenceExtension on Bip122Reference {
  String get asString {
    switch (this) {
      case Bip122Reference.BitcoinMainnet:
        return '"000000000019d6689c085ae165831e93';
      case Bip122Reference.BitcoinTestnet:
        return '000000000933ea01ad0ee984209779ba';
    }
  }

  static Bip122Reference fromString(String reference) {
    switch (reference) {
      case '000000000019d6689c085ae165831e93':
        return Bip122Reference.BitcoinMainnet;
      case '000000000933ea01ad0ee984209779ba':
        return Bip122Reference.BitcoinTestnet;
      default:
        throw Exception("Unknown Blockchain Reference: $reference");
    }
  }
}
