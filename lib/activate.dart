import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:throwtrash/viewModels/activation_model.dart';

class Activate extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _Activate();
  }
}

class _Activate extends State<Activate> {
  late ActivationModel _activationModel;
  TextEditingController _controller = TextEditingController();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _activationModel.addListener(() {
        if(_activationModel.status == ActivationStatus.SUCCESS) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Colors.green,
            content: Text('取り込みに成功しました', style: TextStyle(color: Colors.white)),
            duration: Duration(
                seconds: 2
            ),
          ));
        } else if(_activationModel.status == ActivationStatus.FAILED) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Colors.red,
            content: Text('エラーが発生しました', style: TextStyle(color: Colors.white)),
            duration: Duration(
                seconds: 2
            ),
          ));
        }
      });
    });
  }
  @override
  Widget build(BuildContext context) {
    _activationModel = Provider.of<ActivationModel>(context);
    return Scaffold(
        appBar: AppBar(title: Text('スケジュールの取り込み')),
        body: Container(
          child:
          Padding(
            padding: EdgeInsets.fromLTRB(16.0,32.0,16.0,16.0),
              child: Column(
                  children: [
                    TextField(
                      enabled: _activationModel.status != ActivationStatus.SENDING,
                      controller: _controller,
                      keyboardType: TextInputType.number,
                      maxLength: 10,
                      style: TextStyle(fontSize: 32.0,color: Theme.of(context).colorScheme.primary),
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                          labelText: '共有コードを入力',
                          hintText: '10桁の数字を入力',
                          border: OutlineInputBorder(),
                          labelStyle: TextStyle(fontSize: 20.0)
                      ),
                      onChanged: (value){
                        _activationModel.activateCode(value);
                      },
                    ),
                    if(_activationModel.status == ActivationStatus.SENDING)
                        CircularProgressIndicator()
                  ]
              )
          )
        )
    );
  }
}