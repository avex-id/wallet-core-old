import 'package:solana/encoder.dart';
import 'package:solana/solana.dart';
import '../../blockchain/solana/account.dart';
import '../../domain/caip/asset_id/asset_id.dart';
import '../../domain/caip/asset_id/asset_namespace/solana_asset_namespace.dart';
import '../../domain/caip/asset_id/asset_type.dart';
import '../../domain/caip/account_id/account_id.dart';
import '../../model/transaction.dart';
import 'rpc.dart';

abstract class SolanaTransactionWrapper
    implements
        TransactionWrapper<CompiledMessage, SolanaKeyPair,
            SolanaBlockchainAccountId, SolanaBlockchainAssetType> {
  final CompiledMessage compiledMessage;

  SolanaTransactionWrapper(this.compiledMessage, this.keyPair);

  @override
  final SolanaKeyPair keyPair;

  @override
  CompiledMessage get innerRawTransaction => compiledMessage;

  SolanaTransactionWrapper.compileMessage(List<Instruction> instructions,
      String recentBlockhash, SolanaKeyPair signer,
      {List<AddressLookupTableAccount>? addressLookupTableAccounts})
      : this(
            addressLookupTableAccounts != null
                ? _compileMessageVersioned(
                    _generateMessageForInstructions(instructions),
                    recentBlockhash,
                    signer.publicKey,
                    addressLookupTableAccounts)
                : _compileMessageLegacy(
                    _generateMessageForInstructions(instructions),
                    recentBlockhash,
                    signer.publicKey),
            signer);

  static CompiledMessage _compileMessageLegacy(
    Message message,
    String recentBlockhash,
    Ed25519HDPublicKey feePayer,
  ) {
    return message.compile(
      recentBlockhash: recentBlockhash,
      feePayer: feePayer,
    );
  }

  static CompiledMessage _compileMessageVersioned(
    Message message,
    String recentBlockhash,
    Ed25519HDPublicKey feePayer,
    List<AddressLookupTableAccount> addressLookupTableAccounts,
  ) {
    return message.compileV0(
        recentBlockhash: recentBlockhash,
        feePayer: feePayer,
        addressLookupTableAccounts: addressLookupTableAccounts);
  }

  static Message _generateMessageForInstructions(
      List<Instruction> instructions) {
    return Message(instructions: instructions);
  }

  Future<Signature> signCompiledMessage() async {
    final signer = await Ed25519HDKeyPair.fromPrivateKeyBytes(
        privateKey: keyPair.privateKey.sublist(0, 32));
    return await signer.sign(compiledMessage.toByteArray());
  }

  Future<SignedTx> signCompiledMessageForTransaction() async {
    return SignedTx(
      signatures: [await signCompiledMessage()],
      compiledMessage: compiledMessage,
    );
  }

  static String transactionHash(SignedTx transaction) {
    return transaction.id;
  }

  static String transactionHex(SignedTx transaction) {
    return transaction.encode();
  }
}

class NativeSolanaTransaction extends SolanaTransactionWrapper {
  static const _NATIVE_SOLANA_ADDRESS = '11111111111111111111111111111111';

  @override
  final SolanaBlockchainAccountId from;

  @override
  final SolanaBlockchainAccountId to;

  @override
  SolanaBlockchainAssetType get assetType => SolanaBlockchainAssetType(
      from.blockchainId,
      SolanaAssetNamespace.slip44,
      Ed25519HDPublicKey.fromBase58(_NATIVE_SOLANA_ADDRESS));

  NativeSolanaTransaction.transfer(this.from, this.to, int value,
      String recentBlockhash, SolanaKeyPair signer)
      : super.compileMessage([
          _instructionForSolTransfer(
              from.accountAddress, to.accountAddress, value)
        ], recentBlockhash, signer);

  static SystemInstruction _instructionForSolTransfer(
      Ed25519HDPublicKey from, Ed25519HDPublicKey to, int value) {
    return SystemInstruction.transfer(
      fundingAccount: from,
      recipientAccount: to,
      lamports: value,
    );
  }
}

class SplSolanaTransaction extends SolanaTransactionWrapper {
  @override
  final SolanaBlockchainAccountId from;

  @override
  final SolanaBlockchainAccountId to;

  @override
  final SolanaBlockchainAssetType assetType;

  SplSolanaTransaction.transfer(
      this.from,
      this.to,
      this.assetType,
      int amount,
      int decimals,
      Ed25519HDPublicKey sourceAta,
      Ed25519HDPublicKey destinationAta,
      bool hasAta,
      String recentBlockhash,
      SolanaKeyPair signer)
      : super.compileMessage([
          if (!hasAta)
            _instructionForAssociatedTokenAccountCreation(
              signer.publicKey,
              destinationAta,
              to.accountAddress,
              assetType.assetReference,
            ),
          _instructionForSplTokenTransfer(
            amount,
            decimals,
            sourceAta,
            assetType.assetReference,
            destinationAta,
            from.accountAddress,
            [signer.publicKey],
          ),
        ], recentBlockhash, signer);

