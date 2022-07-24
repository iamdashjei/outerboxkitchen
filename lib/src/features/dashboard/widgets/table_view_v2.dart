import 'dart:async';
import 'dart:collection';

import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pusher/pusher.dart';
import 'package:outerboxkitchen/src/database/database_helper.dart';
import 'package:outerboxkitchen/src/features/login/screens/login_pincode.dart';
import 'package:outerboxkitchen/src/models/orders_by_table.dart';
import 'package:outerboxkitchen/src/models/product_reports.dart';
import 'package:outerboxkitchen/src/models/store_firebase.dart';
import 'package:outerboxkitchen/src/models/table_join_order.dart';
import 'package:outerboxkitchen/src/models/table_with_orders_model.dart';
import 'package:outerboxkitchen/src/utils/hex_color.dart';
import 'package:outerboxkitchen/src/utils/user_sessions.dart';
import 'package:firebase_database/firebase_database.dart' as ftdb;
import 'package:loading_indicator/loading_indicator.dart';
import 'package:uuid/uuid.dart';

import 'printer.dart';


class TableViewV2 extends StatefulWidget {

  const TableViewV2(
      {Key key})
      : super(key: key);

  @override
  _TableViewV2State createState() =>
      _TableViewV2State();
}

class _TableViewV2State extends State<TableViewV2> with WidgetsBindingObserver{

  var quantityController = TextEditingController(text: "1");
  int itemComplete = 1;
  String merchantId = "";
  Event lastEvent;

  AudioCache audioCache = AudioCache();
  AudioPlayer advancedPlayer = AudioPlayer(), advancedPlayerForFinishItem = AudioPlayer();

  ftdb.DatabaseReference itemRef, itemProductUpdateRef;
  ftdb.Query _todoQuery;
  StreamSubscription<ftdb.Event> _onMerchantAddedSubscription;
  StreamSubscription<ftdb.Event> _onMerchantChangedSubscription;

  Future<List<TableJoinOrder>> _futureCurrentList;

  List<TableJoinOrder> _currentList = [];
  List<StoreOrderFirebase> storeItems = [];
  List<int> listTimer = [];
  List<int> quantityList = [];
  List<String> completedOrders = [];
  List<String> addedTableItems = [];

  Timer _timer;
  Map<String, dynamic> itemOrder = new HashMap<String, dynamic>();

  ScrollController _scrollController = new ScrollController();

  bool isCompletedTask;
  bool display = false;

  int totalIndexes = 0;

  int itemTotalCount = 0;
  int countTotalComplete = 0;

  int currentIndex = 0, currentQuantity = 0;


