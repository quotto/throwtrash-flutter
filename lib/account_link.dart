
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:throwtrash/usecase/repository/app_config_provider_interface.dart';
import 'package:throwtrash/viewModels/account_link_model.dart';
import 'package:webview_flutter/webview_flutter.dart';

class AccountLink extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AccountLink();
  }
}

class _AccountLink extends State<AccountLink> {
  late AccountLinkModel _accountLinkModel;
  late AppConfigProviderInterface _appConfigProvider;
  late WebViewController controller;
  final _logger = Logger();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _accountLinkModel = Provider.of<AccountLinkModel>(context);
    _appConfigProvider = Provider.of<AppConfigProviderInterface>(context);
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {
            _logger.d("webview@$url");
          },
          onPageFinished: (String url) {},
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            _logger.d("webview@${request.url}");
            // LWAでログインを行った場合、ユニバーサルリンクでリダイレクトされる。
            // Alexaアプリが存在しない場合はモバイルAPIの/enable_skillでスキルを有効化するため、リダイレクト先を変更する。
            var redirectUriPattern = RegExp("^(https://mobileapp.mythrowaway.net/accountlink)\\?(.+)");
            var matchUri = redirectUriPattern.allMatches(request.url).toList();
            if(matchUri.toList().isNotEmpty && !request.url.contains("redirect_uri")) {
              _logger.d("webview@${matchUri.toList()[0].group(1)}");
              controller.loadRequest(Uri.parse("${_appConfigProvider.mobileApiUrl}/enable_skill?${matchUri.toList()[0].group(2)}&token=${_accountLinkModel.accountLinkInfo.token}&redirect_uri=${matchUri.toList()[0].group(1)}"));
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
    ..loadRequest(Uri.parse("${_accountLinkModel.accountLinkInfo.linkUrl}&token=${_accountLinkModel.accountLinkInfo.token}"));

    Widget body = WebViewWidget(controller: controller);
    return Scaffold(
      appBar: AppBar(title: const Text('アカウントリンク')),
      body: body,
    );
  }

}