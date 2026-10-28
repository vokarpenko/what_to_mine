import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:what_to_mine/src/domain/gpu/gpu.dart';
import 'package:what_to_mine/src/domain/gpu/gpu_catalog_order.dart';
import '../../design/app_ui.dart';

class GpuModelPicker extends StatefulWidget {
  final List<Gpu> gpus;
  final Gpu selected;
  const GpuModelPicker({required this.gpus, required this.selected, super.key});

  @override
  State<GpuModelPicker> createState() => _GpuModelPickerState();
}

class _GpuModelPickerState extends State<GpuModelPicker> {
  final _search = TextEditingController();
  late String? _vendor = widget.selected.vendor;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final vendors = widget.gpus.map((gpu) => gpu.vendor).toSet().toList()
      ..sort();
    final terms = _search.text.trim().toLowerCase().split(RegExp(r'\s+'));
    final models = widget.gpus.where((gpu) {
      final text = '${gpu.vendor} ${gpu.marketingName}'.toLowerCase();
      return (_vendor == null || gpu.vendor == _vendor) &&
          terms.every(text.contains);
    }).toList()..sort(compareGpuByRecency);
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * .85,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          0,
          24,
          MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'choose_gpu_model'.tr(context: context),
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
                IconButton(
                  tooltip: 'close_picker'.tr(context: context),
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              key: const ValueKey('gpu_model_search'),
              controller: _search,
              textInputAction: TextInputAction.search,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'search_gpu_models'.tr(context: context),
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _search.text.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'clear_search'.tr(context: context),
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => setState(() => _search.clear()),
                      ),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                ChoiceChip(
                  label: Text('all_gpu_vendors'.tr(context: context)),
                  selected: _vendor == null,
                  showCheckmark: false,
                  onSelected: (_) => setState(() => _vendor = null),
                ),
                for (final vendor in vendors)
                  ChoiceChip(
                    label: Text(vendor.toUpperCase()),
                    selected: _vendor == vendor,
                    showCheckmark: false,
                    onSelected: (_) => setState(() => _vendor = vendor),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: models.isEmpty
                  ? SingleChildScrollView(
                      child: EmptyContent(
                        icon: Icons.search_off_rounded,
                        title: 'no_matches'.tr(context: context),
                        message: 'try_another_search'.tr(context: context),
                      ),
                    )
                  : ListView.separated(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: EdgeInsets.only(
                        bottom: 24 + MediaQuery.paddingOf(context).bottom,
                      ),
                      itemCount: models.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final gpu = models[index];
                        final selected = gpu.id == widget.selected.id;
                        return Semantics(
                          selected: selected,
                          child: SurfaceCard(
                            key: ValueKey('gpu_option_${gpu.id}'),
                            padding: const EdgeInsets.all(16),
                            color: selected
                                ? colors.primaryContainer.withValues(alpha: .5)
                                : null,
                            borderColor: selected ? colors.primary : null,
                            onTap: () {
                              FocusManager.instance.primaryFocus?.unfocus();
                              Navigator.pop(context, gpu);
                            },
                            child: Row(
                              children: [
                                Icon(
                                  Icons.memory_rounded,
                                  color: colors.primary,
                                  size: 22,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        gpu.marketingName,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.titleSmall,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        gpu.vendor.toUpperCase(),
                                        style: TextStyle(
                                          color: colors.onSurfaceVariant,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Icon(
                                  selected
                                      ? Icons.check_circle_rounded
                                      : Icons.radio_button_unchecked_rounded,
                                  color: selected
                                      ? colors.primary
                                      : colors.outlineVariant,
                                  size: 22,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
