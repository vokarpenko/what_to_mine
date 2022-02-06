import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:what_to_mine/src/ui/screens/settings/SettingsViewModel.dart';

class ElectricityCostSelectorWidget extends StatelessWidget {
  final SettingsViewModel _viewModel;
  final double initialItem;

  const ElectricityCostSelectorWidget(this._viewModel, this.initialItem, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<double> items = [];
    for (int i = 1; i <= 40; i++) {
      double item = 0.01 * i;
      items.add(double.parse(item.toStringAsFixed(2)));
    }
    return Material(
        child: SafeArea(
      top: false,
          child: SizedBox(
          height: 200,
          width: MediaQuery.of(context).size.width,
          child: CupertinoPicker(
            diameterRatio: 2,
            scrollController: FixedExtentScrollController(initialItem: items.indexOf(initialItem)),
            children: items.map<DropdownMenuItem<double>>((double value) {
              return DropdownMenuItem<double>(
                value: value,
                child: Center(
                  child: Text(
                    value.toStringAsFixed(2) + ' USD',
                    style: Theme.of(context).textTheme.bodyText2,
                  ),
                ),
              );
            }).toList(),
            onSelectedItemChanged: (selected) => _onChangeElectricityCost(items.elementAt(selected)),
            itemExtent: 50,
          )),
    ));
  }

  void _onChangeElectricityCost(double cost) async {
    _viewModel.onChangeElectricityCost(cost);
  }
}
