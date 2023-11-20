import 'package:wallet_core/src/blockchain/eip155/transaction.dart';

import '../blockchain/bip122/transaction.dart';
import '../blockchain/solana/transaction.dart';
import '../domain/caip/account_id/account_id.dart';
import '../domain/caip/asset_id/asset_type.dart';
import '../domain/caip/asset_id/asset_id.dart';
import '../model/rpc.dart';
import 'keypair.dart';

abstract class TransactionWrapper<T, U extends KeyPair,
    V extends BlockchainAccountId, W extends BlockchainAssetType> {
  T get innerRawTransaction;
  U get keyPair;
  V get from;
  V get to;
  W get assetType;
}

abstract class TransactionWrapperFactory<
    T,
    U extends KeyPair,
    V extends BlockchainAccountId,
    W extends BlockchainAssetType,
    X extends BlockchainAssetId,
    Y extends RpcWrapper> {
  final X assetId;

  TransactionWrapperFactory(this.assetId);

  Future<TransactionWrapper<T, U, V, W>> createTransaction(
    Y rpc,
    U keyPair,
    V from,
    V to,
    int amount,
    int decimals,
    int transactionSpeed,
  );
}

class TransactionWrapperFactoryProducer {
  static TransactionWrapperFactory getFactory(BlockchainAssetId assetId) {
    if (assetId is Eip155BlockchainAssetId) {
      return Eip155TransactionWrapperFactoryProducer.getFactory(assetId);
    } else if (assetId is Bip122BlockchainAssetId) {
      return Bip122TransactionWrapperFactoryProducer.getFactory(assetId);
    } else if (assetId is SolanaBlockchainAssetId) {
      return SolanaTransactionWrapperFactoryProducer.getFactory(assetId);
    } else {
      throw Exception("Unsupported asset namespace");
    }
  }
}