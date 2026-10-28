import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:what_to_mine/src/domain/gpu/gpu.dart';
import 'package:what_to_mine/src/domain/gpu/used_gpu.dart';
import 'package:what_to_mine/src/logic/services.dart';

class GpuListViewModel {
  final StreamController<String> _errorMessage = StreamController<String>();
  final StreamController _addGpu = StreamController();
  final StreamController<List<UsedGpu>> _usedGpus =
      StreamController<List<UsedGpu>>();

  Stream<String> get errorMessage => _errorMessage.stream;

  Stream get addGpu => _addGpu.stream;

  Stream<List<UsedGpu>> get usedGpus => _usedGpus.stream;

  List<Gpu>? _listOfAllGpu;

  void onViewInitState() async {
    Services.gpuService.onUsedGpuChanged().listen((_) => _getData());
    _getData();
  }

  void _getData() async {
    try {
      final used = await Services.gpuService.getUsedGPUList();
      if (!_usedGpus.isClosed) _usedGpus.add(used ?? []);
    } catch (error) {
      if (!_errorMessage.isClosed) {
        _errorMessage.add('${'error_get_gpu_list'.tr()}.\n$error');
      }
    }
  }

  void onViewDispose() async {
    this
      .._errorMessage.close()
      .._addGpu.close()
      .._usedGpus.close();
  }

  bool _catalogLoading = false;

  void onClickAddGPU() async {
    if (_catalogLoading) return;
    _catalogLoading = true;
    try {
      _listOfAllGpu = await Services.gpuService.getGPUList();
      if (_listOfAllGpu == null || _listOfAllGpu!.isEmpty) {
        throw StateError('error_get_gpu_list'.tr());
      }
      if (!_addGpu.isClosed) _addGpu.add('');
    } catch (error) {
      if (!_errorMessage.isClosed) _errorMessage.add('$error');
    } finally {
      _catalogLoading = false;
    }
  }

  List<String> get vendors =>
      (_listOfAllGpu ?? []).map((gpu) => gpu.vendor).toSet().toList()..sort();

  List<Gpu> onFilterGPUListByVendor(String vendor) {
    List<Gpu> result = _listOfAllGpu!
        .where((element) => element.vendor == vendor.toLowerCase())
        .toList();
    return result;
  }

  void onAddGPU(Gpu gpu, int quantity) async {
    UsedGpu newUsedGpu =
        (UsedGpuBuilder()
              ..gpuData = gpu.toBuilder()
              ..quantity = quantity)
            .build();
    Services.gpuService.addUsedGpu(newUsedGpu).then((value) => null).catchError(
      (Object error) {
        _errorMessage.add('${'error_gpu_add'.tr()}.\n${error.toString()}');
      },
    );
  }

  void deleteUsedGpu(String id) async {
    Services.gpuService.deleteUsedGpu(id).then((value) => null).catchError((
      Object error,
    ) {
      _errorMessage.add('${'error_gpu_delete'.tr()}.\n${error.toString()}');
    });
  }
}
