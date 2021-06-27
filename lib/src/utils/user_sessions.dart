import 'package:flutter/material.dart';
import 'package:outerboxkitchen/src/database/database_helper.dart';
import 'package:outerboxkitchen/src/features/dashboard/widgets/printer.dart';
import 'package:outerboxkitchen/src/models/business_info.dart';
import 'package:outerboxkitchen/src/models/current_user.dart';
import 'package:outerboxkitchen/src/models/headoffice_details.dart';
import 'package:outerboxkitchen/src/models/store_details.dart';
import 'package:outerboxkitchen/src/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserSessions {
  static Future<CurrentUser> getLoggedIn() async {
    SharedPreferences _prefs = await _sharedPreference();
    final status = _prefs.getString(loggedIn);
    final username = _prefs.getString(USERNAME);
    final userAvatar = _prefs.getString(USER_AVATAR);
    CurrentUser user = new CurrentUser();
    user.username = username;
    user.status = status;
    user.userAvatar = userAvatar;

    //print("Current User => " + user.status);
    return user;
  }

  static Future<String> getBearerToken() async {
    SharedPreferences _prefs = await _sharedPreference();
    return _prefs.getString(bearerToken);
  }

  static setBearerToken(String bearer) async {
    SharedPreferences _prefs = await _sharedPreference();
    return _prefs.setString(bearerToken, "Bearer $bearer");
  }

  static setMerchantId(String merchantId) async {
    SharedPreferences _prefs = await _sharedPreference();
    return _prefs.setString(MERCHANT_ID, merchantId);
  }

  static setUsername(String username) async {
    SharedPreferences _prefs = await _sharedPreference();
    return _prefs.setString(USERNAME, username);
  }

  static Future<String> getUsername() async {
    SharedPreferences _prefs = await _sharedPreference();
    return _prefs.getString(USERNAME);
  }

  static setUserAvatar(String avatar) async {
    SharedPreferences _prefs = await _sharedPreference();
    // return _prefs.setString(USER_AVATAR, "https://outerboxpos.com/img/business/$avatar");
    return _prefs.setString(USER_AVATAR, "http://posweb.outerbox.net/img/$avatar");
  }

  static Future<String> getUserAvatar() async {
    SharedPreferences _prefs = await _sharedPreference();
    return _prefs.getString(USER_AVATAR);
  }

  static Future<String> getMerchantId() async {
    SharedPreferences _prefs = await _sharedPreference();
    return _prefs.getString(MERCHANT_ID);
  }

  static setLoggedIn() async {
    SharedPreferences _prefs = await _sharedPreference();
    _prefs.setString(loggedIn, 'Login');
  }

  static setFirstAPICall() async {
    SharedPreferences _prefs = await _sharedPreference();
    _prefs.setBool(firstCall, true);
  }

  static setPrinterConnected() async {
    SharedPreferences _prefs = await _sharedPreference();
    _prefs.setBool("PrinterConnected", true);
  }

  static Future<bool> getPrinterConnected() async {
    SharedPreferences _prefs = await _sharedPreference();
    final status = _prefs.getBool("PrinterConnected");
    return status;
  }

  static Future<bool> getFirstAPICall() async {
    SharedPreferences _prefs = await _sharedPreference();
    final status = _prefs.getBool(firstCall);
    return status;
  }

  // static logout() async {
  //   SharedPreferences _prefs = await _sharedPreference();
  //   _prefs.setBool(loggedIn, false);
  // }

  static setLoggedOut() async {
    await Printer().printTicketReports();
    SharedPreferences _prefs = await _sharedPreference();

    await _prefs.setString(loggedIn, '');
    await setBearerToken('');
    await setMerchantId('');
    await savePinCode('');
    await DatabaseHelper().deleteDatabaseLogout();
    //await _prefs.clear();
  }

  static setBluetoothDevice(String mac) async {
    SharedPreferences _prefs = await _sharedPreference();
    _prefs.setString("btDevice", mac);
  }

  static Future<String> getBluetoothDevice() async {
    SharedPreferences _prefs = await _sharedPreference();
    final status = _prefs.getString("btDevice");
    return status;
  }

  static Future<SharedPreferences> _sharedPreference() async {
    return SharedPreferences.getInstance();
  }

  static Future<int> getLastLogoutTime() async {
    SharedPreferences _prefs = await _sharedPreference();
    final status = _prefs.getInt(lastLogoutTime);
    return status;
  }

  static savePinCode(String key) async {
    SharedPreferences _prefs = await _sharedPreference();
    _prefs.setString("key", '$key');
  }

  static Future<String> getPinCode() async {
    SharedPreferences _prefs = await _sharedPreference();
    return _prefs.getString("key") ?? '';
  }

  static Future<bool> isCompletedList() async {
    SharedPreferences _prefs = await _sharedPreference();
    final status = _prefs.getBool("completed") ?? false;
    return status;
  }

  static setCompletedList({@required bool isCompleted}) async {
    SharedPreferences _prefs = await _sharedPreference();
    _prefs.setBool("completed", isCompleted);
  }

  static saveRecentUsers(List<String> key) async {
    SharedPreferences _prefs = await _sharedPreference();
    _prefs.setStringList("recentUsers", key);
  }

  static Future<List<String>> getRecentUsers() async {
    SharedPreferences _prefs = await _sharedPreference();
    return _prefs.getStringList("recentUsers") ?? [];
  }

  static saveLastLogin(String key) async {
    SharedPreferences _prefs = await _sharedPreference();
    _prefs.setString("loginDate", '$key');
  }

  static Future<String> getLastLogin() async {
    SharedPreferences _prefs = await _sharedPreference();
    return _prefs.getString("loginDate") ?? '';
  }

  static saveKitchenDetails(String kitchenUserName, String merchantId) async {
    SharedPreferences _prefs = await _sharedPreference();
    _prefs.setString("kitchenDetails", '$kitchenUserName,$merchantId');
  }

  static Future<BusinessInfo> getKitchenDetails() async {
    SharedPreferences _prefs = await _sharedPreference();
    StoreDetails data = await DatabaseHelper().getStoreDetails();
    HeadOfficeDetails image = await DatabaseHelper().getHeadOfficeDetails();
    BusinessInfo info = new BusinessInfo();
    info.cashierName = _prefs.getString("kitchenDetails").split(',')[0] ?? '';
    info.businessName = data.businessName;
    info.businessLogo = 'https://$PROD_URL/img/business/${image.businessIcon}';
    info.merchantId = _prefs.getString("kitchenDetails").split(',')[1] ?? '';
    info.salesId = "none";
    info.accountType = data.accountType;
    return info;
  }

  static savePrinterID(String key) async {
    SharedPreferences _prefs = await _sharedPreference();
    _prefs.setString("printerId", '$key');
  }

  static Future<String> getPrinterID() async {
    SharedPreferences _prefs = await _sharedPreference();
    return _prefs.getString("printerId") ?? '';
  }



}