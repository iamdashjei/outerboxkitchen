// import 'dart:async';
// import 'dart:developer' as developer;
//
// import 'package:bloc/bloc.dart';
// import 'package:equatable/equatable.dart';
// import 'package:kitchen_monitoring/src/database/database.dart';
// import 'package:kitchen_monitoring/src/models/item_with_table_model.dart';
//
// part 'orders_by_item_event.dart';
// part 'orders_by_item_state.dart';
//
// class OrdersByItemBloc extends Bloc<OrdersByItemEvent, OrdersByItemState> {
//   OrdersByItemBloc() : super();
//
//   @override
//   Stream<OrdersByItemState> mapEventToState(
//     OrdersByItemEvent event,
//   ) async* {
//     try {
//       yield* event.applySync(currentState: state, bloc: this);
//     } catch (_, stackTrace) {
//       developer.log('$_', name: 'TableBloc', error: _, stackTrace: stackTrace);
//       yield state;
//     }
//   }
//
//   @override
//   OrdersByItemState get initialState => OrdersByItemInitialState();
// }
