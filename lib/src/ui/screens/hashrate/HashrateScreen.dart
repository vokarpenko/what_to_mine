import 'package:flutter/material.dart';
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
        title: Text("123"),
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
                    padding: EdgeInsets.only(top: 15, bottom: 15),
                    itemCount: itemsCount,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(items[index].name),
                        subtitle:
                            Text(items[index].hashrate.toString() + " " + items[index].hashrateCoefficient.toString()),
                      );
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
