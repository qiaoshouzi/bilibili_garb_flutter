import 'dart:convert';
import 'package:http/http.dart' as http;

class AppVersion {
  final String buildName;
  final int buildNumber;
  AppVersion(this.buildName, this.buildNumber);
}

class AppVersionModel {
  Future<AppVersion?> getLatestBuildNumber() async {
    final response = await http.get(Uri.parse('https://alt.cfm.moe'));
    if (response.statusCode != 200) {
      throw ('获取失败: ${response.statusCode}');
    }
    final Map<String, dynamic> result = jsonDecode(response.body);
    final buildName = result['apps']?[0]?['versions']?[0]?['version'];
    final buildNumber = int.tryParse(
      result['apps']?[0]?['versions']?[0]?['buildVersion'],
    );
    if (buildName is! String || buildNumber is! int) return null;
    return AppVersion(buildName, buildNumber);
  }
}
