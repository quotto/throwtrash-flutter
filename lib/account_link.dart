
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:throwtrash/models/account_link_info.dart';
import 'package:throwtrash/viewModels/account_link_model.dart';
import 'package:throwtrash/viewModels/activation_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class AccountLink extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AccountLink();
  }
}

class _AccountLink extends State<AccountLink> {
  late AccountLinkModel _accountLinkModel;
  late WebViewController controller;
  final _logger = Logger();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _accountLinkModel = Provider.of<AccountLinkModel>(context);
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
            var redirectUriPattern = RegExp("^(https://mobile.mythrowaway.net/.+/enable_skill)\\?.+");
            var matchUri = redirectUriPattern.allMatches(request.url).toList();
            if(matchUri.toList().isNotEmpty && !request.url.contains("redirect_uri")) {
              controller.loadRequest(Uri.parse("${request.url}&token=${_accountLinkModel.accountLinkInfo.token}&redirect_uri=${matchUri.toList()[0].group(1)}"));
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
    ..loadRequest(Uri.parse("${_accountLinkModel.accountLinkInfo.linkUrl}&token=${_accountLinkModel.accountLinkInfo.token}"));

    Widget body = WebViewWidget(controller: controller);
    if(_accountLinkModel.accountLinkType == AccountLinkType.iOS) {
      launchUrl(Uri.parse(_accountLinkModel.accountLinkInfo.linkUrl));
      body = Container();
    }
    return Scaffold(
      appBar: AppBar(title: const Text('アカウントリンク')),
      body: body,
    );
  }

}