import 'package:flutter/material.dart';
import 'package:bili_garb/models/app_version_model.dart';

class AppVersionViewModel extends ChangeNotifier {
  final AppVersionModel model;
  String? errMsg;
  AppVersion? result;
  bool loading = false;

  AppVersionViewModel(this.model);

  Future<void> init() async {
    errMsg = null;
    result = null;
    loading = true;
    notifyListeners();
    try {
      result = await model.getLatestBuildNumber();
    } catch (e) {
      errMsg = e.toString();
    }
    loading = false;
    notifyListeners();
  }
}
