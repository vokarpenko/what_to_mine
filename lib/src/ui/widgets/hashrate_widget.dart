import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:what_to_mine/src/domain/algorithms/hash_algorithm.dart';
import 'package:what_to_mine/src/ui/screens/hashrate/hashrate_view_model.dart';
import '../design/app_ui.dart';

class HashrateWidget extends StatefulWidget {
  final HashrateViewModel viewModel;
  final HashAlgorithm algorithm;
  const HashrateWidget(this.viewModel, this.algorithm, {super.key});
  @override
  State<HashrateWidget> createState() => _HashrateWidgetState();
}

class _HashrateWidgetState extends State<HashrateWidget>
    with AutomaticKeepAliveClientMixin {
  late final TextEditingController _hashrate;
  late final TextEditingController _power;
  final _hashFocus = FocusNode();
  final _powerFocus = FocusNode();
  @override
  bool get wantKeepAlive => true;
  @override
  void initState() {
    super.initState();
    _hashrate = TextEditingController(
      text: (widget.algorithm.hashrate ?? 0).toStringAsFixed(2),
    );
    _power = TextEditingController(text: '${widget.algorithm.power ?? 0}');
  }

  @override
  void didUpdateWidget(covariant HashrateWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.algorithm != widget.algorithm) {
      if (!_hashFocus.hasFocus) {
        _hashrate.text = (widget.algorithm.hashrate ?? 0).toStringAsFixed(2);
      }
      if (!_powerFocus.hasFocus) _power.text = '${widget.algorithm.power ?? 0}';
    }
  }

  @override
  void dispose() {
    _hashrate.dispose();
    _power.dispose();
    _hashFocus.dispose();
    _powerFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.hub_outlined,
                size: 18,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  widget.algorithm.name,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: LabeledField(
                  label: 'hashrate_label'.tr(context: context),
                  child: TextField(
                    textInputAction: TextInputAction.done,
                    controller: _hashrate,
                    focusNode: _hashFocus,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                    ],
                    decoration: InputDecoration(
                      suffixText: widget.algorithm.getHashUnit(),
                    ),
                    onChanged: (value) {
                      if (double.tryParse(value.replaceAll(',', '.')) != null ||
                          value.isEmpty) {
                        widget.viewModel.onChangeHashrate(
                          widget.algorithm.name,
                          value.replaceAll(',', '.'),
                        );
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: LabeledField(
                  label: 'power_label'.tr(context: context),
                  child: TextField(
                    textInputAction: TextInputAction.done,
                    controller: _power,
                    focusNode: _powerFocus,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(suffixText: 'W'),
                    onChanged: (value) => widget.viewModel.onChangePower(
                      widget.algorithm.name,
                      value,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
