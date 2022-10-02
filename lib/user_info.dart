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

class _UserInfo extends State<UserInfo>  {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ユーザー情報"),
      ),
      body: Column(
        children: [
          Container(
           child: Consumer<UserServiceInterface> (
             builder: (context,userService,child) {
               return Row(
                 children: [
                   Text(userService.user.id),
                   IconButton(
                       icon: Icon(Icons.copy),
                     onPressed: () async {
                      ClipboardData userId = ClipboardData(text: userService.user.id);
                      await Clipboard.setData(userId);
                      Fluttertoast.showToast(msg: "クリップボードにコピーしました");
                     },
                   )
                 ],
               );
             }
           )
          )
        ],
      ),
    );
  }
}