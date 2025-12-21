import 'package:flutter/material.dart';
import 'package:bili_garb/models/bili_data_model.dart';

class PackageViewModel extends ChangeNotifier {
  final BiliDataModel model;
  List<CardData> list = [];
  String? errMsg;
  bool loading = false;

  PackageViewModel(this.model);

  Future<void> init(PackageItem data) async {
    errMsg = null;
    loading = true;
    notifyListeners();
    try {
      if (data.type == PackageType.act) {
        list = await model.getActCardData(data.id);
      } else if (data.type == PackageType.garb) {
        list = await model.getGarbCardData(data.id);
      }
    } catch (e) {
      errMsg = e.toString();
    }
    loading = false;
    notifyListeners();
  }
}
