import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:what_to_mine/src/domain/algorithms/HashAlgorithm.dart';
import 'package:what_to_mine/src/ui/screens/hashrate/HashrateViewModel.dart';

class HashrateScreen extends StatefulWidget {
  final HashrateViewModel _viewModel = HashrateViewModel();
  @override
  State<StatefulWidget> createState() {
    return HashrateScreenState(_viewModel);
  }
}

class HashrateScreenState extends State<HashrateScreen> {
  final HashrateViewModel _viewModel;
  HashrateScreenState(this._viewModel);

  @override
  void initState() {
    super.initState();
    _viewModel.usedGpuUpdate.listen((_) => _viewModel.onViewInitState());

    _viewModel.onViewInitState();
/*    _viewModel.errorMessage.listen((message) {
      new Future.delayed(Duration.zero, () {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Error"),
                content: Text(message),
                actions: [
                  TextButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        await SysUtils.delay(6);
                        _viewModel.onViewInitState();
                      },
                      child: Text("OK"))
                ],
              );
            });
      });
    });*/
  }

  @override
  void dispose() {
    super.dispose();
    widget._viewModel.onViewDispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Хэшрейт"),
      ),
      body: Center(
        child: StreamBuilder<List<HashAlgorithm>>(
          stream: _viewModel.hashrate,
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data != null) {
              List<HashAlgorithm> items = [];
              items = snapshot.data!;
              if (snapshot.data!.isNotEmpty) {
                int itemsCount = snapshot.data!.length;
                if (itemsCount > 0)
                  return ListView.builder(
                    itemCount: itemsCount,
                    itemBuilder: (context, index) {
                      return Card(
                          margin: EdgeInsets.all(10),
                          elevation: 30,
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
                                  child: Text(items[index].name),
                                ),
                                Flexible(
                                    fit: FlexFit.tight,
                                    flex: 1,
                                    child: Container(
                                      alignment: Alignment.center,
                                      padding: EdgeInsets.only(left: 10),
                                      //width: 100,
                                      child: TextField(
                                          inputFormatters: [
                                            FilteringTextInputFormatter.allow(RegExp(r"^([0-9]){1,}([.][0-9]{0,2})?"))
                                          ],
                                          keyboardType: TextInputType.number,
                                          decoration: new InputDecoration(
                                            labelText: _viewModel.getHashUnit(items[index]),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(color: Colors.black26, width: 2),
                                            ),
                                          ),
                                          controller:
                                              TextEditingController(text: items[index].hashrate!.toStringAsFixed(2))),
                                    )),
                                Flexible(
                                    fit: FlexFit.tight,
                                    flex: 1,
                                    child: Container(
                                      alignment: Alignment.center,
                                      //width: 100,
                                      padding: EdgeInsets.only(left: 10),
                                      child: TextField(
                                          enabled: false,
                                          decoration: new InputDecoration(
                                            labelText: "W",
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
                                    )),
                              ],
                            ),
                          ));
                    },
                  );
                else
                  return _buildEmptyHashrateListLabel();
              } else
                return _buildEmptyHashrateListLabel();
            } else
              return CircularProgressIndicator();
          },
        ),
      ),
    );
  }

  Widget _buildEmptyHashrateListLabel() {
    return Text(
      "Список хэшрейтов пуст, добавьте свои первые видеокарты",
      textAlign: TextAlign.center,
    );
  }
}
