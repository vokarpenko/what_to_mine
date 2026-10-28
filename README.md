# What to mine?

Калькулятор доходности майнинга. Проект адаптирован для Android на Flutter **3.44.9 / Dart 3.12.2**. Версия Flutter закреплена в `.fvmrc`. iOS не входит в эту миграцию.

Google Play: https://play.google.com/store/apps/details?id=ru.vokarpenko.what_to_mine

## Подготовка Android

Нужны Flutter 3.44.9, JDK 17 или новее и Android SDK: Platform 36, Build Tools 36, NDK 28.2.13676358. Gradle 8.14.3 и Android Gradle Plugin 8.13.2 загружаются автоматически. Минимальная версия устройства — Android 7.0 (API 24).

В Android Studio откройте **Tools → SDK Manager → SDK Tools** и установите **Android SDK Command-line Tools (latest)**, если `flutter doctor` сообщает об их отсутствии. Затем выполните:

```sh
flutter doctor --android-licenses
flutter doctor -v
flutter pub get
flutter devices
```

При использовании FVM сначала выполните `fvm install`, а команды Flutter запускайте через `fvm flutter`.

## Как получить и добавить ключ Minerstat

Старый анонимный API больше не работает: `POST /v2/coins` возвращает HTTP 405, а GET без ключа — HTTP 401. Приложение использует GET и передаёт ключ в заголовке `X-API-Key`.

1. Откройте [портал разработчика Minerstat](https://minerstat.com/developers).
2. Войдите через Google либо укажите email и перейдите по ссылке из письма (**Send magic link**). Также доступна регистрация через **Sign up**.
3. После входа откройте управление API-ключами, создайте ключ и скопируйте его. Названия разделов внутри личного кабинета могут меняться.
4. Передайте ключ при запуске или сборке одним из способов ниже. Замените `YOUR_MINERSTAT_KEY` своим значением.

### Из терминала

```sh
flutter run -d emulator-5554 --dart-define=MINERSTAT_API_KEY=YOUR_MINERSTAT_KEY
```

Для физического устройства замените `emulator-5554` идентификатором из `flutter devices`.

Для локального release APK:

```sh
flutter build apk --release --dart-define=MINERSTAT_API_KEY=YOUR_MINERSTAT_KEY
```

Ключ читается при компиляции. После его изменения остановите приложение и запустите заново; hot reload недостаточно. Ключ также будет доступен фоновому обработчику уведомлений.

### Из Android Studio

1. Откройте **Run → Edit Configurations…**.
2. Выберите конфигурацию типа **Flutter**, запускающую `lib/main.dart`.
3. В поле **Additional run args** добавьте:

   ```text
   --dart-define=MINERSTAT_API_KEY=YOUR_MINERSTAT_KEY
   ```

4. Нажмите **Apply**, выберите Android-устройство и запустите приложение.

Ключ не нужно добавлять в Dart-файлы или `pubspec.yaml`. Не сохраняйте личный ключ в общих конфигурациях репозитория.

### Если данные не загружаются

Без ключа или при HTTP 401/403 приложение показывает сообщение о необходимости действующего ключа Minerstat. HTTP 429 означает превышение лимита запросов. На момент миграции бесплатный тариф включает 100 запросов в месяц и ограничивает ответы 20 результатами; актуальные условия смотрите в [документации Minerstat](https://minerstat.com/api-docs). Фоновые уведомления тоже расходуют запросы.

## Проверки и генерация

```sh
flutter analyze
flutter test
dart run build_runner build --delete-conflicting-outputs
flutter build apk --debug
```

Floor 1.5 ограничивает версии генераторов: совместимый `built_value_generator` — 8.9.2. `pubspec.lock` хранится в репозитории. Генерация работает на Dart 3.12.2, но старый analyzer из зависимостей Floor сообщает о неполной поддержке языка 3.12. Не добавляйте `dependency_overrides` для обхода этих ограничений без проверки генерации и тестов.

APK находятся в `build/app/outputs/flutter-apk/`. Если `android/key.properties` отсутствует, release APK подписывается debug-ключом для локальной проверки. Для обновления приложения в Google Play нужен исходный upload keystore и корректный `android/key.properties`.

## Проверка фонового планировщика

Разрешите уведомления на Android 13+ при включении соответствующего переключателя в настройках приложения.

```sh
adb logcat '*:S' flutter:V TSBackgroundFetch:V
adb shell cmd jobscheduler run -f ru.vokarpenko.what_to_mine 999
```
