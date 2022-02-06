import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:http/http.dart';

import '../../domain/currency/CryptoCurrency.dart';
import 'IMinerStatClient.dart';

class MinerStatClient implements IMinerStatClient {
  final Client _client;

  MinerStatClient() : _client = Client();

  @override
  Future<List<CryptoCurrency>> getCryptoCurrenciesListFromApi() async {
    //SHA-256,Cuckarood29,Cuckatoo31,Cuckatoo32,CuckooCycle,Cortex,Equihash,Equihash(125,4),Equihash(144,5),BeamHash,Ethash,Etchash,MTP,KAWPOW,RandomX,Eaglesong,Autolykos2,Darkcoin
    var url = Uri.parse('https://api.minerstat.com/v2/coins');
    try {
      var response = await _client.post(url);
      print('getCryptoCurrenciesList Response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        // Если сервер вернул 200 значит все успешно, парсим JSON.
        List<dynamic> parsedListJson = jsonDecode(response.body);
        List<CryptoCurrency> result = List<CryptoCurrency>.from(parsedListJson.map((i) => CryptoCurrency.fromJson(i)));
        //_client.close();
        return result;
      } else {
        //_client.close();
        print('error_load_data'.tr());
        throw Exception('error_load_data'.tr());
      }
    } on Exception catch (e) {
      print('Exception post: ${e.toString()}');
      return Future.error(e);
    }
  }
}
