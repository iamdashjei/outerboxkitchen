// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:kitchen_monitoring/src/database/database.dart';
// import 'package:kitchen_monitoring/src/features/dashboard/bloc/orders_by_table/orders_by_table_bloc.dart';
// import 'package:kitchen_monitoring/src/features/dashboard/widgets/table_view.dart';
// import 'package:kitchen_monitoring/src/utils/botton_loader.dart';
// import 'package:kitchen_monitoring/src/utils/loading.dart';
//
// class OrdersTableView extends StatelessWidget {
//   final OrdersByTableBloc ordersByTableBloc;
//   final LocalDatabase appDatabase;
//
//   const OrdersTableView({Key key, @required this.ordersByTableBloc, @required this.appDatabase}) : super(key: key);
//   @override
//   Widget build(BuildContext context) {
//     return BlocConsumer(
//       bloc: this.ordersByTableBloc,
//       listener: (BuildContext context, state) {  },
//       builder: (BuildContext context, state) {
//         if (state is OrdersByTableLoadingState) {
//           return BuildLoading();
//         }
//         if (state is OrdersByTableErrorState) {
//           return Center(
//             child: Container(
//               child: Text("Some Thing Went Wrong"),
//             ),
//           );
//         }
//         if (state is OrdersByTableLoadedState) {
//           if (state.data.isEmpty) {
//             return Center(
//               child: Text("No Orders today"),
//             );
//           }
//           return _orderList(state);
//         } else {
//           return Container();
//         }
//       },);
//   }
//
//   _orderList(OrdersByTableLoadedState state) {
//     return ListView.builder(
//       itemBuilder: (context, index) {
//         if (index == state.data.length) {
//           this.ordersByTableBloc.add(LoadTableEvent(appDatabase: appDatabase));
//           return BottomLoader();
//         } else {
//           return TableView(tableWithOrdersModel: state.data[index], localDatabase: appDatabase, ordersByTableBloc: ordersByTableBloc);
//         }
//       },
//       itemCount: state.data != null ? state.data.length : 0,
//     );
//   }
// }
