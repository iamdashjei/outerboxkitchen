import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';
import 'package:outerboxkitchen/src/database/database_helper.dart';
import 'package:outerboxkitchen/src/features/login/models/token.dart';
import 'package:outerboxkitchen/src/features/login/models/user_model.dart';
import 'package:outerboxkitchen/src/models/headoffice_details.dart';
import 'package:outerboxkitchen/src/models/orders_by_table.dart';
import 'package:outerboxkitchen/src/models/resource.dart';
import 'package:outerboxkitchen/src/services/api_provider.dart';
import 'package:outerboxkitchen/src/utils/constants.dart';
import 'package:outerboxkitchen/src/utils/save_image.dart';
import 'package:outerboxkitchen/src/utils/user_sessions.dart';
import 'package:http/http.dart' as http;

class LoginService {

  static Future<String> logIn({
    @required String email,
    @required String password,
  }) async {
    try {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      Token token = await LoginService.getToken(email: email, password: password);

      if(token != null){
        //print(token.toJson());
        //print(token.toJson());
        //Session.setVerified(isVerified: true);

        Resource resource = await LoginService.getResources(deviceId: androidInfo.androidId, token: token.accessToken);

        if(resource.staffDetails != null){

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

}