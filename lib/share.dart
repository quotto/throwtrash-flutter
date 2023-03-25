import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:throwtrash/activate.dart';
import 'package:throwtrash/usecase/share_service_interface.dart';
import 'package:throwtrash/viewModels/activation_model.dart';

import 'get_activation_code.dart';

class Share extends StatefulWidget {
  @override
  _ShareState createState()=>_ShareState();
}

class _ShareState extends State<Share> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text('スケジュールの共有')
        ),
        body: Padding(
            padding: EdgeInsets.fromLTRB(32.0,0,32.0,32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                    ),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) =>
                              ChangeNotifierProvider<ActivationModel>(
                                create: (context) =>
                                    ActivationModel(Provider.of<
                                        ShareServiceInterface>(context,listen: false)),
                                child: GetActivationCodeView(),
                              )
                          )
                      );
                    },
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.share),
                          Text("スケジュールを共有する"),
                        ]
                    )
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) =>
                              ChangeNotifierProvider<ActivationModel>(
                                create: (context) =>
                                    ActivationModel(Provider.of<
                                        ShareServiceInterface>(context,listen: false)),
                                child: Activate(),
                              )
                          )
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                    ),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.input_sharp),
                          Text("スケジュールを取り込む"),
                        ]
                    )
                )
              ],
            )
        )
    );
  }
}