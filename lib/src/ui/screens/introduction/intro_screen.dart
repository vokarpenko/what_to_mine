import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:what_to_mine/src/logic/services.dart';
import '../../design/app_ui.dart';
import '../screen_routes.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});
  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final _cost = TextEditingController(text: '0.10');
  final _form = GlobalKey<FormState>();
  bool _busy = false;

  @override
  void dispose() {
    _cost.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    if (!_form.currentState!.validate() || _busy) return;
    setState(() => _busy = true);
    try {
      final settings = await Services.settingsService.getSettings();
      settings.electricityCost = double.parse(_cost.text.replaceAll(',', '.'));
      settings.isFirstRun = false;
      await Services.settingsService.setSettings(settings);
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          ScreenRoutes.homeScreen,
          (_) => false,
        );
      }
    } catch (error) {
      if (mounted) {
        setState(() => _busy = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$error')));
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.all(28),
        child: Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: ink,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.bolt_rounded, color: mint),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'WHAT TO MINE',
                      style: TextStyle(
                        fontSize: 11,
                        letterSpacing: 2,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '2.0',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 36),
              Text(
                'welcome_title'.tr(context: context),
                style: Theme.of(
                  context,
                ).textTheme.headlineLarge?.copyWith(fontSize: 40, height: 1.12),
              ),
              const SizedBox(height: 16),
              Text(
                'welcome_subtitle'.tr(context: context),
                style: TextStyle(
                  fontSize: 15,
                  height: 1.6,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 30),
              _feature(
                context,
                Icons.memory_rounded,
                'welcome_hardware',
                'welcome_hardware_body',
              ),
              _feature(
                context,
                Icons.star_outline_rounded,
                'welcome_favorites',
                'welcome_favorites_body',
              ),
              _feature(
                context,
                Icons.bolt_rounded,
                'welcome_energy',
                'welcome_energy_body',
              ),
              const SizedBox(height: 20),
              LabeledField(
                label: 'setting_electricity_cost'.tr(context: context),
                child: TextFormField(
                  textInputAction: TextInputAction.done,
                  controller: _cost,
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
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _busy ? null : _continue,
                  child: Text('open_dashboard'.tr(context: context)),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  Widget _feature(
    BuildContext context,
    IconData icon,
    String title,
    String description,
  ) => Padding(
    padding: const EdgeInsets.only(bottom: 20),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.primaryContainer.withValues(alpha: .6),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
            size: 22,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title.tr(context: context),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(
                description.tr(context: context),
                style: TextStyle(
                  fontSize: 12,
                  height: 1.6,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
