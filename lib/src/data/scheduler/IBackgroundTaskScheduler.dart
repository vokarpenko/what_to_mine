abstract class IBackgroundTaskScheduler{
  // Включить планироващик задач
  Future<void> enable(int minimumFetchInterval);

  // Отключить планироващик задач
  Future<void> disable();

}