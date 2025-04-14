import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:throwtrash/usecase/user_service_interface.dart';

class UserInfo extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _UserInfo();
  }
}

class _UserInfo extends State<UserInfo> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ユーザー情報"),
      ),
      body: Consumer<UserServiceInterface>(builder: (context, userService, child) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ユーザーID部分
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "ユーザーID",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Text(userService.user.id,
                                style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                          ),
                          IconButton(
                            icon: Icon(Icons.copy, color: Theme.of(context).colorScheme.secondary),
                            onPressed: () async {
                              ClipboardData userId = ClipboardData(text: userService.user.id);
                              await Clipboard.setData(userId);
                              Fluttertoast.showToast(msg: "クリップボードにコピーしました");
                            },
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 24),

              // アカウント情報部分
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "アカウント情報",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 8),
                      // ログイン状態表示
                      Row(
                        children: [
                          Icon(
                            userService.user.isAuthenticated
                                ? Icons.check_circle
                                : Icons.account_circle,
                            color: userService.user.isAuthenticated ? Colors.green : Colors.grey,
                          ),
                          SizedBox(width: 8),
                          Text(
                            userService.user.isAuthenticated ? "ログイン中" : "匿名ユーザー",
                          ),
                        ],
                      ),

                      // ログインユーザーの場合はユーザー情報を表示
                      if (userService.user.isAuthenticated) ...[
                        SizedBox(height: 16),
                        if (userService.user.email != null) Text("メール: ${userService.user.email}"),
                        if (userService.user.displayName != null)
                          Text("名前: ${userService.user.displayName}"),
                      ],

                      SizedBox(height: 16),

                      // ボタン表示
                      if (_isLoading)
                        Center(child: CircularProgressIndicator())
                      else ...[
                        // ログインボタン（認証されていない場合のみ表示）
                        if (!userService.user.isAuthenticated)
                          ElevatedButton.icon(
                            icon: Icon(Icons.login),
                            label: Text("Googleアカウントでログイン"),
                            style: ElevatedButton.styleFrom(
                              minimumSize: Size(double.infinity, 50),
                            ),
                            onPressed: () async {
                              setState(() => _isLoading = true);
                              try {
                                final result = await userService.signInWithGoogle();
                                if (result) {
                                  Fluttertoast.showToast(
                                    msg: "ログインしました",
                                    backgroundColor: Colors.green,
                                  );
                                } else {
                                  Fluttertoast.showToast(
                                    msg: "ログインに失敗しました",
                                    backgroundColor: Colors.red,
                                  );
                                }
                              } finally {
                                setState(() => _isLoading = false);
                              }
                            },
                          ),

                        SizedBox(height: 8),

                        // ログアウトボタン（認証されている場合のみ表示）
                        if (userService.user.isAuthenticated)
                          OutlinedButton.icon(
                            icon: Icon(Icons.logout),
                            label: Text("ログアウト"),
                            style: OutlinedButton.styleFrom(
                              minimumSize: Size(double.infinity, 50),
                            ),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text("ログアウト"),
                                  content: Text("ローカル上のデータがすべて削除されます。よろしいですか？"),
                                  actions: [
                                    TextButton(
                                      child: Text("キャンセル"),
                                      onPressed: () => Navigator.of(context).pop(false),
                                    ),
                                    TextButton(
                                      child: Text("ログアウト"),
                                      onPressed: () => Navigator.of(context).pop(true),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm == true) {
                                setState(() => _isLoading = true);
                                try {
                                  final result = await userService.signOut();
                                  if (result) {
                                    Fluttertoast.showToast(
                                      msg: "ログアウトしました",
                                      backgroundColor: Colors.blue,
                                    );
                                  } else {
                                    Fluttertoast.showToast(
                                      msg: "ログアウトに失敗しました",
                                      backgroundColor: Colors.red,
                                    );
                                  }
                                } finally {
                                  setState(() => _isLoading = false);
                                }
                              }
                            },
                          ),

                        SizedBox(height: 16),

                        // アカウント削除ボタン
                        TextButton.icon(
                          icon: Icon(Icons.delete_forever, color: Colors.red),
                          label: Text(
                            "アカウントを削除",
                            style: TextStyle(color: Colors.red),
                          ),
                          style: TextButton.styleFrom(
                            minimumSize: Size(double.infinity, 50),
                          ),
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text("アカウント削除"),
                                content: Text("アカウントとすべてのデータが完全に削除されます。この操作は元に戻せません。よろしいですか？"),
                                actions: [
                                  TextButton(
                                    child: Text("キャンセル"),
                                    onPressed: () => Navigator.of(context).pop(false),
                                  ),
                                  TextButton(
                                    child: Text("削除する"),
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.red,
                                    ),
                                    onPressed: () => Navigator.of(context).pop(true),
                                  ),
                                ],
                              ),
                            );

                            if (confirm == true) {
                              setState(() => _isLoading = true);
                              try {
                                final result = await userService.deleteAccount();
                                if (result) {
                                  Fluttertoast.showToast(
                                    msg: "アカウントを削除しました",
                                    backgroundColor: Colors.blue,
                                  );
                                } else {
                                  Fluttertoast.showToast(
                                    msg: "アカウント削除に失敗しました",
                                    backgroundColor: Colors.red,
                                  );
                                }
                              } finally {
                                setState(() => _isLoading = false);
                              }
                            }
                          },
                        ),
                      ]
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
