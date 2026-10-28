import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:what_to_mine/src/constants.dart';
import 'package:what_to_mine/src/domain/settings.dart';
import 'package:what_to_mine/src/logic/scheduler_service.dart';
import 'package:what_to_mine/src/logic/services.dart';
import 'package:what_to_mine/src/utils/notificator.dart';
import '../../design/app_ui.dart';
import '../../theme/theme_config.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});
  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  Settings? _settings;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final settings = await Services.settingsService.getSettings();
    if (mounted) setState(() => _settings = settings);
  }

  Future<void> _notifications(bool enabled) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      if (enabled) enabled = await Notificator().requestPermission();
      if (enabled) {
        await Services.schedulerService.enableScheduler(
          SchedulerService.refreshIntervalMinutes,
        );
      } else {
        await Services.schedulerService.disableScheduler();
      }
      await Services.settingsService.setNotificationsIsEnable(enabled);
      await _load();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$error')));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _theme(ThemeMode mode) async {
    await Services.settingsService.setThemeIndex(mode.index);
    currentTheme.switchTheme(mode);
    await _load();
  }

  Future<void> _electricity() async {
    final value = await showModalBottomSheet<double>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      builder: (_) =>
          ElectricitySheet(initialValue: _settings!.electricityCost),
    );
    if (value != null) {
      await Services.settingsService.setElectricityCost(value);
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 32),
          children: [
            PageHeading(
              title: 'settings_appbar_title'.tr(context: context),
              subtitle: 'settings_subtitle'.tr(context: context),
            ),
            if (_settings == null)
              const Padding(
                padding: EdgeInsets.all(50),
                child: Center(child: CircularProgressIndicator()),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _section('mining_preferences'.tr(context: context)),
                    SurfaceCard(
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          SwitchListTile.adaptive(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 9,
                            ),
                            title: Text(
                              'daily_notifications'.tr(context: context),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 5),
                              child: Text(
                                'daily_notifications_hint'.tr(context: context),
                                style: TextStyle(
                                  fontSize: 11,
                                  height: 1.5,
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                            ),
                            value: _settings!.notificationIsEnabled,
                            onChanged: _busy ? null : _notifications,
                            secondary: _icon(
                              context,
                              Icons.notifications_none_rounded,
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Divider(),
                          ),
                          ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            leading: _icon(context, Icons.bolt_rounded),
                            title: Text(
                              'setting_electricity_cost'.tr(context: context),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            subtitle: Text(
                              'per_kwh'.tr(context: context),
                              style: TextStyle(
                                fontSize: 11,
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  usd(_settings!.electricityCost),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontFeatures: numberFeatures,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Icon(
                                  Icons.chevron_right_rounded,
                                  size: 18,
                                ),
                              ],
                            ),
                            onTap: _electricity,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 26),
                    _section('appearance'.tr(context: context)),
                    SurfaceCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.contrast_rounded,
                                color: colors.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'settings_theme'.tr(context: context),
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (final mode in [
                                ThemeMode.light,
                                ThemeMode.dark,
                                ThemeMode.system,
                              ])
                                ChoiceChip(
                                  showCheckmark: false,
                                  avatar: Icon(switch (mode) {
                                    ThemeMode.light =>
                                      Icons.light_mode_outlined,
                                    ThemeMode.dark => Icons.dark_mode_outlined,
                                    ThemeMode.system =>
                                      Icons.phone_android_rounded,
                                  }, size: 17),
                                  label: Text(switch (mode) {
                                    ThemeMode.light => 'theme_light_short'.tr(
                                      context: context,
                                    ),
                                    ThemeMode.dark => 'theme_dark_short'.tr(
                                      context: context,
                                    ),
                                    ThemeMode.system => 'theme_auto_short'.tr(
                                      context: context,
                                    ),
                                  }),
                                  selected: _settings!.themeIndex == mode.index,
                                  onSelected: (_) => _theme(mode),
                                ),
                            ],
                          ),
                          const SizedBox(height: 22),
                          const Divider(),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Icon(
                                Icons.language_rounded,
                                color: colors.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'settings_language'.tr(context: context),
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                ),
                              ),
                              DropdownButton<String>(
                                value: context.locale.languageCode,
                                underline: const SizedBox.shrink(),
                                borderRadius: BorderRadius.circular(16),
                                items: const [
                                  DropdownMenuItem(
                                    value: 'en',
                                    child: Text(
                                      'English',
                                      style: TextStyle(fontSize: 13),
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: 'ru',
                                    child: Text(
                                      'Русский',
                                      style: TextStyle(fontSize: 13),
                                    ),
                                  ),
                                ],
                                onChanged: (value) {
                                  if (value != null) {
                                    context.setLocale(Locale(value));
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 26),
                    SurfaceCard(
                      color: colors.primaryContainer.withValues(alpha: .45),
                      borderColor: Colors.transparent,
                      child: Row(
                        children: [
                          Icon(
                            Icons.auto_awesome_rounded,
                            color: colors.primary,
                            size: 25,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'What to mine',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'version_label'.tr(args: [appVersion]),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: colors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _section(String title) => Padding(
    padding: const EdgeInsets.only(left: 2, bottom: 12),
    child: Text(
      title.toUpperCase(),
      style: TextStyle(
        fontSize: 10,
        letterSpacing: 1.3,
        fontWeight: FontWeight.w800,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    ),
  );
  Widget _icon(BuildContext context, IconData icon) => Container(
    width: 38,
    height: 38,
    decoration: BoxDecoration(
      color: Theme.of(
        context,
      ).colorScheme.primaryContainer.withValues(alpha: .5),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
  );
}

class ElectricitySheet extends StatefulWidget {
  final double initialValue;
  const ElectricitySheet({required this.initialValue, super.key});
  @override
  State<ElectricitySheet> createState() => _ElectricitySheetState();
}

class _ElectricitySheetState extends State<ElectricitySheet> {
  late final TextEditingController _controller;
  final _form = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.initialValue.toStringAsFixed(2),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
    child: Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        4,
        24,
        24 +
            MediaQuery.viewInsetsOf(context).bottom +
            MediaQuery.paddingOf(context).bottom,
      ),
      child: Form(
        key: _form,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'setting_electricity_cost'.tr(context: context),
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'electricity_hint'.tr(context: context),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            LabeledField(
              label: 'setting_electricity_cost'.tr(context: context),
              child: TextFormField(
                textInputAction: TextInputAction.done,
                controller: _controller,
                autofocus: true,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  prefixText: '\$ ',
                  suffixText: '/ kWh',
                ),
                validator: (value) {
                  final cost = double.tryParse(
                    (value ?? '').replaceAll(',', '.'),
                  );
                  return cost == null ||
                          !cost.isFinite ||
                          cost < 0 ||
                          cost > 100
                      ? 'invalid_electricity'.tr(context: context)
                      : null;
                },
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: [0.05, 0.10, 0.15, 0.20]
                  .map(
                    (value) => ActionChip(
                      label: Text(usd(value)),
                      onPressed: () =>
                          _controller.text = value.toStringAsFixed(2),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  if (_form.currentState!.validate()) {
                    Navigator.pop(
                      context,
                      double.parse(_controller.text.replaceAll(',', '.')),
                    );
                  }
                },
                child: Text('save_changes'.tr(context: context)),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
