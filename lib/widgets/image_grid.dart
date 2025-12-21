import 'dart:async';
import 'package:flutter/material.dart';

class ImageData {
  ImageData(this.name, this.url);
  final String name;
  final String? url;
}

abstract class ImageConvertible<R> {
  ImageData toImageData();
}

class ImageGrid<T extends ImageConvertible> extends StatefulWidget {
  const ImageGrid({
    super.key,
    required this.list,
    this.cb,
    this.ext = '@208w_312h.webp',
    this.crossAxisCount = 3,
    this.crossAxisSpacing = 4.0,
    this.mainAxisSpacing = 8.0,
    this.childAspectRatio = 2 / 3,
    this.controller,
    this.showName = true,
  });
  final List<T> list;
  final FutureOr<void> Function(T data)? cb;
  final String ext;
  final int crossAxisCount;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final double childAspectRatio;
  final ScrollController? controller;
  final bool showName;
  @override
  State<ImageGrid> createState() => _ImageGridState<T>();
}

class _ImageGridState<T extends ImageConvertible> extends State<ImageGrid<T>> {
  @override
  Widget build(BuildContext context) {
    if (widget.list.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.all(4.0),
        child: GridView.builder(
          controller: widget.controller,
          itemCount: widget.list.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: widget.crossAxisCount, // 2;3
            crossAxisSpacing: widget.crossAxisSpacing, // 4;8
            mainAxisSpacing: widget.mainAxisSpacing, // 4;8
            childAspectRatio: widget.childAspectRatio, // 0.6
          ),
          itemBuilder: (context, index) {
            final data = widget.list[index];
            return GestureDetector(
              onTap: () async {
                await widget.cb?.call(data);
              },
              child: _buildImageItem(data.toImageData(), ext: widget.ext),
            );
          },
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget _buildImageItem(ImageData data, {required String ext}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: ImageItem(url: data.url, ext: ext, width: double.infinity),
        ),
        if (widget.showName)
          Padding(
            padding: const EdgeInsets.only(top: 4.0, bottom: 2.0),
            child: Text(
              data.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
            ),
          ),
      ],
    );
  }
}

class ImageItem extends StatefulWidget {
  const ImageItem({
    super.key,
    this.url,
    this.ext = '@208w_312h.webp',
    this.width,
  });
  final String? url;
  final String ext;
  final double? width;
  @override
  State<ImageItem> createState() => _ImageItemState();
}

class _ImageItemState extends State<ImageItem> {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: Image.network(
        '${widget.url}${widget.ext}',
        width: widget.width,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: Colors.grey[200],
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.red[50],
            child: const Center(
              child: Icon(Icons.broken_image, color: Colors.red),
            ),
          );
        },
      ),
    );
  }
}