  @override
  void initState() {
    UserSessions.getPrinterConnected();
    getTableOrders();
    UserSessions.getMerchantId().then((value) {
      //print("Merchant IDS => " + value);
      itemProductUpdateRef = ftdb.FirebaseDatabase.instance.reference().child("Orders").child(value).child("by_product");
      itemRef = ftdb.FirebaseDatabase.instance.reference().child("Orders").child(value).child("by_table");
      _todoQuery = ftdb.FirebaseDatabase.instance.reference().child("Orders").child(value).child("by_table");
      _onMerchantAddedSubscription = _todoQuery.onChildAdded.listen(onEntryUserAdded);
      _onMerchantChangedSubscription = _todoQuery.onChildChanged.listen(onEntryUserChanged);

      _timer = Timer.periodic(Duration(seconds: 1), (_) {
        setState(() {
          for(int start = 0; start < _currentList.length; start++){
            if(_currentList[start].items != null){
              for(int item = 0; item < _currentList[start].items.length; item++){
                ItemOrder itemOrder =  _currentList[start].items[item];
                itemOrder.timerLastValue = (int.parse(_currentList[start].items[item].timerLastValue) + 1).toString();
                _currentList[start].items[item] = itemOrder;
              }
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

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        print("app in resumed");
        //showExampleDialog();
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

  void scrollToMaxUpdate(){
    Future.delayed(Duration(seconds: 3), () {
      // 5s over, navigate to a new page
      _scrollController.jumpTo(
          _scrollController.position.maxScrollExtent + 600);
    });
  }

  void playCompleteOnSound() async {
    await advancedPlayerForFinishItem.release();
    await advancedPlayerForFinishItem.setReleaseMode(ReleaseMode.RELEASE);
    advancedPlayerForFinishItem.play(await audioCache.getAbsoluteUrl('mp3/ding.mp3'), isLocal: true);
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

  int tableItemCount(List<ItemOrder> json){
    int counter = 0;

    for(int x = 0; x < json.length; x++){
      if(json[x].status == "no"){
        int quantity = json[x].quantity - json[x].completedCount;
        counter += quantity;
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

  void updateProduct(StoreOrderFirebase storeOrderParent, StoreOrderItemsFirebase storeOrderItem) async {
    // update the by_table and then update the by_product
    print("GOING TO CHILD TABLE");
    Map<String, dynamic> childTableUpdate = new HashMap<String, dynamic>();
    childTableUpdate.putIfAbsent(storeOrderParent.key, () => storeOrderParent.toJson());
    itemRef.update(childTableUpdate);

    String productKey = storeOrderItem.itemName + "_" + storeOrderItem.variance;
    ftdb.TransactionResult transactionResult = await itemProductUpdateRef.child(productKey).runTransaction((ftdb.MutableData mutableData) async {
      return mutableData;
    });

    if(transactionResult.dataSnapshot.value != null){
      StoreTableParentOrderFirebase storeProductTableItem = StoreTableParentOrderFirebase.fromSnapshot(transactionResult.dataSnapshot);

      if(storeProductTableItem.tableItems != null){
        int listItemCount = storeProductTableItem.tableItems.length;
        List<bool> completedState  = [];
        String tableKeyRDB = storeOrderParent.tableName + "_" + storeOrderParent.tableId;

        if(storeProductTableItem.tableItems[tableKeyRDB] != null){
          if(storeProductTableItem.tableItems[tableKeyRDB]["completed"].toString() == "no"){
            int quantity = storeProductTableItem.tableItems[tableKeyRDB]["quantity"];
            //int completeCount = storeProductTableItem.tableItems[tableKeyRDB]["completeCount"];
            int completeCount = storeOrderItem.completeCount;
            print("BEFORE COMPLETE COUNT => " + completeCount.toString());
            if(quantity == completeCount){
              print("COMPARE QUANTITY COUNT EQUAL => " + quantity.toString());
              print("EQUAL COMPLETE COUNT => " + completeCount.toString());
              storeProductTableItem.tableItems[tableKeyRDB]["completed"] = "yes";
              storeProductTableItem.tableItems[tableKeyRDB]["status"] = "completed";
              storeProductTableItem.tableItems[tableKeyRDB]["completeCount"] = quantity;
              completedState.add(true);
            } else {
              completeCount = storeOrderItem.completeCount;
              print("COMPARE QUANTITY COUNT => " + quantity.toString());
              print("ADDED COMPLETE COUNT => " + completeCount.toString());
              if(quantity == completeCount){
                storeProductTableItem.tableItems[tableKeyRDB]["completed"] = "yes";
                storeProductTableItem.tableItems[tableKeyRDB]["status"] = "completed";
                storeProductTableItem.tableItems[tableKeyRDB]["completeCount"] = quantity;
                completedState.add(true);
              } else {
                storeProductTableItem.tableItems[tableKeyRDB]["completeCount"] = completeCount;
              }
            }

          } else if(storeProductTableItem.tableItems[tableKeyRDB]["completed"].toString() == "yes"){
            completedState.add(true);
          }

          if(completedState.length == listItemCount){
            storeProductTableItem.completed = "yes";
            storeProductTableItem.status = "complete";
            storeProductTableItem.tableItems = null;
          }

          Map<String, dynamic> childUpdate = new HashMap<String, dynamic>();
          childUpdate.putIfAbsent(storeProductTableItem.key, () => storeProductTableItem.toJson());
          itemProductUpdateRef.update(childUpdate);
        }
        // storeProductTableItem.tableItems.forEach((itemKey, itemValue) {
        //       if(storeOrderParent.tableName == itemValue["tableName"].toString() && storeOrderParent.tableId == itemValue["id"].toString()){
        //           print("EQUAL");
        //           //print("Complete Count final value => " + storeOrderItem.completeCount.toString());
        //           if(itemValue["completed"].toString() == "no"){
        //             int quantity = itemValue["quantity"];
        //             int completeCount = itemValue["completeCount"];
        //
        //             if(quantity == completeCount){
        //               storeProductTableItem.tableItems[itemKey]["completed"] = "yes";
        //               storeProductTableItem.tableItems[itemKey]["status"] = "completed";
        //               storeProductTableItem.tableItems[itemKey]["completeCount"] = quantity;
        //               completedState.add(true);
        //             } else {
        //               completeCount+= storeOrderItem.completeCount;
        //               if(quantity == completeCount){
        //                 storeProductTableItem.tableItems[itemKey]["completed"] = "yes";
        //                 storeProductTableItem.tableItems[itemKey]["status"] = "completed";
        //                 storeProductTableItem.tableItems[itemKey]["completeCount"] = quantity;
        //                 completedState.add(true);
        //               } else {
        //                 storeProductTableItem.tableItems[itemKey]["completeCount"] = completeCount;
        //               }
        //             }
        //
        //           } else if(itemValue["completed"].toString() == "yes"){
        //             completedState.add(true);
        //           }
        //
        //       }
        //
        // });




      }
    }
  }

  void updateParentTable(StoreOrderFirebase storeOrderParent, int countTotal, StoreOrderItemsFirebase storeOrderChild) async {
    // update by_table to complete and then update by_product by parentTable list items
    print("GOING TO PARENT TABLE");
    ftdb.TransactionResult transactionResult = await itemRef.child(storeOrderParent.key).runTransaction((ftdb.MutableData mutableData) async {
      return mutableData;
    });

    StoreOrderFirebase updateResult = StoreOrderFirebase.fromSnapshot(transactionResult.dataSnapshot);
    updateResult.status = "complete";
    Map<String, dynamic> childTableUpdate = new HashMap<String, dynamic>();
    childTableUpdate.putIfAbsent(updateResult.key, () => updateResult.toJson());
    itemRef.update(childTableUpdate);
  }

  getTableOrders() async {
    setState(() {
      _futureCurrentList = DatabaseHelper().getJoinTableOrdersToItemOrder();
    });

  }

  Future _refreshData() async {

    setState(() {
      Future.delayed(Duration(seconds: 1), () {
        // 5s over, navigate to a new page
        _futureCurrentList = DatabaseHelper().getJoinTableOrdersToItemOrder();
      });
    });

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
                      child: FutureBuilder<List<TableJoinOrder>>(
                        future: _futureCurrentList,
                        builder: (context, snapshot){
                          if(snapshot.connectionState == ConnectionState.done){
                            if(snapshot.hasData){
                              _currentList = snapshot.data;
                              if(_currentList.length > 0){
                                return ListView.builder(
                                    controller: _scrollController,
                                    //   reverse: true,
                                    // shrinkWrap:  true,
                                    itemCount: _currentList.length,
                                    itemBuilder: (context, index){
                                      return Column(
                                          children: <Widget>[
                                            Container(
                                              //  padding: EdgeInsets.all(10),
                                              height: 65,
                                              decoration: new BoxDecoration(
                                                color: HexColor("#C5C5C5"),
                                              ),
                                              child: Row(
                                                children: [
                                                  SizedBox(width: 15),
                                                  Text(_currentList[index].tableName,
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
                                                      child: Text(tableItemCount(_currentList[index].items).toString(),
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
                                              children: productList(_currentList[index].items, _currentList[index].tableName, _currentList[index].tableId, _currentList[index], index),
                                            ),
                                            SizedBox(height: 15),
                                          ]
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
                  ),
                ]
              ),

            ]),
          ),
        ],
      ),
    );
  }

  showExampleDialog() async {
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
        addedTableItems = [];

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
                        children: [
                          Column(
                            //crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text("MY TABLE ITEM",
                                style: TextStyle(
                                    color: HexColor("#0B1043"),
                                    fontSize: MediaQuery.of(context).textScaleFactor * 25,
                                    fontWeight: FontWeight.bold),
                              ),

                              SizedBox(height: 10),

                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: sampleItemList(),
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
                              SizedBox(height: 15),
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

  List<Widget> sampleItemList(){
    List<Widget> sampleAddWidget = [];

    for(int x = 0; x < 50; x++){
      Widget rowWidget = Row(
        children: [
          SizedBox(width: 20),
          Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(x.toString() + " x", style: TextStyle(color: HexColor("#0B1043"), fontSize: 18, fontWeight: FontWeight.bold), maxLines: 4,),

              ],
            ),
          ),
          Container(
            width: 370,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Sample Test Data", style: TextStyle(color: HexColor("#0B1043"), fontSize: 18, fontWeight: FontWeight.bold), maxLines: 4,),
              ],
            ),
          ),
        ],
      );

      sampleAddWidget.add(rowWidget);
    }

    return sampleAddWidget;
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
        addedTableItems = [];
        setState(() {
          item.status = "pending";
          Map<String, dynamic> childUpdate = new HashMap<String, dynamic>();
          childUpdate.putIfAbsent(item.key, () => item.toJson());
          DatabaseHelper().selectItems(item);

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

  showConfirmAlertDialog(BuildContext context, int quantity, int count, String tableName, String tableId, String productName, TableJoinOrder itemParent, int mainIndex, String timeStamp) {
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
          onPressed: ()  {
                itemTotalCount = storeItems.length;
                countTotalComplete = 0;

                int itemCurrentTimeStamp = int.parse(timeStamp);
                int listItemCount = itemParent.items.length;
                int completeCountTotal = 0;
                int completeCountValue = 0;
                ItemOrder itemOrder = new ItemOrder();
                List<bool> completedState  = [];
                setState(()  {
                  for(int x = 0; x < itemParent.items.length; x++)  {
                    if(itemParent.items[x].status == "no"){
                      int diffTimeStamp = itemParent.items[x].timestamp;
                      if(itemCurrentTimeStamp == diffTimeStamp){
                        print("Yes they are equal");
                        completeCountTotal = itemParent.items[x].completedCount;
                        completeCountValue = completeCountTotal + firstValue;
                        print(completeCountTotal.toString());
                        print(completeCountValue.toString());
                        if(completeCountValue == quantity) {
                          itemOrder.key = itemParent.items[x].key;
                          itemOrder.transUuid = itemParent.items[x].transUuid;
                          itemOrder.transactionNo = itemParent.items[x].transactionNo;
                          itemOrder.tableIdRtdb = itemParent.items[x].tableIdRtdb;
                          itemOrder.tableName = itemParent.items[x].tableName;
                          itemOrder.customerName = itemParent.items[x].customerName;
                          itemOrder.orderIdRtdb = itemParent.items[x].orderIdRtdb;
                          itemOrder.merchantId = itemParent.items[x].merchantId;
                          itemOrder.storeId = itemParent.items[x].storeId;
                          itemOrder.itemName = itemParent.items[x].itemName;
                          itemOrder.variance = itemParent.items[x].variance;
                          itemOrder.quantity = itemParent.items[x].quantity;
                          itemOrder.completedCount = quantity;
                          itemOrder.isTakeOUt = itemParent.items[x].isTakeOUt;
                          itemOrder.price = itemParent.items[x].price;
                          itemOrder.timestamp = itemParent.items[x].timestamp;
                          itemOrder.timerLastValue = itemParent.items[x].timerLastValue;
                          itemOrder.uuid = itemParent.items[x].uuid;
                          itemOrder.status = "yes";

                          itemParent.items[x] = itemOrder;
                          completedState.add(true);
                          playCompleteOnSound();
                          printTicketOrder(itemParent, firstValue, itemOrder);


                          ProductReports productReports = new ProductReports();
                          productReports.product = itemOrder.itemName;
                          productReports.quantity = firstValue;
                          productReports.time = int.parse(itemOrder.timerLastValue);

                          DatabaseHelper().insertItemToProductReports(productReports);

                          DatabaseHelper().updateItemOrderComplete(itemOrder.completedCount, itemOrder.orderIdRtdb);

                        } else {
                          itemOrder.key = itemParent.items[x].key;
                          itemOrder.transUuid = itemParent.items[x].transUuid;
                          itemOrder.transactionNo = itemParent.items[x].transactionNo;
                          itemOrder.tableIdRtdb = itemParent.items[x].tableIdRtdb;
                          itemOrder.orderIdRtdb = itemParent.items[x].orderIdRtdb;
                          itemOrder.tableName = itemParent.items[x].tableName;
                          itemOrder.customerName = itemParent.items[x].customerName;
                          itemOrder.merchantId = itemParent.items[x].merchantId;
                          itemOrder.storeId = itemParent.items[x].storeId;
                          itemOrder.itemName = itemParent.items[x].itemName;
                          itemOrder.variance = itemParent.items[x].variance;
                          itemOrder.quantity = itemParent.items[x].quantity;
                          itemOrder.completedCount = completeCountValue;
                          itemOrder.isTakeOUt = itemParent.items[x].isTakeOUt;
                          itemOrder.price = itemParent.items[x].price;
                          itemOrder.timestamp = itemParent.items[x].timestamp;
                          itemOrder.timerLastValue = itemParent.items[x].timerLastValue;
                          itemOrder.uuid = itemParent.items[x].uuid;
                          itemOrder.status = itemParent.items[x].status;

                          playCompleteOnSound();
                          printTicketOrder(itemParent, firstValue, itemOrder);
                          itemParent.items[x] = itemOrder;

                          ProductReports productReports = new ProductReports();
                          productReports.product = itemOrder.itemName;
                          productReports.quantity = firstValue;
                          productReports.time = int.parse(itemOrder.timerLastValue);
                          DatabaseHelper().insertItemToProductReports(productReports);

                          DatabaseHelper().updateItemOrder(itemOrder.completedCount, itemOrder.orderIdRtdb);

                        }
                      }
                    } else if(itemParent.items[x].status == "yes") {
                      completedState.add(true);
                    }
                  }

                  if(completedState.length == listItemCount){
                    //itemParent. = "complete";
                    //storeItems[mainIndex] = itemParent;
                    _currentList[mainIndex] = itemParent;

                  }

                });

        Navigator.of(context).pop();
        _refreshData();
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

  List<Widget> productList(List<ItemOrder> json, String tableName, String tableId, TableJoinOrder itemParent, int mainIndex){
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
              showConfirmAlertDialog(context, json[x].quantity, json[x].completedCount, tableName, itemParent.tableId, json[x].itemName, itemParent, mainIndex, json[x].timestamp.toString());
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
                        Text(
                          " ",
                          style: TextStyle( color: HexColor("#0B1043"),
                              fontSize: MediaQuery.of(context).textScaleFactor * 12),
                        ),

                      ],
                    ),
                  ),
                  Container(
                    width: 340,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(json[x].itemName, style: TextStyle(color: HexColor("#0B1043"), fontSize: 25), maxLines: 4,),
                        Text(
                          json[x].variance,
                          style: TextStyle( color: HexColor("#0B1043"),
                              fontSize: MediaQuery.of(context).textScaleFactor * 18),
                        ),

                      ],
                    ),
                  ),
                  Spacer(),
                  Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(json[x].timerLastValue,
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

    return addToList;
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

  printTicketOrder(TableJoinOrder itemParent, int firstValue, ItemOrder itemOrder) async {
    bool connectedPrinter = await Printer().connectPrinterAutomatic();
    if(connectedPrinter){
      bool statusPrint = await Printer().printTicket(
          itemParent.tableName,
          firstValue.toString(),
          itemOrder.itemName,
          itemOrder.variance,
          itemOrder.customerName,
          itemOrder.transactionNo
      );
      print("Printing");
    } else {
      print("Disconnected");
      showPrinterDCAlertDialog(context);
    }
    // bool statusPrint = await Printer().printTicket(
    //     itemParent.tableName,
    //     firstValue.toString(),
    //     itemOrder.itemName,
    //     itemOrder.variance,
    //     itemOrder.customerName,
    //     itemOrder.transactionNo
    // );
    // if(statusPrint){
    //   print("Printing");
    // } else {
    //   print("Disconnected");
    //   showPrinterDCAlertDialog(context);
    // }
  }

}
