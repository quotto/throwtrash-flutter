import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:throwtrash/models/exclude_date.dart';
import 'package:throwtrash/viewModels/exclude_date_model.dart';

class ExcludeDateView extends StatefulWidget {
  @override
  _ExcludeDateState createState() => _ExcludeDateState();
}

class _ExcludeDateState extends State<ExcludeDateView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('例外日の設定')),
        body: Consumer<ExcludeViewModel>(
          builder: (context, excludeViewModel, child) {
            List<Widget> columnChildren = [];
            List<Widget> listViewChildren = [];
            excludeViewModel.excludeDates.asMap().forEach((index, pair) {
              listViewChildren.add(
                  Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            showBottomSheet(context: context, builder: (context) {
                              FixedExtentScrollController _ctrl = FixedExtentScrollController(
                                  initialItem: pair[1] - 1
                              );
                              // 月が変わった場合に日付の列を動的に変更するためStatefulBuilderのsetStateが必要
                              return StatefulBuilder(
                                  builder: (context, setState) {
                                    return Container(
                                        height: MediaQuery.of(context).size.height/4,
                                        child: Column(
                                            children:[
                                              Expanded(child:
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                children: [
                                                  Expanded(
                                                      child: CupertinoPicker(
                                                        itemExtent: 32,
                                                        onSelectedItemChanged: (changedMonthIndex) {
                                                          excludeViewModel.changeMonth(index, changedMonthIndex+1);
                                                          _ctrl.animateToItem(
                                                              excludeViewModel.excludeDates[index][1]-1,
                                                              duration: Duration(milliseconds: 250),
                                                              curve: Curves.easeInOut);
                                                          setState((){});
                                                        },
                                                        children: List.generate(12, (month) {
                                                          return Text('${month + 1}月');
                                                        }),
                                                        looping: true,
                                                        scrollController: FixedExtentScrollController(
                                                            initialItem: pair[0] - 1
                                                        ),
                                                      )),
                                                  Expanded(
                                                      child: CupertinoPicker(
                                                        itemExtent: 32,
                                                        onSelectedItemChanged: (changedDateIndex) {
                                                          excludeViewModel.changeDate(index, changedDateIndex+1);
                                                        },
                                                        children: List.generate(excludeViewModel.maxDate,((index){
                                                          return Text('${index+1}日');
                                                        })),
                                                        scrollController: _ctrl,
                                                        looping: true,
                                                      )
                                                  )
                                                ],
                                              )
                                              ),
                                              FilledButton.tonal(onPressed: (){Navigator.pop(context);}, child: Text('選択'))
                                            ]
                                        ));
                                  });
                            });
                          },
                          child: Text('${pair[0]}月${pair[1]}日',
                              style: TextStyle(
                                  fontSize: 32,
                                  color: Theme.of(context).colorScheme.primary
                              )
                          ),
                        ),
                        Padding(
                            padding: EdgeInsets.only(right: 16.0),
                            child: IconButton(
                              icon: Icon(Icons.delete_forever),
                              iconSize: 32,
                              color: Theme.of(context).colorScheme.error,
                              onPressed: ()=>excludeViewModel.removeExcludeDate(index),
                            )
                        )
                      ]
                  )
              );
            });
            columnChildren.add(Expanded(
                child: ListView(
                  children: listViewChildren,
                )
            ));
            if(excludeViewModel.excludeDates.length < 10) {
              columnChildren.add(
                  Container(
                      padding: EdgeInsets.only(bottom: 32.0),
                      child: IconButton(
                          icon: Icon(Icons.add_circle_outline),
                          iconSize: 32,
                          color: Theme.of(context).colorScheme.primary,
                          onPressed: () {
                            excludeViewModel.addExcludeDate(ExcludeDate(1,1));
                          }
                      )
                  )
              );
            }
            columnChildren.add(
                Container(
                    padding: EdgeInsets.only(bottom: 32.0),
                    child: FilledButton.tonal(
                      child: Text('設定'),
                      onPressed: (){
                        Navigator.pop(context, excludeViewModel);
                      },
                    )
                )
            );
            return Column(
              children: columnChildren,
            );
          },
        )
    );
  }
}
