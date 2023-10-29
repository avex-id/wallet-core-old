import 'package:ntcdcrypto/ntcdcrypto.dart';

class ShamirSecretManager {
  static final _SSS = SSS();
  static const String _NOT_ENOUGH_SHARES = 'Not enough shares';
  static const String _NEGATIVE_VALUE = 'Minimum and shares cannot be negative';
  static const String _INVALID_MINIMUM = 'Minimum must be <= shares';
  final int minimum;
  final int shares;

  ShamirSecretManager({this.minimum = 2, this.shares = 3}) {
    if (minimum < 0 || shares < 0) throw ArgumentError(_NEGATIVE_VALUE);
    if (minimum > shares) throw ArgumentError(_INVALID_MINIMUM);
  }

  List<String> generate({required secret, bool isBase64 = false}) {
    return _SSS.create(minimum, shares, secret, isBase64);
  }

  String combine({required List<String> shares, bool isBase64 = false}) {
    if (shares.length < minimum) throw ArgumentError(_NOT_ENOUGH_SHARES);
    return _SSS.combine(shares, isBase64);
  }
}
