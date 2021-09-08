import 'CurrenciesService.dart';
import 'GpuService.dart';

class Services {
  static CurrenciesService? _currenciesService;
  static GpuService? _gpuService;

  Services._();

  static bool isInitialized() {
    return null != _currenciesService && null != _gpuService;
  }

  static void initialize({
    required CurrenciesService currenciesService,
    required GpuService gpuService,
  }) {
    _currenciesService = currenciesService;
    _gpuService = gpuService;
  }

  static CurrenciesService get currenciesService => _currenciesService!;

  static GpuService get gpuService => _gpuService!;
}
