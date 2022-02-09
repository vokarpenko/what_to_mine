import 'package:built_collection/built_collection.dart';
import 'package:built_value/serializer.dart';
import 'package:built_value/standard_json_plugin.dart';

import 'domain/algorithms/hash_algorithm.dart';
import 'domain/gpu/gpu.dart';
import 'domain/gpu/used_gpu.dart';

part 'serializers.g.dart';

//add all of the built value types that require serialization
@SerializersFor([Gpu, UsedGpu, HashAlgorithm])
final Serializers serializers = (_$serializers.toBuilder()..addPlugin(StandardJsonPlugin())).build();
