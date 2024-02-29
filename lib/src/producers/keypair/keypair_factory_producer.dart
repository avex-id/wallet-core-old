import '../../blockchain/aptos/aptos_blockchain_id/aptos_blockchain_reference.dart';
import '../../blockchain/aptos/keypair/aptos_keypair.dart';
import '../../blockchain/bip122/keypair/bip122_keypair.dart';
import '../../blockchain/solana/keypair/solana_keypair.dart';
import '../../blockchain/bip122/bip122_blockchain_id/bip122_blockchain_reference.dart';
import '../../blockchain/eip155/eip155_blockchain_id/eip155_blockchain_reference.dart';
import '../../blockchain/eip155/keypair/eip155_keypair.dart';
import '../../blockchain/solana/solana_blockchain_id/solana_blockchain_reference.dart';
import '../../domain/common/caip/blockchain_id/blockchain_reference.dart';
import '../../domain/common/keypair/keypair.dart';
import '../../domain/common/keypair/strategy/private_key_strategy.dart';
import '../../domain/common/keypair/strategy/seed_strategy.dart';

class KeyPairFactoryProducer {
  static KeyPairFactory getFactory(BlockchainReference reference) {
    if (reference is Eip155Reference) {
      return Eip155KeyPairFactory(reference);
    } else if (reference is SolanaReference) {
      return SolanaKeyPairFactory(reference);
    } else if (reference is Bip122Reference) {
      return Bip122KeyPairFactory(reference);
    } else if (reference is AptosReference) {
      return AptosKeyPairFactory(reference);
    } else {
      throw Exception('Invalid blockchain reference: ${reference.toString()}');
    }
  }
}

class SeedKeyPairStrategyProducer {
  static SeedKeyPairStrategyFactory getFactory(BlockchainReference reference) {
    if (reference is Eip155Reference) {
      return Eip155SeedKeyPairStrategyFactory(reference);
    } else if (reference is SolanaReference) {
      return SolanaSeedKeyPairStrategyFactory(reference);
    } else if (reference is Bip122Reference) {
      return Bip122SeedKeyPairStrategyFactory(reference);
    } else if (reference is AptosReference) {
      return AptosSeedKeyPairStrategyFactory(reference);
    } else {
      throw Exception('Invalid blockchain reference: ${reference.toString()}');
    }
  }
}

class PrivateKeyPairStrategyProducer {
  static PrivateKeyPairStrategyFactory getFactory(
      BlockchainReference reference) {
    if (reference is Eip155Reference) {
      return Eip155PrivateKeyPairStrategyFactory(reference);
    } else if (reference is SolanaReference) {
      return SolanaPrivateKeyPairStrategyFactory(reference);
    } else if (reference is Bip122Reference) {
      return Bip122PrivateKeyPairStrategyFactory(reference);
    } else if (reference is AptosReference) {
      return AptosPrivateKeyPairStrategyFactory(reference);
    } else {
      throw Exception('Invalid blockchain reference: ${reference.toString()}');
    }
  }
}

// class KeyPairSignerStrategyProducer {
//   static KeyPairSignerStrategyFactory getFactory(
//       BlockchainReference reference) {
//     if (reference is Eip155Reference) {
//       return Eip155KeyPairSignerStrategyFactory();
//     } else if (reference is SolanaReference) {
//       return SolanaKeyPairSignerStrategyFactory();
//     } else if (reference is Bip122Reference) {
//       return Bip122KeyPairSignerStrategyFactory();
//     } else {
//       throw Exception('Invalid blockchain reference: ${reference.toString()}');
//     }
//   }
// }
