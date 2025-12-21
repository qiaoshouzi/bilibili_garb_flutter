import 'package:flutter/material.dart';
import 'package:bili_garb/models/bili_data_model.dart';
import 'package:bili_garb/models/save_media_model.dart';

class SaveMediaViewModel extends ChangeNotifier {
  final SaveMediaModel model;
  String? errMsg;
  bool loading = false;

  SaveMediaViewModel(this.model);

  Future<String?> saveMedia(FileType type, CardData data) async {
    errMsg = null;
    loading = true;
    notifyListeners();
    String? result;
    try {
      result = await model.saveMedia(type, data);
    } catch (e) {
      errMsg = e.toString();
    }
    loading = false;
    notifyListeners();
    return result;
  }
}
