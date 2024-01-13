import '../caip/blockchain_id/blockchain_id.dart';
import '../caip/blockchain_account_id/blockchain_account_id.dart';
import '../keypair/keypair.dart';

abstract class BlockchainAccountSigner<BlockchainIdType extends BlockchainId> {
  Future<String> signMessage(String message);
  // Future<String> signTransaction(String message);
}

abstract class BlockchainAccountGenerator<
    BlockchainAccountType extends BlockchainAccount<BlockchainAccountIdType,
        BlockchainAccountSignerType, BlockchainIdType, AccountAddress>,
    BlockchainAccountIdType extends BlockchainAccountId<BlockchainIdType,
        AccountAddress>,
    BlockchainAccountSignerType extends BlockchainAccountSigner<
        BlockchainIdType>,
    BlockchainIdType extends BlockchainId,
    AccountAddress> {
  Future<BlockchainAccountType> generate();
}

abstract class BlockchainAccount<
    BlockchainAccountIdType extends BlockchainAccountId<BlockchainIdType,
        AccountAddress>,
    BlockchainAccountSignerType extends BlockchainAccountSigner<
        BlockchainIdType>,
    BlockchainIdType extends BlockchainId,
    AccountAddress> implements BlockchainAccountSigner<BlockchainIdType> {
  BlockchainAccountIdType get blockchainAccountId;
  void setAccountSigner(BlockchainAccountSignerType signer);
}

abstract class BlockchainAccountFactory<
        BlockchainAccountType extends BlockchainAccount<BlockchainAccountIdType,
            BlockchainAccountSignerType, BlockchainIdType, AccountAddress>,
        BlockchainAccountIdType extends BlockchainAccountId<BlockchainIdType,
            AccountAddress>,
        BlockchainAccountSignerType extends BlockchainAccountSigner<
            BlockchainIdType>,
        BlockchainAccountGeneratorType extends BlockchainAccountGenerator<
            BlockchainAccountType,
            BlockchainAccountIdType,
            BlockchainAccountSignerType,
            BlockchainIdType,
            AccountAddress>,
        BlockchainIdType extends BlockchainId,
        AccountAddress>
    implements
        BlockchainAccountGenerator<
            BlockchainAccountType,
            BlockchainAccountIdType,
            BlockchainAccountSignerType,
            BlockchainIdType,
            AccountAddress> {
  BlockchainAccountType fromAddress(AccountAddress accountAddress);
  BlockchainAccountType fromString(String accountAddress);
  void setGenerator(BlockchainAccountGeneratorType generator);
}

abstract class KeyPairBlockchainAccountStrategy<
        BlockchainAccountType extends BlockchainAccount<BlockchainAccountIdType,
            BlockchainAccountSignerType, BlockchainIdType, AccountAddress>,
        BlockchainAccountIdType extends BlockchainAccountId<BlockchainIdType,
            AccountAddress>,
        BlockchainAccountSignerType extends BlockchainAccountSigner<
            BlockchainIdType>,
        BlockchainIdType extends BlockchainId,
        AccountAddress>
    implements
        BlockchainAccountGenerator<
            BlockchainAccountType,
            BlockchainAccountIdType,
            BlockchainAccountSignerType,
            BlockchainIdType,
            AccountAddress>,
        BlockchainAccountSigner<BlockchainIdType> {}

abstract class KeyPairBlockchainAccountStrategyFactory<
    BlockchainAccountType extends BlockchainAccount<BlockchainAccountIdType,
        BlockchainAccountSignerType, BlockchainIdType, AccountAddress>,
    BlockchainAccountIdType extends BlockchainAccountId<BlockchainIdType,
        AccountAddress>,
    BlockchainAccountSignerType extends BlockchainAccountSigner<
        BlockchainIdType>,
    BlockchainIdType extends BlockchainId,
    AccountAddress,
    PublicKeyType,
    PrivateKeyType,
    KeyPairType extends KeyPair<PublicKeyType, PrivateKeyType,
        KeyPairSignerType, KeyPairVerifierType>,
    KeyPairSignerType extends KeyPairSigner<PublicKeyType, PrivateKeyType>,
    KeyPairVerifierType extends KeyPairVerifier<PublicKeyType, PrivateKeyType>,
    KeyPairBlockchainAccountStrategyType extends KeyPairBlockchainAccountStrategy<
        BlockchainAccountType,
        BlockchainAccountIdType,
        BlockchainAccountSignerType,
        BlockchainIdType,
        AccountAddress>> {
  KeyPairBlockchainAccountStrategyType createFromKeyPair(KeyPairType keyPair);
}
