import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:what_to_mine/src/domain/gpu/Gpu.dart';
import 'package:what_to_mine/src/domain/gpu/UsedGpu.dart';
import 'package:what_to_mine/src/logic/Services.dart';

class GpuListViewModel {
  final StreamController<String> _errorMessage = StreamController<String>();
  final StreamController _addGpu = StreamController();
  final StreamController<List<UsedGpu>> _usedGpus = StreamController<List<UsedGpu>>();

  Stream<String> get errorMessage => _errorMessage.stream;

  Stream get addGpu => _addGpu.stream;

  Stream<List<UsedGpu>> get usedGpus => _usedGpus.stream;

  List<Gpu>? _listOfAllGpu;

  void onViewInitState() async {
    Services.gpuService.onUsedGpuChanged().listen((_) => _getData());
    _getData();
  }

  void _getData() async {
    _listOfAllGpu = await Services.gpuService.getGPUList();
    Services.gpuService.getUsedGPUList().then((usedGpuList) {
      if (usedGpuList != null) {
        _usedGpus.add(usedGpuList);
      } else {
        _usedGpus.add([]);
      }
    }).catchError((error) {
      String errorMessage = 'error_get_gpu_list'.tr() + '.\n${error.toString()}';
      print(errorMessage);
      _errorMessage.add(errorMessage);
    });
  }

  void onViewDispose() async {
    this
      .._errorMessage.close()
      .._addGpu.close()
      .._usedGpus.close();
  }

  void onClickAddGPU() async {
    _addGpu.add('');
  }

  List<Gpu> onFilterGPUListByVendor(String vendor) {
    List<Gpu> result = _listOfAllGpu!.where((element) => element.vendor == vendor.toLowerCase()).toList();
    return result;
  }

  void onAddGPU(Gpu gpu, int quantity) async {
    UsedGpu newUsedGpu = (UsedGpuBuilder()
          ..gpuData = gpu.toBuilder()
          ..quantity = quantity)
        .build();
    Services.gpuService.addUsedGpu(newUsedGpu).then((value) => null).catchError((Object error) {
      _errorMessage.add('error_gpu_add'.tr() + '.\n${error.toString()}');
    });
  }

  void deleteUsedGpu(String id) async {
    Services.gpuService.deleteUsedGpu(id).then((value) => null).catchError((Object error) {
      _errorMessage.add('error_gpu_delete'.tr() + '.\n${error.toString()}');
    });
  }
}
