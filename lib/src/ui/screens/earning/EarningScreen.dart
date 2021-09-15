import 'package:flutter/material.dart';
import 'package:what_to_mine/src/domain/currency/Earnings.dart';
import 'package:what_to_mine/src/ui/screens/earning/EarningViewModel.dart';
import 'package:what_to_mine/src/ui/widgets/EarningsWidget.dart';

class EarningScreen extends StatefulWidget {
  final EarningViewModel _viewModel = EarningViewModel();
  @override
  State<StatefulWidget> createState() {
    return EarningScreenState(_viewModel);
  }
}

class EarningScreenState extends State<EarningScreen> {
  EarningViewModel _viewModel = EarningViewModel();
  EarningScreenState(this._viewModel);

  @override
  void initState() {
    super.initState();
    _viewModel.onViewInitState();
    _viewModel.usedGpuUpdate.listen((_) => _viewModel.onViewInitState());
  }

  @override
  void dispose() {
    super.dispose();
    _viewModel.onViewDispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Доходность"),
      ),
      body: Center(
          child: StreamBuilder<List<Earnings>>(
        stream: _viewModel.earnings,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            if (snapshot.data!.isNotEmpty)
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  return EarningsWidget(snapshot.data![index]);
                },
              );
            else
              return (Text(
                "Чтобы увидеть доходы от ваших видеокарт добавьте их на вкладке \"Видеокарты\"",
                textAlign: TextAlign.center,
              ));
          } else
            return CircularProgressIndicator();
        },
      )),
    );
  }
}
