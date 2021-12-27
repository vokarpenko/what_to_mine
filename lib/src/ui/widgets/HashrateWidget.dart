import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:what_to_mine/src/domain/algorithms/HashAlgorithm.dart';
import 'package:what_to_mine/src/ui/screens/hashrate/HashrateViewModel.dart';

class HashrateWidget extends StatelessWidget {
  final HashrateViewModel _viewModel;
  final HashAlgorithm _algorithm;

  HashrateWidget(this._viewModel, this._algorithm);

  @override
  Widget build(BuildContext context) {
    return Card(
        margin: EdgeInsets.all(10),
        elevation: 5,
        child: Container(
          padding: EdgeInsets.only(left: 0, top: 10, bottom: 10),
          child: Flex(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            direction: Axis.horizontal,
            children: [
              Flexible(flex: 1, child: Icon(Icons.forward)),
              Flexible(
                fit: FlexFit.tight,
                flex: 1,
                child: Text(_algorithm.name),
              ),
              Flexible(
                  fit: FlexFit.tight,
                  flex: 1,
                  child: Container(
                    padding: EdgeInsets.only(left: 10),
                    child: TextField(
                        onChanged: (value) => _onChangeHashrate(_algorithm.name, value),
                        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^([0-9]){1,}([.][0-9]{0,2})?'))],
                        keyboardType: TextInputType.number,
                        decoration: new InputDecoration(
                          contentPadding: EdgeInsets.only(left: 10, top: 0, bottom: 0),
                          labelText: _viewModel.getHashUnit(_algorithm),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black26, width: 2),
                          ),
                        ),
                        controller: TextEditingController(text: _algorithm.hashrate!.toStringAsFixed(2))),
                  )),
              /*Flexible(
                  fit: FlexFit.tight,
                  flex: 1,
                  child: Container(
                    alignment: Alignment.center,
                    //width: 100,
                    padding: EdgeInsets.only(left: 10),
                    child: TextField(
                        enabled: false,
                        decoration: new InputDecoration(
                          contentPadding: EdgeInsets.only(left: 10, top: 0, bottom: 0),
                          labelText: 'W',
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black26, width: 2),
                          ),
                          disabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black12, width: 2),
                          ),
                        ),
                        controller: TextEditingController()),
                  )),*/
            ],
          ),
        ));
  }

  void _onChangeHashrate(String name, String? value) {
    _viewModel.onChangeHashrate(name, value);
  }
}
