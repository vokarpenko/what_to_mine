import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../design/app_ui.dart';
import '../gpu/gpu_list_screen.dart';
import '../hashrate/hashrate_screen.dart';

class RigScreen extends StatefulWidget {
  const RigScreen({super.key});
  @override
  State<RigScreen> createState() => _RigScreenState();
}

class _RigScreenState extends State<RigScreen> {
  int _index = 0;
  final List<Widget?> _screens = [const GpuListScreen(embedded: true), null];

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      bottom: false,
      child: Column(
        children: [
          PageHeading(
            title: 'home_rig'.tr(context: context),
            subtitle: 'rig_subtitle'.tr(context: context),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
            child: SizedBox(
              width: double.infinity,
              child: SegmentedButton<int>(
                segments: [
                  ButtonSegment(
                    value: 0,
                    icon: const Icon(Icons.memory_rounded, size: 18),
                    label: Text('home_gpus'.tr(context: context)),
                  ),
                  ButtonSegment(
                    value: 1,
                    icon: const Icon(Icons.tune_rounded, size: 18),
                    label: Text('home_hashrate'.tr(context: context)),
                  ),
                ],
                selected: {_index},
                showSelectedIcon: false,
                onSelectionChanged: (selection) => setState(() {
                  _index = selection.first;
                  _screens[1] ??= _index == 1
                      ? const HashrateScreen(embedded: true)
                      : null;
                }),
                style: ButtonStyle(
                  visualDensity: VisualDensity.standard,
                  padding: const WidgetStatePropertyAll(
                    EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: IndexedStack(
              index: _index,
              children: _screens
                  .map((screen) => screen ?? const SizedBox.shrink())
                  .toList(),
            ),
          ),
        ],
      ),
    ),
  );
}
