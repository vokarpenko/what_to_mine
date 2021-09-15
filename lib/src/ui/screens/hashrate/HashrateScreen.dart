import 'package:flutter/material.dart';
import 'package:what_to_mine/src/domain/algorithms/Algos.dart';
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
        title: Text("Курсы криптовалют"),
      ),
      body: Center(
        child: StreamBuilder<Algos>(
          stream: _viewModel.hashrate,
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data != null) {
              return ListView(
                children: [
                  _buildListTile(snapshot.data!.Etchash!, "Etchash"),
                  _buildListTile(snapshot.data!.KAWPOW!, "KAWPOW")
                ],

                /*itemCount: 3,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(snapshot.data!.Etchash.toString()),
                  );
                },*/
              );
            } else
              return CircularProgressIndicator();
          },
        ),
      ),
      /*StreamBuilder<bool>(
          initialData: true,
          stream: widget._viewModel.isLoading,
          builder: (context, loadingSnapShot) {
            if (loadingSnapShot.hasData && loadingSnapShot.data!)
              return CircularProgressIndicator();
            else
              return Container();
          },
        ),*/
    );
  }

  Widget _buildListTile(double hashrate, String name) {
    return ListTile(
      title: Text(name),
      subtitle: Text(hashrate.toString()),
    );
  }
}