  static AssociatedTokenAccountInstruction
      _instructionForAssociatedTokenAccountCreation(
    Ed25519HDPublicKey funder,
    Ed25519HDPublicKey derivedAddress,
    Ed25519HDPublicKey owner,
    Ed25519HDPublicKey mint,
  ) {
    return AssociatedTokenAccountInstruction.createAccount(
      funder: funder,
      address: derivedAddress,
      owner: owner,
      mint: mint,
    );
  }

  static TokenInstruction _instructionForSplTokenTransfer(
    int amount,
    int decimals,
    Ed25519HDPublicKey source,
    Ed25519HDPublicKey mint,
    Ed25519HDPublicKey destination,
    Ed25519HDPublicKey owner,
    List<Ed25519HDPublicKey> signers,
  ) {
    return TokenInstruction.transferChecked(
        amount: amount,
        decimals: decimals,
        source: source,
        mint: mint,
        destination: destination,
        owner: owner,
        signers: signers);
  }

  // TokenInstruction _instructionForSplTokenApproval(
  //   int amount,
  //   int decimals,
  //   Ed25519HDPublicKey mint,
  //   Ed25519HDPublicKey source,
  //   Ed25519HDPublicKey delegate,
  //   Ed25519HDPublicKey sourceOwner,
  //   List<Ed25519HDPublicKey> signers,
  // ) {
  //   return TokenInstruction.approveChecked(
  //       amount: amount,
  //       decimals: decimals,
  //       mint: mint,
  //       source: source,
  //       delegate: delegate,
  //       sourceOwner: sourceOwner,
  //       signers: signers);
  // }

  // TokenInstruction _instructionForSplTokenRevoke(
  //   Ed25519HDPublicKey source,
  //   Ed25519HDPublicKey sourceOwner,
  //   List<Ed25519HDPublicKey> signers,
  // ) {
  //   return TokenInstruction.revoke(
  //       source: source, sourceOwner: sourceOwner, signers: signers);
  // }

  // TokenInstruction _instructionForSplTokenBurnChecked(
  //   int amount,
  //   int decimals,
  //   Ed25519HDPublicKey mint,
  //   Ed25519HDPublicKey source,
  //   Ed25519HDPublicKey owner,
  //   List<Ed25519HDPublicKey> signers,
  // ) {
  //   return TokenInstruction.burnChecked(
  //       amount: amount,
  //       decimals: decimals,
  //       accountToBurnFrom: source,
  //       mint: mint,
  //       owner: owner,
  //       signers: signers);
  // }
}

abstract class SolanaTransactionWrapperFactory
    implements
        TransactionWrapperFactory<
            CompiledMessage,
            SolanaKeyPair,
            SolanaBlockchainAccountId,
            SolanaBlockchainAssetType,
            SolanaBlockchainAssetId,
            SolanaRpc> {
  @override
  final SolanaBlockchainAssetId assetId;

  SolanaTransactionWrapperFactory(this.assetId);
}

class NativeSolanaTransactionWrapperFactory
    extends SolanaTransactionWrapperFactory {
  NativeSolanaTransactionWrapperFactory(SolanaBlockchainAssetId assetId)
      : super(assetId);

  @override
  Future<NativeSolanaTransaction> createTransaction(
      SolanaRpc rpc,
      SolanaKeyPair keyPair,
      SolanaBlockchainAccountId from,
      SolanaBlockchainAccountId to,
      int amount,
      int decimals,
      int transactionSpeed) async {
    final recentBlockhash = await rpc.getRecentBlockhash();
    return NativeSolanaTransaction.transfer(
        from, to, amount, recentBlockhash, keyPair);
  }
}

class SplSolanaTransactionWrapperFactory
    extends SolanaTransactionWrapperFactory {
  SplSolanaTransactionWrapperFactory(SolanaBlockchainAssetId assetId)
      : super(assetId);

  @override
  Future<SplSolanaTransaction> createTransaction(
      SolanaRpc rpc,
      SolanaKeyPair keyPair,
      SolanaBlockchainAccountId from,
      SolanaBlockchainAccountId to,
      int amount,
      int decimals,
      int transactionSpeed) async {
    final recentBlockhash = await rpc.getRecentBlockhash();
    final Ed25519HDPublicKey sourceAta = await rpc.getAssociatedTokenAddress(
        from.accountAddress, assetId.assetType.assetReference);
    final Ed25519HDPublicKey destinationAta =
        await rpc.getAssociatedTokenAddress(
            to.accountAddress, assetId.assetType.assetReference);
    final bool hasAta = await rpc.hasAssociatedTokenAccount(
        to.accountAddress, assetId.assetType.assetReference);
    return SplSolanaTransaction.transfer(from, to, assetId.assetType, amount,
        decimals, sourceAta, destinationAta, hasAta, recentBlockhash, keyPair);
  }
}

class SolanaTransactionWrapperFactoryProducer {
  static SolanaTransactionWrapperFactory getFactory(
      SolanaBlockchainAssetId assetId) {
    if (assetId.assetType.assetNamespace == SolanaAssetNamespace.slip44) {
      return NativeSolanaTransactionWrapperFactory(assetId);
    } else if (assetId.assetType.assetNamespace == SolanaAssetNamespace.spl) {
      return SplSolanaTransactionWrapperFactory(assetId);
    } else {
      throw Exception("Unsupported asset namespace");
    }
  }
}
