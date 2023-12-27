import '../caip/blockchain_account_id/blockchain_account_id.dart';
import '../keypair/keypair.dart';

abstract class BlockchainAccountAuthenticator {
  Future<String> authenticate(String message);
}

abstract class BlockchainAccount<U extends BlockchainAccountId>
    implements BlockchainAccountAuthenticator {
  U get blockchainAccountId;
  void setAuthenticator(BlockchainAccountAuthenticator authenticator);
}

abstract class BlockchainAccountGenerator<T extends BlockchainAccount> {
  Future<T> generate();
}

abstract class BlockchainAccountFactory<T extends BlockchainAccount<U>,
    U extends BlockchainAccountId, V> implements BlockchainAccountGenerator<T> {
  T fromAddress(V accountAddress);
  T fromString(String accountAddress);
  void setGenerator(BlockchainAccountGenerator<T> generator);
}

abstract class KeyPairKeyPairBlockchainAccountGeneratorStrategy<U extends BlockchainAccount>
    implements BlockchainAccountGenerator<U> {}

abstract class KeyPairKeyPairBlockchainAccountGeneratorStrategyFactory<U extends BlockchainAccount,
    V extends KeyPair> {
  KeyPairKeyPairBlockchainAccountGeneratorStrategy<U> createFromKeyPair(V keyPair);
}
