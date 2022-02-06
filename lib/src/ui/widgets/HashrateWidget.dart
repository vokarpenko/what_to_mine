import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:what_to_mine/src/domain/algorithms/HashAlgorithm.dart';
import 'package:what_to_mine/src/ui/screens/hashrate/HashrateViewModel.dart';

class HashrateWidget extends StatelessWidget {
  final HashrateViewModel _viewModel;
  final HashAlgorithm _algorithm;

  HashrateWidget(this._viewModel, HashAlgorithm algorithm)
      : _algorithm = algorithm,
        super(key: ValueKey(algorithm));

  @override
  Widget build(BuildContext context) {
    return Card(
        margin: const EdgeInsets.all(10),
        elevation: 5,
        child: Container(
          padding: const EdgeInsets.only(left: 0, top: 10, bottom: 10),
          child: Flex(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            direction: Axis.horizontal,
            children: [
              const Flexible(flex: 4, child: Icon(Icons.forward)),
              Flexible(
                fit: FlexFit.tight,
                flex: 5,
                child: Text(_algorithm.name),
              ),
              Flexible(
                  fit: FlexFit.tight,
                  flex: 5,
                  child: Container(
                    padding: const EdgeInsets.only(left: 10),
                    child: TextField(
                        onChanged: (value) => _onChangeHashrate(_algorithm.name, value),
                        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^([0-9]){1,12}([.][0-9]{0,2})?'))],
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.only(left: 10, top: 0, bottom: 0),
                          labelText: _viewModel.getHashUnit(_algorithm),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
                          ),
                          enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black26, width: 2),
                          ),
                        ),
                        controller: TextEditingController(text: _algorithm.hashrate!.toStringAsFixed(2))),
                  )),
              Flexible(
                  fit: FlexFit.tight,
                  flex: 5,
                  child: Container(
                    alignment: Alignment.center,
                    //width: 100,
                    padding: const EdgeInsets.only(left: 10),
                    child: TextField(
                        onChanged: (value) => _onChangePower(_algorithm.name, value),
                        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^([0-9]){1,10}'))],
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.only(left: 10, top: 0, bottom: 0),
                          labelText: 'W',
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
                          ),
                          enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black26, width: 2),
                          ),
                          disabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black12, width: 2),
                          ),
                        ),
                        controller: TextEditingController(text: _algorithm.power!.toString())),
                  )),
            ],
          ),
        ));
  }

  void _onChangeHashrate(String name, String? value) {
    _viewModel.onChangeHashrate(name, value);
  }

  void _onChangePower(String name, String? value) {
    _viewModel.onChangePower(name, value);
  }
}
