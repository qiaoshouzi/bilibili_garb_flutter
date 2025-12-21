import 'package:flutter/material.dart';
import 'package:bili_garb/models/bili_data_model.dart';

class DownloadButton extends StatefulWidget {
  const DownloadButton({
    super.key,
    required this.cb,
    this.imageButtonEnable = true,
    this.imageLabel = '下载图片',
    this.imageDownloadingLabel = '下载图片中~',
    this.videoButtonEnable = true,
    this.videoLabel = '下载视频',
    this.videoDownloadingLabel = '下载视频中~',
  });
  final Future<void> Function(FileType type, BuildContext context) cb;
  final bool imageButtonEnable;
  final String? imageLabel;
  final String? imageDownloadingLabel;
  final bool videoButtonEnable;
  final String? videoLabel;
  final String? videoDownloadingLabel;
  @override
  State<DownloadButton> createState() => _DownloadButtonState();
}

class _DownloadButtonState extends State<DownloadButton> {
  bool isDownloadingImg = false;
  bool isDownloadingVideo = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          button(
            isDownloadingImg,
            onPressed: widget.imageButtonEnable
                ? () async {
                    setState(() {
                      isDownloadingImg = true;
                    });
                    await widget.cb(FileType.image, context);
                    if (mounted) {
                      setState(() {
                        isDownloadingImg = false;
                      });
                    }
                  }
                : null,
            icon: const Icon(Icons.download),
            label: widget.imageLabel,
            downloadingLabel: widget.imageDownloadingLabel,
          ),
          const SizedBox(width: 8),
          button(
            isDownloadingVideo,
            onPressed: widget.videoButtonEnable
                ? () async {
                    setState(() {
                      isDownloadingVideo = true;
                    });
                    await widget.cb(FileType.video, context);
                    if (mounted) {
                      setState(() {
                        isDownloadingVideo = false;
                      });
                    }
                  }
                : null,
            icon: const Icon(Icons.video_collection),
            label: widget.videoLabel,
            downloadingLabel: widget.videoDownloadingLabel,
          ),
        ],
      ),
    );
  }

  Widget button(
    bool isDownloading, {
    Widget? icon,
    String? label,
    String? downloadingLabel,
    void Function()? onPressed,
  }) {
    return Expanded(
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: isDownloading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : icon,
        label: Text(
          isDownloading ? (downloadingLabel ?? '下载中~') : (label ?? '下载'),
        ),
      ),
    );
  }
}
