import 'dart:async';

import 'package:what_to_mine/src/domain/gpu/Gpu.dart';
import 'package:what_to_mine/src/domain/gpu/UsedGpu.dart';
import 'package:what_to_mine/src/logic/Services.dart';

class GpuListViewModel {
  final StreamController<bool> _isLoading = StreamController<bool>();
  final StreamController<String> _errorMessage = StreamController<String>();
  final StreamController<bool> _addGPU = StreamController<bool>();
  final StreamController<List<Gpu>> _gpus = StreamController<List<Gpu>>();
  final StreamController<List<UsedGpu>> _usedGpus = StreamController<List<UsedGpu>>();

  Stream<bool> get isLoading => _isLoading.stream;
  Stream<String> get errorMessage => _errorMessage.stream;
  Stream<bool> get addGPU => _addGPU.stream;
  Stream<List<Gpu>> get gpus => _gpus.stream;
  Stream<List<UsedGpu>> get usedGpus => _usedGpus.stream;

  // Состояние viewModel
  List<Gpu>? _listGPU;

  void onViewInitState() async {
    Services.gpuService.onUsedGpuChanged().listen((_) => _getData());
    _getData();
  }

  void _getData() async {
    Services.gpuService.getGPUList().then((gpuList) {
      if (gpuList != null) {
        _listGPU = gpuList;
        gpuList = onFilterGPUListByVendor('nvidia');
        _gpus.add(gpuList);
      }
    });

    Services.gpuService.getUsedGPUList().then((usedGpuList) {
      if (usedGpuList != null)
        _usedGpus.add(usedGpuList);
      else
        _usedGpus.add([]);
    });
  }

  void onViewDispose() async {
    _isLoading.close();
    _errorMessage.close();
    _addGPU.close();
    _gpus.close();
    _usedGpus.close();
  }

  void onClickAddGPU() async {
    _addGPU.add(true);
  }

  List<Gpu> onFilterGPUListByVendor(String vendor) {
    List<Gpu> result = _listGPU!.where((element) => element.vendor == vendor.toLowerCase()).toList();
    return result;
  }

  void onAddGPU(Gpu gpu, int quantity) async {
    UsedGpu newUsedGpu = (UsedGpuBuilder()
          ..gpuData = gpu.toBuilder()
          ..quantity = quantity)
        .build();
    Services.gpuService.addUsedGpu(newUsedGpu).then((value) => null).catchError((Object error) {
      _errorMessage.add("Ошибка добавления видеокарты: " + error.toString());
    });
  }

  void deleteUsedGpu(String id) async {
    Services.gpuService.deleteUsedGpu(id).then((value) => null).catchError((Object error) {
      _errorMessage.add("Ошибка удаления видеокарты: " + error.toString());
    });
  }
}
