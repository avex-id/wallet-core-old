import '../caip/blockchain_id/blockchain_id.dart';
import '../caip/blockchain_account_id/blockchain_account_id.dart';

abstract class BlockchainAccountSigner<BlockchainIdType extends BlockchainId> {
  Future<String> sign(String message);
}

abstract class BlockchainAccountVerifier<
    BlockchainIdType extends BlockchainId> {
  Future<bool> verifySignature(String message, String signature);
}

abstract class BlockchainAccountGenerator<
    BlockchainAccountType extends BlockchainAccount<
        BlockchainAccountIdType,
        BlockchainAccountSignerType,
        BlockchainAccountVerifierType,
        BlockchainIdType,
        AccountAddress>,
    BlockchainAccountIdType extends BlockchainAccountId<BlockchainIdType,
        AccountAddress>,
    BlockchainAccountSignerType extends BlockchainAccountSigner<
        BlockchainIdType>,
    BlockchainAccountVerifierType extends BlockchainAccountVerifier<
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
        BlockchainAccountVerifierType extends BlockchainAccountVerifier<
            BlockchainIdType>,
        BlockchainIdType extends BlockchainId,
        AccountAddress>
    implements
        BlockchainAccountSigner<BlockchainIdType>,
        BlockchainAccountVerifier<BlockchainIdType> {
  BlockchainAccountIdType get blockchainAccountId;
  set signer(BlockchainAccountSignerType signer);
  set verifier(BlockchainAccountVerifierType verifier);
}

abstract class BlockchainAccountFactory<
        BlockchainAccountType extends BlockchainAccount<
            BlockchainAccountIdType,
            BlockchainAccountSignerType,
            BlockchainAccountVerifierType,
            BlockchainIdType,
            AccountAddress>,
        BlockchainAccountIdType extends BlockchainAccountId<BlockchainIdType,
            AccountAddress>,
        BlockchainAccountSignerType extends BlockchainAccountSigner<
            BlockchainIdType>,
        BlockchainAccountVerifierType extends BlockchainAccountVerifier<
            BlockchainIdType>,
        BlockchainAccountGeneratorType extends BlockchainAccountGenerator<
            BlockchainAccountType,
            BlockchainAccountIdType,
            BlockchainAccountSignerType,
            BlockchainAccountVerifierType,
            BlockchainIdType,
            AccountAddress>,
        BlockchainIdType extends BlockchainId,
        AccountAddress>
    implements
        BlockchainAccountGenerator<
            BlockchainAccountType,
            BlockchainAccountIdType,
            BlockchainAccountSignerType,
            BlockchainAccountVerifierType,
            BlockchainIdType,
            AccountAddress> {
  BlockchainAccountType fromAddress(AccountAddress accountAddress);
  BlockchainAccountType fromString(String accountAddress);
  set generator(BlockchainAccountGeneratorType generator);
}
