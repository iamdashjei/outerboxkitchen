// import 'dart:convert';
//
// import 'package:audioplayers/audio_cache.dart';
// import 'package:audioplayers/audioplayers.dart';
// import 'package:auto_size_text/auto_size_text.dart';
// import 'package:awesome_dialog/awesome_dialog.dart';
// import 'package:bluetooth_thermal_printer/bluetooth_thermal_printer.dart';
// import 'package:esc_pos_utils/esc_pos_utils.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_pusher/pusher.dart';
// import 'package:kitchen_monitoring/src/database/database.dart';
// import 'package:kitchen_monitoring/src/features/dashboard/bloc/orders_by_table/orders_by_table_bloc.dart';
// import 'package:kitchen_monitoring/src/features/login/models/pusher_response.dart';
// import 'package:kitchen_monitoring/src/models/table_with_orders_model.dart';
// import 'package:kitchen_monitoring/src/utils/botton_loader.dart';
// import 'package:kitchen_monitoring/src/utils/loading.dart';
// import 'package:kitchen_monitoring/src/utils/user_sessions.dart';
// import 'package:timer_builder/timer_builder.dart';
// import 'package:kitchen_monitoring/src/utils/numeric_step_button.dart';
//
// extension ListUtils<T> on List<T> {
//   num sumBy(num f(T element)) {
//     num sum = 0;
//     for(var item in this) {
//       sum += f(item);
//     }
//     return sum;
//   }
// }
//
// class TableView extends StatefulWidget {
//   // final TableWithOrdersModel tableWithOrdersModel;
//   final LocalDatabase localDatabase;
//   final OrdersByTableBloc ordersByTableBloc;
//
//   const TableView(
//       {Key key, @required this.localDatabase, @required this.ordersByTableBloc})
//       : super(key: key);
//
//   @override
//   _TableViewState createState() =>
//       _TableViewState(localDatabase, ordersByTableBloc);
// }
//
// class _TableViewState extends State<TableView> {
//   final LocalDatabase localDatabase;
//   final OrdersByTableBloc ordersByTableBloc;
//   Channel channelTable;
//
//   _TableViewState(this.localDatabase, this.ordersByTableBloc);
//
//   var quantityController = TextEditingController(text: "1");
//   int itemComplete = 1;
//   String merchantId = "";
//   Event lastEvent;
//
//   AudioCache audioCache = AudioCache();
//   AudioPlayer advancedPlayer = AudioPlayer();
//
//   @override
//   void initState() {
//     UserSessions.getPrinterConnected();
//     connectPusher();
//     super.initState();
//   }
//
//   @override
//   void dispose() {
//     advancedPlayer.dispose();
//     // Pusher.disconnect();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocConsumer(
//       bloc: this.ordersByTableBloc,
//       listener: (BuildContext context, state) {},
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
//           return ListView.builder(
//             itemBuilder: (context, index) {
//               if (index == state.data.length) {
//                 this
//                     .ordersByTableBloc
//                     .add(LoadTableEvent(appDatabase: localDatabase));
//                 return BottomLoader();
//               } else {
//                 return state.data[index].orders != null
//                     ? Container(
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.start,
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Container(
//                               width: MediaQuery.of(context).size.width,
//                               color: Colors.grey[400],
//                               child: Row(
//                                 children: [
//                                   Container(
//                                     padding: EdgeInsets.all(10.0),
//                                     child: AutoSizeText(
//                                       "${state.data[index].tableName}",
//                                       maxLines: 1,
//                                       style: TextStyle(
//                                           fontWeight: FontWeight.bold,
//                                           fontSize: 28),
//                                     ),
//                                   ),
//                                   Spacer(),
//                                   Container(
//                                     padding: EdgeInsets.only(
//                                         top: 10.0,
//                                         bottom: 10.0,
//                                         left: 20.0,
//                                         right: 20.0),
//                                     color: Colors.grey[500],
//                                     child: AutoSizeText(
//                                       "${state.data[index].orders != null ? state.data[index].orders.sumBy((orders) => orders.quantity) : 0}",
//                                       maxLines: 1,
//                                       style: TextStyle(
//                                           fontWeight: FontWeight.bold,
//                                           color: Colors.white,
//                                           fontSize: 28),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             Container(
//                               child: Column(
//                                 children: state.data[index].orders != null
//                                     ? _itemView(
//                                         context,
//                                         state.data[index].orders,
//                                         state.data[index].tableId,
//                                         state.data[index].tableName)
//                                     : [],
//                               ),
//                             ),
//                           ],
//                         ),
//                       )
//                     : Container();
//               }
//             },
//             itemCount: state.data != null ? state.data.length : 0,
//           );
//         } else {
//           return Container();
//         }
//       },
//     );
//   }
//
//   List<Widget> _itemView(BuildContext context, List<OrdersModel> orders,
//       String tableId, String tableName) {
//     return new List<Widget>.generate(orders != null ? orders.length : 0,
//         (index) {
//       if (orders != null) {
//         if (orders[index].isComplete != null && !orders[index].isComplete) {
//           return GestureDetector(
//             onTap: () {
//               AwesomeDialog(
//                 context: context,
//                 dismissOnTouchOutside: true,
//                 animType: AnimType.SCALE,
//                 dialogType: DialogType.QUESTION,
//                 body: Column(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Center(
//                       child: Container(
//                         width: MediaQuery.of(context).size.width * 0.8,
//                         child: Column(
//                           children: [
//                             AutoSizeText(
//                               "Do you want to complete",
//                               maxLines: 3,
//                               style: TextStyle(
//                                   fontSize: 24, fontWeight: FontWeight.bold),
//                             ),
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               crossAxisAlignment: CrossAxisAlignment.center,
//                               children: [
//                                 AutoSizeText(
//                                   "${orders[index].transactionItem}",
//                                   maxLines: 2,
//                                   style: TextStyle(
//                                       fontSize: 26,
//                                       fontWeight: FontWeight.bold,
//                                       color: Colors.red
//                                   ),
//                                 ),
//                                 AutoSizeText(
//                                   " for ",
//                                   maxLines: 2,
//                                   style: TextStyle(
//                                       fontSize: 26,
//                                       fontWeight: FontWeight.bold,
//                                       color: Colors.black
//                                   ),
//                                 ),
//                                 AutoSizeText(
//                                   "$tableName",
//                                   maxLines: 2,
//                                   style: TextStyle(
//                                       fontSize: 26,
//                                       fontWeight: FontWeight.bold,
//                                       color: Colors.red
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             // AutoSizeText(
//                             //   "${orders[index].transactionItem}",
//                             //   maxLines: 2,
//                             //   style: TextStyle(
//                             //       fontSize: 26, fontWeight: FontWeight.bold),
//                             // ),
//                           ],
//                         ),
//                       ),
//                     ),
//                     NumericStepButton(
//                       maxValue: orders[index].quantity,
//                       onChanged: (value) {
//                         itemComplete = value;
//                       },
//                     ),
//                   ],
//                 ),
//                 btnOk: SizedBox(
//                   height: 60,
//                   child: RaisedButton(
//                     shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(18.0),
//                         side: BorderSide(color: Colors.green)),
//                     onPressed: () {
//                       localDatabase.processOrder(
//                           orders[index].quantity - itemComplete,
//                           tableId,
//                           orders[index].orderId,
//                           orders[index].isTakeOut,
//                         orders[index].id
//                       );
//                       printTicket(orders[index].transactionItem, tableName,
//                           itemComplete);
//                       ordersByTableBloc
//                           .add(LoadTableEvent(appDatabase: localDatabase));
//                       Navigator.of(context)?.pop();
//                       setState(() {});
//                     },
//                     color: Colors.green,
//                     textColor: Colors.white,
//                     child: Text("OK".toUpperCase(),
//                         style: TextStyle(fontSize: 28)),
//                   ),
//                 ),
//               )..show();
//             },
//             child: Container(
//               color: Colors.white,
//               child: Row(
//                 children: [
//                   Container(
//                     margin: EdgeInsets.all(10),
//                     width: 30,
//                     height: 30,
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       color: orders[index].isTakeOut ? Colors.green : Colors.red,
//                     ),
//                   ),
//                   AutoSizeText(
//                     "${orders[index].quantity}x  ${orders[index].transactionItem}",
//                     style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
//                   ),
//                   Spacer(),
//                   Container(
//                     width: 60.0,
//                     padding: EdgeInsets.only(top: 3.0, right: 4.0),
//                     child: TimerBuilder.periodic(Duration(seconds: 1),
//                         builder: (context) {
//                       return AutoSizeText(
//                         "${DateTime.now().difference(orders[index].orderCreated).inSeconds}",
//                         maxLines: 1,
//                         style: TextStyle(
//                             fontSize: 26, fontWeight: FontWeight.bold),
//                       );
//                     }),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         } else {
//           return Container();
//         }
//       } else {
//         return Container();
//       }
//     });
//   }
//
//   // Future<void> printTicket(
//   //     String orderName, String tableName, int quantity) async {
//   //   String isConnected = await BluetoothThermalPrinter.connectionStatus;
//   //   if (isConnected == "true") {
//   //     if (orderName != null) {
//   //       Ticket ticket = await getTicketReprint(orderName, tableName, quantity);
//   //       await BluetoothThermalPrinter.writeBytes(ticket.bytes);
//   //     }
//   //   }
//   // }
//
//   // Future<Ticket> getTicketReprint(
//   //     String order, String tableNo, int quantity) async {
//   //   CapabilityProfile profile = await CapabilityProfile.load();
//   //   final Ticket ticket = Ticket(PaperSize.mm58, profile);
//   //
//   //   ticket.text("$tableNo",
//   //       styles: PosStyles(
//   //         align: PosAlign.center,
//   //         height: PosTextSize.size2,
//   //         width: PosTextSize.size2,
//   //       ),
//   //       linesAfter: 1
//   //   );
//   //
//   //   ticket.text("${quantity}x $order",
//   //       styles: PosStyles(
//   //         align: PosAlign.center,
//   //         bold: true,
//   //         height: PosTextSize.size1,
//   //         width: PosTextSize.size1,
//   //       ),
//   //       linesAfter: 1
//   //   );
//   //
//   //   ticket.cut();
//   //   return ticket;
//   // }
//
//   Future<void> connectPusher() async {
//     await Pusher.connect();
//     merchantId = await UserSessions.getMerchantId();
//
//     if (merchantId.isNotEmpty) {
//       channelTable = await Pusher.subscribe("my-channel-$merchantId");
//       // channelTable = await Pusher.subscribe("my-channel-72ddacd6-d3a9-4f22-8749-2ae3ff3c4414");
//       await channelTable.bind("my-event", (x) {
//         if (mounted)
//           setState(() {
//             lastEvent = x;
//             final newOrder = PusherResponse.fromJson(jsonDecode(x.data));
//             print("TABLE : ${jsonDecode(x.data)}");
//             for (PusherOrders pusherOrders in newOrder.message.orders) {
//               localDatabase.insertItemOrders(
//                   pusherOrders.id,
//                   newOrder.message.tableId,
//                   pusherOrders.transactionItem,
//                   int.parse(pusherOrders.quantity),
//                   false,
//                   pusherOrders.dineIn);
//             }
//             showAlertDialog(PusherResponse.fromJson(jsonDecode(x.data)));
//           });
//       });
//     }
//   }
//
//   showAlertDialog(PusherResponse newOrder) async {
//     await advancedPlayer.release();
//     await advancedPlayer.setReleaseMode(ReleaseMode.LOOP);
//     advancedPlayer.play(await audioCache.getAbsoluteUrl('mp3/alarming.mp3'),
//         isLocal: true);
//     return AwesomeDialog(
//       context: context,
//       dismissOnTouchOutside: false,
//       animType: AnimType.SCALE,
//       dialogType: newOrder.message.status == 'orders'
//           ? DialogType.INFO
//           : DialogType.ERROR,
//       body: Column(
//         children: [
//           SizedBox(height: 10),
//           Column(
//             children: _createItems(newOrder.message, context),
//           ),
//         ],
//       ),
//       btnOk: SizedBox(
//         height: 50,
//         child: RaisedButton(
//           shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(18.0),
//               side: BorderSide(color: Colors.green)),
//           onPressed: () async {
//             await advancedPlayer.release();
//             Navigator.of(context)?.pop();
//             ordersByTableBloc.add(LoadTableEvent(appDatabase: localDatabase));
//             setState(() {});
//             // _ordersByItemBloc.add(LoadItemEvent(appDatabase: appDatabase));
//             // _ordersByTableBloc.add(LoadTableEvent(appDatabase: appDatabase));
//           },
//           color: Colors.green,
//           textColor: Colors.white,
//           child: Text("OK".toUpperCase(), style: TextStyle(fontSize: 14)),
//         ),
//       ),
//       // btnOkOnPress: () async {
//       //   await advancedPlayer.release();
//       // },
//     )..show();
//   }
//
//   List<Widget> _createItems(Message items, BuildContext context) {
//     return new List<Widget>.generate(items.orders.length, (int index) {
//       return Row(
//         children: [
//           SizedBox(
//             width: 30,
//           ),
//           AutoSizeText(
//             "${items.orders[index].quantity}x",
//             maxLines: 1,
//             style: TextStyle(
//               fontWeight: FontWeight.bold,
//               fontSize: 24,
//             ),
//           ),
//           SizedBox(
//             width: 30,
//           ),
//           AutoSizeText(
//             "${items.orders[index].transactionItem}",
//             maxLines: 1,
//             style: TextStyle(
//               fontWeight: FontWeight.bold,
//               fontSize: 24,
//             ),
//           ),
//           SizedBox(
//             width: 20,
//           ),
//         ],
//       );
//     });
//   }
// }
