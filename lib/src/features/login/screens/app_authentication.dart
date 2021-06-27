import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pusher/pusher.dart';
import 'package:outerboxkitchen/src/features/dashboard/screens/dashboard_page.dart';
import 'package:outerboxkitchen/src/features/login/screens/login_pincode.dart';
import 'package:outerboxkitchen/src/features/login/screens/login_screen.dart';
import 'package:outerboxkitchen/src/models/current_user.dart';
import 'package:outerboxkitchen/src/utils/constants.dart';
import 'package:outerboxkitchen/src/utils/user_sessions.dart';

import 'login_email_screen.dart';

class AppAuthentication extends StatefulWidget {
  const AppAuthentication({Key key}) : super(key: key);

  @override
  _AppAuthenticationState createState() => _AppAuthenticationState();
}

class _AppAuthenticationState extends State<AppAuthentication> {
  Future _session;

  @override
  void initState() {
    _session = UserSessions.getBearerToken();
    //initPusher();
    super.initState();
  }

  Future<void> initPusher() async {
    try {
      await Pusher.init(
          KEY,
          PusherOptions(
            cluster: CLUSTER,
          ),
          enableLogging: true);
    } on PlatformException catch (e) {
      print(e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {

          if (snapshot.hasData && snapshot.data != null) {
            //print("Snapshot data => " + snapshot.data);
            //CurrentUser currentUser = snapshot.data;
            return LoginPinCodeScreen();
          } else if (snapshot.hasError && snapshot.error != null) {
            return Center(
              child: Text(snapshot.error),
            );
          } else {
            return LoginEmailScreen();
          }
        },
        future: _session,
      ),
    );
  }
}
