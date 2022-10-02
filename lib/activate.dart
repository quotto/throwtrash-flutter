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
    List<FocusNode> focusList = [];
    for(int i=0; i<10; i++) {
      focusList.add(FocusNode());
    }
    List<Flexible> CodeInputs = [];
    for(int i=0; i<10; i++) {
      CodeInputs.add(
          Flexible(
              child: KeyboardListener(
                  onKeyEvent: ((keyEvent) {
                    print(keyEvent.logicalKey.keyLabel) ;
                    if(i > 0 && keyEvent is KeyDownEvent &&
                        keyEvent.logicalKey.keyLabel == "Backspace" &&
                        _activationModel.activateCodeChars[i] == "") {
                      focusList[i-1].requestFocus();
                    }
                  }),
                  focusNode: FocusNode(),
                  child: TextField(
                    enabled: _activationModel.status == ActivationStatus.NONE || _activationModel.status == ActivationStatus.FAILED,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      counterText: "",
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.black12,
                          width: 2
                        )

                    )
                    ),
                    maxLength: 1,
                    focusNode: focusList[i],
                    keyboardType: TextInputType.number,
                    onChanged: (value){
                      print(value);
                      _activationModel.setCodeValue(value, i);
                      if(value.isNotEmpty && i <= 8) {
                        focusList[i+1].requestFocus();
                      }
                    },
                  )
              )
          )
      );
    }
    return Scaffold(
        appBar: AppBar(title: Text('スケジュールの取り込み')),
        body: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: CodeInputs
                )
              ],
            )
        )
    );
  }
}