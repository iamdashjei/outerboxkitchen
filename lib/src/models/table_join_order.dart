import 'package:outerboxkitchen/src/models/table_with_orders_model.dart';

import 'orders_by_table.dart';

class TableJoinOrder {
  String tableName;
  String tableId;
  String transUuid;
  List<ItemOrder> items = [];

  TableJoinOrder({
     this.transUuid,
     this.tableName,
     this.tableId,
     this.items
  });
}

class OrderJoinTable {
  String name;
  String variance;
  ItemOrder itemOrder;
  List<TableItems> listTableOrder = [];

  OrderJoinTable({
    this.name,
    this.variance,
    this.itemOrder,
    this.listTableOrder
  });
}