import 'dart:collection';

import 'package:firebase_database/firebase_database.dart';
import 'package:meta/meta.dart';

class StoreFirebase {
  String merchantId;
  String storeId;
  String cashierName;
  String type;
  String createdAt;
  Map<dynamic, dynamic> routes = new HashMap<dynamic, dynamic>();

  StoreFirebase({
    @required this.merchantId,
    @required this.storeId,
    @required this.cashierName,
    @required this.type,
    @required this.createdAt,
    @required this.routes
  });

  StoreFirebase.fromSnapshot(DataSnapshot snapshot)
      : merchantId = snapshot.value["merchantId"],
        storeId = snapshot.value["storeId"],
        cashierName = snapshot.value["cashierName"],
        type = snapshot.value["type"],
        createdAt = snapshot.value["createdAt"],
        routes = snapshot.value["routes"];


  Map<String, dynamic> toJson() {
    return {
      "merchantId": merchantId,
      "storeId": storeId,
      "cashierName": cashierName,
      "type": type,
      "createdAt": createdAt,
      "routes": routes
    };
  }
}

class StoreOrderFirebase {
  String key;
  String tableId;
  String merchantId;
  String storeId;
  String cashierName;
  String tableName;
  String type;
  int createdAt;
  String from;
  String to;
  String storeOrderItemList;
  String status;
  String transactionNo;
  String customerName;
  Map<dynamic, dynamic> ordersCopy = new HashMap<dynamic, dynamic>();
  Map<dynamic, dynamic> listItem = new HashMap<dynamic, dynamic>();

  StoreOrderFirebase({
    this.key,
    this.tableId,
    this.merchantId,
    this.tableName,
    this.storeId,
    this.cashierName,
    this.transactionNo,
    this.customerName,
    this.type,
    this.from,
    this.to,
    this.status,
    this.createdAt,
    this.storeOrderItemList,
    this.ordersCopy,
    this.listItem
  });

  StoreOrderFirebase.fromSnapshot(DataSnapshot snapshot)
      : key = snapshot.key,
        merchantId = snapshot.value["merchantId"],
        storeId = snapshot.value["storeId"],
        tableId = snapshot.value["tableId"].toString(),
        cashierName = snapshot.value["cashierName"],
        tableName = snapshot.value["tableName"],
        transactionNo = snapshot.value["transactionNo"],
        customerName = snapshot.value["customerName"],
        type = snapshot.value["type"],
        from = snapshot.value["from"],
        to = snapshot.value["to"],
        status =  snapshot.value["status"],
        createdAt = snapshot.value["createdAt"] != null ? int.parse(snapshot.value["createdAt"].toString()) : 0,
        storeOrderItemList = snapshot.value["storeOrderItemList"],
        ordersCopy = snapshot.value["orders"],
        listItem = snapshot.value["listItem"];


  Map<String, dynamic> toJson() {
    return {
      "merchantId": merchantId,
      "storeId": storeId,
      "tableId": tableId,
      "cashierName": cashierName,
      "transactionNo": transactionNo,
      "customerName": customerName,
      "tableName": tableName,
      "type": type,
      "from": from,
      "to": to,
      "status": status,
      "createdAt": createdAt,
      "storeOrderItemList": storeOrderItemList,
      "orders": ordersCopy,
      "listItem": listItem
    };
  }
}

class StoreOrderItemsFirebase {
  String key;
  int id;
  String uuid;
  int quantity;
  String variance;
  String itemName;
  double price;
  int isTakeOut;
  String completed;
  String timerLastValue;
  int timeStamp;
  int completeCount;


  StoreOrderItemsFirebase({
    this.key,
    this.id,
    this.uuid,
    this.quantity,
    this.variance,
    this.itemName,
    this.price,
    this.isTakeOut,
    this.completed,
    this.timerLastValue,
    this.timeStamp,
    this.completeCount
  });

  StoreOrderItemsFirebase.fromSnapshot(DataSnapshot snapshot)
      : key = snapshot.key,
        id = snapshot.value["id"]  != null ? int.parse(snapshot.value["id"].toString()) : 0,
        uuid = snapshot.value["uuid"],
        quantity = snapshot.value["quantity"] != null ? int.parse(snapshot.value["quantity"].toString()) : 0,
        variance = snapshot.value["variance"],
        itemName = snapshot.value["itemName"],
        price = snapshot.value["price"],
        completed = snapshot.value["completed"],
        timerLastValue = snapshot.value["timerLastValue"],
        isTakeOut = snapshot.value["isTakeOut"]  != null ? int.parse(snapshot.value["isTakeOut"].toString()) : 0,
        timeStamp = int.parse(snapshot.value["timeStamp"].toString()),
        completeCount = int.parse(snapshot.value["completeCount"].toString());


  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "uuid": uuid,
      "quantity": quantity,
      "variance": variance,
      "itemName": itemName,
      "price": price,
      "completed": completed,
      "timerLastValue": timerLastValue,
      "isTakeOut": isTakeOut,
      "timeStamp": timeStamp,
      "completeCount": completeCount
    };
  }
}

class StoreTableParentOrderFirebase {
  String key;
  String id;
  String uid;
  String completed;
  String status;
  Map<dynamic, dynamic> tableItems = new HashMap<dynamic, dynamic>();


  StoreTableParentOrderFirebase({
    this.key,
    this.id,
    this.uid,
    this.completed,
    this.status,
    this.tableItems
  });

  StoreTableParentOrderFirebase.fromSnapshot(DataSnapshot snapshot)
      : key = snapshot.key,
        id = snapshot.value["id"].toString(),
        uid = snapshot.value["uid"],
        completed = snapshot.value["completed"].toString(),
        status = snapshot.value["status"].toString(),
        tableItems = snapshot.value["tableItems"];


  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "uid": uid,
      "completed": completed,
      "status": status,
      "tableItems": tableItems
    };
  }
}

class StoreTableOrderFirebase {
  String key;
  String id;
  int quantity;
  int completeCount;
  String tableName;
  String isTakeOut;
  String completed;
  String status;
  String transactionNo;
  String customerName;
  String lastTimerValue;
  int timestamp;


  StoreTableOrderFirebase({
    this.key,
    this.id,
    this.tableName,
    this.isTakeOut,
    this.lastTimerValue,
    this.status,
    this.transactionNo,
    this.customerName,
    this.completeCount,
    this.quantity,
    this.timestamp,
    this.completed
  });

  StoreTableOrderFirebase.fromSnapshot(DataSnapshot snapshot)
      : key = snapshot.key,
        id = snapshot.value["id"].toString(),
        quantity = snapshot.value["quantity"] != null ? int.parse(snapshot.value["quantity"].toString()) : 0,
        tableName = snapshot.value["tableName"].toString(),
        isTakeOut = snapshot.value["isTakeOut"].toString(),
        lastTimerValue = snapshot.value["lastTimerValue"].toString(),
        completed = snapshot.value["completed"].toString(),
        status = snapshot.value["status"].toString(),
        transactionNo = snapshot.value["transactionNo"].toString(),
        customerName = snapshot.value["customerName"].toString(),
        timestamp = snapshot.value["timestamp"] != null ? int.parse(snapshot.value["timestamp"].toString()) : 0,
        completeCount = int.parse(snapshot.value["completeCount"].toString());


  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "quantity": quantity,
      "tableName": tableName,
      "isTakeOut": isTakeOut,
      "lastTimerValue": lastTimerValue,
      "completed": completed,
      "status": status,
      "transactionNo": transactionNo,
      "customerName": customerName,
      "timestamp": timestamp,
      "completeCount": completeCount
    };
  }
}