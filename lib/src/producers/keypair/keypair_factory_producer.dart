import '../../blockchain/bip122/keypair/bip122_keypair.dart';
import '../../blockchain/solana/keypair/solana_keypair.dart';
import '../../blockchain/bip122/bip122_blockchain_id/bip122_blockchain_reference.dart';
import '../../blockchain/eip155/eip155_blockchain_id/eip155_blockchain_reference.dart';
import '../../blockchain/eip155/keypair/eip155_keypair.dart';
import '../../blockchain/solana/solana_blockchain_id/solana_blockchain_reference.dart';
import '../../domain/common/caip/blockchain_id/blockchain_reference.dart';
import '../../domain/common/keypair/keypair.dart';

class KeyPairFactoryProducer {
  static KeyPairFactory getFactory(BlockchainReference reference) {
    if (reference is Eip155Reference) {
      return Eip155KeyPairFactory(reference);
    } else if (reference is SolanaReference) {
      return SolanaKeyPairFactory(reference);
    } else if (reference is Bip122Reference) {
      return Bip122KeyPairFactory(reference);
    } else {
      throw Exception('Invalid blockchain reference: ${reference.toString()}');
    }
  }
}

class SeedKeyPairGeneratorStrategyProducer {
  static SeedKeyPairGeneratorStrategyFactory getFactory(
      BlockchainReference reference) {
    if (reference is Eip155Reference) {
      return Eip155SeedKeyPairGeneratorStrategyFactory(reference);
    } else if (reference is SolanaReference) {
      return SolanaSeedKeyPairGeneratorStrategyFactory(reference);
    } else if (reference is Bip122Reference) {
      return Bip122SeedKeyPairGeneratorStrategyFactory(reference);
    } else {
      throw Exception('Invalid blockchain reference: ${reference.toString()}');
    }
  }
}

class KeyPairSignerStrategyProducer {
  static KeyPairSignerStrategyFactory getFactory(
      BlockchainReference reference) {
    if (reference is Eip155Reference) {
      return Eip155KeyPairSignerStrategyFactory();
    } else if (reference is SolanaReference) {
      return SolanaKeyPairSignerStrategyFactory();
    } else if (reference is Bip122Reference) {
      return Bip122KeyPairSignerStrategyFactory();
    } else {
      throw Exception('Invalid blockchain reference: ${reference.toString()}');
    }
  }
}
