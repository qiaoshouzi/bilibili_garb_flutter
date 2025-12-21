import 'package:flutter/material.dart';
import 'package:bili_garb/models/bili_data_model.dart';
import 'package:bili_garb/view_models/package_view_model.dart';
import 'package:bili_garb/views/image_showcase.dart';
import 'package:bili_garb/widgets/image_grid.dart';

class PackageShowcasePage extends StatefulWidget {
  const PackageShowcasePage({super.key, required this.data});
  final PackageItem data;

  @override
  State<PackageShowcasePage> createState() => _PackageShowcasePageState();
}

class _PackageShowcasePageState extends State<PackageShowcasePage> {
  bool _loading = true;
  final PackageViewModel viewModel = PackageViewModel(BiliDataModel());

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _loadData());
  }

  Future<void> _loadData() async {
    try {
      final messenger = ScaffoldMessenger.of(context);
      await viewModel.init(widget.data);
      final errMsg = viewModel.errMsg;
      if (errMsg is String) {
        messenger.showSnackBar(SnackBar(content: Text('加载失败:$errMsg')));
      }
    } catch (e) {
      debugPrint("加载失败: $e");
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  int getCrossAxisCount(double width) {
    final breakpoints = [
      (1600.0, 10),
      (1415.0, 9),
      (1230.0, 8),
      (1060.0, 7),
      (870.0, 6),
      (680.0, 5),
      (500.0, 4),
    ];

    for (var breakpoint in breakpoints) {
      if (width >= breakpoint.$1) return breakpoint.$2;
    }

    return 3;
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(title: Text(widget.data.name)),
      body: _loading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text("正在加载中..."),
                ],
              ),
            )
          : ListenableBuilder(
              listenable: viewModel,
              builder: (context, child) {
                if (viewModel.list.isEmpty) {
                  return const Center(child: Text("暂无数据"));
                }

                return ImageGrid(
                  list: viewModel.list,
                  showName: false,
                  crossAxisCount: getCrossAxisCount(width),
                  ext: width >= 600 ? '@416w_624h.webp' : '@208w_312h.webp',
                  cb: (data) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ImageShowcaseScreen(data: data),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
