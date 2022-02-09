abstract class ISchedulerGateway {
  // Включить шедулер
  Future<void> enableScheduler(int interval);

  // Выключить шедулер
  Future<void> disableScheduler();
}
