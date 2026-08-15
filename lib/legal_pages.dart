import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OtherPage extends StatelessWidget {
  const OtherPage({super.key, required this.applicationVersion});

  final String applicationVersion;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('その他')),
      body: ListView(
        children: [
          ListTile(
            title: Text('利用規約'),
            leading: Icon(Icons.description),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => LegalDocumentPage(
                    title: '利用規約',
                    assetPath: 'assets/legal/term_of_service.txt',
                  ),
                ),
              );
            },
          ),
          ListTile(
            title: Text('プライバシーポリシー'),
            leading: Icon(Icons.privacy_tip),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => LegalDocumentPage(
                    title: 'プライバシーポリシー',
                    assetPath: 'assets/legal/privacy_policy.txt',
                  ),
                ),
              );
            },
          ),
          ListTile(
            title: Text('ライセンス'),
            leading: Icon(Icons.info),
            onTap: () {
              showLicensePage(
                context: context,
                applicationVersion: applicationVersion,
                applicationName: '今日のゴミ出し',
                applicationIcon: Icon(Icons.account_circle_outlined),
              );
            },
          ),
        ],
      ),
    );
  }
}

class LegalDocumentPage extends StatelessWidget {
  const LegalDocumentPage({
    super.key,
    required this.title,
    required this.assetPath,
  });

  final String title;
  final String assetPath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: FutureBuilder<String>(
        future: rootBundle.loadString(assetPath),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('文書を読み込めませんでした'));
          }
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Text(snapshot.data!),
          );
        },
      ),
    );
  }
}
