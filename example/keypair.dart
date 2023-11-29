import 'package:coinlib/coinlib.dart';
import 'package:wallet_core/wallet_core.dart';

const toBeSignedMessage = "Test";

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

  final ethereumKeyPair =
      await KeyPairFactoryProducer.getFactory(Eip155Reference.ethereumMainnet)
          .fromSeed(mnemonic.toSeed, 0);
  print("Generated Ethereum key pair:");
  print("Public key: ${ethereumKeyPair.public}");
  print("Private key: ${ethereumKeyPair.private}");
  final ethSignedData = await ethereumKeyPair.signData(toBeSignedMessage);
  print("Signed Hash for message: $toBeSignedMessage: $ethSignedData\n");

  final solanaKeyPair =
      await KeyPairFactoryProducer.getFactory(SolanaReference.solanaMainnet)
          .fromSeed(mnemonic.toSeed, 0);
  print("Generated Solana key pair:");
  print("Public key: ${solanaKeyPair.public}");
  print("Private key: ${solanaKeyPair.private}");
  final solSignedData = await solanaKeyPair.signData(toBeSignedMessage);
  print("Signed Hash for message: $toBeSignedMessage: $solSignedData\n");

  final bitcoinKeyPair =
      await KeyPairFactoryProducer.getFactory(Bip122Reference.bitcoinMainnet)
          .fromSeed(mnemonic.toSeed, 0);
  print("Generated Bitcoin key pair:");
  print("Public key: ${bitcoinKeyPair.public}");
  print("Private key: ${bitcoinKeyPair.private}");
  final bitcoinSignedData = await bitcoinKeyPair.signData(toBeSignedMessage);
  print("Signed Hash for message: $toBeSignedMessage: $bitcoinSignedData\n");
}
