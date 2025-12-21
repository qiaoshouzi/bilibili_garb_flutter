import 'package:bili_garb/views/package_showcase.dart';
import 'package:flutter/material.dart';
import 'package:bili_garb/models/bili_data_model.dart';
import 'package:bili_garb/view_models/search_view_model.dart';
import 'package:bili_garb/widgets/image_grid.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final myController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _loading = false;
  final SearchViewModel viewModel = SearchViewModel(BiliDataModel());

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    // 判断是否滚动到底部附近
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final data = viewModel.data;
      if (!_loading && data is SearchList && data.list.length < data.total) {
        _loadMore();
      }
    }
  }

  Future<void> _handleSearch(BuildContext context, double width) async {
    if (myController.text.isEmpty) return;
    setState(() => _loading = true);
    final messenger = ScaffoldMessenger.of(context);
    await viewModel.init(myController.text);
    final errMsg = viewModel.errMsg;
    if (errMsg is String) {
      messenger.showSnackBar(SnackBar(content: Text('加载失败:$errMsg')));
    }
    setState(() => _loading = false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkIfNeedMore();
    });
  }

  void _checkIfNeedMore() {
    if (!_scrollController.hasClients) return;

    // 如果最大滚动距离为 0 (不可滚动) 且还有更多数据
    final maxScroll = _scrollController.position.maxScrollExtent;
    final data = viewModel.data;

    if (maxScroll <= 0 &&
        data is SearchList &&
        data.list.length < data.total &&
        !_loading) {
      _loadMore().then((_) {
        // 加载完后递归检查，直到填满屏幕
        _checkIfNeedMore();
      });
    }
  }

  Future<void> _loadMore() async {
    setState(() => _loading = true);
    final messenger = ScaffoldMessenger.of(context);
    await viewModel.loadMore();
    final errMsg = viewModel.errMsg;
    if (errMsg is String) {
      messenger.showSnackBar(SnackBar(content: Text('加载失败:$errMsg')));
    }
    setState(() => _loading = false);
  }

  int getCrossAxisCount(double width) {
    final breakpoints = [
      (1260.0, 7),
      (1090.0, 6),
      (860.0, 5),
      (520.0, 4),
      (500.0, 3),
    ];

    for (var breakpoint in breakpoints) {
      if (width >= breakpoint.$1) return breakpoint.$2;
    }

    return 2;
  }

  @override
  void dispose() {
    myController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Column(
      children: <Widget>[
        Visibility(visible: _loading, child: const LinearProgressIndicator()),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: myController,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (value) => _handleSearch(context, width),
                  decoration: const InputDecoration(
                    labelText: '装扮名称',
                    border: UnderlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8.0),
              ElevatedButton(
                onPressed: () => _handleSearch(context, width),
                child: const Text('搜索'),
              ),
            ],
          ),
        ),
        ListenableBuilder(
          listenable: viewModel,
          builder: (context, child) {
            final data = viewModel.data;
            if (data is SearchList) {
              return Expanded(
                child: ImageGrid(
                  controller: _scrollController,
                  list: data.list,
                  crossAxisCount: getCrossAxisCount(width),
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                  childAspectRatio: 0.6,
                  ext: '@492w_540h_1o.webp',
                  cb: (data) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PackageShowcasePage(data: data),
                      ),
                    );
                  },
                ),
              );
            } else {
              return const SizedBox.shrink();
            }
          },
        ),
      ],
    );
  }
}
