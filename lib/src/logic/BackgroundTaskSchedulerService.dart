import 'gateway/IGateway.dart';

class BackgroundTaskSchedulerService {
  final IGateway _gateway;
  BackgroundTaskSchedulerService({required IGateway gateway}) : _gateway = gateway {
    _initializeScheduler();
  }

  Future<void> enableScheduler(int interval) async {
    return _gateway.enableScheduler(interval);
  }

  Future<void> disableScheduler() async {
    return _gateway.disableScheduler();
  }

  void _initializeScheduler() async {
    if (await _gateway.isSchedulerEnabled()) {
      enableScheduler(15);
    }
  }
}
