import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:what_to_mine/src/domain/algorithms/hash_algorithm.dart';
import 'package:what_to_mine/src/ui/design/app_ui.dart';
import 'package:what_to_mine/src/ui/widgets/hashrate_widget.dart';
import 'hashrate_view_model.dart';

class HashrateScreen extends StatefulWidget {
  final bool embedded;
  const HashrateScreen({this.embedded = false, super.key});
  @override
  State<HashrateScreen> createState() => _HashrateScreenState();
}

class _HashrateScreenState extends State<HashrateScreen> {
  final _viewModel = HashrateViewModel();
  final _subscriptions = <StreamSubscription<dynamic>>[];
  List<HashAlgorithm>? _data;
  bool _dirty = false;

  @override
  void initState() {
    super.initState();
    _subscriptions.add(
      _viewModel.hashrate.listen((items) {
        if (mounted) setState(() => _data = items);
      }),
    );
    _subscriptions.add(
      _viewModel.showApplyButton.listen((dirty) {
        if (mounted) setState(() => _dirty = dirty);
      }),
    );
    _subscriptions.add(_viewModel.infoMessage.listen(_message));
    _subscriptions.add(_viewModel.errorMessage.listen(_message));
    _viewModel.onViewInitState();
  }

  void _message(String text) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
    }
  }

  @override
  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _viewModel.onViewDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: widget.embedded
        ? null
        : AppBar(title: Text('home_hashrate'.tr(context: context))),
    body: _data == null
        ? const Center(child: CircularProgressIndicator())
        : ListView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 18),
                child: Text(
                  'hashrate_hint'.tr(context: context),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 12,
                    height: 1.6,
                  ),
                ),
              ),
              if (_data!.isEmpty)
                EmptyContent(
                  icon: Icons.tune_rounded,
                  title: 'start_mining'.tr(context: context),
                  message: 'empty_hashrates_message'.tr(context: context),
                ),
              for (final algorithm in _data!)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: HashrateWidget(
                    _viewModel,
                    algorithm,
                    key: ValueKey('hashrate_${algorithm.name}'),
                  ),
                ),
            ],
          ),
    bottomNavigationBar: _dirty
        ? SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
              child: FilledButton.icon(
                onPressed: () {
                  FocusManager.instance.primaryFocus?.unfocus();
                  _viewModel.onApplyHashrate();
                },
                icon: const Icon(Icons.check_rounded),
                label: Text('save_changes'.tr(context: context)),
              ),
            ),
          )
        : null,
  );
}
