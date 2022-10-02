import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:throwtrash/activate.dart';
import 'package:throwtrash/repository/activation_api.dart';
import 'package:throwtrash/repository/activation_api_interface.dart';
import 'package:throwtrash/repository/trash_repository_interface.dart';
import 'package:throwtrash/usecase/share_service.dart';
import 'package:throwtrash/usecase/share_service_interface.dart';
import 'package:throwtrash/usecase/trash_data_service_interface.dart';
import 'package:throwtrash/usecase/user_service_interface.dart';
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
        body: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.secondary),
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
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
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
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.secondary)
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
          ],
        )
    );
  }
}