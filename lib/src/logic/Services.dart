import 'package:what_to_mine/src/logic/HashAlgorithmService.dart';

import 'CurrenciesService.dart';
import 'GpuService.dart';

class Services {
  static CurrenciesService? _currenciesService;
  static GpuService? _gpuService;
  static HashAlgorithmService? _hashAlgorithmService;
  Services._();

  static bool isInitialized() {
    return null != _currenciesService && null != _gpuService && null != _hashAlgorithmService;
  }

  static void initialize({
    required CurrenciesService currenciesService,
    required GpuService gpuService,
    required HashAlgorithmService hashAlgorithmService,
  }) {
    _currenciesService = currenciesService;
    _gpuService = gpuService;
    _hashAlgorithmService = hashAlgorithmService;
  }

  static CurrenciesService get currenciesService => _currenciesService!;

  static GpuService get gpuService => _gpuService!;

  static HashAlgorithmService get hashAlgorithmService => _hashAlgorithmService!;
}
