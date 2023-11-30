import 'package:coinlib/coinlib.dart';
import 'package:wallet_core/wallet_core.dart';

const toBeSignedMessage = "ecb969e2-d688-4cdd-82d7-7f94cb7f6f02";
const BlockchainReference blockchainReference = Eip155Reference
    .ethereumMainnet; // Or SolanaReference.mainnetBeta, Bip122Reference.mainnet
const blockchain = "eip155:1";

Future<void> main() async {
  await loadCoinlib();
  final mnemonic = Mnemonic(
      "daring clay intact recipe fly gaze intact goose energy sun feed talent dry emotion grief slogan menu impose negative rhythm glow quarter undo moment");
  print("Generated mnemonic: $mnemonic\n");

  final secretShares = ShamirSecretManager(minimum: 2, shares: 3)
      .generate(secret: mnemonic.toString());
  print("Generated secret shares:");
  for (var i = 0; i < secretShares.length; i++) {
    print("Share ${i + 1}: ${secretShares[i]}\n");
  }
  final BlockchainId blockchainId = BlockchainId.parse(blockchain);
  final keyPair = await KeyPairFactoryProducer.getFactory(
          blockchainId.reference // OR blockchainReference
          )
      .fromSeed(mnemonic.toSeed, 0);
  print("Generated ${keyPair.blockchainId.toString()} key pair:");
  print("Public key: ${keyPair.public}");
  print("Private key: ${keyPair.private}");
  final signedData = await keyPair.signData(toBeSignedMessage);
  print("Signed Hash for message: $toBeSignedMessage: $signedData\n");
}
