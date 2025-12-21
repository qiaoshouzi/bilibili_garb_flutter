import 'dart:io';
import 'package:bili_garb/main.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:bili_garb/models/app_version_model.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:bili_garb/view_models/app_version_view_model.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});
  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  String _version = 'V0.0.0+0';
  int _buildNumber = 0;

  AppVersionViewModel appVersionViewModel = AppVersionViewModel(
    AppVersionModel(),
  );

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
  }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _version = 'V${info.version}+${info.buildNumber}';
        _buildNumber = int.tryParse(info.buildNumber) ?? 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final messenger = ScaffoldMessenger.of(context);
    return ListView(
      children: <Widget>[
        ListenableBuilder(
          listenable: appVersionViewModel,
          builder: (context, child) => Visibility(
            visible: appVersionViewModel.loading,
            child: const LinearProgressIndicator(),
          ),
        ),
        ListTile(
          title: Text('主题'),
          subtitle: Text(switch (MyApp.of(context).currentThemeMode) {
            ThemeMode.system => '跟随系统',
            ThemeMode.light => '亮色',
            ThemeMode.dark => '深色',
          }),
          trailing: PopupMenuButton<ThemeMode>(
            tooltip: '选择主题',
            initialValue: MyApp.of(context).currentThemeMode,
            onSelected: (ThemeMode value) {
              MyApp.of(context).changeTheme(value);
              setState(() {});
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<ThemeMode>>[
              const PopupMenuItem<ThemeMode>(
                value: ThemeMode.system,
                child: Text('跟随系统'),
              ),
              const PopupMenuItem<ThemeMode>(
                value: ThemeMode.light,
                child: Text('亮色'),
              ),
              const PopupMenuItem<ThemeMode>(
                value: ThemeMode.dark,
                child: Text('深色'),
              ),
            ],
          ),
        ),
        Divider(height: 0),
        ListTile(
          title: Text('联系我们'),
          onTap: () async {
            !await launchUrl(Uri.parse('https://b23.cfm.moe/app/contact'));
          },
        ),
        Divider(height: 0),
        ListTile(
          title: Text('关于应用'),
          onTap: () {
            showAboutDialog(
              context: context,
              applicationName: 'BiliBili 装扮获取',
              applicationVersion: _version,
              applicationIcon: Icon(Icons.checkroom),
              applicationLegalese: '© 2025 CFM.MOE',
            );
          },
        ),
        Divider(height: 0),
        ListenableBuilder(
          listenable: appVersionViewModel,
          builder: (context, child) => ListTile(
            title: Text('版本'),
            subtitle:
                (appVersionViewModel.result?.buildNumber ?? 0) > _buildNumber
                ? Text(
                    '$_version(最新版本: ${appVersionViewModel.result?.buildName}+${appVersionViewModel.result?.buildNumber})',
                  )
                : Text(_version),
            onTap: () async {
              await appVersionViewModel.init();
              final result = appVersionViewModel.result;
              final buildNumber = result?.buildNumber ?? 0;
              if (appVersionViewModel.errMsg is String) {
                messenger.showSnackBar(
                  SnackBar(
                    content: Text('获取最新版本错误: ${appVersionViewModel.errMsg}'),
                  ),
                );
              } else if (buildNumber == _buildNumber) {
                messenger.showSnackBar(SnackBar(content: Text('已经是最新版本了喵~')));
              } else if (buildNumber < _buildNumber) {
                messenger.showSnackBar(SnackBar(content: Text('你的版本为什么那么新喵?')));
              } else {
                final Uri url = Uri.parse('https://b23.cfm.moe/app?update');
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      '需要更新，请前往官网${Platform.isIOS ? '或AltStore' : ''}更新喵~',
                    ),
                    action: SnackBarAction(
                      label: '前往官网',
                      onPressed: () async {
                        if (await canLaunchUrl(url)) {
                          await launchUrl(
                            url,
                            mode: LaunchMode.externalApplication,
                          );
                        } else {}
                      },
                    ),
                    duration: const Duration(seconds: 5),
                  ),
                );
              }
            },
          ),
        ),
      ],
    );
  }
}
