import 'dart:io';

import 'package:coinlib/coinlib.dart';
import 'package:wallet_core/wallet_core.dart';

// Nonce for Backend AuthV2/User/User Data/Get Nonce
const toBeSignedMessage = "hello world !";

// Blockchain ID # CAIP-2 Format https://github.com/ChainAgnostic/CAIPs/blob/main/CAIPs/caip-2.md
final List<BlockchainId> blockchainIds = [
  Eip155BlockchainId(Eip155Reference.ethereumMainnet),
  SolanaBlockchainId(SolanaReference.solanaMainnet),
  Bip122BlockchainId(Bip122Reference.bitcoinMainnet),
];

Future<void> main() async {
  await loadCoinlib();

  // Generate a mnemonic phrase
  final mnemonic = Platform.environment['MNEMONIC_PHRASE'] == null
      ? Mnemonic.generateMnemonic()
      : Platform.environment['MNEMONIC_PHRASE']!;
  print("Mnemonic: $mnemonic\n");

  // // Get Eip155 Private Key
  // final eip155PrivateKey = Platform.environment['EIP155_PRIVATE_KEY'];
  // final bip122PrivateKey = Platform.environment['BIP122_PRIVATE_KEY'];
  // final solanaPrivateKey = Platform.environment['SOLANA_PRIVATE_KEY'];
  // final privateKey = bip122PrivateKey;
  // if (privateKey == null) {
  //   print("EIP155_PRIVATE_KEY not set");
  //  return;
  // }

  // Generate secret shares
  final secretShares = ShamirSecretManager(minimum: 2, shares: 2)
      .generate(secret: mnemonic);
  print("Generated secret shares:");
  for (var i = 0; i < secretShares.length; i++) {
    print("Share ${i + 1}: ${secretShares[i]}\n");
  }

  for (var blockchainId in blockchainIds) {
    // Generate Factory
    final SeedKeyPairStrategyFactory seedStrategyFactory =
        SeedKeyPairStrategyProducer.getFactory(blockchainId.reference);
    // final PrivateKeyPairStrategyFactory privateKeyStrategyFactory =
    //    PrivateKeyPairStrategyProducer.getFactory(blockchainId.reference);
    final KeyPairFactory keyPairFactory =
        KeyPairFactoryProducer.getFactory(blockchainId.reference);
    final KeyPairBlockchainAccountStrategyFactory
        keyPairBlockchainAccountStrategyFactory =
        KeyPairBlockchainAccountStrategyProducer.getFactory(
            blockchainId.reference);
    final BlockchainAccountFactory accountFactory =
        BlockchainAccountFactoryProducer.getFactory(blockchainId.reference);

    // Alice Keypair
    SeedKeyPairStrategy aliceSeedStrategy =
        seedStrategyFactory.createFromSeedAndIndex(Mnemonic.toSeed(mnemonic), 0);
    keyPairFactory.generator = aliceSeedStrategy;
    final aliceKeyPair = await keyPairFactory.generate();
    aliceKeyPair.signer = aliceSeedStrategy;
    aliceKeyPair.verifier = aliceSeedStrategy;

    // // Bob Keypair
    // SeedKeyPairStrategy bobSeedStrategy =
    //     seedStrategyFactory.createFromSeedAndIndex(mnemonic.toSeed, 1);
    // keyPairFactory.generator = bobSeedStrategy;
    // final bobKeyPair = await keyPairFactory.generate();
    // bobKeyPair.signer = bobSeedStrategy;
    // bobKeyPair.verifier = bobSeedStrategy;

    // Alice Account
    final aliceKeyPairStrategy =
        keyPairBlockchainAccountStrategyFactory.createFromKeyPair(aliceKeyPair);
    accountFactory.generator = aliceKeyPairStrategy;
    final aliceAccount = await accountFactory.generate();
    aliceAccount.signer = aliceKeyPairStrategy;
    aliceAccount.verifier = aliceKeyPairStrategy;

    // // Bob Account
    // final bobKeyPairStrategy =
    //     keyPairBlockchainAccountStrategyFactory.createFromKeyPair(bobKeyPair);
    // accountFactory.generator = bobKeyPairStrategy;
    // final bobAccount = await accountFactory.generate();
    // bobAccount.signer = bobKeyPairStrategy;
    // bobAccount.verifier = bobKeyPairStrategy;

    final aliceSignature = await aliceAccount.sign(toBeSignedMessage);
    final aliceSignatureVerificationStatus =
        await aliceAccount.verifySignature(toBeSignedMessage, aliceSignature);
    print(
        "\nBlockchain: ${aliceAccount.blockchainAccountId.blockchainId.toString()}\nAlice Account ${aliceAccount.blockchainAccountId.address}\nSigned: $toBeSignedMessage\nSignature: $aliceSignature\nVerification Status: $aliceSignatureVerificationStatus\n");

    // final bobSignature = await bobAccount.sign(toBeSignedMessage);
    // final bobSignatureVerificationStatus =
    //     await bobAccount.verifySignature(toBeSignedMessage, bobSignature);
    // print(
    //     "Bob Account ${bobAccount.blockchainAccountId.address}\nSigned: $toBeSignedMessage\nSignature: $bobSignature\nVerification Status: $bobSignatureVerificationStatus\n");

  }
}
