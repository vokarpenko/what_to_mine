import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:http/http.dart';
import 'package:what_to_mine/src/data/client/api_client.dart';
import 'package:what_to_mine/src/domain/currency/crypto_currency.dart';

class MinerStatClient implements ApiClient {
  final Client _client;
  final String apiKey;

  MinerStatClient({
    Client? client,
    this.apiKey = const String.fromEnvironment('MINERSTAT_API_KEY'),
  }) : _client = client ?? Client();

  @override
  Future<List<CryptoCurrency>> getCryptoCurrenciesListFromApi() async {
    if (apiKey.isEmpty) {
      throw Exception('error_minerstat_api_key'.tr());
    }

    final response = await _client
        .get(
          Uri.parse('https://api.minerstat.com/v2/coins'),
          headers: {'X-API-Key': apiKey},
        )
        .timeout(const Duration(seconds: 30));
    if (response.statusCode == 401 || response.statusCode == 403) {
      throw Exception('error_minerstat_api_key'.tr());
    }
    if (response.statusCode != 200) {
      throw Exception(
        '${'error_load_data'.tr()} (HTTP ${response.statusCode})',
      );
    }

    final parsedListJson = jsonDecode(response.body) as List<dynamic>;
    return parsedListJson
        .map((item) => CryptoCurrency.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
