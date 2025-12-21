import 'package:flutter/material.dart';
import 'package:bili_garb/models/bili_data_model.dart';

class SearchViewModel extends ChangeNotifier {
  final BiliDataModel model;
  SearchList? data;
  String? errMsg;
  bool loading = false;

  SearchViewModel(this.model);

  Future<void> init(String keyword) async {
    errMsg = null;
    loading = true;
    notifyListeners();
    try {
      data = await model.search(keyword);
    } catch (e) {
      errMsg = e.toString();
    }
    loading = false;
    notifyListeners();
  }

  Future<void> loadMore() async {
    final oldData = data;
    if (oldData is! SearchList || loading == true) return;
    errMsg = null;
    loading = true;
    notifyListeners();
    try {
      final newData = await model.search(oldData.keyword, pn: oldData.pn + 1);
      oldData.pn = newData.pn;
      oldData.list.addAll(newData.list);
    } catch (e) {
      errMsg = e.toString();
    }
    loading = false;
    notifyListeners();
  }
}
