import 'package:solana/encoder.dart';
import 'package:solana/solana.dart';
import 'package:wallet_core/src/model/transaction.dart';

class SolanaTransaction extends TransactionWrapper {
  CompiledMessage compiledMessage;

  SolanaTransaction(this.compiledMessage);

  SolanaTransaction.compileMessage(
      List<Instruction> instructions,
      String recentBlockhash,
      Ed25519HDPublicKey feePayer,
      List<AddressLookupTableAccount>? addressLookupTableAccounts)
      : this(addressLookupTableAccounts != null
            ? _compileMessageVersioned(
                generateMessageForInstructions(instructions),
                recentBlockhash,
                feePayer,
                addressLookupTableAccounts)
            : _compileMessageLegacy(
                generateMessageForInstructions(instructions),
                recentBlockhash,
                feePayer));

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

  static Message generateMessageForInstructions(
      List<Instruction> instructions) {
    return Message(instructions: instructions);
  }

  

  Future<Signature> signCompiledMessage(Ed25519HDKeyPair signer) async {
    return await signer.sign(compiledMessage.toByteArray());
  }

  Future<SignedTx> signCompiledMessageForTransaction(
      Ed25519HDKeyPair signer) async {
    return SignedTx(
      signatures: [await signCompiledMessage(signer)],
      compiledMessage: compiledMessage,
    );
  }
}

class NativeSolanaTransactionHelper extends SolanaTransaction {
  NativeSolanaTransactionHelper() : super(CompiledMessage(ByteArray.empty()));

  NativeSolanaTransactionHelper.transfer(Ed25519HDPublicKey from,
      Ed25519HDPublicKey to, int value, String recentBlockhash)
      : super.compileMessage(
          [_instructionForSolTransfer(from, to, value)],
          recentBlockhash,
          from,
          null,
        );

  static SystemInstruction _instructionForSolTransfer(
      Ed25519HDPublicKey from, Ed25519HDPublicKey to, int value) {
    return SystemInstruction.transfer(
      fundingAccount: from,
      recipientAccount: to,
      lamports: value,
    );
  }
}

class SplSolanaTransactionHelper extends SolanaTransaction {
  SplSolanaTransactionHelper() : super(CompiledMessage(ByteArray.empty()));

  SolanaTransaction transfer(
      int amount,
      int decimals,
      Ed25519HDPublicKey source,
      Ed25519HDPublicKey mint,
      Ed25519HDPublicKey destination,
      Ed25519HDPublicKey sender,
      Ed25519HDPublicKey receiver,
      String recentBlockhash,
      bool hasAta) {
    return SolanaTransaction.compileMessage(
      [
        if (!hasAta)
          _instructionForAssociatedTokenAccountCreation(
            sender,
            destination,
            receiver,
            mint,
          ),
        _instructionForSplTokenTransfer(
          amount,
          decimals,
          source,
          mint,
          destination,
          sender,
          [sender],
        ),
      ],
      recentBlockhash,
      source,
      null,
    );
  }

  AssociatedTokenAccountInstruction
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

  TokenInstruction _instructionForSplTokenTransfer(
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