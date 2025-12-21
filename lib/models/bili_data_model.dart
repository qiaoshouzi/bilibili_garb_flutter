import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bili_garb/widgets/image_grid.dart';

enum FileType { image, video }

class CardData implements ImageConvertible {
  final String name;
  final String img;
  final List<String>? videos;
  CardData(this.name, this.img, {this.videos});

  @override
  ImageData toImageData() => ImageData(name, img);
}

enum PackageType { garb, act, error }

class PackageItem implements ImageConvertible {
  PackageItem(this.type, this.id, this.name, this.cover);
  final PackageType type;
  final String name;
  final String id;
  final String? cover;

  @override
  ImageData toImageData() => ImageData(name, cover);
}

class SearchList {
  SearchList(this.list, this.keyword, this.pn, this.total);
  final List<PackageItem> list;
  final String keyword;
  int pn;
  final int total;
}

class BiliDataModel {
  Future<SearchList> search(String keyword, {int pn = 1}) async {
    final uri = Uri.parse(
      'https://api.bilibili.com/x/garb/v2/mall/home/search?key_word=$keyword&pn=$pn',
    );
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw ('搜索失败: ${response.statusCode}');
    }
    final Map<String, dynamic> result = jsonDecode(response.body);
    final List<PackageItem> list = [];
    for (final i in result['data']?['list'] ?? []) {
      final String name;
      if (i['name'] is String) {
        name = i['name'];
      } else if (i['group_name'] is String) {
        name = i['group_name'];
      } else {
        name = '获取名称失败';
      }
      final String? cover = i['properties']?['image_cover'];
      if (i['properties']?['dlc_act_id'] is String) {
        list.add(
          PackageItem(
            PackageType.act,
            i['properties']['dlc_act_id'].toString(),
            name,
            cover,
          ),
        );
      } else if (i['item_id'] is int && i['item_id'] > 0) {
        list.add(
          PackageItem(PackageType.garb, i['item_id'].toString(), name, cover),
        );
      } else {
        list.add(PackageItem(PackageType.error, '0', name, cover));
      }
    }
    return SearchList(
      list,
      keyword,
      result['data']?['pn'] ?? 1,
      result['data']?['total'] ?? 0,
    );
  }

  Future<List<CardData>> getGarbCardData(String id) async {
    final uri = Uri.parse(
      'https://api.bilibili.com/x/garb/v2/mall/suit/detail?item_id=$id',
    );
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw ('获取失败: ${response.statusCode}');
    }
    final Map<String, dynamic> result = jsonDecode(response.body);
    final List<dynamic>? spaceBg = result['data']?['suit_items']?['space_bg'];
    final List<CardData> list = [];
    if (spaceBg is! List<dynamic>) {
      return list;
    }
    for (final i in spaceBg) {
      if (i is! Map<String, dynamic>) continue;
      final Map<String, dynamic>? properties = i['properties'];
      if (properties is! Map<String, dynamic>) continue;
      list.addAll(
        properties.entries
            .where((entry) => RegExp(r'image\d_portrait').hasMatch(entry.key))
            .map((entry) => entry.value)
            .whereType<String>()
            .map((v) => CardData('img', v))
            .toList(),
      );
    }
    return list;
  }

  Future<List<CardData>> getActCardData(String id) async {
    final uri = Uri.parse(
      'https://api.bilibili.com/x/vas/dlc_act/asset_bag?act_id=$id',
    );
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw ('获取失败: ${response.statusCode}');
    }
    final Map<String, dynamic> result = jsonDecode(response.body);
    final List<CardData> list = [];
    for (final i in result['data']?['item_list'] ?? []) {
      final cardItem = i?['card_item'];
      final dynamic name = cardItem?['card_name'];
      final dynamic img = cardItem?['card_img'];
      if (name is! String || img is! String) continue;
      final dynamic videosValue = cardItem?['video_list'];
      List<String>? videos;
      if (videosValue is List) {
        if (videosValue.every((item) => item is String)) {
          videos = videosValue.cast<String>();
        }
      }
      list.add(CardData(name, img, videos: videos));
    }
    for (final i in result['data']?['collect_list'] ?? []) {
      if (i['redeem_item_type'] != 1) continue;
      final cardItem = i?['card_item']?['card_type_info'];
      final dynamic name = cardItem?['name'];
      final dynamic img = cardItem?['overview_image'];
      if (name is! String || img is! String) continue;
      final dynamic videosValue =
          cardItem?['content']?['animation']?['animation_video_urls'];
      List<String>? videos;
      if (videosValue is List) {
        if (videosValue.every((item) => item is String)) {
          videos = videosValue.cast<String>();
        }
      }
      list.add(CardData(name, img, videos: videos));
    }
    return list;
  }
}
