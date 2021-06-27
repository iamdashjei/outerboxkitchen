// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:kitchen_monitoring/src/database/database.dart';
// import 'package:kitchen_monitoring/src/features/dashboard/bloc/order_by_item/orders_by_item_bloc.dart';
// import 'package:kitchen_monitoring/src/features/dashboard/widgets/item_view.dart';
// import 'package:kitchen_monitoring/src/utils/botton_loader.dart';
// import 'package:kitchen_monitoring/src/utils/loading.dart';
//
// class OrdersItemView extends StatelessWidget {
//   final OrdersByItemBloc ordersByItemBloc;
//   final LocalDatabase appDatabase;
//
//   const OrdersItemView({Key key, @required this.ordersByItemBloc, @required this.appDatabase})
//       : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocConsumer(
//       bloc: this.ordersByItemBloc,
//       listener: (BuildContext context, state) {},
//       builder: (BuildContext context, state) {
//         if (state is OrdersByItemLoadingState) {
//           return BuildLoading();
//         }
//         if (state is OrdersByItemErrorState) {
//           return Center(
//             child: Container(
//               child: Text("Some Thing Went Wrong"),
//             ),
//           );
//         }
//         if (state is OrdersByItemLoadedState) {
//           if (state.data.isEmpty) {
//             return Center(
//               child: Text("No Orders today"),
//             );
//           }
//           return _orderList(state);
//         } else {
//           return Container();
//         }
//       },
//     );
//   }
//
//   _orderList(OrdersByItemLoadedState state) {
//     return ListView.builder(
//       itemBuilder: (context, index) {
//         if (index == state.data.length) {
//           this.ordersByItemBloc.add(LoadItemEvent(appDatabase: appDatabase));
//           return BottomLoader();
//         } else {
//           return ItemView(itemWithTableModel: state.data[index], localDatabase: appDatabase, ordersByItemBloc: ordersByItemBloc,);
//         }
//       },
//       itemCount: state.data != null ? state.data.length : 0,
//     );
//   }
// }
