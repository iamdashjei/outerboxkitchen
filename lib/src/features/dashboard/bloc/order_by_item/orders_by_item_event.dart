// part of 'orders_by_item_bloc.dart';
//
// abstract class OrdersByItemEvent {
//   Stream<OrdersByItemState> applySync({OrdersByItemState currentState, OrdersByItemBloc bloc});
// }
//
// class UnHomeEvent extends OrdersByItemEvent {
//
//   @override
//   Stream<OrdersByItemState> applySync(
//       {OrdersByItemState currentState, OrdersByItemBloc bloc}) async* {
//     yield OrdersByItemLoadingState();
//   }
// }
//
// class LoadItemEvent extends OrdersByItemEvent {
//   final LocalDatabase appDatabase;
//
//   LoadItemEvent({this.appDatabase});
//   @override
//   Stream<OrdersByItemState> applySync({OrdersByItemState currentState, OrdersByItemBloc bloc}) async* {
//     try {
//       if (currentState is OrdersByItemState) {
//         yield OrdersByItemLoadingState();
//         final res = await appDatabase.watchTableWithOrders();
//         List<String> itemNames = [];
//         for (TableWithOrdersResult res in res) {
//           itemNames.add(res.orderName);
//         }
//         List<ItemWithTableModel> tableWithOrders = [];
//         for (String itemName in itemNames.toSet().toList()) {
//           ItemWithTableModel tableWithOrder = new ItemWithTableModel();
//           List<TableModel> tableModelList = [];
//           tableWithOrder.itemName = itemName;
//           for (TableWithOrdersResult res in res) {
//             if (itemName == res.orderName) {
//               if (res.orderId != null) {
//                 if (res.orderQuantity > 0) {
//                   tableWithOrder.itemId = res.orderId;
//                   TableModel tableModel = new TableModel();
//                   tableModel.tableId = res.tableId;
//                   tableModel.tableName = res.name;
//                   tableModel.orderQuantity = res.orderQuantity;
//                   tableModel.orderCreated = res.orderCreated;
//                   tableModel.isComplete = res.isComplete;
//                   tableModel.startTimer = res.startTimer;
//                   tableModel.isTakeOut = res.isTakeOut;
//                   tableModelList.add(tableModel);
//                   tableWithOrder.tables = tableModelList;
//                 }
//               }
//             }
//           }
//           tableWithOrders.add(tableWithOrder);
//         }
//
//         yield OrdersByItemLoadedState(data: tableWithOrders);
//       }
//     } catch (_, stackTrace) {
//       developer.log('$_',
//           name: 'LoadItemEvent', error: _, stackTrace: stackTrace);
//       yield OrdersByItemErrorState(_?.toString());
//     }
//   }
// }