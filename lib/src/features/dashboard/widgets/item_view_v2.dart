
import 'dart:async';
import 'dart:collection';

import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_pusher/pusher.dart';
import 'package:outerboxkitchen/src/database/database_helper.dart';
import 'package:outerboxkitchen/src/features/dashboard/widgets/printer.dart';
import 'package:outerboxkitchen/src/features/login/screens/login_pincode.dart';
import 'package:outerboxkitchen/src/models/orders_by_table.dart';
import 'package:outerboxkitchen/src/models/product_reports.dart';
import 'package:outerboxkitchen/src/models/store_firebase.dart';
import 'package:outerboxkitchen/src/models/table_join_order.dart';
import 'package:outerboxkitchen/src/utils/hex_color.dart';
import 'package:outerboxkitchen/src/utils/user_sessions.dart';
import 'package:firebase_database/firebase_database.dart' as ftdb;
import 'package:loading_indicator/loading_indicator.dart';
import 'package:uuid/uuid.dart';

import '../../../models/table_with_orders_model.dart';


class ItemViewV2 extends StatefulWidget {

  @override
  _ItemViewV2State createState() =>
      _ItemViewV2State();
}

class _ItemViewV2State extends State<ItemViewV2> with WidgetsBindingObserver{



  AudioCache audioCache = AudioCache();
  AudioPlayer advancedPlayer = AudioPlayer(), advancedPlayerForFinishItem = AudioPlayer();

  ftdb.DatabaseReference itemRef, itemProductUpdateRef;
  ftdb.Query _todoQuery;
  StreamSubscription<ftdb.Event> _onMerchantAddedSubscription;
  StreamSubscription<ftdb.Event> _onMerchantChangedSubscription;

  Future<List<OrderJoinTable>> _futureCurrentList;

  List<OrderJoinTable> _currentList = [];
  List<StoreOrderFirebase> storeItems = [];
  List<StoreTableParentOrderFirebase> parentItems = [];

  List<int> listTimer = [];

  List<StoreOrderFirebase> allTableList = [];
  List<String> addedTrack = [];

  int currentIndex = 0;
  int currentTimerValue = 1;
  int itemTotalCount = 0;
  int countTotalComplete = 0;
  bool display = false;
  String merchantId = "";

  Timer _timer;

  @override
  void initState() {
    UserSessions.getPrinterConnected();
    //parentItems.addAll(widget.itemList);
    getItemOrders();
    UserSessions.getMerchantId().then((value) {
      itemProductUpdateRef = ftdb.FirebaseDatabase.instance.reference().child("Orders").child(value).child("by_product");
      itemRef = ftdb.FirebaseDatabase.instance.reference().child("Orders").child(value).child("by_table");
      _todoQuery = ftdb.FirebaseDatabase.instance.reference().child("Orders").child(value).child("by_table");
      _onMerchantAddedSubscription = _todoQuery.onChildAdded.listen(onEntryUserAdded);
      _onMerchantChangedSubscription = _todoQuery.onChildChanged.listen(onEntryUserChanged);
      _timer = Timer.periodic(Duration(seconds: 1), (_) {
        setState(() {

          for(int start = 0; start < _currentList.length; start++){
            if(_currentList[start].listTableOrder != null){
              for(int item = 0; item < _currentList[start].listTableOrder.length; item++){
                TableItems tableItems =  _currentList[start].listTableOrder[item];
                tableItems.timerLastValue = (int.parse(_currentList[start].listTableOrder[item].timerLastValue) + 1).toString();
                _currentList[start].listTableOrder[item] = tableItems;
              }
              // var sortedByValue = new HashMap.fromEntries(parentItems[start].tableItems.entries.toList().reversed);
              // sortedByValue.forEach((key, value) {
              //   parentItems[start].tableItems[key]["lastTimerValue"] = (int.parse(parentItems[start].tableItems[key]["lastTimerValue"].toString()) + 1).toString();
              //   //parentItems[start].tableItems[key]["lastTimerValue"] = (diff.inSeconds + 1).toString();
              // });
            }
          }

        });
      });
    });

    WidgetsBinding.instance.addObserver(this);

    UserSessions.setCompletedList(isCompleted: true);
    super.initState();
  }

