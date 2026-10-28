import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:what_to_mine/src/domain/gpu/gpu.dart';
import 'package:what_to_mine/src/domain/gpu/used_gpu.dart';
import 'package:what_to_mine/src/ui/design/app_ui.dart';
import 'package:what_to_mine/src/ui/widgets/used_gpu_widget.dart';
import 'gpu_list_view_model.dart';
import 'gpu_model_picker.dart';

class GpuListScreen extends StatefulWidget {
  final bool embedded;
  const GpuListScreen({this.embedded = false, super.key});
  @override
  State<GpuListScreen> createState() => _GpuListScreenState();
}

class _GpuListScreenState extends State<GpuListScreen> {
  final _viewModel = GpuListViewModel();
  final _subscriptions = <StreamSubscription<dynamic>>[];
  List<UsedGpu>? _data;

  @override
  void initState() {
    super.initState();
    _subscriptions.add(
      _viewModel.usedGpus.listen((data) {
        if (mounted) setState(() => _data = data);
      }),
    );
    _subscriptions.add(_viewModel.addGpu.listen((_) => _addGpu()));
    _subscriptions.add(
      _viewModel.errorMessage.listen((error) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(error)));
        }
      }),
    );
    _viewModel.onViewInitState();
  }

  @override
  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _viewModel.onViewDispose();
    super.dispose();
  }

  Future<void> _addGpu() async {
    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => AddGpuSheet(viewModel: _viewModel),
    );
  }

  Future<void> _delete(UsedGpu used) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('remove_gpu'.tr(context: context)),
        content: Text(
          'remove_gpu_message'.tr(args: [used.gpuData.marketingName]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('cancel'.tr(context: context)),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('remove'.tr(context: context)),
          ),
        ],
      ),
    );
    if (confirmed == true) _viewModel.deleteUsedGpu(used.gpuData.id);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final count = (_data ?? []).fold(0, (sum, gpu) => sum + gpu.quantity);
    return Scaffold(
      appBar: widget.embedded
          ? null
          : AppBar(title: Text('home_gpus'.tr(context: context))),
      floatingActionButton: FloatingActionButton.extended(
        key: const ValueKey('add_gpu'),
        onPressed: _viewModel.onClickAddGPU,
        icon: const Icon(Icons.add_rounded),
        label: Text('add_gpu'.tr(context: context)),
      ),
      body: _data == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
              children: [
                if (_data!.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: colors.primaryContainer.withValues(alpha: .45),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$count',
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineLarge,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'gpu_units'.tr(context: context),
                                style: TextStyle(
                                  color: colors.onSurfaceVariant,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 42,
                          color: colors.outlineVariant,
                        ),
                        const SizedBox(width: 26),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${_data!.length}',
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineLarge,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'gpu_models'.tr(context: context),
                                style: TextStyle(
                                  color: colors.onSurfaceVariant,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  Text(
                    'your_hardware'.tr(context: context).toUpperCase(),
                    style: TextStyle(
                      color: colors.onSurfaceVariant,
                      fontSize: 10,
                      letterSpacing: 1,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  for (final used in _data!)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: UsedGpuWidget(
                        used,
                        key: ValueKey('gpu_${used.gpuData.id}'),
                        onDelete: () => _delete(used),
                      ),
                    ),
                ] else
                  EmptyContent(
                    icon: Icons.memory_rounded,
                    title: 'build_your_rig'.tr(context: context),
                    message: 'empty_gpus_message'.tr(context: context),
                  ),
              ],
            ),
    );
  }
}

class AddGpuSheet extends StatefulWidget {
  final GpuListViewModel viewModel;
  const AddGpuSheet({required this.viewModel, super.key});
  @override
  State<AddGpuSheet> createState() => _AddGpuSheetState();
}

class _AddGpuSheetState extends State<AddGpuSheet> {
  final _form = GlobalKey<FormState>();
  final _quantity = TextEditingController(text: '1');
  late Gpu _gpu;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _gpu = widget.viewModel.catalog.first;
  }

  @override
  void dispose() {
    _quantity.dispose();
    super.dispose();
  }

  Future<void> _selectModel() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final model = await showModalBottomSheet<Gpu>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) =>
          GpuModelPicker(gpus: widget.viewModel.catalog, selected: _gpu),
    );
    if (mounted && model != null) setState(() => _gpu = model);
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate() || _busy) return;
    setState(() => _busy = true);
    final added = await widget.viewModel.onAddGPU(
      _gpu,
      int.parse(_quantity.text),
    );
    if (!mounted) return;
    if (added) {
      Navigator.pop(context);
    } else {
      setState(() => _busy = false);
    }
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
              'add_gpu'.tr(context: context),
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'add_gpu_hint'.tr(context: context),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 22),
            LabeledField(
              label: 'gpu_model'.tr(context: context),
              child: SurfaceCard(
                key: const ValueKey('select_gpu_model'),
                padding: const EdgeInsets.all(16),
                onTap: _busy ? null : _selectModel,
                child: Row(
                  children: [
                    Icon(
                      Icons.memory_rounded,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _gpu.vendor.toUpperCase(),
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            _gpu.marketingName,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'change_gpu_model'.tr(context: context),
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.chevron_right_rounded),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            LabeledField(
              label: 'quantity'.tr(context: context),
              child: Row(
                children: [
                  IconButton.filledTonal(
                    onPressed: () {
                      final value = int.tryParse(_quantity.text) ?? 1;
                      _quantity.text = '${(value - 1).clamp(1, 1000)}';
                    },
                    icon: const Icon(Icons.remove_rounded),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: TextFormField(
                      controller: _quantity,
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                      ],
                      textInputAction: TextInputAction.done,
                      validator: (value) {
                        final count = int.tryParse(value ?? '');
                        return count == null || count < 1 || count > 1000
                            ? 'invalid_quantity'.tr(context: context)
                            : null;
                      },
                    ),
                  ),
                  const SizedBox(width: 14),
                  IconButton.filledTonal(
                    onPressed: () {
                      final value = int.tryParse(_quantity.text) ?? 1;
                      _quantity.text = '${(value + 1).clamp(1, 1000)}';
                    },
                    icon: const Icon(Icons.add_rounded),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 26),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _busy ? null : _save,
                icon: const Icon(Icons.add_rounded),
                label: Text('add_to_rig'.tr(context: context)),
              ),
            ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    ),
  );
}
