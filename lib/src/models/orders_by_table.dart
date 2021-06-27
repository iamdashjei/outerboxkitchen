// class OrdersByTable {
//   String id;
//   String merchantId;
//   String saleId;
//   String cname;
//   String cashier;
//   String table;
//   List<ItemOrders> orders;
//   int type;
//   int active;
//   String orderStart;
//   String createdAt;
//   String updatedAt;
//
//   OrdersByTable(
//       {this.id,
//         this.merchantId,
//         this.saleId,
//         this.cname,
//         this.cashier,
//         this.table,
//         this.orders,
//         this.type,
//         this.active,
//         this.orderStart,
//         this.createdAt,
//         this.updatedAt});
//
//   OrdersByTable.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     merchantId = json['merchant_id'];
//     saleId = json['sale_id'];
//     cname = json['cname'];
//     cashier = json['cashier'];
//     table = json['table'];
//     if (json['orders'] != null) {
//       orders = new List<ItemOrders>();
//       json['orders'].forEach((v) {
//         orders.add(new ItemOrders.fromJson(v));
//       });
//     }
//     type = json['type'];
//     active = json['active'];
//     orderStart = json['order_start'];
//     createdAt = json['created_at'];
//     updatedAt = json['updated_at'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['id'] = this.id;
//     data['merchant_id'] = this.merchantId;
//     data['sale_id'] = this.saleId;
//     data['cname'] = this.cname;
//     data['cashier'] = this.cashier;
//     data['table'] = this.table;
//     if (this.orders != null) {
//       data['orders'] = this.orders.map((v) => v.toJson()).toList();
//     }
//     data['type'] = this.type;
//     data['active'] = this.active;
//     data['order_start'] = this.orderStart;
//     data['created_at'] = this.createdAt;
//     data['updated_at'] = this.updatedAt;
//     return data;
//   }
// }
//
// class ItemOrders {
//   String id;
//   String transactionItem;
//   String price;
//   String quantity;
//   bool isComplete;
//   bool dineIn;
//
//   ItemOrders(
//       {this.id,
//         this.transactionItem,
//         this.price,
//         this.quantity,
//         this.dineIn,
//         this.isComplete});
//
//   ItemOrders.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     transactionItem = json['transaction_item'];
//     price = json['price'];
//     quantity = json['quantity'];
//     dineIn = json['dine_in'];
//     isComplete = json['isComplete'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['id'] = this.id;
//     data['transaction_item'] = this.transactionItem;
//     data['price'] = this.price;
//     data['quantity'] = this.quantity;
//     data['dine_in'] = this.dineIn;
//     data['isComplete'] = this.isComplete;
//     return data;
//   }
// }
class ItemOrder{
  String key;
  String transUuid;
  String transactionNo;
  String tableIdRtdb;
  String orderIdRtdb;
  String tableName;
  String customerName;
  String merchantId;
  String storeId;
  String itemName;
  String variance;
  int quantity;
  int completedCount;
  int isTakeOUt;
  double price;
  int timestamp;
  String timerLastValue;
  String uuid;
  String status;

  ItemOrder({
    this.key,
    this.transUuid,
    this.transactionNo,
    this.tableIdRtdb,
    this.orderIdRtdb,
    this.tableName,
    this.customerName,
    this.merchantId,
    this.storeId,
    this.itemName,
    this.variance,
    this.quantity,
    this.completedCount,
    this.isTakeOUt,
    this.price,
    this.timestamp,
    this.timerLastValue,
    this.uuid,
    this.status
  });

