// class TableWithOrdersModel {
//   String tableName;
//   String tableId;
//   List<OrdersModel> orders;
//
//   TableWithOrdersModel({this.tableName, this.tableId, this.orders});
//
//   TableWithOrdersModel.fromJson(Map<String, dynamic> json) {
//     tableName = json['tableName'];
//     tableId = json['tableId'];
//     if (json['orders'] != null) {
//       orders = new List<OrdersModel>();
//       json['orders'].forEach((v) {
//         orders.add(new OrdersModel.fromJson(v));
//       });
//     }
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['tableId'] = this.tableId;
//     data['tableName'] = this.tableName;
//     if (this.orders != null) {
//       data['orders'] = this.orders.map((v) => v.toJson()).toList();
//     }
//     return data;
//   }
// }
//
// class OrdersModel {
//   int id;
//   String orderId;
//   String transactionItem;
//   String price;
//   int quantity;
//   int startTimer;
//   DateTime orderCreated;
//   bool isComplete;
//   bool isTakeOut;
//
//   OrdersModel(
//       {
//         this.id,
//         this.orderId,
//         this.transactionItem,
//         this.price,
//         this.startTimer,
//         this.quantity,
//         this.orderCreated,
//         this.isTakeOut,
//         this.isComplete});
//
//   OrdersModel.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     orderId = json['orderId'];
//     transactionItem = json['transaction_item'];
//     price = json['price'];
//     startTimer = json['startTimer'];
//     quantity = json['quantity'];
//     orderCreated = json['orderCreated'];
//     isComplete = json['isComplete'];
//     isTakeOut = json['isTakeOut'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['id'] = this.id;
//     data['orderId'] = this.orderId;
//     data['startTimer'] = this.startTimer;
//     data['transaction_item'] = this.transactionItem;
//     data['price'] = this.price;
//     data['orderCreated'] = this.orderCreated;
//     data['quantity'] = this.quantity;
//     data['isComplete'] = this.isComplete;
//     data['isTakeOut'] = this.isTakeOut;
//     return data;
//   }
// }
class TableOrder {
  String key;
  String transUuid;
  String transactionNo;
  String tableIdRtdb;
  String tableName;
  String cashierName;
  String customerName;
  String merchantId;
  String storeId;
  String type;
  String from;
  String to;
  int createdAt;
  String status;

  TableOrder({
    this.key,
    this.transUuid,
    this.transactionNo,
    this.tableIdRtdb,
    this.tableName,
    this.cashierName,
    this.customerName,
    this.merchantId,
    this.storeId,
    this.type,
    this.from,
    this.to,
    this.createdAt,
    this.status
  });

  factory TableOrder.fromJson(Map<String, dynamic> json){
    return TableOrder(
        key: json['table_key'].toString(),
        transUuid: json['trans_uuid'].toString(),
        transactionNo: json['transaction_no'].toString(),
      tableIdRtdb: json['table_id_rtdb'].toString(),
      tableName: json['table_name'].toString(),
      cashierName: json['cashier_name'].toString(),
      customerName: json['customer_name'].toString(),
      merchantId: json['merchant_id'].toString(),
      storeId: json['store_id'].toString(),
      type: json['trans_type'].toString(),
      from: json['from_user'].toString(),
      to: json['to_user'].toString(),
      createdAt: int.parse(json['created_at'].toString()),
      status: json['status'].toString()
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['table_key'] = key;
    data['trans_uuid'] = transUuid;
    data['transaction_no'] = transactionNo;
    data['table_id_rtdb'] = tableIdRtdb;
    data['table_name'] = tableName;
    data['cashier_name'] = cashierName;
    data['customer_name'] = customerName;
    data['merchant_id'] = merchantId;
    data['store_id'] = storeId;
    data['trans_type'] = type;
    data['from_user'] = from;
    data['to_user'] = to;
    data['created_at'] = createdAt;
    data['status'] = status;

    return data;
  }

}