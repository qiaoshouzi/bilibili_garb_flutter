import 'package:flutter/material.dart';
import 'package:bili_garb/widgets/image_grid.dart';
import 'package:bili_garb/models/bili_data_model.dart';
import 'package:bili_garb/widgets/download_button.dart';
import 'package:bili_garb/models/save_media_model.dart';
import 'package:bili_garb/view_models/save_media_view_model.dart';

class ImageShowcaseScreen extends StatefulWidget {
  const ImageShowcaseScreen({super.key, required this.data});
  final CardData data;
  @override
  State<ImageShowcaseScreen> createState() => _ImageShowcaseScreenState();
}

class _ImageShowcaseScreenState extends State<ImageShowcaseScreen> {
  final SaveMediaViewModel viewModel = SaveMediaViewModel(SaveMediaModel());

  Future<void> saveMedia(FileType type, BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final result = await viewModel.saveMedia(type, widget.data);
      if (viewModel.errMsg is String) {
        messenger.showSnackBar(
          SnackBar(content: Text('错误: ${viewModel.errMsg}')),
        );
      }
      if (result is String) {
        messenger.showSnackBar(SnackBar(content: Text(result)));
      }
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('未知错误, ${e.toString()}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.data.name)),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            DownloadButton(
              cb: saveMedia,
              videoButtonEnable: widget.data.videos is List,
            ),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: ImageItem(
                url: widget.data.img,
                ext: '@832w_1248h.webp',
                width: 416,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
