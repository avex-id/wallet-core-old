import 'dart:convert';
import 'package:http/http.dart' as http;

// const apiUrl = "https://mempool.space/testnet/api";

class MempoolApiClient {
  final String apiUrl;

  MempoolApiClient({required this.apiUrl});

  Future<AddressData> fetchAddressData(String address) async {
    final url = Uri.parse("$apiUrl/address/$address");
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = AddressData.fromJson(json.decode(response.body));
        return data;
      } else {
        throw Exception("Request failed with status: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  Future<List<TransactionData>> fetchTransactionHistory(String address) async {
    final url = Uri.parse("$apiUrl/address/$address/txs");
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> transactionList = json.decode(response.body);
        return transactionList
            .map((item) => TransactionData.fromJson(item))
            .toList();
      } else {
        throw Exception("Request failed with status: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  Future<List<TransactionData>> fetchConfirmedTransactionHistory(
      String address) async {
    final url = Uri.parse("$apiUrl/address/$address/txs/chain");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> transactionList = json.decode(response.body);
        return transactionList
            .map((item) => TransactionData.fromJson(item))
            .toList();
      } else {
        throw Exception("Request failed with status: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  Future<List<TransactionData>> fetchUnconfirmedTransactionHistory(
      String address) async {
    final url = Uri.parse("$apiUrl/address/$address/txs/mempool");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> transactionList = json.decode(response.body);
        return transactionList
            .map((item) => TransactionData.fromJson(item))
            .toList();
      } else {
        throw Exception("Request failed with status: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  Future<List<Utxo>> fetchUtxoList(String address) async {
    final url = Uri.parse("$apiUrl/address/$address/utxo");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> utxoList = json.decode(response.body);
        return utxoList.map((item) => Utxo.fromJson(item)).toList();
      } else {
        throw Exception("Request failed with status: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  Future<RecommendedFees> fetchRecommendedFees() async {
    final url = Uri.parse("$apiUrl/v1/fees/recommended");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return RecommendedFees.fromJson(data);
      } else {
        throw Exception("Request failed with status: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  Future<TransactionData> fetchTransactionDetails(String txid) async {
    final url = Uri.parse("$apiUrl/tx/$txid");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return TransactionData.fromJson(data);
      } else {
        throw Exception("Request failed with status: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  Future<String> fetchTransactionHex(String txid) async {
    final url = Uri.parse("$apiUrl/tx/$txid/hex");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return response.body;
      } else {
        throw Exception("Request failed with status: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  Future<TransactionBroadcastResponse> postTransactionHex(
      String rawTransactionHex) async {
    final url = Uri.parse("$apiUrl/tx");
    final response = await http.post(
      url,
      body: rawTransactionHex,
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return TransactionBroadcastResponse.fromJson(data);
    } else {
      throw Exception("Request failed with status: ${response.statusCode}");
    }
  }
}

class AddressData {
  final String address;
  final ChainStats chainStats;
  final MempoolStats mempoolStats;

  AddressData({
    required this.address,
    required this.chainStats,
    required this.mempoolStats,
  });

  factory AddressData.fromJson(Map<String, dynamic> json) {
    return AddressData(
      address: json['address'],
      chainStats: ChainStats.fromJson(json['chain_stats']),
      mempoolStats: MempoolStats.fromJson(json['mempool_stats']),
    );
  }
}

class ChainStats {
  final int fundedTxoCount;
  final int fundedTxoSum;
  final int spentTxoCount;
  final int spentTxoSum;
  final int txCount;

  ChainStats({
    required this.fundedTxoCount,
    required this.fundedTxoSum,
    required this.spentTxoCount,
    required this.spentTxoSum,
    required this.txCount,
  });

  factory ChainStats.fromJson(Map<String, dynamic> json) {
    return ChainStats(
      fundedTxoCount: json['funded_txo_count'],
      fundedTxoSum: json['funded_txo_sum'],
      spentTxoCount: json['spent_txo_count'],
      spentTxoSum: json['spent_txo_sum'],
      txCount: json['tx_count'],
    );
  }
}

class MempoolStats {
  final int fundedTxoCount;
  final int fundedTxoSum;
  final int spentTxoCount;
  final int spentTxoSum;
  final int txCount;

  MempoolStats({
    required this.fundedTxoCount,
    required this.fundedTxoSum,
    required this.spentTxoCount,
    required this.spentTxoSum,
    required this.txCount,
  });

  factory MempoolStats.fromJson(Map<String, dynamic> json) {
    return MempoolStats(
      fundedTxoCount: json['funded_txo_count'],
      fundedTxoSum: json['funded_txo_sum'],
      spentTxoCount: json['spent_txo_count'],
      spentTxoSum: json['spent_txo_sum'],
      txCount: json['tx_count'],
    );
  }
}

class TransactionData {
  final String txid;
  final int version;
  final int locktime;
  final List<Vin> vin;
  final List<Vout> vout;
  final int size;
  final int weight;
  final int fee;
  final TransactionStatus status;

  TransactionData({
    required this.txid,
    required this.version,
    required this.locktime,
    required this.vin,
    required this.vout,
    required this.size,
    required this.weight,
    required this.fee,
    required this.status,
  });

  factory TransactionData.fromJson(Map<String, dynamic> json) {
    return TransactionData(
      txid: json['txid'],
      version: json['version'],
      locktime: json['locktime'],
      vin: List<Vin>.from(json['vin'].map((x) => Vin.fromJson(x))),
      vout: List<Vout>.from(json['vout'].map((x) => Vout.fromJson(x))),
      size: json['size'],
      weight: json['weight'],
      fee: json['fee'],
      status: TransactionStatus.fromJson(json['status']),
    );
  }
}

class Vin {
  final String txid;
  final int vout;
  final Prevout prevout;
  // final String scriptsig;
  // final String scriptsigAsm;
  // final List<String> witness;
  // final bool isCoinbase;
  // final int sequence;

  Vin({
    required this.txid,
    required this.vout,
    required this.prevout,
    // required this.scriptsig,
    // required this.scriptsigAsm,
    // required this.witness,
    // required this.isCoinbase,
    // required this.sequence,
  });

  factory Vin.fromJson(Map<String, dynamic> json) {
    return Vin(
      txid: json['txid'],
      vout: json['vout'],
      prevout: Prevout.fromJson(json['prevout']),
      // scriptsig: json['scriptsig'],
      // scriptsigAsm: json['scriptsig_asm'],
      // witness: List<String>.from(json['witness']),
      // isCoinbase: json['is_coinbase'],
      // sequence: json['sequence'],
    );
  }
}

class Prevout {
  // final String scriptpubkey;
  // final String scriptpubkeyAsm;
  // final String scriptpubkeyType;
  final String scriptpubkeyAddress;
  final int value;

  Prevout({
    // required this.scriptpubkey,
    // required this.scriptpubkeyAsm,
    // required this.scriptpubkeyType,
    required this.scriptpubkeyAddress,
    required this.value,
  });

  factory Prevout.fromJson(Map<String, dynamic> json) {
    return Prevout(
      // scriptpubkey: json['scriptpubkey'],
      // scriptpubkeyAsm: json['scriptpubkey_asm'],
      // scriptpubkeyType: json['scriptpubkey_type'],
      scriptpubkeyAddress: json['scriptpubkey_address'],
      value: json['value'],
    );
  }
}

class Vout {
  // final String scriptpubkey;
  // final String scriptpubkeyAsm;
  // final String scriptpubkeyType;
  final String scriptpubkeyAddress;
  final int value;

  Vout({
    // required this.scriptpubkey,
    // required this.scriptpubkeyAsm,
    // required this.scriptpubkeyType,
    required this.scriptpubkeyAddress,
    required this.value,
  });

  factory Vout.fromJson(Map<String, dynamic> json) {
    return Vout(
      // scriptpubkey: json['scriptpubkey'],
      // scriptpubkeyAsm: json['scriptpubkey_asm'],
      // scriptpubkeyType: json['scriptpubkey_type'],
      scriptpubkeyAddress: json['scriptpubkey_address'],
      value: json['value'],
    );
  }
}

class TransactionStatus {
  final bool confirmed;
  final int? blockHeight;
  final String? blockHash;
  final int? blockTime;

  TransactionStatus({
    required this.confirmed,
    this.blockHeight,
    this.blockHash,
    this.blockTime,
  });

  factory TransactionStatus.fromJson(Map<String, dynamic> json) {
    return TransactionStatus(
      confirmed: json['confirmed'],
      blockHeight: json['block_height'],
      blockHash: json['block_hash'],
      blockTime: json['block_time'],
    );
  }
}

class Utxo {
  final String txid;
  final int vout;
  final UtxoStatus status;
  final int value;

  Utxo({
    required this.txid,
    required this.vout,
    required this.status,
    required this.value,
  });

  factory Utxo.fromJson(Map<String, dynamic> json) {
    return Utxo(
      txid: json['txid'],
      vout: json['vout'],
      status: UtxoStatus.fromJson(json['status']),
      value: json['value'],
    );
  }
}

class UtxoStatus {
  final bool confirmed;
  final int? blockHeight;
  final String? blockHash;
  final int? blockTime;

  UtxoStatus({
    required this.confirmed,
    this.blockHeight,
    this.blockHash,
    this.blockTime,
  });

  factory UtxoStatus.fromJson(Map<String, dynamic> json) {
    return UtxoStatus(
      confirmed: json['confirmed'],
      blockHeight: json['block_height'],
      blockHash: json['block_hash'],
      blockTime: json['block_time'],
    );
  }
}

class RecommendedFees {
  final int fastestFee;
  final int halfHourFee;
  final int hourFee;
  final int economyFee;
  final int minimumFee;

  RecommendedFees({
    required this.fastestFee,
    required this.halfHourFee,
    required this.hourFee,
    required this.economyFee,
    required this.minimumFee,
  });

  factory RecommendedFees.fromJson(Map<String, dynamic> json) {
    return RecommendedFees(
      fastestFee: json['fastestFee'],
      halfHourFee: json['halfHourFee'],
      hourFee: json['hourFee'],
      economyFee: json['economyFee'],
      minimumFee: json['minimumFee'],
    );
  }
}

class TransactionBroadcastResponse {
  final String txid;

  TransactionBroadcastResponse({
    required this.txid,
  });

  factory TransactionBroadcastResponse.fromJson(Map<String, dynamic> json) {
    return TransactionBroadcastResponse(
      txid: json['txid'],
    );
  }
}
