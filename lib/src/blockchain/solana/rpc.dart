import 'package:solana/dto.dart';
import 'package:solana/encoder.dart';
import 'package:solana/solana.dart';

import '../../model/rpc.dart';

class SolanaRpc extends RpcWrapper {
  RpcClient client;

  SolanaRpc(this.client);

  SolanaRpc.fromUrl(String url) : this(RpcClient(url));

  Future<int> getFee() async => 5000;

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

  Future<TransactionId> sendRawTransaction({
    required String rawTransaction,
    required Commitment commitment,
  }) async {
    return await client.sendTransaction(
      rawTransaction,
      preflightCommitment: commitment,
    );
  }
}

class SplSolanaRpc extends SolanaRpc {
  SplSolanaRpc(RpcClient client) : super(client);

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
