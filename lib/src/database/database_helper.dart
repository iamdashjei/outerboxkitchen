import 'dart:io';

import 'package:flutter/material.dart';
import 'package:outerboxkitchen/src/models/headoffice_details.dart';
import 'package:outerboxkitchen/src/models/orders_by_table.dart';
import 'package:outerboxkitchen/src/models/product_reports.dart';
import 'package:outerboxkitchen/src/models/store_details.dart';
import 'package:outerboxkitchen/src/models/store_firebase.dart';
import 'package:outerboxkitchen/src/models/table_join_order.dart';
import 'package:outerboxkitchen/src/models/table_with_orders_model.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

class DatabaseHelper {
  static Database _db;

  Future<Database> get db async {
    if (_db != null) {
      return _db;
    }
    _db = await initDatabase();
    return _db;
  }

  initDatabase() async {
    Directory documentDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentDirectory.path, 'kitchen.db');
    try {
      await Directory(dirname(path)).create(recursive: true);
    } catch (e) {
      print(e);
    }
    var db = await openDatabase(path, version: 1, onCreate: _onCreate);
    return db;
  }

  Future close() async {
    var dbClient = await db;
    dbClient.close();
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('CREATE TABLE tableOrder ('
        'id INTEGER PRIMARY KEY AUTOINCREMENT, '
        'table_key TEXT, '
        'trans_uuid TEXT, '
        'transaction_no TEXT, '
        'table_id_rtdb TEXT, '
        'table_name TEXT, '
        'cashier_name TEXT, '
        'customer_name TEXT, '
        'merchant_id TEXT, '
        'store_id TEXT, '
        'trans_type TEXT, '
        'from_user TEXT, '
        'to_user TEXT, '
        'created_at INTEGER, '
        'status TEXT '
        ')',
    );
    await db.execute('CREATE TABLE itemOrder ('
        'id INTEGER PRIMARY KEY AUTOINCREMENT, '
        'key TEXT, '
        'trans_uuid TEXT, '
        'transaction_no TEXT, '
        'table_id_rtdb TEXT, '
        'order_id_rtdb TEXT, '
        'table_name TEXT, '
        'customer_name TEXT, '
        'merchant_id TEXT, '
        'store_id TEXT, '
        'item_name TEXT, '
        'variance TEXT, '
        'quantity INTEGER, '
        'completed_count INTEGER, '
        'is_take_out INTEGER, '
        'price REAL, '
        'timestamp INTEGER, '
        'timer_last_value TEXT, '
        'uuid TEXT, '
        'status TEXT '
        ')',
    );
    await db.execute('CREATE TABLE tableItems ('
        'id INTEGER PRIMARY KEY AUTOINCREMENT, '
        'key TEXT, '
        'trans_uuid TEXT, '
        'transaction_no TEXT, '
        'table_id_rtdb TEXT, '
        'order_id_rtdb TEXT, '
        'table_name TEXT, '
        'customer_name TEXT, '
        'merchant_id TEXT, '
        'store_id TEXT, '
        'item_name TEXT, '
        'variance TEXT, '
        'quantity INTEGER, '
        'completed_count INTEGER, '
        'is_take_out INTEGER, '
        'timestamp INTEGER, '
        'timer_last_value TEXT, '
        'status TEXT '
        ')',
    );
    await db.execute('CREATE TABLE transactionReports ('
        'id INTEGER PRIMARY KEY AUTOINCREMENT, '
        'product TEXT, '
        'quantity INTEGER, '
        'time INTEGER '
        ')',
    );
    await db.execute('CREATE TABLE tblStoreDetails ('
        'storeId INTEGER PRIMARY KEY AUTOINCREMENT,'
        'id TEXT,'
        'user_id TEXT,'
        'device_id TEXT,'
        'business_name TEXT,'
        'address TEXT,'
        'tin TEXT,'
        'bir_num TEXT,'
        'transaction_no TEXT,'
        'contact_no TEXT,'
        'account_type TEXT,'
        'created_at TEXT,'
        'updated_at TEXT'
        ')',
    );
    await db.execute('CREATE TABLE tblHeadOfficeDetails ('
        'headOfficeId INTEGER PRIMARY KEY AUTOINCREMENT,'
        'id TEXT,'
        'user_id TEXT,'
        'bthumbnail TEXT,'
        'bthumbnailBlob BLOB,'
        'business_name TEXT,'
        'business_type TEXT,'
        'address TEXT,'
        'tin TEXT,'
        'contact_no TEXT,'
        'r_header TEXT,'
        'r_footer TEXT,'
        'vat_enable INTEGER,'
        'vat_percentages TEXT,'
        'acred_num TEXT,'
        'date_issued TEXT,'
        'valid_until TEXT,'
        'final_permit_used TEXT,'
        'created_at TEXT,'
        'updated_at TEXT'
        ')',
    );
  }

  Future deleteDatabaseLogout() async {
    var dbClient = await db;
    await dbClient.rawDelete('DELETE FROM tableOrder');
    await dbClient.rawDelete('DELETE FROM itemOrder');
    await dbClient.rawDelete('DELETE FROM tableItems');
    await dbClient.rawDelete('DELETE FROM transactionReports');
    await dbClient.rawDelete('DELETE FROM tblStoreDetails');
    await dbClient.rawDelete('DELETE FROM tblHeadOfficeDetails');

  }

  Future<List<TableOrder>> getAllTableOrders() async {
    var dbClient = await db;
    var data = await dbClient.rawQuery("SELECT * FROM tableOrder where status !='yes'");

    if (data.isNotEmpty) {
      return data.map((e) => TableOrder.fromJson(e)).toList();
    } else {
      return null;
    }
  }

  Future<List<TableJoinOrder>> getJoinTableOrdersToItemOrder() async {
    List<TableOrder> listTableOrder = [];
    List<ItemOrder> listItemOrder = [];

    List<TableJoinOrder> listTableJoinOrder = [];

    var dbClient = await db;
    var tableData = await dbClient.rawQuery("SELECT * FROM tableOrder where status !='yes'");
    var orderItemData = await dbClient.rawQuery("SELECT * FROM itemOrder where status !='yes'");


    if(tableData != null){
      listTableOrder = tableData.map((e) => TableOrder.fromJson(e)).toList();

    } else {
      listTableOrder = [];
    }

    if(orderItemData != null){
      listItemOrder = orderItemData.map((e) => ItemOrder.fromJson(e)).toList();
    } else {
      listItemOrder = [];
    }

    if(listTableOrder.length > 0 && listItemOrder.length > 0){
      for(TableOrder tableItemData in listTableOrder){

        TableJoinOrder tableJoinOrder = new TableJoinOrder();
        tableJoinOrder.transUuid = tableItemData.transUuid;
        tableJoinOrder.tableName = tableItemData.tableName;
        tableJoinOrder.tableId = tableItemData.tableIdRtdb;
        tableJoinOrder.items = [];

        for(int x = 0; x < listItemOrder.length; x++){

          if(tableItemData.tableName == listItemOrder[x].tableName){
            int totalCount = listItemOrder[x].quantity - listItemOrder[x].completedCount;
            if(totalCount > 0){
              tableJoinOrder.items.add(listItemOrder[x]);
            }

          }
        }

        if(tableJoinOrder.items.length > 0){
          listTableJoinOrder.add(tableJoinOrder);
        }

      }
    }




    if(listTableJoinOrder.length > 0){
      // Do nothing
    } else {
      listTableJoinOrder = [];
    }


    return listTableJoinOrder;
  }

  Future<List<OrderJoinTable>> getJoinItemOrdersToTableOrder() async {
    List<TableItems> listTableOrder = [];
    List<ItemOrder> listItemOrder = [];
    List<OrderJoinTable> listOrderJoinTable = [];
    List<String> itemNames = [];
    var dbClient = await db;
    var tableItemsData = await dbClient.rawQuery("SELECT * FROM tableItems where status !='yes'");
    var orderItemData = await dbClient.rawQuery("SELECT * FROM itemOrder where status !='yes'");



    if(tableItemsData.length > 0){
      listTableOrder = tableItemsData.map((e) => TableItems.fromJson(e)).toList();
      //
      // for(TableItems tables in listTableOrder){
      //   print(tables.toJson());
      // }
    } else {
      listTableOrder = [];
    }

    if(orderItemData.length > 0){
      listItemOrder = orderItemData.map((e) => ItemOrder.fromJson(e)).toList();
    } else {
      listItemOrder = [];
    }

    // if(listItemOrder.length > 0 && listTableOrder.length > 0){
    //
    //   for(ItemOrder order in listItemOrder){
    //     OrderJoinTable orderJoinTable = new OrderJoinTable();
    //     orderJoinTable.itemOrder = order;
    //     orderJoinTable.listTableOrder = [];
    //     for(int x = 0; x < listTableOrder.length; x++){
    //       //if(order.itemName == listTableOrder[x].itemName && order.variance == listTableOrder[x].variance && order.orderIdRtdb == listTableOrder[x].orderIdRtdb){
    //       if(order.itemName == listTableOrder[x].itemName  && order.variance == listTableOrder[x].variance){
    //         int totalCount = listTableOrder[x].quantity - listTableOrder[x].completedCount;
    //         if(totalCount > 0){
    //           orderJoinTable.listTableOrder.add(listTableOrder[x]);
    //         }
    //       }
    //     }
    //
    //     if(orderJoinTable.listTableOrder.length > 0){
    //       listOrderJoinTable.add(orderJoinTable);
    //     }
    //   }
    // }

    if(listItemOrder.length > 0){
      for(ItemOrder itemOrder in listItemOrder){
        itemNames.add(itemOrder.itemName+"_"+itemOrder.variance);
      }

      itemNames = itemNames.toSet().toList();

      for(String inItems in itemNames){
        String name = inItems.split("_")[0];
        String variance = inItems.split("_")[1];

        OrderJoinTable orderJoinTable = new OrderJoinTable();
        orderJoinTable.name = name;
        orderJoinTable.variance = variance;
        orderJoinTable.listTableOrder = [];
        //print("Variance Length " + orderJoinTable.variance);
        for(TableItems items in listTableOrder){
          if(orderJoinTable.name == items.itemName && variance == items.variance){
            int totalCount = items.quantity - items.completedCount;
            if(totalCount > 0){
              orderJoinTable.listTableOrder.add(items);
            }
            //print("Table Item Data => " + items.itemName + " variance " + items.variance +" =>" + items.tableName);
          }

        }
        if(orderJoinTable.listTableOrder.length > 0){
          listOrderJoinTable.add(orderJoinTable);
        }
      }
    }



    if(listOrderJoinTable.length == 0){
      listOrderJoinTable = [];
    }

    return listOrderJoinTable;
  }

  Future<String> insertItemToTableOrders(TableOrder tableOrder) async {
    var dbClient = await db;
    var data = await dbClient.insert('tableOrder', tableOrder.toJson());
    //print("Insert data => " + data.toString());
    if(data != null){
      return "Success";
    } else {
      return "Failed";
    }
  }

  Future<List<ItemOrder>> getAllItemOrders() async {
    var dbClient = await db;
    var data = await dbClient.rawQuery("SELECT * FROM itemOrder where status !='yes'");

    if (data.isNotEmpty) {
      return data.map((e) => ItemOrder.fromJson(e)).toList();
    } else {
      return null;
    }
  }

  Future<String> insertItemToItemOrders(ItemOrder itemOrder) async {
    var dbClient = await db;
    var data = await dbClient.insert('itemOrder', itemOrder.toJson());
    //print("Insert data => " + data.toString());
    if(data != null){
      return "Success";
    } else {
      return "Failed";
    }
  }

  Future<List<ProductReports>> getProductReports() async {
    var dbClient = await db;
    var data = await dbClient.rawQuery("SELECT * FROM transactionReports");

    if (data.isNotEmpty) {
      return data.map((e) => ProductReports.fromJson(e)).toList();
    } else {
      return null;
    }
  }

  Future<ProductReports> getAvgReportProducts(String product) async {
    var dbClient = await db;
    var data = await dbClient.rawQuery("SELECT *, SUM(quantity) AS sum, SUM(time) / COUNT(product) AS avg_time, MAX(time) AS slowest, MIN(time) AS fastest FROM transactionReports WHERE product ='"+ product + "'");
    //var data = await dbClient.rawQuery("SELECT AVG(time) FROM transactionReports GROUP BY product ORDER BY time DESC");

    // for(int x = 0; x < data.length; x++){
    //
    // }

    //print(data.toList());
    return data.map((e) => ProductReports.fromJsonDB(e)).first;
   // return data.map((e) => ProductReports.fromJson(e)).toList();
  }

  Future<String> insertItemToProductReports(ProductReports item) async {
    var dbClient = await db;
    var data = await dbClient.insert('transactionReports', item.toJson());
    //print("Insert data => " + data.toString());
    if(data != null){
      return "Success";
    } else {
      return "Failed";
    }
  }

  Future<StoreDetails> getStoreDetails() async {
    var dbClient = await db;
    var data = await dbClient.rawQuery('SELECT * FROM tblStoreDetails');
    return data.map((e) => StoreDetails.fromJson(e)).first;
  }

  Future<void> insertStoreDetails({
    @required StoreDetails storeDetails
  }) async {
    var dbClient = await db;
    await dbClient.insert('tblStoreDetails', storeDetails.toJson());

  }

  Future<HeadOfficeDetails> getHeadOfficeDetails() async {
    var dbClient = await db;
    var headOffice = await dbClient.rawQuery('SELECT * FROM tblHeadOfficeDetails');
    if (headOffice.isNotEmpty) {
      return headOffice.map((e) => HeadOfficeDetails.fromJson(e)).first;
    } else {
      return null;
    }
  }

  Future<void> insertHeadOffice({@required HeadOfficeDetails officeDetails}) async {
    var dbClient = await db;
    await dbClient.insert('tblHeadOfficeDetails', officeDetails.toJson());
  }

  Future<String> insertItemToTableItems(TableItems item) async {
    var dbClient = await db;
    var data = await dbClient.insert('tableItems', item.toJson());
    //print("Insert data => " + data.toString());
    if(data != null){
      return "Success";
    } else {
      return "Failed";
    }
  }

  Future updateItemOrder(int completedCount, String orderIdRtdb) async {
    var dbClient = await db;
    //print("Variance => "+variance);
    var tableItemsData = await dbClient.rawUpdate("UPDATE tableItems set completed_count = ? where order_id_rtdb = ?",
        [completedCount, orderIdRtdb]);

    var itemOrderData = await dbClient.rawUpdate("UPDATE itemOrder set completed_count = ? where order_id_rtdb = ?",
        [completedCount, orderIdRtdb]);

  }

  Future updateItemOrderComplete(int completedCount, String orderIdRtdb) async {
    var dbClient = await db;
    //print("Variance => "+variance);
    var itemOrderData = await dbClient.rawUpdate("UPDATE itemOrder set completed_count = ?, status='yes' where order_id_rtdb = ?",
        [completedCount, orderIdRtdb]);
    var tableItemsData = await dbClient.rawUpdate("UPDATE tableItems set completed_count = ?, status='yes' where order_id_rtdb = ?",
        [completedCount, orderIdRtdb]);
  }

  // Future updateTableItems(int quantity, String transUuid, String itemName, String variance) async {
  //   var dbClient = await db;
  //   var itemOrderData = await dbClient.rawUpdate("UPDATE itemOrder set quantity = ? where item_name = ? AND variance =?",
  //       [quantity, itemName, variance]);
  //   var tableItemsData = await dbClient.rawUpdate("UPDATE tableItems set quantity = ? where item_name = ? AND variance =?",
  //       [quantity,itemName, variance]);
  // }

  Future selectItems(StoreOrderFirebase storeOrderFirebase) async {
    var dbClient = await db;
    var tableSearch = await dbClient.rawQuery("SELECT * FROM tableItems where table_name ='"+ storeOrderFirebase.tableName +"'");
    //var tableItemsData = await dbClient.rawQuery("SELECT * FROM tableItems where table_name ='"+ storeOrderFirebase.tableName +"' AND item_name ='" + "yss" + "' AND  variance ='" + "no" + "' AND  is_take_out ='1'");

    //TableItems table = tableName.map((e) => TableItems.fromJson(e)).first;

    //print(tableItemsData.length.toString() + " => " + table.toJson().toString());
    // List<TableItems> listTableOrder = [];
    // listTableOrder = tableItemsData.map((e) => TableItems.fromJson(e)).toList();
    // print(table.toJson());
    String uuid = Uuid().v4();
    TableOrder tableOrder = new TableOrder();
    tableOrder.key = storeOrderFirebase.key;
    tableOrder.transUuid = uuid;
    tableOrder.transactionNo = storeOrderFirebase.transactionNo;
    tableOrder.tableIdRtdb = storeOrderFirebase.tableId;
    tableOrder.tableName = storeOrderFirebase.tableName;
    tableOrder.cashierName = storeOrderFirebase.cashierName;
    tableOrder.customerName = storeOrderFirebase.customerName;
    tableOrder.merchantId = storeOrderFirebase.merchantId;
    tableOrder.storeId = storeOrderFirebase.storeId;
    tableOrder.type = storeOrderFirebase.type;
    tableOrder.from = storeOrderFirebase.from;
    tableOrder.to = storeOrderFirebase.to;
    tableOrder.createdAt = storeOrderFirebase.createdAt;
    tableOrder.status = storeOrderFirebase.status;
    if(tableSearch.length == 0){
      DatabaseHelper().insertItemToTableOrders(tableOrder);
    }

    storeOrderFirebase.listItem.forEach((key, value) async {
      int isTakeOut = int.parse(value['isTakeOut'].toString());
      var data = await dbClient.rawQuery("SELECT * FROM tableItems where table_name ='"+ storeOrderFirebase.tableName +"' AND item_name ='" + value["itemName"].toString().replaceAll("'", "") + "' AND  variance ='" + value["variance"].toString() + "' AND  is_take_out =$isTakeOut" + " AND order_id_rtdb ='"+ value["id"].toString() + "'");
      //var data = await dbClient.rawQuery("SELECT * FROM tableItems where table_name ='"+ " AND order_id_rtdb ='"+ value["id"].toString() + "'");
      print(data.length);
      if(data.length > 0){
        TableItems table = data.map((e) => TableItems.fromJson(e)).first;
        int quantity = int.parse(value['quantity'].toString()) + table.quantity;
        await dbClient.rawUpdate("UPDATE tableItems set quantity = ? where trans_uuid = ? AND item_name = ? AND variance =? AND is_take_out =?",
            [quantity, table.transUuid, table.itemName, table.variance, table.isTakeOUt]);
        await dbClient.rawUpdate("UPDATE itemOrder set quantity = ? where trans_uuid = ? AND item_name = ? AND variance =? AND is_take_out =?",
            [quantity, table.transUuid, table.itemName, table.variance, table.isTakeOUt]);
      } else {
        if(tableSearch.length > 0){
          print("Table Search proceed");
          //String tableUuid = Uuid().v4();
          TableItems table = tableSearch.map((e) => TableItems.fromJson(e)).first;
          ItemOrder itemOrder = new ItemOrder();
          itemOrder.key = storeOrderFirebase.key;
          itemOrder.transUuid = table.transUuid;
          itemOrder.transactionNo = table.transactionNo;
          itemOrder.tableIdRtdb = table.tableIdRtdb;
          itemOrder.tableName = table.tableName;
          itemOrder.customerName = table.customerName;
          itemOrder.merchantId = table.merchantId;
          itemOrder.storeId = table.storeId;
          itemOrder.orderIdRtdb = value["id"].toString();
          itemOrder.itemName = value["itemName"].toString().replaceAll("'", "");
          itemOrder.variance = value["variance"].toString();
          itemOrder.quantity = int.parse(value["quantity"].toString());
          itemOrder.completedCount = int.parse(value["completeCount"].toString());
          itemOrder.isTakeOUt = int.parse(value["isTakeOut"].toString());
          itemOrder.price = double.parse(value["price"].toString());
          itemOrder.timestamp = int.parse(value["timeStamp"].toString());
          itemOrder.timerLastValue = value["timerLastValue"].toString();
          itemOrder.uuid = value["uuid"].toString();
          itemOrder.status = value["completed"].toString();
          DatabaseHelper().insertItemToItemOrders(itemOrder);

          TableItems tableItems = new TableItems();
          tableItems.key =  storeOrderFirebase.key;
          tableItems.transUuid =  table.transUuid;
          tableItems.transactionNo = table.transactionNo;
          tableItems.tableIdRtdb = table.tableIdRtdb;
          tableItems.tableName = table.tableName;
          tableItems.customerName = table.customerName;
          tableItems.merchantId = table.merchantId;
          tableItems.storeId = table.storeId;
          tableItems.orderIdRtdb = value["id"].toString();
          tableItems.itemName = value["itemName"].toString().replaceAll("'", "");
          tableItems.variance = value["variance"].toString();
          tableItems.quantity = int.parse(value["quantity"].toString());
          tableItems.completedCount = int.parse(value["completeCount"].toString());
          tableItems.isTakeOUt = int.parse(value["isTakeOut"].toString());
          tableItems.timestamp = int.parse(value["timeStamp"].toString());
          tableItems.timerLastValue = value["timerLastValue"].toString();
          tableItems.status = value["completed"].toString();

          DatabaseHelper().insertItemToTableItems(tableItems);
        } else {

          print("Table Search failed");
          ItemOrder itemOrder = new ItemOrder();
          itemOrder.key = storeOrderFirebase.key;
          itemOrder.transUuid = uuid;
          itemOrder.transactionNo = tableOrder.transactionNo;
          itemOrder.tableIdRtdb = tableOrder.tableIdRtdb;
          itemOrder.tableName = tableOrder.tableName;
          itemOrder.customerName = tableOrder.customerName;
          itemOrder.orderIdRtdb = value["id"].toString();
          itemOrder.merchantId = tableOrder.merchantId;
          itemOrder.storeId = tableOrder.storeId;
          itemOrder.itemName = value["itemName"].toString().replaceAll("'", "");
          itemOrder.variance = value["variance"].toString();
          itemOrder.quantity = int.parse(value["quantity"].toString());
          itemOrder.completedCount = int.parse(value["completeCount"].toString());
          itemOrder.isTakeOUt = int.parse(value["isTakeOut"].toString());
          itemOrder.price = double.parse(value["price"].toString());
          itemOrder.timestamp = int.parse(value["timeStamp"].toString());
          itemOrder.timerLastValue = value["timerLastValue"].toString();
          itemOrder.uuid = value["uuid"].toString();
          itemOrder.status = value["completed"].toString();
          DatabaseHelper().insertItemToItemOrders(itemOrder);

          TableItems tableItems = new TableItems();
          tableItems.key = storeOrderFirebase.key;
          tableItems.transUuid = uuid;
          tableItems.transactionNo = tableOrder.transactionNo;
          tableItems.tableName = tableOrder.tableName;
          tableItems.customerName = tableOrder.customerName;
          tableItems.orderIdRtdb = value["id"].toString();
          tableItems.merchantId = tableOrder.merchantId;
          tableItems.storeId = tableOrder.storeId;
          tableItems.itemName = value["itemName"].toString().replaceAll("'", "");
          tableItems.variance = value["variance"].toString();
          tableItems.quantity = int.parse(value["quantity"].toString());
          tableItems.completedCount = int.parse(value["completeCount"].toString());
          tableItems.isTakeOUt = int.parse(value["isTakeOut"].toString());
          tableItems.timestamp = int.parse(value["timeStamp"].toString());
          tableItems.timerLastValue = value["timerLastValue"].toString();
          tableItems.status = value["completed"].toString();
          DatabaseHelper().insertItemToTableItems(tableItems);
        }
      }

    });

  }

}