import 'package:coinlib/coinlib.dart';
import 'package:wallet_core/wallet_core.dart';

const toBeSignedMessage = "Test";
const BlockchainReference blockchainReference = Eip155Reference.arbitrumOne; // Or SolanaReference.mainnetBeta, Bip122Reference.mainnet

Future<void> main() async {
  await loadCoinlib();
  final mnemonic = Mnemonic.generate();
  print("Generated mnemonic: $mnemonic\n");

  final secretShares = ShamirSecretManager(minimum: 2, shares: 3)
      .generate(secret: mnemonic.toString());
  print("Generated secret shares:");
  for (var i = 0; i < secretShares.length; i++) {
    print("Share ${i + 1}: ${secretShares[i]}\n");
  }

  final keyPair = await KeyPairFactoryProducer.getFactory(blockchainReference)
      .fromSeed(mnemonic.toSeed, 0);
  print("Generated ${keyPair.blockchainId.toString()} key pair:");
  print("Public key: ${keyPair.public}");
  print("Private key: ${keyPair.private}");
  final signedData = await keyPair.signData(toBeSignedMessage);
  print("Signed Hash for message: $toBeSignedMessage: $signedData\n");
}
