import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../domain/currency/CryptoCurrency.dart';
import 'IMinerStatClient.dart';

class MinerStatClient implements IMinerStatClient {
  //final Uri _cryptoCurrencyListUrl = Uri(path: "https://api.minerstat.com/v2/coins");
  MinerStatClient();

  @override
  Future<List<CryptoCurrency>> getCryptoCurrenciesList() async {
    // HTTP запрос
    var client = http.Client();

    //var url = Uri.parse('https://api.minerstat.com/v2/coins?list=BTC,LTC,DOGE,ERG,XMR,ETH,ETC,RVN');

    var url = Uri.parse(
        'https://api.minerstat.com/v2/coins?algo=Cuckarood29,Cuckatoo31,Cuckatoo32,CuckooCycle,CuckooCortex,Equihash,Equihash,Equihash,BeamHash,Ethash,Etchash,MTP,KAWPOW,RandomX,Eaglesong,Autolykos2');
    var response = await client.post(url);
    print('getCryptoCurrenciesList Response status: ${response.statusCode}');
    if (response.statusCode == 200) {
      // Если сервер вернул 200 значит все успешно, парсим JSON.

      List<dynamic> parsedListJson = jsonDecode(response.body);
      List<CryptoCurrency> result = List<CryptoCurrency>.from(parsedListJson.map((i) => CryptoCurrency.fromJson(i)));
      client.close();
      return result;
    } else {
      client.close();
      print('Failed to load data');
      throw Exception('Failed to load data');
    }
  }
}
