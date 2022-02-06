import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:what_to_mine/src/data/jsonReader/IJsonReader.dart';
import 'package:what_to_mine/src/domain/algorithms/HashAlgorithm.dart';
import 'package:what_to_mine/src/domain/gpu/Gpu.dart';
import 'package:what_to_mine/src/serializers.dart';

class JsonReader implements IJsonReader {
  // Получить список видеокарт
  @override
  Future<List<Gpu>?> getGPUList() async {
    String jsonGpus = await rootBundle.loadString('assets/json/gpu.json');

    try {
      List<dynamic> json = jsonDecode(jsonGpus);
      List<Gpu> result = [];
      result = json.map<Gpu>((e) => serializers.deserializeWith<Gpu>(Gpu.serializer, e)!).toList();
      return result;
    } on Exception catch (exception) {
      print(exception.toString());
      return null;
    }
  }

  // Получить список алгоритмов
  @override
  Future<List<HashAlgorithm>> getHashAlgorithmsWithZeroValues() async {
    String jsonGpus = await rootBundle.loadString('assets/json/algos.json');
    List<dynamic> json = jsonDecode(jsonGpus);
    List<HashAlgorithm> result = [];
    result = json
        .map<HashAlgorithm>((e) => serializers.deserializeWith<HashAlgorithm>(HashAlgorithm.serializer, e)!)
        .toList();
    return result;
  }
}
