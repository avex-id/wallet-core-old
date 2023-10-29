import 'package:wallet_core/wallet_core.dart';

void main() {
  var mnemonicManager = MnemonicManager();
  var shamirSecretManager = ShamirSecretManager();
  var mnemonic = mnemonicManager.generate();
  print('Mnemonic: $mnemonic');
  var shares = shamirSecretManager.generate(secret: mnemonic);
  for (var share in shares) {
    print('Share: $share');
  }
  var combined = shamirSecretManager.combine(shares: shares);
  print('Combined: $combined');
}
