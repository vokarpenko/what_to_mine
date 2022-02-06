import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:what_to_mine/src/domain/algorithms/HashAlgorithm.dart';
import 'package:what_to_mine/src/ui/screens/hashrate/HashrateViewModel.dart';
import 'package:what_to_mine/src/ui/widgets/HashrateWidget.dart';
import 'package:what_to_mine/src/utils/UIUtils.dart';

class HashrateScreen extends StatefulWidget {
  const HashrateScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return HashrateScreenState();
  }
}

class HashrateScreenState extends State<HashrateScreen> {
  final HashrateViewModel _viewModel = HashrateViewModel();
  StreamSubscription? _subscriptionInfoMessage, _subscriptionError;

  HashrateScreenState();

  @override
  void initState() {
    super.initState();
    _subscriptionInfoMessage = _viewModel.infoMessage.listen((message) => UIUtils.showSnackBar(context, message));
    _subscriptionError =
        _viewModel.errorMessage.listen((error) => UIUtils.showAlertDialog(context, 'error'.tr(), error, 'ok'.tr()));
    _viewModel.onViewInitState();
  }

  @override
  void dispose() {
    super.dispose();
    this
      .._viewModel.onViewDispose()
      .._subscriptionInfoMessage?.cancel()
      .._subscriptionError?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('hashrate_appbar_title'.tr()),
          actions: <Widget>[
            StreamBuilder<bool>(
                initialData: false,
                stream: _viewModel.showApplyButton,
                builder: (context, snapshot) => (snapshot.data!)
                    ? Padding(
                  padding: const EdgeInsets.only(right: 5),
                        child: IconButton(
                            tooltip: 'apply'.tr(),
                            onPressed: _applyHashrateButtonClick,
                            splashRadius: 25,
                            icon: const Icon(
                              Icons.check,
                              size: 30,
                            )),
                      )
                    : Container())
          ],
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
                  if (itemsCount > 0) {
                    List<HashrateWidget> widgets = [];
                    for (var item in items) {
                      widgets.add(HashrateWidget(_viewModel, item));
                    }
                    return SingleChildScrollView(
                      child: Column(
                        children: widgets,
                      ),
                    );
                  } else {
                    return _buildEmptyHashrateListLabel();
                  }
                } else {
                  return _buildEmptyHashrateListLabel();
                }
              } else {
                return const CircularProgressIndicator();
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyHashrateListLabel() {
    return Text(
      'empty_hashrates_message'.tr(),
      textAlign: TextAlign.center,
    );
  }

  void _applyHashrateButtonClick() {
    UIUtils.hideKeyboard();
    _viewModel.onApplyHashrate();
  }
}
