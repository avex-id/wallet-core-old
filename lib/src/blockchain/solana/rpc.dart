import 'package:solana/dto.dart';
import 'package:solana/encoder.dart';
import 'package:solana/solana.dart';

import '../../model/rpc.dart';

class SolanaRpc implements RpcWrapper {
  RpcClient client;

  SolanaRpc(this.client);

  SolanaRpc.fromUrl(String url) : this(RpcClient(url));

  int getFee() => 5000;

  int estimateGas(CompiledMessage compiledMessage) =>
      compiledMessage.requiredSignatureCount;

  Future<String> getRecentBlockhash() async {
    LatestBlockhashResult blockhash =
        await client.getLatestBlockhash(commitment: Commitment.confirmed);
    return blockhash.value.blockhash;
  }

  Future<int> getBalance(Ed25519HDPublicKey address) async {
    BalanceResult balance = await client.getBalance(address.toBase58());
    return balance.value;
  }

  @override
  Future<String> broadcastTransaction({
    required String transactionHex,
    Commitment commitment = Commitment.confirmed,
  }) async {
    return await client.sendTransaction(
      transactionHex,
      preflightCommitment: commitment,
    );
  }

  Future<Ed25519HDPublicKey> getAssociatedTokenAddress(
    Ed25519HDPublicKey owner,
    Ed25519HDPublicKey mint,
  ) async {
    return await findAssociatedTokenAddress(owner: owner, mint: mint);
  }

  Future<TokenAmount> getTokenBalance(
      Ed25519HDPublicKey owner, Ed25519HDPublicKey mint,
      {Commitment commitment = Commitment.finalized}) async {
    final ata = await getAssociatedTokenAddress(owner, mint);
    return client
        .getTokenAccountBalance(ata.toBase58(), commitment: commitment)
        .value;
  }

  Future<ProgramAccount?> getAssociatedTokenAccount(
    Ed25519HDPublicKey owner,
    Ed25519HDPublicKey mint, {
    Commitment commitment = Commitment.finalized,
  }) async {
    final accounts = await client
        .getTokenAccountsByOwner(
          owner.toBase58(),
          TokenAccountsFilter.byMint(mint.toBase58()),
          encoding: Encoding.jsonParsed,
          commitment: commitment,
        )
        .value;
    if (accounts.isEmpty) return null;

    return accounts.first;
  }

  Future<bool> hasAssociatedTokenAccount(
      Ed25519HDPublicKey owner, Ed25519HDPublicKey mint,
      {Commitment commitment = Commitment.finalized}) async {
    final account = await getAssociatedTokenAccount(owner, mint);
    return account != null;
  }
}

// class SplSolanaRpc extends SolanaRpc {
//   SplSolanaRpc(RpcClient client) : super(client);

//   Future<Ed25519HDPublicKey> getAssociatedTokenAddress(
//     Ed25519HDPublicKey owner,
//     Ed25519HDPublicKey mint,
//   ) async {
//     return await findAssociatedTokenAddress(owner: owner, mint: mint);
//   }

//   Future<TokenAmount> getTokenBalance(
//       Ed25519HDPublicKey owner, Ed25519HDPublicKey mint,
//       {Commitment commitment = Commitment.finalized}) async {
//     final ata = await getAssociatedTokenAddress(owner, mint);
//     return client
//         .getTokenAccountBalance(ata.toBase58(), commitment: commitment)
//         .value;
//   }

//   Future<ProgramAccount?> getAssociatedTokenAccount(
//     Ed25519HDPublicKey owner,
//     Ed25519HDPublicKey mint, {
//     Commitment commitment = Commitment.finalized,
//   }) async {
//     final accounts = await client
//         .getTokenAccountsByOwner(
//           owner.toBase58(),
//           TokenAccountsFilter.byMint(mint.toBase58()),
//           encoding: Encoding.jsonParsed,
//           commitment: commitment,
//         )
//         .value;
//     if (accounts.isEmpty) return null;

//     return accounts.first;
//   }

//   Future<bool> hasAssociatedTokenAccount(
//       Ed25519HDPublicKey owner, Ed25519HDPublicKey mint,
//       {Commitment commitment = Commitment.finalized}) async {
//     final account = await getAssociatedTokenAccount(owner, mint);
//     return account != null;
//   }
// }
