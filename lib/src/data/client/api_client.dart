import 'package:what_to_mine/src/domain/algorithms/hash_algorithm.dart';
import 'package:what_to_mine/src/domain/currency/crypto_currency.dart';
import 'package:what_to_mine/src/domain/currency/earnings.dart';
import 'package:what_to_mine/src/domain/gpu/gpu.dart';

abstract class ApiClient {
  Future<List<CryptoCurrency>> getCryptoCurrenciesListFromApi({
    bool forceRefresh = false,
  });

  Future<List<Gpu>> getGPUListFromApi();

  Future<List<HashAlgorithm>> getHashAlgorithmsFromApi();

  Future<List<Earnings>> calculateEarningsFromApi({
    required List<HashAlgorithm> algorithms,
    required double electricityCost,
    bool forceRefresh = false,
  });
}
