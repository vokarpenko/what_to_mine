import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:what_to_mine/src/ui/screens/settings/settings_view_model.dart';

class LanguageSelectorWidget extends StatelessWidget {
  final SettingsViewModel _viewModel;

  const LanguageSelectorWidget(this._viewModel, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
        child: SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            title: Text('settings_language_en'.tr()),
            leading: const Icon(Icons.language),
            onTap: () {
              _onSwitchLanguage(context, 'en');
              Navigator.of(context).pop();
            },
          ),
          ListTile(
            title: Text('settings_language_ru'.tr()),
            leading: const Icon(Icons.language),
            onTap: () {
              _onSwitchLanguage(context, 'ru');
              Navigator.of(context).pop();
            },
          )
        ],
      ),
    ));
  }

  void _onSwitchLanguage(BuildContext context, String languageCode) async {
    EasyLocalization.of(context)?.setLocale(Locale(languageCode));
    _viewModel.onChangeLocale(languageCode);
  }
}