  @override
  void dispose() {
    _timer.cancel();
    advancedPlayer.dispose();
    advancedPlayerForFinishItem.dispose();
    _onMerchantAddedSubscription.cancel();
    _onMerchantChangedSubscription.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void playCompleteOnSound() async {
    await advancedPlayerForFinishItem.release();
    await advancedPlayerForFinishItem.setReleaseMode(ReleaseMode.RELEASE);
    advancedPlayerForFinishItem.play(await audioCache.getAbsoluteUrl('mp3/ding.mp3'), isLocal: true);
  }



  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        print("app in resumed");
        // Navigator.of(context).pushAndRemoveUntil<void>(
        //   // HomePage.route(),
        //   //     (route) => false,
        //   LoginPinCodeScreen.route(), (route) => false,
        // );
        break;
      case AppLifecycleState.inactive:
        print("app in inactive");
        break;
      case AppLifecycleState.paused:
        print("app in paused");
        break;
      case AppLifecycleState.detached:
        print("app in detached");
        break;
    }
  }

  onEntryUserAdded(ftdb.Event event) {
    if(event.snapshot.value != null){

      setState(() {
        StoreOrderFirebase storeOrderFirebase = StoreOrderFirebase.fromSnapshot(event.snapshot);

        if(storeOrderFirebase.status == "new"){
         // UserSessions.setCompletedList(isCompleted: false);
          showAlertDialog(context, storeOrderFirebase);
        } else {
          storeItems.add(storeOrderFirebase);

        }


        // print(storeItems.length);
      });

    }
  }

  onEntryUserChanged(ftdb.Event event) {
    StoreOrderFirebase storeOrderFirebase = StoreOrderFirebase.fromSnapshot(event.snapshot);
    if(storeOrderFirebase.status == "new"){
     // UserSessions.setCompletedList(isCompleted: false);
      showAlertDialog(context, storeOrderFirebase);
    }

  }


  int tableItemCount(List<TableItems> json){
    int counter = 0;

    for(int x = 0; x < json.length; x++){
      if(json[x].status == "no"){
        int qty = json[x].quantity - json[x].completedCount;
        counter+= qty;
      }
    }


    return counter;
  }

  double itemCount(int length){
    double maxLength = 0;

    if(length >= 1 && length <= 3){
      maxLength = 250;
    } else if(length > 3 && length <= 7){
      maxLength = 420;
    } else if(length > 7){
      maxLength = 700;
    }
    return maxLength;
  }

  void updateProduct(String parentKey, String nodeKey, StoreTableOrderFirebase itemNode) async {
      print("Parent key => " + parentKey);
      print("Node key => " + nodeKey);

      ftdb.TransactionResult transactionResult = await itemRef.child(parentKey).runTransaction((ftdb.MutableData mutableData) async {
        return mutableData;
      });

      StoreTableParentOrderFirebase itemResult = StoreTableParentOrderFirebase.fromSnapshot(transactionResult.dataSnapshot);

      //print(itemResult.tableItems.containsKey(nodeKey));

      if(itemResult.tableItems.containsKey(nodeKey)){
        itemResult.tableItems.update(nodeKey, (value) => itemNode.toJson());
        Map<String, dynamic> childUpdate = new HashMap<String, dynamic>();
        childUpdate.putIfAbsent(parentKey, () => itemResult.toJson());
        itemRef.update(childUpdate);
      }



      for(int itemIndex = 0; itemIndex < allTableList.length; itemIndex++){
        StoreOrderFirebase orderItem = allTableList[itemIndex];

        if(orderItem.tableName == itemNode.tableName && orderItem.tableId == itemNode.id){
          print("You have table equal");
          if(orderItem.listItem != null){
              // Split the key
              String itemName = parentKey.split("_")[0];
              String varianceName = parentKey.split("_")[1];
              int listItemCount = orderItem.listItem.length;
              List<bool> completedState  = [];
              orderItem.listItem.forEach((itemKey, tableValue) {

                if(tableValue["completed"].toString() == "no"){
                  if(varianceName == tableValue["variance"].toString() &&  itemName == tableValue["itemName"]){
                    int quantity = tableValue["quantity"];
                    int completeCount = itemNode.completeCount;

                    if(quantity == completeCount){
                      tableValue["completed"] = "yes";
                      tableValue["completeCount"] = completeCount;
                      completedState.add(true);
                    } else {
                      completeCount = itemNode.completeCount;
                      if(quantity == completeCount){
                        tableValue["completed"] = "yes";
                        tableValue["completeCount"] = completeCount;
                        completedState.add(true);
                      } else {
                        tableValue["completeCount"] = completeCount;
                      }
                    }
                  }
                } else if (tableValue["completed"].toString() == "yes"){
                  completedState.add(true);
                }

                print("COMPLETED STATE LENGTH => " + completedState.length.toString());

              });


              // print("listItemCount LENGTH => " + listItemCount.toString());
              if(completedState.length == listItemCount){
                orderItem.status = "complete";
              }

              Map<String, dynamic> childUpdate = new HashMap<String, dynamic>();
              childUpdate.putIfAbsent(orderItem.key, () => orderItem.toJson());
            //  itemTableRefUpdate.update(childUpdate);

          }
        }
      }

      //print(allTableList.length);

  }

  void updateParentProduct(StoreTableParentOrderFirebase parentTableItem, String parentKey) async {
    print("UPDATE PARENT PRODUCT");
    ftdb.TransactionResult transactionResult = await itemRef.child(parentKey).runTransaction((ftdb.MutableData mutableData) async {
      return mutableData;
    });

    StoreTableParentOrderFirebase itemResult = StoreTableParentOrderFirebase.fromSnapshot(transactionResult.dataSnapshot);
    itemResult.status = "complete";
    itemResult.completed = "yes";
    itemResult.tableItems = null;
    Map<String, dynamic> childUpdate = new HashMap<String, dynamic>();
    childUpdate.putIfAbsent(itemResult.key, () => itemResult.toJson());
    itemRef.update(childUpdate);

  }

  getItemOrders() async {
    setState(() {
      _futureCurrentList = DatabaseHelper().getJoinItemOrdersToTableOrder();

    });
  }

  Future _refreshData() async {

    setState(() {
      Future.delayed(Duration(seconds: 1), () {
        // 5s over, navigate to a new page
        _futureCurrentList = DatabaseHelper().getJoinItemOrdersToTableOrder();
      });
    });


  }

  printTicketOrder(OrderJoinTable itemParent, int firstValue, TableItems tableItems) async {
    bool connectedPrinter = await Printer().connectPrinterAutomatic();

    if(connectedPrinter){
      bool statusPrint = await Printer().printTicket(
          tableItems.tableName,
          firstValue.toString(),
          tableItems.itemName,
          tableItems.variance,
          tableItems.customerName,
          tableItems.transactionNo
      );
      print("Printing");
    } else {
      print("Disconnected");
      showPrinterDCAlertDialog(context);
    }
    // bool statusPrint = await Printer().printTicket(
    //     tableItems.tableName,
    //     firstValue.toString(),
    //     tableItems.itemName,
    //     tableItems.variance,
    //     tableItems.customerName,
    //     tableItems.transactionNo
    // );
    // if(statusPrint){
    //   print("Printing");
    // } else {
    //   print("Disconnected");
    //   showPrinterDCAlertDialog(context);
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: <Widget>[
          SliverList(
            delegate: new SliverChildListDelegate([
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    height: MediaQuery.of(context).size.height - 80,
                    child: FutureBuilder<List<OrderJoinTable>>(
                      future: _futureCurrentList,
                        builder: (context, snapshot){
                          if(snapshot.connectionState == ConnectionState.done){
                            if(snapshot.hasData){
                              _currentList = snapshot.data;
                              if(_currentList.length > 0){
                                return ListView.builder(
                                    itemCount: _currentList.length,
                                    itemBuilder: (context, index){
                                      return Column(
                                        children: <Widget>[
                                          Container(
                                            //  padding: EdgeInsets.all(10),
                                            height: _currentList[index].variance.length > 50 ? 80 : 65,
                                            decoration: new BoxDecoration(
                                              color: HexColor("#C5C5C5"),
                                            ),
                                            child: Row(
                                              children: [
                                                SizedBox(width: 15),
                                                _currentList[index].variance.length > 0 ?
                                                Container(
                                                    width: 450,
                                                    child: Column(
                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        SizedBox(height: 5),
                                                        Text(_currentList[index].name,
                                                          style: TextStyle(
                                                              color: HexColor("#0B1043"),
                                                              fontSize: MediaQuery.of(context).textScaleFactor * 25,
                                                              fontWeight: FontWeight.bold),
                                                        ),
                                                        Text(_currentList[index].variance,
                                                          style: TextStyle(
                                                              color: HexColor("#0B1043"),
                                                              fontSize: MediaQuery.of(context).textScaleFactor * 17,
                                                              fontWeight: FontWeight.bold),
                                                        ),
                                                      ],
                                                    )
                                                )
                                                    : Text(_currentList[index].name,
                                                  style: TextStyle(
                                                      color: HexColor("#0B1043"),
                                                      fontSize: MediaQuery.of(context).textScaleFactor * 25,
                                                      fontWeight: FontWeight.bold),
                                                ),

                                                Spacer(),
                                                Container(
                                                  height: 65,
                                                  width: 50,
                                                  decoration: new BoxDecoration(
                                                    color: HexColor("#9F9F9F"),
                                                  ),
                                                  child: Center(
                                                    child: Text(tableItemCount(_currentList[index].listTableOrder).toString(),
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: MediaQuery.of(context).textScaleFactor * 29,
                                                          fontWeight: FontWeight.bold),
                                                    ),
                                                  ),
                                                ),

                                              ],
                                            ),
                                          ),

                                          Column(
                                            children: productList(_currentList[index].listTableOrder, _currentList[index], index),
                                          ),
                                          SizedBox(height: 15),

                                        ],
                                      );

                                    }
                                );
                              } else {
                                return Container(
                                  child: Center(
                                    child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: <Widget>[
                                          Image.asset("assets/images/nodata.jpg", width: 300, height: 300),
                                          Text("No Data Available.", style: TextStyle(
                                              color: HexColor("#0B1043"),
                                              fontSize: MediaQuery.of(context).textScaleFactor * 25,
                                              fontWeight: FontWeight.bold),),
                                        ]
                                    ),
                                  ),
                                );
                              }
                            } else if(snapshot.hasError){
                              return Text("${snapshot.error}");
                            } else {
                              return Container(
                                child: Center(
                                  child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[
                                        Image.asset("assets/images/nodata.jpg", width: 300, height: 300),
                                        Text("No Data Available.", style: TextStyle(
                                        color: HexColor("#0B1043"),
                                    fontSize: MediaQuery.of(context).textScaleFactor * 25,
                                    fontWeight: FontWeight.bold),),
                                      ]
                                  ),
                                ),
                              );
                            }

                          }

                          return Center(
                            child: Container(
                              width: 100,
                              height: 100,
                              child: LoadingIndicator(indicatorType: Indicator.ballRotateChase, color: HexColor("#0B1043"),),
                            ),
                          );
                        }
                    ),
                  )
                ]
              ),
              // Column(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: <Widget>[
              //     Container(
              //       height: MediaQuery.of(context).size.height - 75,
              //       child:
              //       ListView.builder(
              //           itemCount: parentItems.length,
              //           itemBuilder: (context, index){
              //
              //             //print(tableItemCount(parentItems[index].tableItems));
              //
              //               if(parentItems[index].status != "complete"){
              //                 //print(display);
              //                 if(tableItemCount(parentItems[index].tableItems) > 0){
              //                     UserSessions.setCompletedList(isCompleted: false);
              //                     String itemName = parentItems[index].key.split("_")[0];
              //                     String varianceName = parentItems[index].key.split("_")[1];
              //                     // print(varianceName.length);
              //                     return Column(
              //                       children: <Widget>[
              //                         Container(
              //                           //  padding: EdgeInsets.all(10),
              //                           height: varianceName.length > 50 ? 80 : 65,
              //                           decoration: new BoxDecoration(
              //                             color: HexColor("#C5C5C5"),
              //                           ),
              //                           child: Row(
              //                             children: [
              //                               SizedBox(width: 15),
              //                               varianceName.length > 0 ?
              //                               Container(
              //                                   width: 450,
              //                                   child: Column(
              //                                     mainAxisAlignment: MainAxisAlignment.start,
              //                                     crossAxisAlignment: CrossAxisAlignment.start,
              //                                     children: [
              //                                       SizedBox(height: 5),
              //                                       Text(itemName,
              //                                         style: TextStyle(
              //                                             color: HexColor("#0B1043"),
              //                                             fontSize: MediaQuery.of(context).textScaleFactor * 25,
              //                                             fontWeight: FontWeight.bold),
              //                                       ),
              //                                       Text(varianceName,
              //                                         style: TextStyle(
              //                                             color: HexColor("#0B1043"),
              //                                             fontSize: MediaQuery.of(context).textScaleFactor * 17,
              //                                             fontWeight: FontWeight.bold),
              //                                       ),
              //                                     ],
              //                                   )
              //                               )
              //                                   : Text(itemName,
              //                                 style: TextStyle(
              //                                     color: HexColor("#0B1043"),
              //                                     fontSize: MediaQuery.of(context).textScaleFactor * 25,
              //                                     fontWeight: FontWeight.bold),
              //                               ),
              //
              //                               Spacer(),
              //                               Container(
              //                                 height: 65,
              //                                 width: 50,
              //                                 decoration: new BoxDecoration(
              //                                   color: HexColor("#9F9F9F"),
              //                                 ),
              //                                 child: Center(
              //                                   child: Text(tableItemCount(parentItems[index].tableItems).toString(),
              //                                     style: TextStyle(
              //                                         color: Colors.white,
              //                                         fontSize: MediaQuery.of(context).textScaleFactor * 29,
              //                                         fontWeight: FontWeight.bold),
              //                                   ),
              //                                 ),
              //                               ),
              //
              //                             ],
              //                           ),
              //                         ),
              //
              //                         Column(
              //                           children: productList(parentItems[index].tableItems, parentItems[index], index),
              //                         ),
              //                         SizedBox(height: 15),
              //
              //                       ],
              //                     );
              //
              //
              //                 } else {
              //                   return Container();
              //                 }
              //
              //               } else {
              //
              //                 return Container();
              //               }
              //
              //
              //           }
              //       ),
              //     ),
              //
              //
              //   ],
              // ),
              //     : Container(
              //   margin: EdgeInsets.only(top: 200),
              //   child: Center(
              //     child: Column(
              //         mainAxisAlignment: MainAxisAlignment.center,
              //         children: <Widget>[
              //           Image.asset("assets/images/nodata.jpg", width: 300, height: 300),
              //           Text("No data available.", style: TextStyle(
              //               color: HexColor("#0B1043"),
              //               fontSize: MediaQuery.of(context).textScaleFactor * 20,
              //               fontWeight: FontWeight.normal),),
              //         ]
              //     ),
              //   ),
              // ),
            ]),
          ),
        ],
      ),
    );
  }

  List<Widget> productList(List<TableItems> json, OrderJoinTable itemParent, int mainIndex){
    List<Widget> addToList = [];

    for(int x = 0; x < json.length; x++){
      if(json[x].status != "yes"){
        var now = DateTime.now();
        var date = DateTime.fromMillisecondsSinceEpoch(json[x].timestamp);
        var diff = now.difference(date).inSeconds;
        json[x].timerLastValue = diff.toString();
        Widget newItem = Container(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              //String parentKey = itemParent.key.split("_")[0];
              showConfirmAlertDialog(
                  context,
                  json[x].quantity,
                  json[x].completedCount,
                  json[x].tableName,
                  json[x].tableIdRtdb,
                  json[x].itemName,
                  json[x].variance,
                  itemParent,
                  mainIndex,
                  json[x].timestamp.toString()
              );
            },
            child: Container(
              padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
              child: Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: json[x].isTakeOUt.toString() == "0" ? Colors.green : Colors.red,
                    ),
                  ),

                  SizedBox(width: 10),
                  Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text((json[x].quantity -  json[x].completedCount).toString() + "x ", style: TextStyle(color: HexColor("#0B1043"), fontSize: 25), maxLines: 4,),
                      ],
                    ),
                  ),
                  Container(
                    width: 340,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(json[x].tableName, style: TextStyle(color: HexColor("#0B1043"), fontSize: 25), maxLines: 4,),
                      ],
                    ),
                  ),
                  Spacer(),
                  Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(json[x].timerLastValue.toString(),
                          style: TextStyle(
                              color: HexColor("#0B1043"),
                              fontSize: MediaQuery.of(context).textScaleFactor * 25,
                              fontWeight: FontWeight.bold), maxLines: 4,
                        ),

                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
        addToList.add(newItem);
      }
    }
    // var sortedByValue = new HashMap.fromEntries(json.entries.toList().reversed);
    // sortedByValue.forEach((tableKey, tableValue) {
    //   if(tableValue["completed"] != "yes"){
    //
    //     var now = DateTime.now();
    //     var date = DateTime.fromMillisecondsSinceEpoch(int.parse(json[tableKey]["timestamp"].toString()));
    //     var diff = now.difference(date).inSeconds;
    //     // int lastTimerValue = int.parse(tableValue["lastTimerValue"].toString()) + currentTimerValue;
    //     // json[tableKey]["lastTimerValue"] = lastTimerValue.toString();
    //     // listTimer.add(lastTimerValue);
    //     json[tableKey]["lastTimerValue"] = diff.toString();
    //     Widget newItem = Container(
    //       child: GestureDetector(
    //         behavior: HitTestBehavior.translucent,
    //         onTap: () {
    //           String parentKey = itemParent.key.split("_")[0];
    //           showConfirmAlertDialog(context, int.parse(tableValue["quantity"].toString()),
    //               int.parse(tableValue["completeCount"].toString()),
    //               tableValue["tableName"].toString(), tableValue["id"].toString(), parentKey,
    //               itemParent, mainIndex,
    //               tableValue["timestamp"].toString());
    //         },
    //         child: Container(
    //           padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
    //           child: Row(
    //             children: [
    //               Container(
    //                 width: 20,
    //                 height: 20,
    //                 decoration: BoxDecoration(
    //                   shape: BoxShape.circle,
    //                   color: tableValue["isTakeOut"].toString() == "0" ? Colors.green : Colors.red,
    //                 ),
    //               ),
    //
    //               SizedBox(width: 10),
    //               Container(
    //                 child: Column(
    //                   mainAxisAlignment: MainAxisAlignment.start,
    //                   crossAxisAlignment: CrossAxisAlignment.start,
    //                   children: [
    //                     Text((int.parse(tableValue["quantity"].toString()) -  int.parse(tableValue["completeCount"].toString())).toString() + "x ", style: TextStyle(color: HexColor("#0B1043"), fontSize: 25), maxLines: 4,),
    //                   ],
    //                 ),
    //               ),
    //               Container(
    //                 width: 340,
    //                 child: Column(
    //                   mainAxisAlignment: MainAxisAlignment.start,
    //                   crossAxisAlignment: CrossAxisAlignment.start,
    //                   children: [
    //                     Text(tableValue["tableName"].toString(), style: TextStyle(color: HexColor("#0B1043"), fontSize: 25), maxLines: 4,),
    //                   ],
    //                 ),
    //               ),
    //               Spacer(),
    //               Container(
    //                 child: Column(
    //                   mainAxisAlignment: MainAxisAlignment.start,
    //                   crossAxisAlignment: CrossAxisAlignment.start,
    //                   children: [
    //                     Text(tableValue["lastTimerValue"].toString(),
    //                       style: TextStyle(
    //                           color: HexColor("#0B1043"),
    //                           fontSize: MediaQuery.of(context).textScaleFactor * 25,
    //                           fontWeight: FontWeight.bold), maxLines: 4,
    //                     ),
    //
    //                   ],
    //                 ),
    //               ),
    //             ],
    //           ),
    //         ),
    //       ),
    //     );
    //     addToList.add(newItem);
    //   }
    // });
    return addToList;
  }

  showAlertDialog(BuildContext context, StoreOrderFirebase item) async {
    await advancedPlayer.release();
    await advancedPlayer.setReleaseMode(ReleaseMode.LOOP);
    advancedPlayer.play(await audioCache.getAbsoluteUrl('mp3/alarming.mp3'), isLocal: true);
    // set up the button
    Widget okButton = FlatButton(
      color: HexColor("#0C9E1F"),
      textColor: Colors.white,
      padding: EdgeInsets.only(left: 50, top: 10, bottom: 10, right: 50),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0),
          side: BorderSide(color: HexColor("#0C9E1F"))
      ),
      child: Text("OK", style: TextStyle(
          color: Colors.white,
          fontSize: MediaQuery.of(context).textScaleFactor * 25,
          fontWeight: FontWeight.bold),),
      onPressed: () async {
        await advancedPlayer.release();

        setState(() {
          item.status = "pending";
          Map<String, dynamic> childUpdate = new HashMap<String, dynamic>();
          childUpdate.putIfAbsent(item.key, () => item.toJson());
          DatabaseHelper().selectItems(item);
          // if(_currentList.length > 0){
          //   DatabaseHelper().selectItems(item);
          // } else {
          //   String uuid = Uuid().v4();
          //   TableOrder tableOrder = new TableOrder();
          //   tableOrder.key = item.key;
          //   tableOrder.transUuid = uuid;
          //   tableOrder.transactionNo = item.transactionNo;
          //   tableOrder.tableIdRtdb = item.tableId;
          //   tableOrder.tableName = item.tableName;
          //   tableOrder.cashierName = item.cashierName;
          //   tableOrder.customerName = item.customerName;
          //   tableOrder.merchantId = item.merchantId;
          //   tableOrder.storeId = item.storeId;
          //   tableOrder.type = item.type;
          //   tableOrder.from = item.from;
          //   tableOrder.to = item.to;
          //   tableOrder.createdAt = item.createdAt;
          //   tableOrder.status = item.status;
          //   DatabaseHelper().insertItemToTableOrders(tableOrder);
          //
          //   item.listItem.forEach((mapKey, mapValue) async {
          //
          //     //print(mapValue["completeCount"]);
          //     ItemOrder itemOrder = new ItemOrder();
          //     itemOrder.key = item.key;
          //     itemOrder.transUuid = uuid;
          //     itemOrder.transactionNo = item.transactionNo;
          //     itemOrder.tableIdRtdb = item.tableId;
          //     itemOrder.tableName = item.tableName;
          //     itemOrder.customerName = item.customerName;
          //     itemOrder.merchantId = item.merchantId;
          //     itemOrder.storeId = item.storeId;
          //     itemOrder.orderIdRtdb = mapValue["id"].toString();
          //     itemOrder.itemName = mapValue["itemName"].toString().replaceAll("'", "");
          //     itemOrder.variance = mapValue["variance"].toString();
          //     itemOrder.quantity = int.parse(mapValue["quantity"].toString());
          //     itemOrder.completedCount = int.parse(mapValue["completeCount"].toString());
          //     itemOrder.isTakeOUt = int.parse(mapValue["isTakeOut"].toString());
          //     itemOrder.price = double.parse(mapValue["price"].toString());
          //     itemOrder.timestamp = int.parse(mapValue["timeStamp"].toString());
          //     itemOrder.timerLastValue = mapValue["timerLastValue"].toString();
          //     itemOrder.uuid = mapValue["uuid"].toString();
          //     itemOrder.status = mapValue["completed"].toString();
          //     DatabaseHelper().insertItemToItemOrders(itemOrder);
          //
          //     TableItems tableItems = new TableItems();
          //     tableItems.key = item.key;
          //     tableItems.transUuid = uuid;
          //     tableItems.transactionNo = item.transactionNo;
          //     tableItems.tableIdRtdb = item.tableId;
          //     tableItems.tableName = item.tableName;
          //     tableItems.customerName = item.customerName;
          //     tableItems.merchantId = item.merchantId;
          //     tableItems.storeId = item.storeId;
          //     tableItems.orderIdRtdb = mapValue["id"].toString();
          //     tableItems.itemName = mapValue["itemName"].toString().replaceAll("'", "");
          //     tableItems.variance = mapValue["variance"].toString();
          //     tableItems.quantity = int.parse(mapValue["quantity"].toString());
          //     tableItems.completedCount = int.parse(mapValue["completeCount"].toString());
          //     tableItems.isTakeOUt = int.parse(mapValue["isTakeOut"].toString());
          //     tableItems.timestamp = int.parse(mapValue["timeStamp"].toString());
          //     tableItems.timerLastValue = mapValue["timerLastValue"].toString();
          //     tableItems.status = mapValue["completed"].toString();
          //     DatabaseHelper().insertItemToTableItems(tableItems);
          //
          //   });
          // }



          item.listItem.forEach((mapKey, mapValue) async {

            String productKey = mapValue["itemName"].toString() + "_" + mapValue["variance"].toString();
            ftdb.TransactionResult transactionResult = await itemProductUpdateRef.child(productKey).runTransaction((ftdb.MutableData mutableData) async {
              return mutableData;
            });

            if(transactionResult.dataSnapshot.value != null) {
              StoreTableParentOrderFirebase storeProductTableItem = StoreTableParentOrderFirebase.fromSnapshot(transactionResult.dataSnapshot);
              storeProductTableItem.status = "pending";
              Map<String, dynamic> childUpdate = new HashMap<String, dynamic>();
              childUpdate.putIfAbsent(storeProductTableItem.key, () => storeProductTableItem.toJson());
              itemProductUpdateRef.update(childUpdate);
            }

          });

          itemRef.update(childUpdate);

          // _scrollController.jumpTo(
          //     _scrollController.position.maxScrollExtent + 700);
          //scrollToMaxUpdate();
        });
        _refreshData();

        await advancedPlayer.stop();
        Navigator.of(context).pop();

      },
    );

    // set up the button
    Widget cancel = FlatButton(
      color: HexColor("#FF0000"),
      textColor: Colors.white,
      padding: EdgeInsets.only(left: 25, top: 10, bottom: 10, right: 25),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0),
          side: BorderSide(color: HexColor("#FF0000"))
      ),
      child: Text("Cancel", style: TextStyle(
          color: Colors.white,
          fontSize: MediaQuery.of(context).textScaleFactor * 25,
          fontWeight: FontWeight.bold),),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    // show the dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (context, setState)
            {

              return AlertDialog(
                titlePadding: EdgeInsets.zero,
                contentPadding: EdgeInsets.zero,
                title: Container(
                  height: 50,
                  decoration: new BoxDecoration(
                    color: HexColor("#FFAA00"),
                  ),
                  child: Center(
                    child: Text("NEW ORDER!",
                      style: TextStyle(
                          color: HexColor("#0B1043"),
                          fontSize: MediaQuery.of(context).textScaleFactor * 25,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                content: Container(
                  width: MediaQuery.of(context).size.width,
                  child: SingleChildScrollView(
                    child: ListBody(
                      children: <Widget>[
                        Column(
                          //crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(item.tableName,
                              style: TextStyle(
                                  color: HexColor("#0B1043"),
                                  fontSize: MediaQuery.of(context).textScaleFactor * 25,
                                  fontWeight: FontWeight.bold),
                            ),

                            SizedBox(height: 10),

                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: newItemList(item.listItem),
                            ),
                            SizedBox(height: 25),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                              ],
                            ),

                            SizedBox(height: 25),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                okButton
                              ],
                            ),
                          ],
                        ),
                      ]
                    ),
                  ),
                ),
              );
            });
      },
    );
  }

  showConfirmAlertDialog(
      BuildContext context,
      int quantity,
      int count,
      String tableName,
      String tableId,
      String productName,
      String variance,
      OrderJoinTable itemParent,
      int mainIndex,
      String timeStamp
      ) {
    int origValue = quantity - count;
    int firstValue = 1;
    // set up the button
    print("My Orig value => "+origValue.toString());
    print("Init first value => "+firstValue.toString());
    Widget okButton = FlatButton(
      color: HexColor("#0C9E1F"),
      textColor: Colors.white,
      padding: EdgeInsets.only(left: 50, top: 10, bottom: 10, right: 50),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0),
          side: BorderSide(color: HexColor("#0C9E1F"))
      ),
      child: Text("OK", style: TextStyle(
          color: Colors.white,
          fontSize: MediaQuery.of(context).textScaleFactor * 25,
          fontWeight: FontWeight.bold),),
      onPressed: () {
        itemTotalCount = parentItems.length;
        countTotalComplete = 0;
        int itemCurrentTimeStamp = int.parse(timeStamp);
        int listItemCount = itemParent.listTableOrder.length;
        StoreTableOrderFirebase itemUpdateCount = new StoreTableOrderFirebase();
        TableItems tableItems = new TableItems();
        int completeCountTotal = 0;
        int completeCountValue = 0;
        List<bool> completedState  = [];
        setState(()  {
          for(int x = 0; x < itemParent.listTableOrder.length;x++){
              if(itemParent.listTableOrder[x].status == "no"){
                int diffTimeStamp = itemParent.listTableOrder[x].timestamp;
                if(itemCurrentTimeStamp == diffTimeStamp){
                  print("Yes they are equal");
                  completeCountTotal = itemParent.listTableOrder[x].completedCount;
                  completeCountValue = completeCountTotal + firstValue;
                  print(completeCountTotal.toString());
                  print(completeCountValue.toString());
                  if(completeCountValue == quantity) {
                    tableItems.key = itemParent.listTableOrder[x].key;
                    tableItems.transUuid = itemParent.listTableOrder[x].transUuid;
                    tableItems.transactionNo = itemParent.listTableOrder[x].transactionNo;
                    tableItems.tableIdRtdb = itemParent.listTableOrder[x].tableIdRtdb;
                    tableItems.tableName = itemParent.listTableOrder[x].tableName;
                    tableItems.customerName = itemParent.listTableOrder[x].customerName;
                    tableItems.orderIdRtdb = itemParent.listTableOrder[x].orderIdRtdb;
                    tableItems.merchantId = itemParent.listTableOrder[x].merchantId;
                    tableItems.storeId = itemParent.listTableOrder[x].storeId;
                    tableItems.itemName = itemParent.listTableOrder[x].itemName.replaceAll("'", "");
                    tableItems.variance = itemParent.listTableOrder[x].variance;
                    tableItems.quantity = itemParent.listTableOrder[x].quantity;
                    tableItems.completedCount = quantity;
                    tableItems.isTakeOUt = itemParent.listTableOrder[x].isTakeOUt;
                    tableItems.timestamp = itemParent.listTableOrder[x].timestamp;
                    tableItems.timerLastValue = itemParent.listTableOrder[x].timerLastValue;
                    tableItems.status = "yes";

                    itemParent.listTableOrder[x] = tableItems;
                    completedState.add(true);
                    playCompleteOnSound();
                    printTicketOrder(itemParent, firstValue, tableItems);


                    ProductReports productReports = new ProductReports();
                    productReports.product = tableItems.itemName;
                    productReports.quantity = firstValue;
                    productReports.time = int.parse(tableItems.timerLastValue);

                    DatabaseHelper().insertItemToProductReports(productReports);

                    DatabaseHelper().updateItemOrderComplete(tableItems.completedCount, tableItems.orderIdRtdb);

                  } else {
                    tableItems.key = itemParent.listTableOrder[x].key;
                    tableItems.transUuid = itemParent.listTableOrder[x].transUuid;
                    tableItems.transactionNo = itemParent.listTableOrder[x].transactionNo;
                    tableItems.tableIdRtdb = itemParent.listTableOrder[x].tableIdRtdb;
                    tableItems.orderIdRtdb = itemParent.listTableOrder[x].orderIdRtdb;
                    tableItems.tableName = itemParent.listTableOrder[x].tableName;
                    tableItems.customerName = itemParent.listTableOrder[x].customerName;
                    tableItems.merchantId = itemParent.listTableOrder[x].merchantId;
                    tableItems.storeId = itemParent.listTableOrder[x].storeId;
                    tableItems.itemName = itemParent.listTableOrder[x].itemName.replaceAll("'", "");
                    tableItems.variance = itemParent.listTableOrder[x].variance;
                    tableItems.quantity = itemParent.listTableOrder[x].quantity;
                    tableItems.completedCount = completeCountValue;
                    tableItems.isTakeOUt = itemParent.listTableOrder[x].isTakeOUt;
                    tableItems.timestamp = itemParent.listTableOrder[x].timestamp;
                    tableItems.timerLastValue = itemParent.listTableOrder[x].timerLastValue;
                    tableItems.status = itemParent.listTableOrder[x].status;

                    playCompleteOnSound();
                    printTicketOrder(itemParent, firstValue, tableItems);
                    itemParent.listTableOrder[x] = tableItems;

                    ProductReports productReports = new ProductReports();
                    productReports.product = tableItems.itemName;
                    productReports.quantity = firstValue;
                    productReports.time = int.parse(tableItems.timerLastValue);
                    DatabaseHelper().insertItemToProductReports(productReports);

                    DatabaseHelper().updateItemOrder(tableItems.completedCount,tableItems.orderIdRtdb);

                  }
                }
              } else if(itemParent.listTableOrder[x].status == "yes") {
                completedState.add(true);
              }
          }

          if(completedState.length == listItemCount){
            _currentList[mainIndex] = itemParent;
            //updateProduct(itemParent.key, itemUpdateCount.key, itemUpdateCount);
            //updateParentProduct(itemParent, itemParent.key);

          } else {
            // Do nothing
          }
          _refreshData();
        });


        Navigator.of(context).pop();

      },
    );

    // set up the button
    Widget cancel = FlatButton(
      color: HexColor("#FF0000"),
      textColor: Colors.white,
      padding: EdgeInsets.only(left: 25, top: 10, bottom: 10, right: 25),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0),
          side: BorderSide(color: HexColor("#FF0000"))
      ),
      child: Text("Cancel", style: TextStyle(
          color: Colors.white,
          fontSize: MediaQuery.of(context).textScaleFactor * 25,
          fontWeight: FontWeight.bold),),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    // show the dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (context, setState)
            {
              //int newQty = quantity;
              return AlertDialog(
                insetPadding: EdgeInsets.zero,
                titlePadding: EdgeInsets.zero,
                contentPadding: EdgeInsets.zero,
                title: Container(
                  height: 50,
                  decoration: new BoxDecoration(
                    color: HexColor("#FFAA00"),
                  ),
                  child: Center(
                    child: Text("ORDER COMPLETE?",
                      style: TextStyle(
                          color: HexColor("#0B1043"),
                          fontSize: MediaQuery.of(context).textScaleFactor * 25,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                content: SingleChildScrollView(
                  child: Container(
                    height: 250,
                    width: 500,
                    child: Column(
                      //crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(tableName,
                          style: TextStyle(
                              color: HexColor("#0B1043"),
                              fontSize: MediaQuery.of(context).textScaleFactor * 25,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(productName,
                          style: TextStyle(
                              color: HexColor("#0B1043"),
                              fontSize: MediaQuery.of(context).textScaleFactor * 25,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 25),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            InkWell(
                              onTap: () {
                                setState(() {
                                  if(firstValue > 1 && firstValue <= origValue){
                                    firstValue--;
                                    print("decre first value => "+firstValue.toString());
                                  }
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(Radius.circular(5)),
                                  color: HexColor('#E1E1E1'),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 10.0, bottom: 10.0, left: 5.0, right: 5.0),
                                  child: Icon(Icons.remove, color: firstValue > 1 && firstValue <= origValue ? HexColor("#0B1043") : Colors.grey, size: 30,),
                                ),
                              ),
                            ),
                            SizedBox(width: 5),
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Text(firstValue.toString(), style: TextStyle(color: HexColor("#0B1043"), fontSize: MediaQuery.of(context).textScaleFactor * 25, fontWeight: FontWeight.bold,),),
                            ),
                            SizedBox(width: 5),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  if(firstValue < origValue){
                                    firstValue++;
                                    print("incre first value => "+firstValue.toString());
                                  }

                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(Radius.circular(5)),
                                  color: HexColor('#E1E1E1'),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 10.0, bottom: 10.0, left: 5.0, right: 5.0),
                                  child: Icon(Icons.add, color: firstValue < origValue ? HexColor("#0B1043") : Colors.grey, size: 30,),
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 25),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            cancel, SizedBox(width: 30), okButton
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            });
      },
    );
  }

  List<Widget> newItemList(Map<dynamic, dynamic> json){
    List<Widget> addWidgets = [];

    json.forEach((key, value) {

      if(value["completed"].toString() != "yes"){
        Widget newItem = Row(
          children: [
            SizedBox(width: 20),
            Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value["quantity"].toString() + "x ", style: TextStyle(color: HexColor("#0B1043"), fontSize: 18, fontWeight: FontWeight.bold), maxLines: 4,),

                ],
              ),
            ),
            Container(
              width: 370,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value["itemName"].toString(), style: TextStyle(color: HexColor("#0B1043"), fontSize: 18, fontWeight: FontWeight.bold), maxLines: 4,),
                ],
              ),
            ),
          ],
        );
        addWidgets.add(newItem);
      }


    });



    return addWidgets;
  }

  showPrinterDCAlertDialog(BuildContext context){
    // set up the button
    Widget okButton = FlatButton(
      color: HexColor("#0C9E1F"),
      textColor: Colors.white,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0),
          side: BorderSide(color: HexColor("#0C9E1F"))
      ),
      child: Text("Yes"),
      onPressed: () async {

        //print(itemData.toJson());
        //print(itemData.poItems.values);
        //DatabaseHelper().insertItemToPO(itemData);
        Navigator.of(context).pop();
      },
    );

    // set up the button
    Widget cancel = FlatButton(
      color: HexColor("#FF0000"),
      textColor: Colors.white,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0),
          side: BorderSide(color: HexColor("#FF0000"))
      ),
      child: Text("No"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    // show the dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                contentPadding: EdgeInsets.zero,
                //title: Center(child: Text("Confirm Received?")),
                content: SingleChildScrollView(
                  child: Container(
                    height: 220,
                    width: 400,
                    child: Column(
                      //crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Center(child: Text("REMINDER:", style: TextStyle(color: HexColor("#0B1043"),
                            fontSize: MediaQuery.of(context).textScaleFactor * 25, fontWeight: FontWeight.bold))),
                        SizedBox(height: 20),
                        Center(child: Text("There is no available printer.", style: TextStyle(color: HexColor("#FF0000"),
                            fontSize: MediaQuery.of(context).textScaleFactor * 18, fontWeight: FontWeight.normal))),
                        Center(child: Text("Do you still want to complete the order?", style: TextStyle(color: HexColor("#FF0000"),
                            fontSize: MediaQuery.of(context).textScaleFactor * 18, fontWeight: FontWeight.normal))),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            cancel, SizedBox(width: 30), okButton
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                // actions: [
                //   Center(child: cancel ,),
                //   okButton,
                // ],
              );
            }
        );

      },
    );
  }
}


