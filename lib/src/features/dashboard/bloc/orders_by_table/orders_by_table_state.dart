// part of 'orders_by_table_bloc.dart';
//
//
// abstract class OrdersByTableState extends Equatable {
//   final List propss;
//   const OrdersByTableState(this.propss);
//
//   @override
//   List<Object> get props => (propss ?? []);
// }
//
// class OrdersByTableInitialState extends OrdersByTableState {
//   OrdersByTableInitialState() : super([]);
//
//   @override
//   String toString() => 'OrdersByTableInitial';
// }
//
// class OrdersByTableLoadingState extends OrdersByTableState {
//   OrdersByTableLoadingState() : super([]);
//
//   @override
//   String toString() => 'OrdersByTableLoadingState';
// }
//
// class OrdersByTableRefreshingState extends OrdersByTableState {
//   OrdersByTableRefreshingState() : super([]);
//
//   @override
//   String toString() => 'OrdersByTableRefreshingState';
// }
//
// class OrdersByTableErrorState extends OrdersByTableState {
//   final String errorMessage;
//   OrdersByTableErrorState(this.errorMessage) : super([errorMessage]);
//
//   @override
//   String toString() => 'OrdersByTableErrorState';
// }
//
// class OrdersByTableLoadedState extends OrdersByTableState {
//   final List<TableWithOrdersModel> data;
//   OrdersByTableLoadedState({this.data}) : super([data]);
//
//   OrdersByTableLoadedState copyWith({
//     List<TableWithOrdersModel> data ,
//   }) {
//     return OrdersByTableLoadedState(data: data ?? this.data,);
//   }
// }