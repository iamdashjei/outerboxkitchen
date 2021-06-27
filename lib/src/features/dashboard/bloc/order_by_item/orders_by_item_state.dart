// part of 'orders_by_item_bloc.dart';
//
// abstract class OrdersByItemState extends Equatable {
//   final List propss;
//   const OrdersByItemState(this.propss);
//
//   @override
//   List<Object> get props => (propss ?? []);
//
// }
//
// class OrdersByItemInitialState extends OrdersByItemState {
//   OrdersByItemInitialState() : super([]);
//
//   @override
//   String toString() => 'OrdersByTableInitial';
// }
//
// class OrdersByItemLoadingState extends OrdersByItemState {
//   OrdersByItemLoadingState() : super([]);
//
//   @override
//   String toString() => 'OrdersByItemLoadingState';
// }
//
// class OrdersByItemRefreshingState extends OrdersByItemState {
//   OrdersByItemRefreshingState() : super([]);
//
//   @override
//   String toString() => 'OrdersByItemRefreshingState';
// }
//
// class OrdersByItemErrorState extends OrdersByItemState {
//   final String errorMessage;
//   OrdersByItemErrorState(this.errorMessage) : super([errorMessage]);
//
//   @override
//   String toString() => 'OrdersByItemErrorState';
// }
//
// class OrdersByItemLoadedState extends OrdersByItemState {
//   final List<ItemWithTableModel> data;
//   OrdersByItemLoadedState({this.data}) : super([data]);
//
//   OrdersByItemLoadedState copyWith({
//     List<ItemWithTableModel> data ,
//   }) {
//     return OrdersByItemLoadedState(data: data ?? this.data,);
//   }
// }