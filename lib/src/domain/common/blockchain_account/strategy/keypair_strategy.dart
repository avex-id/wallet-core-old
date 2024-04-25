import '../../caip/blockchain_account_id/blockchain_account_id.dart';
import '../../caip/blockchain_id/blockchain_id.dart';
import '../../keypair/keypair.dart';
import '../blockchain_account.dart';

abstract class KeyPairBlockchainAccountStrategy<
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
        AccountAddress>
    implements
        BlockchainAccountGenerator<
            BlockchainAccountType,
            BlockchainAccountIdType,
            BlockchainAccountSignerType,
            BlockchainAccountVerifierType,
            BlockchainIdType,
            AccountAddress>,
        BlockchainAccountSigner<BlockchainIdType>,
        BlockchainAccountVerifier<BlockchainIdType> {}

abstract class KeyPairBlockchainAccountStrategyFactory<
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
        BlockchainAccountVerifierType,
        BlockchainIdType,
        AccountAddress>> {
  KeyPairBlockchainAccountStrategyType createFromKeyPair(KeyPairType keyPair);
}
