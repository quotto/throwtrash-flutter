import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:throwtrash/usecase/user_service_interface.dart';
import 'package:throwtrash/viewModels/activation_model.dart';

class GetActivationCodeView extends StatefulWidget {
  @override
  _GetActivationCodeWidget createState() => _GetActivationCodeWidget();
}

class _GetActivationCodeWidget extends State<GetActivationCodeView> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  late ActivationModel _activationModel;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _activationModel.addListener(() {
        if (_activationModel.status == ActivationStatus.FAILED) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Theme
                .of(context)
                .errorColor,
            duration: Duration(
                seconds: 2
            ),
            content: Text('共有コードの発行に失敗しました'),
          ));
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final UserServiceInterface _userService = Provider.of<UserServiceInterface>(context);

    _activationModel = Provider.of<ActivationModel>(context);
    return Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
            centerTitle: false,
            elevation: 2,
            title: Text("スケジュールを共有する")
        ),
        body: _userService.user.id.isEmpty ?
        AlertDialog(
          content: Text("スケジュールを共有するためにはゴミ出しの予定を登録してください"),
          actions: [
            ElevatedButton(onPressed: () {
              Navigator.pop(context);
            },
                child: Text("戻る"))
          ],
        ):
        Consumer<ActivationModel>(
            builder: (context, activationModel, child) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                      margin: EdgeInsets.only(top: 20),
                      child: FractionallySizedBox(
                        widthFactor: 0.8,
                        child: Container(
                            padding: EdgeInsets.only(top: 20, bottom: 20),
                            decoration: BoxDecoration(
                                border: Border.all(
                                    width: 3,
                                    color: Theme
                                        .of(context)
                                        .colorScheme
                                        .secondary
                                )
                            ),
                            child: TextButton(
                              onLongPress: (() async {
                                final code = ClipboardData(
                                    text: _activationModel.publishedCode);
                                await Clipboard.setData(code);
                                Fluttertoast.showToast(msg: "クリップボードにコピーしました");
                              }),
                              onPressed: (() {}),
                              child: Text(
                                _activationModel.publishedCode,
                                textScaleFactor: 3,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  wordSpacing: 2,
                                ),
                              ),
                            )
                        ),
                      )
                  ),
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(0, 30, 0, 0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: activationModel.status ==
                              ActivationStatus.SENDING ? null : () async {
                            activationModel.getActivationCode();
                          },
                          child: Text('共有コード発行'),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                      child: Padding(
                          padding: EdgeInsets.only(left: 10, right: 10),

                          child: ListView(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(top: 10, bottom:10),
                                child: Text("1.「共有コード発行」ボタンを押すと枠の中に10桁の数字が表示されます"),
                              ),
                              Padding(
                                  padding: EdgeInsets.only(top: 10, bottom: 10),
                                  child: Text("2.スケジュールを共有したい端末でアプリを起動して、10桁の数字を入力してください。")
                              )
                            ],
                          )
                      )
                  )
                ],
              );
            }
        )
    );
  }
}
