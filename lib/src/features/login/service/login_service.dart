import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart';
import 'package:outerboxkitchen/src/database/database_helper.dart';
import 'package:outerboxkitchen/src/features/login/models/token.dart';
import 'package:outerboxkitchen/src/features/login/models/user_model.dart';
import 'package:outerboxkitchen/src/models/FirebaseUser.dart';
import 'package:outerboxkitchen/src/models/headoffice_details.dart';
import 'package:outerboxkitchen/src/models/orders_by_table.dart';
import 'package:outerboxkitchen/src/models/received_message_model.dart';
import 'package:outerboxkitchen/src/models/resource.dart';
import 'package:outerboxkitchen/src/services/api_provider.dart';
import 'package:outerboxkitchen/src/services/push_notif_manager.dart';
import 'package:outerboxkitchen/src/services/stream_user_api.dart';
import 'package:outerboxkitchen/src/utils/constants.dart';
import 'package:outerboxkitchen/src/utils/save_image.dart';
import 'package:outerboxkitchen/src/utils/user_sessions.dart';
import 'package:http/http.dart' as http;
import 'package:rxdart/rxdart.dart';

class LoginService {

  // ignore: close_sinks
  final BehaviorSubject<ReceivedNotificationModel> didReceiveLocalNotificationSubject =
  BehaviorSubject<ReceivedNotificationModel>();

  // ignore: close_sinks
  final BehaviorSubject<String> selectNotificationSubject =
  BehaviorSubject<String>();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
  NotificationAppLaunchDetails notificationAppLaunchDetails;

  static Future<String> logIn({
    @required String email,
    @required String password,
  }) async {
    try {
      DatabaseReference usersReference = FirebaseDatabase.instance.reference().child("users");
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      Token token = await LoginService.getToken(email: email, password: password);

      if(token != null){
        //print(token.toJson());
        //print(token.toJson());
        //Session.setVerified(isVerified: true);

        Resource resource = await LoginService.getResources(deviceId: androidInfo.androidId, token: token.accessToken);

        if(resource.staffDetails != null){
          UserSessions.saveEmail(email);
          UserSessions.savePassword(password);
          UserSessions.saveAdminUID(resource.staffDetails.id);
          UserSessions.setMerchantId(resource.staffDetails.merchantId);
          UserSessions.saveCommissaryId(resource.staffDetails.commissaryId);
          UserSessions.saveClusterId(resource.staffDetails.clusterId);

          TransactionResult transactionResult = await usersReference.child(resource.staffDetails.id).runTransaction((MutableData mutableData) async {
            return mutableData;
          });


          if(transactionResult.dataSnapshot.value != null){
            FirebaseUser firebaseUser = new FirebaseUser();
            firebaseUser.uid = resource.staffDetails.id;
            firebaseUser.name = resource.staffDetails.fName + " " + resource.staffDetails.lName;
            firebaseUser.status = "Active";
            firebaseUser.email = email;
            firebaseUser.avatar = "";
            firebaseUser.pin = password;
            firebaseUser.loginName = resource.staffDetails.fName + " " + resource.staffDetails.lName;
            firebaseUser.lastActiveAt = DateTime.now().millisecondsSinceEpoch;
            firebaseUser.type = resource.staffDetails.role;
            usersReference.child(resource.staffDetails.id).update(firebaseUser.toJson());
            UserSessions.saveAdminRole(resource.staffDetails.role);
          } else {
            Map<String, dynamic> childUpdate = new HashMap<String, dynamic>();
            FirebaseUser firebaseUser = new FirebaseUser();
            firebaseUser.uid = resource.staffDetails.id;
            firebaseUser.name = resource.staffDetails.fName + " " + resource.staffDetails.lName;
            firebaseUser.status = "Active";
            firebaseUser.email = email;
            firebaseUser.avatar = "";
            firebaseUser.pin = password;
            firebaseUser.loginName = resource.staffDetails.fName + " " + resource.staffDetails.lName;
            firebaseUser.lastActiveAt = DateTime.now().millisecondsSinceEpoch;
            firebaseUser.type = resource.staffDetails.role;
            childUpdate.putIfAbsent(resource.staffDetails.id, () => firebaseUser.toJson());
            usersReference.update(childUpdate);
            UserSessions.saveAdminRole(resource.staffDetails.role);
          }
          UserSessions.saveKitchenDetails(resource.staffDetails.fName + " " + resource.staffDetails.lName, resource.staffDetails.merchantId);
        }
        if(resource.headOfficeDetails != null){
          HeadOfficeDetails headOfficeDetails = resource.headOfficeDetails;
          headOfficeDetails.businessIconBlob = await SaveImage().urlToFile('https://pos.outerboxcloud.com/img/business/${resource.headOfficeDetails.businessIcon}');
          DatabaseHelper().insertHeadOffice(officeDetails: headOfficeDetails);
        }
        if(resource.storeDetails != null){
          UserSessions.setMerchantId(resource.storeDetails.id);
          DatabaseHelper().insertStoreDetails(storeDetails: resource.storeDetails);
        }


        UserSessions.saveLastLogin(DateTime.now().toUtc().toString());
        UserSessions.setBearerToken(token.accessToken);
        UserSessions.savePinCode(password);
        UserSessions.setLoggedIn();
        PushNotificationsManager().init();
        // LoginService().loginChat();
        LoginService().initPlatformSpecifics();
        return "Success";
      } else {
        return "Invalid";
      }

    } on SocketException catch (_) {
      print("Socket Exception");
      //Session.setVerified(isVerified: false);
      //throw LoginFailure();
      return "Error";
    } on TimeoutException catch (_){
      print("Socket Timeout");
      return "Error";
    }
  }

