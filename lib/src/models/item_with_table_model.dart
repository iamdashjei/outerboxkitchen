class ItemWithTableModel {
  String itemName;
  String itemId;
  List<TableModel> tables;

  ItemWithTableModel({this.itemName, this.itemId, this.tables});

  ItemWithTableModel.fromJson(Map<String, dynamic> json) {
    itemName = json['itemName'];
    itemId = json['itemId'];
    if (json['tables'] != null) {
      tables = [];
      json['orders'].forEach((v) {
        tables.add(new TableModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['itemName'] = this.itemName;
    data['itemId'] = this.itemId;
    if (this.tables != null) {
      data['tables'] = this.tables.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class TableModel {
  int id;
  String tableId;
  String tableName;
  int orderQuantity;
  int startTimer;
  DateTime orderCreated;
  bool isComplete;
  bool isTakeOut;
  String price;

  TableModel(
      {
        this.id,
        this.tableId,
      this.tableName,
      this.orderQuantity,
      this.startTimer,
      this.orderCreated,
      this.isComplete,
      this.isTakeOut,
      this.price});

  TableModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    tableId = json['tableId'];
    tableName = json['tableName'];
    orderQuantity = json['orderQuantity'];
    startTimer = json['startTimer'];
    orderCreated = json['orderCreated'];
    isComplete = json['isComplete'];
    isTakeOut = json['isTakeOut'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['tableId'] = this.tableId;
    data['tableName'] = this.tableName;
    data['startTimer'] = this.startTimer;
    data['price'] = this.price;
    data['orderCreated'] = this.orderCreated;
    data['orderQuantity'] = this.orderQuantity;
    data['isComplete'] = this.isComplete;
    data['isTakeOut'] = this.isTakeOut;
    return data;
  }
}
