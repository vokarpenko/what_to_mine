#What to mine? 
Калькулятор майнинга с использованием открытого api.
Google play : https://play.google.com/store/apps/details?id=ru.vokarpenko.what_to_mine


Для тестирования шедулера
adb logcat *:S flutter:V, TSBackgroundFetch:V
adb shell cmd jobscheduler run -f ru.vokarpenko.what_to_mine 999
