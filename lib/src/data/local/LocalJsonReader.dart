import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:what_to_mine/src/data/local/ILocalJsonReader.dart';
import 'package:what_to_mine/src/domain/gpu/Gpu.dart';
import 'package:what_to_mine/src/serializers.dart';

class LocalJsonReader implements ILocalJsonReader {
  // Получить список видеокарт
  @override
  Future<List<Gpu>?> getGPUList() async {
    final String response = await rootBundle.loadString('assets/json/GPUs.json');

    try {
      List<dynamic> json = jsonDecode(response);
      //List<Map<String, dynamic>> json = jsonDecode(response);
      List<Gpu> result = [];
      result = json.map<Gpu>((e) => serializers.deserializeWith<Gpu>(Gpu.serializer, e)!).toList();
      return result;
    } on Exception catch (exception) {
      print(exception.toString());
      return null;
    }
  }
}
