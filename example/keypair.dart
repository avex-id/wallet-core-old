import 'dart:io';

import 'package:coinlib/coinlib.dart';
import 'package:wallet_core/wallet_core.dart';

// Nonce for Backend AuthV2/User/User Data/Get Nonce
const toBeSignedMessage = "ecb969e2-d688-4cdd-82d7-7f94cb7f6f02";

// Blockchain ID # CAIP-2 Format https://github.com/ChainAgnostic/CAIPs/blob/main/CAIPs/caip-2.md
final List<BlockchainId> blockchainIds = [
  Eip155BlockchainId(Eip155Reference.ethereumMainnet),
  SolanaBlockchainId(SolanaReference.solanaMainnet),
  Bip122BlockchainId(Bip122Reference.bitcoinMainnet),
];

// class KeyPairAuthenticator<U extends KeyPair>
//     implements BlockchainAccountAuthenticator {
//   final U _keyPair;

//   KeyPairAuthenticator(this._keyPair);

//   @override
//   Future<String> authenticate(String message) async {
//     return _keyPair.signMessage(message);
//   }
// }

Future<void> main() async {
  await loadCoinlib();

  // Generate a mnemonic phrase
  final mnemonic = Platform.environment['MNEMONIC_PHRASE'] == null
      ? Mnemonic.generate()
      : Mnemonic.fromString(Platform.environment['MNEMONIC_PHRASE']!);
  print("Mnemonic: $mnemonic\n");

  // Generate secret shares
  final secretShares = ShamirSecretManager(minimum: 2, shares: 3)
      .generate(secret: mnemonic.toString());
  print("Generated secret shares:");
  for (var i = 0; i < secretShares.length; i++) {
    print("Share ${i + 1}: ${secretShares[i]}\n");
  }

  for (var blockchainId in blockchainIds) {
    // Generate KeyPair
    SeedKeyPairStrategy seedStrategy =
        SeedKeyPairStrategyProducer.getFactory(blockchainId.reference)
            .createFromSeedAndIndex(mnemonic.toSeed, 0);
    final keyPairFactory =
        KeyPairFactoryProducer.getFactory(blockchainId.reference)
          ..setGenerator(seedStrategy);
    final keyPair = await keyPairFactory.generate();
    keyPair.setSigner(seedStrategy);

    // Generate Blockchain Account
    final keyPairStrategy = KeyPairBlockchainAccountStrategyProducer.getFactory(
            blockchainId.reference)
        .createFromKeyPair(keyPair);
    final accountFactory =
        BlockchainAccountFactoryProducer.getFactory(blockchainId.reference)
          ..setGenerator(keyPairStrategy);
    final account = await accountFactory.generate();
    account.setAuthenticator(keyPairStrategy);
    print(
        "${account.blockchainAccountId.blockchainId.reference.name} Account: ${account.blockchainAccountId.address}");
    print(
        "Public Key: ${keyPair.publicKey}\nPrivate Key: ${keyPair.privateKey}");
    final signedData = await account.authenticate(toBeSignedMessage);
    print("Signed Hash for message: $toBeSignedMessage: $signedData\n");
  }
}
