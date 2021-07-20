import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:outerboxkitchen/src/database/database_helper.dart';
import 'package:outerboxkitchen/src/services/stream_api.dart';
import 'package:outerboxkitchen/src/utils/hex_color.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'src/features/login/screens/app_authentication.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  DatabaseHelper().initDatabase();
  await Firebase.initializeApp();
  // SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
  //     statusBarColor: Colors.orange
  // ));
  runApp(MyApp());

}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themes = ThemeData(
      primarySwatch: Colors.blue,
    );

    return  StreamChat(
      streamChatThemeData: StreamChatThemeData.fromTheme(themes).copyWith(
        ownMessageTheme: MessageTheme(
          messageBackgroundColor: Colors.blueAccent,
          messageText: TextStyle(
            color: Colors.white,
          ),
          // avatarTheme: null,
        ),
        otherMessageTheme: MessageTheme(
          messageBackgroundColor: Colors.grey,
          messageText: TextStyle(
            color: Colors.black,
          ),
          // avatarTheme: null,
        ),
      ),
      client: StreamApi.client,
      child: ChannelsBloc(
        child: OverlaySupport(
          child:MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Kitchen App',
            theme: ThemeData(
              primarySwatch: Colors.orange,
              visualDensity: VisualDensity.adaptivePlatformDensity,
            ),
            home: AppAuthentication(),
          ),
        ),
      ),
    );
  }
}