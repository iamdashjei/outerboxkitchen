// import 'dart:async';
// import 'dart:developer' as developer;
//
// import 'package:bloc/bloc.dart';
// import 'package:equatable/equatable.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:kitchen_monitoring/src/database/database.dart';
// import 'package:kitchen_monitoring/src/models/table_with_orders_model.dart';
//
// part 'orders_by_table_event.dart';
// part 'orders_by_table_state.dart';
//
// class OrdersByTableBloc extends Bloc<OrdersByTableEvent, OrdersByTableState> {
//   OrdersByTableBloc() : super();
//
//   @override
//   Stream<OrdersByTableState> mapEventToState(OrdersByTableEvent event,) async* {
//     try {
//       yield* event.applySync(currentState: state, bloc: this);
//     } catch (_, stackTrace) {
//       developer.log('$_', name: 'TableBloc', error: _, stackTrace: stackTrace);
//       yield state;
//     }
//   }
//
//   @override
//   OrdersByTableState get initialState => OrdersByTableInitialState();
// }
