import 'package:coinlib/coinlib.dart';
import 'package:hex/hex.dart';
import '../../api/mempool/api.dart';
import '../../domain/caip/account_id/account_id.dart';
import '../../domain/caip//blockchain_id/blockchain_reference/bip122_reference.dart';
import '../../domain/caip/asset_id/asset_id.dart';
import '../../domain/caip/asset_id/asset_namespace/bip122_asset_namespace.dart';
import '../../domain/caip/asset_id/asset_type.dart';
import '../../model/transaction.dart';
import 'account.dart';
import 'rpc.dart';
import 'utils/utxo_builder.dart';

abstract class Bip122TransactionWrapper
    implements
        TransactionWrapper<Transaction, Bip122KeyPair,
            Bip122BlockchainAccountId, Bip122BlockchainAssetType> {
  static const int _TRANSACTION_VERSION = 2;

  final Transaction transaction;

  @override
  final Bip122KeyPair keyPair;

  @override
  Transaction get innerRawTransaction => transaction;

  Bip122TransactionWrapper(this.transaction, this.keyPair);

  Bip122TransactionWrapper.fromInputAndOutputList(
      List<Input> inputs, List<Output> outputs, Bip122KeyPair signer,
      {int version = _TRANSACTION_VERSION})
      : this(Transaction(inputs: inputs, outputs: outputs, version: version),
            signer);

  void signInputs(List<Utxo> selectedUtxoList) {
    for (var inputIndex = 0;
        inputIndex < transaction.inputs.length;
        inputIndex++) {
      final input = transaction.inputs[inputIndex];
      final prevOutHash = HEX.encode(input.prevOut.hash.reversed.toList());
      final utxo =
          selectedUtxoList.firstWhere((element) => element.txid == prevOutHash);
      _signTransaction(BigInt.from(utxo.value), inputIndex);
    }
  }

  BigInt calculateTransactionFee(BigInt totalUtxoValue) {
    return totalUtxoValue - totalOutputValue;
  }

  void _signTransaction(BigInt value, int vin) {
    transaction.sign(
        inputN: vin, key: keyPair.privateKey.privkey, value: value);
  }

  BigInt get totalOutputValue =>
      transaction.outputs.fold(BigInt.zero, (sum, output) {
        return sum + output.value;
      });

  String get transactionId => transaction.txid;

  String get transactionHex => transaction.toHex();

  // Bip122TransactionWrapper.fromTransactionFromHex(String transactionHex)
  //     : this(Transaction.fromHex(transactionHex));
}

class NativeBip122Transaction extends Bip122TransactionWrapper {
  static const _NATIVE_BITCOIN_ADDRESS =
      '0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee';

  @override
  final Bip122BlockchainAccountId from;

  @override
  final Bip122BlockchainAccountId to;

  @override
  Bip122BlockchainAssetType get assetType => Bip122BlockchainAssetType(
      from.blockchainId,
      Bip122AssetNamespace.slip44,
      Address.fromString(
          _NATIVE_BITCOIN_ADDRESS, from.blockchainId.reference.networkParams));

  final UtxoHelper utxoHelper;

  NativeBip122Transaction.transfer(
    this.from,
    this.to,
    BigInt value,
    List<Utxo> utxoList,
    int feeRate,
    Bip122KeyPair signer,
  )   : utxoHelper = UtxoHelper(utxoList)
          ..filterUnConfirmedUtxo()
          ..sortUtxo()
          ..toSpend(from.accountAddress, to.accountAddress, value, feeRate),
        super.fromInputAndOutputList(
            UtxoHelper(utxoList)
                .generateInputs(signer.privateKey.privkey.pubkey)
                .toList(),
            UtxoHelper(utxoList)
                .generateOutputs(
                    from.accountAddress, to.accountAddress, value, feeRate)
                .toList(),
            signer);
}

abstract class Bip122TransactionWrapperFactory
    implements
        TransactionWrapperFactory<
            Transaction,
            Bip122KeyPair,
            Bip122BlockchainAccountId,
            Bip122BlockchainAssetType,
            Bip122BlockchainAssetId,
            Bip122Rpc> {
  @override
  final Bip122BlockchainAssetId assetId;

  Bip122TransactionWrapperFactory(this.assetId);
}

class NativeBip122TransactionWrapperFactory
    extends Bip122TransactionWrapperFactory {
  NativeBip122TransactionWrapperFactory(Bip122BlockchainAssetId assetId)
      : super(assetId);

  @override
  Future<NativeBip122Transaction> createTransaction(
      Bip122Rpc rpc,
      Bip122KeyPair keyPair,
      Bip122BlockchainAccountId from,
      Bip122BlockchainAccountId to,
      int amount,
      int decimals,
      int transactionSpeed) async {
    final utxoList = await rpc.getUtxoList(from.accountAddress.toString());
    final feeRate = await rpc.getFeeRates();
    return NativeBip122Transaction.transfer(
      from,
      to,
      BigInt.from(amount),
      utxoList,
      feeRate[transactionSpeed],
      keyPair,
    );
  }
}

class Bip122TransactionWrapperFactoryProducer {
  static Bip122TransactionWrapperFactory getFactory(
      Bip122BlockchainAssetId assetId) {
    if (assetId.assetType.assetNamespace == Bip122AssetNamespace.slip44) {
      return NativeBip122TransactionWrapperFactory(assetId);
    } else {
      throw Exception("Unsupported asset namespace");
    }
  }
}
