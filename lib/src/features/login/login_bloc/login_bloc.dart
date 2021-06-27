import 'dart:async';
import 'dart:developer' as developer;

import 'package:bloc/bloc.dart';
import 'package:device_info/device_info.dart';
import 'package:equatable/equatable.dart';
import 'package:outerboxkitchen/src/database/database.dart';
import 'package:outerboxkitchen/src/features/login/models/token.dart';
import 'package:outerboxkitchen/src/features/login/models/user_model.dart';
import 'package:outerboxkitchen/src/features/login/service/login_service.dart';
import 'package:outerboxkitchen/src/features/login/widgets/app_text_field.dart';
import 'package:outerboxkitchen/src/models/orders_by_table.dart';
import 'package:outerboxkitchen/src/models/resource.dart';
import 'package:outerboxkitchen/src/utils/constants.dart';
import 'package:outerboxkitchen/src/utils/user_sessions.dart';
import 'package:meta/meta.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final TextFieldType type;
  LoginBloc({this.type}) : super();

  @override
  Stream<LoginState> mapEventToState(
    LoginEvent event,
  ) async* {
    try {
      yield* event.applyAsync(currentState: state, bloc: this);
    } catch (_, stackTrace) {
      developer.log('$_', name: 'LoginBloc', error: _, stackTrace: stackTrace);
      yield state;
    }
  }

  @override
  LoginState get initialState => LoginDefaultState();

}