  factory ItemOrder.fromJson(Map<String, dynamic> json){
    return ItemOrder(
        key: json['key'],
        transUuid: json['trans_uuid'],
        transactionNo: json['transaction_no'],
        tableIdRtdb: json['table_id_rtdb'],
        orderIdRtdb: json['order_id_rtdb'],
        tableName: json['table_name'],
        customerName: json['customer_name'],
        merchantId: json['merchant_id'],
        storeId: json['store_id'],
        itemName: json['item_name'],
        variance: json['variance'],
        quantity: json['quantity'] != null ? int.parse(json['quantity'].toString()) : 0,
        completedCount: json['completed_count'] != null ? int.parse(json['completed_count'].toString()) : 0,
        isTakeOUt: json['is_take_out'] != null ? int.parse(json['is_take_out'].toString()) : 0,
        price: json['price'] != null ? double.parse(json['price'].toString()) : 0,
        timestamp: json['timestamp'] != null ? int.parse(json['timestamp'].toString()) : 0,
        timerLastValue: json['timer_last_value'],
        uuid: json['uuid'],
        status: json['status']
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['key'] = key;
    data['trans_uuid'] = transUuid;
    data['transaction_no'] = transactionNo;
    data['table_id_rtdb'] = tableIdRtdb;
    data['order_id_rtdb'] = orderIdRtdb;
    data['table_name'] = tableName;
    data['customer_name'] = customerName;
    data['merchant_id'] = merchantId;
    data['store_id'] = storeId;
    data['item_name'] = itemName;
    data['variance'] = variance;
    data['quantity'] = quantity;
    data['completed_count'] = completedCount;
    data['is_take_out'] = isTakeOUt;
    data['price'] = price;
    data['timestamp'] = timestamp;
    data['timer_last_value'] = timerLastValue;
    data['uuid'] = uuid;
    data['status'] = status;


    return data;
  }
}

class TableItems {
  String key;
  String transUuid;
  String transactionNo;
  String tableIdRtdb;
  String orderIdRtdb;
  String tableName;
  String customerName;
  String merchantId;
  String storeId;
  String itemName;
  String variance;
  int quantity;
  int completedCount;
  int isTakeOUt;
  int timestamp;
  String timerLastValue;
  String status;

  TableItems({
    this.key,
    this.transUuid,
    this.transactionNo,
    this.tableIdRtdb,
    this.orderIdRtdb,
    this.tableName,
    this.customerName,
    this.merchantId,
    this.storeId,
    this.itemName,
    this.variance,
    this.quantity,
    this.completedCount,
    this.isTakeOUt,
    this.timestamp,
    this.timerLastValue,
    this.status
  });

  factory TableItems.fromJson(Map<String, dynamic> json){
    return TableItems(
        key: json['key'],
        transUuid: json['trans_uuid'],
        transactionNo: json['transaction_no'],
        tableIdRtdb: json['table_id_rtdb'],
        orderIdRtdb: json['order_id_rtdb'],
        tableName: json['table_name'],
        customerName: json['customer_name'],
        merchantId: json['merchant_id'],
        storeId: json['store_id'],
        itemName: json['item_name'],
        variance: json['variance'],
        quantity: json['quantity'] != null ? int.parse(json['quantity'].toString()) : 0,
        completedCount: json['completed_count'] != null ? int.parse(json['completed_count'].toString()) : 0,
        isTakeOUt: json['is_take_out'] != null ? int.parse(json['is_take_out'].toString()) : 0,
        timestamp: json['timestamp'] != null ? int.parse(json['timestamp'].toString()) : 0,
        timerLastValue: json['timer_last_value'],
        status: json['status']
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['key'] = key;
    data['trans_uuid'] = transUuid;
    data['transaction_no'] = transactionNo;
    data['table_id_rtdb'] = tableIdRtdb;
    data['order_id_rtdb'] = orderIdRtdb;
    data['table_name'] = tableName;
    data['customer_name'] = customerName;
    data['merchant_id'] = merchantId;
    data['store_id'] = storeId;
    data['item_name'] = itemName;
    data['variance'] = variance;
    data['quantity'] = quantity;
    data['completed_count'] = completedCount;
    data['is_take_out'] = isTakeOUt;
    data['timestamp'] = timestamp;
    data['timer_last_value'] = timerLastValue;
    data['status'] = status;
    return data;
  }
}