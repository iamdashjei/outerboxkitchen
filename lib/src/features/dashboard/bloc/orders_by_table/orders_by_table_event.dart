// part of 'orders_by_table_bloc.dart';
//
// @immutable
// abstract class OrdersByTableEvent {
//   Stream<OrdersByTableState> applySync({OrdersByTableState currentState, OrdersByTableBloc bloc});
// }
//
// class UnHomeEvent extends OrdersByTableEvent {
//
//   @override
//   Stream<OrdersByTableState> applySync({OrdersByTableState currentState, OrdersByTableBloc bloc}) async* {
//     yield OrdersByTableLoadingState();
//   }
// }
//
// class LoadTableEvent extends OrdersByTableEvent {
//   final LocalDatabase appDatabase;
//
//   LoadTableEvent({@required this.appDatabase});
//   @override
//   Stream<OrdersByTableState> applySync({OrdersByTableState currentState, OrdersByTableBloc bloc}) async* {
//     try {
//       if (currentState is OrdersByTableState) {
//         yield OrdersByTableLoadingState();
//         final res = await appDatabase.watchTableWithOrders();
//         List<String> tableNames = [];
//         for (TableWithOrdersResult res in res) {
//           tableNames.add(res.name);
//         }
//         List<TableWithOrdersModel> tableWithOrders = [];
//         for (String tableName in tableNames.toSet().toList()) {
//           TableWithOrdersModel tableWithOrder = new TableWithOrdersModel();
//           List<OrdersModel> orderModelList = [];
//           tableWithOrder.tableName = tableName;
//           for (TableWithOrdersResult res in res) {
//             if (tableName == res.name) {
//               if (res.orderId != null) {
//                 if (res.orderQuantity > 0) {
//                   tableWithOrder.tableId = res.tableId;
//                   OrdersModel ordersModel = new OrdersModel();
//                   ordersModel.id = res.id;
//                   ordersModel.orderId = res.orderId;
//                   ordersModel.transactionItem = res.orderName;
//                   ordersModel.startTimer = res.startTimer;
//                   ordersModel.quantity = res.orderQuantity;
//                   ordersModel.orderCreated = res.orderCreated;
//                   ordersModel.isComplete = res.isComplete;
//                   ordersModel.isTakeOut = res.isTakeOut;
//                   orderModelList.add(ordersModel);
//                   tableWithOrder.orders = orderModelList;
//                 }
//               }
//             }
//           }
//           tableWithOrders.add(tableWithOrder);
//         }
//
//         yield OrdersByTableLoadedState(data: tableWithOrders);
//       }
//     } catch (_, stackTrace) {
//       developer.log('$_',
//           name: 'LoadTableEvent', error: _, stackTrace: stackTrace);
//       yield OrdersByTableErrorState(_?.toString());
//     }
//   }
//
// }