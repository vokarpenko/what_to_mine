import 'package:built_value/serializer.dart';
import 'package:built_value/standard_json_plugin.dart';
import 'package:what_to_mine/src/domain/gpu/Gpu.dart';
import 'package:what_to_mine/src/domain/gpu/UsedGpu.dart';

import 'domain/algorithms/Algos.dart';

part 'serializers.g.dart';

//add all of the built value types that require serialization
@SerializersFor([Gpu, Algos, UsedGpu])
final Serializers serializers = (_$serializers.toBuilder()..addPlugin(StandardJsonPlugin())).build();