  static Future<Token> getToken({@required String email, @required String password}) async {
    String url = "/oauth/token";
    try {
      Response response = await ApiProvider.login(url, email, password);
      if (response.statusCode == 200) {
        return Token.fromJson(jsonDecode(response.body));
        // if (jsonEncode(response.body).contains("true")) {
        //   UserModel user = UserModel.fromJson(jsonDecode(response.body));
        //   UserSessions.setUsername("${user.user.fname} ${user.user.lname}");
        //   UserSessions.setUserAvatar("${user.user.thumbnail}");
        //   return user;
        // } else {
        //   return throw Exception("Invalid email/password");
        // }
      } else if (response.statusCode == 400 || response.statusCode == 401) {
        return throw Exception("Invalid email/password");
      } else {
        return throw Exception(SOMETHING_WENT_WRONG);
      }
    } catch (error) {
      return throw Exception(error);
    }
  }
  // static Future<List<OrdersByTable>> getData({@required String merchantId, @required String token}) async {
  //   String url = "/api/login";
  //   try {
  //     List<OrdersByTable> _ordersByTableList = [];
  //     Response response = await ApiProvider.get(
  //         "$PROD_URL/api/tables/$merchantId", token);
  //     if (response.statusCode == 200) {
  //       List<dynamic> values = [];
  //       values = json.decode(response.body);
  //       for (int i = 0; i < values.length; i++) {
  //         Map<String, dynamic> map = values[i];
  //         OrdersByTable ordersByTable = OrdersByTable.fromJson(map);
  //         _ordersByTableList.add(ordersByTable);
  //       }
  //       return _ordersByTableList;
  //     } else {
  //       return throw Exception(SOMETHING_WENT_WRONG);
  //     }
  //   } catch (error) {
  //     return throw Exception(error);
  //   }
  // }

  static Future<Resource> getResources({@required String deviceId, @required String token}) async {
     // String url = "francos.store";
    String url = "pos.outerboxcloud.com";
    final resourcesRequest = Uri.https(url, '/api/resources');
    final resourceResponse = await http.get(resourcesRequest, headers: {
      HttpHeaders.authorizationHeader:'Bearer $token',
      'device': deviceId
    });
    if (resourceResponse.statusCode == 401) {
      throw Exception('Unauthorized');
    }
    if (resourceResponse.statusCode != 200) {
      throw Exception('Request failed');
    }
    return Resource.fromJson(jsonDecode(resourceResponse.body));
  }

  loginChat() async {
    await UserSessions.getKitchenDetails().then((value) async {
      await StreamUserApi.login(idUser: value.uid,
          fullName: value.cashierName,
          avatar: "",
          merchantId: value.merchantId,
          headOfficeId: value.headOfficeId,
          commissaryId: value.commissaryId,
          clusterId: value.clusterId,
          type: value.accountType,
          uid: value.uid);
      //createChannelWithUsers(info.uid, info.accountType, info.commissaryId, info.clusterId, info.headOfficeId, info.cashierName);
    });
  }

  void initPlatformSpecifics() async{
    notificationAppLaunchDetails =
    await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
    await initNotifications(flutterLocalNotificationsPlugin);

  }

  Future<void> initNotifications(FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
    var initializationSettingsAndroid = AndroidInitializationSettings('ic_launcher');
    var initializationSettingsIOS = IOSInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
        onDidReceiveLocalNotification:
            (int id, String title, String body, String payload) async {
          didReceiveLocalNotificationSubject.add(ReceivedNotificationModel(
              id: id, title: title, body: body, payload: payload));
        });
    var initializationSettings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (String payload) async {
          if (payload != null) {
            // debugPrint('notification payload: ' + payload);
          }
          selectNotificationSubject.add(payload);
        });
  }

}