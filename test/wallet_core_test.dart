import 'package:wallet_core/wallet_core.dart';
import 'package:test/test.dart';

void main() {
  group('Mnemonic Manager tests', () {
    final mnemonicManager = MnemonicManager();

    // setUp(() {
    //   // Additional setup goes here.
    // });

    test('Generate', () {
      final mnemonic = mnemonicManager.generate();
      expect(mnemonic.length, 12);
    });
  });
}
