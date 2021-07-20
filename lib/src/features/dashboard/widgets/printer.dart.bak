import 'package:blue_thermal_printer/blue_thermal_printer.dart' as ble;
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:bluetooth_thermal_printer/bluetooth_thermal_printer.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter_blue/flutter_blue.dart' as fb;
import 'package:intl/intl.dart';
import 'package:outerboxkitchen/src/database/database_helper.dart';
import 'package:outerboxkitchen/src/features/login/models/user_model.dart';
import 'package:outerboxkitchen/src/models/business_info.dart';
import 'package:outerboxkitchen/src/models/headoffice_details.dart';
import 'package:outerboxkitchen/src/models/product_reports.dart';
import 'package:outerboxkitchen/src/models/store_details.dart';
import 'package:outerboxkitchen/src/utils/user_sessions.dart';
import 'package:image/image.dart' as img;


class Printer {

  Printer._();
  factory Printer() => _instance;
  static final Printer _instance = Printer._();

  bool connected = false;
  List availableBluetoothDevices = [];
  List<String> macID = [];
  List<String> macIDCopy = [];

  var subscription;

  ble.BlueThermalPrinter bluetooth = ble.BlueThermalPrinter.instance;

  Future<bool> connectPrinterAutomatic() async {
    bool result = false;
    String isConnected = await BluetoothThermalPrinter.connectionStatus;
    List blueTooths = await BluetoothThermalPrinter.getBluetooths;
    //print("Print $bluetooths");


    if(isConnected == "true"){
      //print("printer connected");
      result = true;
    } else {
      if(blueTooths.length == 0){
        result = false;
      } else {
        if(blueTooths.length > 0){
          for(int i = 0; i < blueTooths.length; i++){
            String select = blueTooths[i].toString();
            String lowerCaseSelect = select.toLowerCase();
            //print(select);
            if(lowerCaseSelect.contains("printer") || lowerCaseSelect.contains("rpp")){
              List list = select.split("#");
              String mac = list[1];
              //print("Mac => " + mac);
              bool status = await setConnect(mac);
              if(status){
                result = true;
              }
            }

          }
        }
      }

    }

    return result;
  }

  Future<bool> getBluetooth() async {
    String isConnected = await BluetoothThermalPrinter.connectionStatus;
    List blueTooths = await BluetoothThermalPrinter.getBluetooths;
    //print("Print $bluetooths");
    availableBluetoothDevices = blueTooths;

    if(isConnected == "true"){
      //print("printer connected");
      return true;
    } else {
      if(availableBluetoothDevices.length == 0){
        connected = false;
        return false;
      } else {

        if(availableBluetoothDevices.length > 0){
          for(int i = 0; i < availableBluetoothDevices.length; i++){
            String select = availableBluetoothDevices[i];
            String lowerCaseSelect = select.toLowerCase();
            //print(select);
            if(lowerCaseSelect.contains("printer") || lowerCaseSelect.contains("rpp")){
              List list = select.split("#");
              String mac = list[1];
              //print("Mac => " + mac);
              bool status = await setConnect(mac);
              if(status){
                return true;
              } else {
                return false;
              }
            }

          }
        }
      }

    }


    return false;
  }

  Future<bool> connectionStatus() async {
    // String printerID = await UserSessions.getPrinterID();
    // List blueTooths = await BluetoothThermalPrinter.getBluetooths;
    // availableBluetoothDevices = blueTooths;
    //
    // for(dynamic bleString in availableBluetoothDevices){
    //   macIDCopy.add(bleString.toString());
    // }
    //
    // // Start scanning
    // flutterBlue.startScan(timeout: Duration(seconds: 4));
    //
    // // Listen to scan results
    // subscription = flutterBlue.scanResults.listen((results) {
    //   // do something with scan results
    //   for (fb.ScanResult r in results) {
    //
    //     if(r.device.name.toLowerCase().contains("printer")){
    //       String select = r.device.name + "#" + r.device.id.id;
    //
    //       macID.add(r.device.name + "#" + r.device.id.id);
    //
    //     }
    //
    //     //print('${r.device.name} found! rssi: ${r.rssi}');
    //     // print(r.device.name +"#"+ r.device.id.id);
    //   }
    // });
    //
    // // Stop scanning
    // flutterBlue.stopScan();
    //
    // macID = macID.toSet().toList();
    //
    // for(String macString in macID){
    //   if(macIDCopy.contains(macString)){
    //     List list = macString.split("#");
    //     String mac = list[1];
    //     setConnect(mac).then((value) {
    //       print("RESULT VALUE => " + value.toString());
    //       if(value){
    //         return true;
    //       } else {
    //         return false;
    //       }
    //     });
    //   }
    // }

    // if(printerID != ''){
    //   print("HAS VALUE PRINTER ID => " + printerID);
    //
    //
    //   // Start scanning
    //   flutterBlue.startScan(timeout: Duration(seconds: 4));
    //
    //   // Listen to scan results
    //   subscription = flutterBlue.scanResults.listen((results) {
    //     // do something with scan results
    //     for (fb.ScanResult r in results) {
    //
    //       if(r.device.name.toLowerCase().contains("printer")){
    //         macID.add(r.device.id.id);
    //       }
    //
    //       //print('${r.device.name} found! rssi: ${r.rssi}');
    //      // print(r.device.name +"#"+ r.device.id.id);
    //     }
    //   });
    //
    //
    //
    //   // Stop scanning
    //   flutterBlue.stopScan();
    //
    //   macID = macID.toSet().toList();
    //
    //   print(macID.length.toString());
    //   if(macID.length > 0){
    //
    //     if(macID.contains(printerID)){
    //       print("PROCEEDING WITH EXISTING PRINTER");
    //
    //       return true;
    //
    //     } else {
    //       UserSessions.savePrinterID('');
    //       print("YOU NEED TO PAIR ANOTHER PRINTER DEVICE");
    //       for(String mac in macID){
    //
    //       }
    //       // Start scanning
    //       // flutterBlue.startScan(timeout: Duration(seconds: 4));
    //       //
    //       // // Listen to scan results
    //       // subscription = flutterBlue.scanResults.listen((results) async {
    //       //   macID = [];
    //       //   // do something with scan results
    //       //   for (fb.ScanResult r in results) {
    //       //     String selects = r.device.name +"#"+ r.device.id.id;
    //       //     String lowerCaseSelect = selects.toLowerCase();
    //       //     if(lowerCaseSelect.contains("printer") || lowerCaseSelect.contains("rpp")){
    //       //       await setConnect(r.device.id.id).then((value) {
    //       //         if(value){
    //       //           UserSessions.savePrinterID(selects);
    //       //           return true;
    //       //         } else {
    //       //           UserSessions.savePrinterID('');
    //       //           return false;
    //       //         }
    //       //       });
    //       //     } else {
    //       //       return false;
    //       //     }
    //       //   }
    //       //
    //       //   //macID.add(r.device.name +"#"+ r.device.id.id);
    //       //   //print('${r.device.name} found! rssi: ${r.rssi}');
    //       //   //print(r.device.name +"#"+ r.device.id.id);
    //       //
    //       //
    //       //   }
    //       // );
    //       //
    //       // // Stop scanning
    //       // flutterBlue.stopScan();
    //
    //     }
    //
    //   } else {
    //     return false;
    //   }
    //
    //
    // } else {
    //   print("NO VALUE FOR PRINTER ID");
    //
    //
    //   // Start scanning
    //   flutterBlue.startScan(timeout: Duration(seconds: 4));
    //
    //   // Listen to scan results
    //   subscription = flutterBlue.scanResults.listen((results) {
    //     // do something with scan results
    //     for (fb.ScanResult r in results) {
    //       //print(r.device.name +"#"+ r.device.id.id);
    //       if(r.device.name.toLowerCase().contains("printer")){
    //         macIDCopy.add(r.device.id.id);
    //
    //
    //         //print("TRUE");
    //         //print(r.device.name +"#"+ r.device.id.id);
    //         //print(r.device.id);
    //         //String selects = r.device.name +"#"+ r.device.id.id;
    //         //String result = await BluetoothThermalPrinter.connect(r.device.id.toString());
    //         //print(result);
    //         // await setConnect(r.device.id.toString()).then((value) {
    //         //   if(value){
    //         //     UserSessions.savePrinterID(selects);
    //         //     return true;
    //         //   }
    //         // });
    //       }
    //
    //     }
    //
    //       //macID.add(r.device.name +"#"+ r.device.id.id);
    //       //print('${r.device.name} found! rssi: ${r.rssi}');
    //       //print(r.device.name +"#"+ r.device.id.id);
    //
    //
    //     }
    //   );
    //
    //   macIDCopy = macIDCopy.toSet().toList();
    //
    //   for(String mac in macIDCopy){
    //     bool result = await setConnect(mac);
    //     print("RESULT VALUE => " + result.toString());
    //    // break;
    //   }
    //
    //   // Stop scanning
    //   //flutterBlue.stopScan();
    //
    // }
    return false;
  }

  Future<bool> setConnect(String mac) async {
    String result = await BluetoothThermalPrinter.connect(mac);
    //print("state connected $result");
    if (result == "true") {
      return true;
      //connected = true;
    } else {
      return false;
      //connected = false;
    }
  }

  Future<bool> printTicket(String tableName, String quantity, String itemName, String variance, String customerName, String transactionNo) async {
    String isConnected = await BluetoothThermalPrinter.connectionStatus;
    if (isConnected == "true") {
      List<int> bytes = await getTicket(tableName, quantity, itemName, variance, customerName, transactionNo);
      final result = await BluetoothThermalPrinter.writeBytes(bytes);
     // print("Print $result");
      return true;
    } else {
      return false;
      //Hadnle Not Connected Senario
    }
  }



  Future<List<int>> getTicket(String tableName, String quantity, String itemName, String variance, String customerName, String transactionNo) async {
    List<int> bytes = [];
    CapabilityProfile profile = await CapabilityProfile.load();
    final Ticket ticket = Ticket(PaperSize.mm58, profile);
    List<String> multipleVariance = [];


    if(variance.contains(",")){
      multipleVariance = variance.split(",");
    }


    // table name
    ticket.text(tableName,
        styles: PosStyles(
          align: PosAlign.center,
          height: PosTextSize.size3,
          width: PosTextSize.size2,
          bold: true,
        ));

    if(transactionNo != "none"){
      String text1 = transactionNo.substring(3, transactionNo.length);
      ticket.row([
        PosColumn( // Item Name
            text: text1,
            width: 12,
            styles: PosStyles(
              height: PosTextSize.size2, width: PosTextSize.size1, align: PosAlign.center,
            )),
      ]);
    }


    ticket.row([
      PosColumn( // Item Name
          text: customerName,
          width: 12,
          styles: PosStyles(
            height: PosTextSize.size2, width: PosTextSize.size1, align: PosAlign.center,
          )),
    ]);

    if(itemName.length > 25){
      int totalStringLength = itemName.length;
      double halfIndex = totalStringLength / 2;
      int startString = halfIndex.toInt();
      int endString = startString + 1;
      String text1 = itemName.substring(0, startString);
      String text2 = itemName.substring(endString);

      ticket.row([
        // PosColumn(
        //     text: quantity + "x",
        //     width: 6,
        //     styles: PosStyles(
        //       // align: PosAlign.center, bold: true, height: PosTextSize.size1, width: PosTextSize.size1,
        //       bold: true, height: PosTextSize.size2, width: PosTextSize.size1
        //     )),
        PosColumn( // Item Name
            text: quantity + "x " + text1,
            width: 12,
            styles: PosStyles(
              height: PosTextSize.size2, width: PosTextSize.size1, align: PosAlign.center
            )),
      ]);

      ticket.text( // part of item name
          text2,
          styles: PosStyles( height: PosTextSize.size2, width: PosTextSize.size1, align: PosAlign.center));

    } else {
      // Quantity
      ticket.row([
        // PosColumn(
        //     text: quantity + "x",
        //     width: 6,
        //     styles: PosStyles(
        //       // align: PosAlign.center, bold: true, height: PosTextSize.size1, width: PosTextSize.size1,
        //       bold: true, height: PosTextSize.size2, width: PosTextSize.size1
        //     )),
        PosColumn( // Item Name
            text: quantity + "x " + itemName,
            width: 12,
            styles: PosStyles(
              height: PosTextSize.size2, width: PosTextSize.size1, align: PosAlign.center
            )),
      ]);
    }


    if(multipleVariance.length > 0){
      for(int x = 0; x < multipleVariance.length; x++){
        // bytes += generator.text( // part of item name
        //     variance.length > 0 ? variance : " ",
        //     styles: PosStyles(align: PosAlign.center, bold: false));

        ticket.text( // part of item name
            multipleVariance[x].toString(),
            styles: PosStyles(align: PosAlign.center, bold: false));
      }
    } else {

      if(variance != ""){
        ticket.text( // part of item name
            variance,
            styles: PosStyles(align: PosAlign.center, bold: false));
      }

    }




    //bytes += generator.hr(ch: '=', linesAfter: 1);
    ticket.cut();
    return ticket.bytes;
  }

  Future<void> printTicketReports() async {
    String isConnected = await BluetoothThermalPrinter.connectionStatus;


    if (isConnected == "true") {
      List<ProductReports> productReports = await DatabaseHelper().getProductReports();
      if(productReports.length > 0){
        Ticket bytes = await getTicketForReports();
        final result = await BluetoothThermalPrinter.writeBytes(bytes.bytes);
        print("Print $result");
      }

    } else {
      //Hadnle Not Connected Senario
    }
  }


  Future<Ticket> getTicketForReports() async {
    CapabilityProfile profile = await CapabilityProfile.load();
    final Ticket ticket = Ticket(PaperSize.mm58, profile);
    var numberFormat = NumberFormat("#,##0.00", "en_US");

    BusinessInfo kitchenUser = await UserSessions.getKitchenDetails();
    StoreDetails storeDetails = await DatabaseHelper().getStoreDetails();
    HeadOfficeDetails officeDetails = await DatabaseHelper().getHeadOfficeDetails();
    final img.Image image = img.decodeImage(officeDetails.businessIconBlob);
    ticket.image(img.copyResize(image, width: 200));

    String dateIssued = "${new DateFormat('MM/d/y hh:mma').format(DateTime.now().toLocal())}";
    String dateLogin = await UserSessions.getLastLogin();
    String loginParsedDate = "${new DateFormat('MM/d/y hh:mma').format(DateTime.parse(dateLogin).toLocal())}";

    List<ProductReports> productReports = await DatabaseHelper().getProductReports();
    List<String> productNames = [];
    List<ProductReports> totalProducts = [];
    int totalProductDisplay = 0;
    for(ProductReports totalItems in productReports){
      totalProductDisplay += totalItems.quantity;
    }



    //List<ItemRanks> itemRanksList = [];
    for(ProductReports inputItems in productReports){
      productNames.add(inputItems.product);
    }

    List<String> distinctNames = productNames.toSet().toList();
    //print(distinctNames);

    for(String names in distinctNames){
      ProductReports product = await DatabaseHelper().getAvgReportProducts(names);
      totalProducts.add(product);
    }

    totalProducts.sort((ProductReports a, ProductReports b) {
      return b.sum.compareTo(a.sum);
    });


    //DatabaseHelper().getAvgReportProducts("Barsilog");
    ticket.text("${storeDetails.businessName}",
      styles: PosStyles(
        align: PosAlign.center,
        height: PosTextSize.size1,
        width: PosTextSize.size2,
      ),
    );

    if (officeDetails.rHeader != null) {
      ticket.text("${officeDetails.rHeader}",
        styles: PosStyles(
          align: PosAlign.center,
        ),
      );
    }

    ticket.feed(1);

    if (storeDetails.address != null) {
      ticket.text("${storeDetails.address}",
        styles: PosStyles(
          align: PosAlign.center,
        ),
      );
    }

    if (storeDetails.tin != null) {
      ticket.text("TIN no.:${storeDetails.tin}",
        styles: PosStyles(
          align: PosAlign.center,
        ),
      );
      ticket.feed(1);
    }

    ticket.hr(ch: '=');
    // ticket.text(" ",
    //   styles: PosStyles(
    //       align: PosAlign.center,
    //       height: PosTextSize.size1,
    //       width: PosTextSize.size3,
    //       bold: true
    //   ),
    // );
    ticket.text("END-OF-DAY",
      styles: PosStyles(
          align: PosAlign.center,
          height: PosTextSize.size1,
          width: PosTextSize.size2,
          bold: true
      ),
    );
    ticket.text("REPORT",
      styles: PosStyles(
          align: PosAlign.center,
          height: PosTextSize.size1,
          width: PosTextSize.size2,
          bold: true
      ),
    );
    ticket.text("(KITCHEN)",
      styles: PosStyles(
          align: PosAlign.center,
          height: PosTextSize.size1,
          width: PosTextSize.size2,
          bold: true
      ),
    );

    ticket.hr(ch: '=');

    ticket.row([
      PosColumn(
        text: 'Shift Opened',
        width: 5,
        styles: PosStyles(align: PosAlign.left),
      ),
      PosColumn(
        text: loginParsedDate,
        width: 7,
        styles: PosStyles(align: PosAlign.right, bold: true),
      ),
    ]);

    ticket.row([
      PosColumn(
        text: 'Shift Closed',
        width: 5,
        styles: PosStyles(align: PosAlign.left),
      ),
      PosColumn(
        text: dateIssued,
        width: 7,
        styles: PosStyles(align: PosAlign.right, bold: true),
      ),
    ]);
    ticket.row([
      PosColumn(
        text: 'Kitchen User',
        width: 6,
        styles: PosStyles(align: PosAlign.left),
      ),
      PosColumn(
        text: kitchenUser.cashierName,
        width: 6,
        styles: PosStyles(align: PosAlign.right, bold: true),
      ),
    ]);
    ticket.row([
      PosColumn(
        text: 'Total Items:',
        width: 6,
        //styles: PosStyles(align: PosAlign.left),
      ),
      PosColumn(
        text: totalProductDisplay.toString(),
        width: 6,
        styles: PosStyles(align: PosAlign.right, bold: true),
      ),
    ]);

    ticket.hr(ch: '-');
    ticket.text(" ",
      styles: PosStyles(
          align: PosAlign.center,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
          bold: true
      ),
    );

    for(ProductReports itemReport in totalProducts){
      ticket.text(itemReport.sum.toString() +"x "+itemReport.product,
        styles: PosStyles(
            align: PosAlign.left,
            height: PosTextSize.size1,
            width: PosTextSize.size1,
            bold: true
        ),
      );
      ticket.row([
        PosColumn(
          text: 'Fastest Time:',
          width: 7,
          //styles: PosStyles(align: PosAlign.left),
        ),
        PosColumn(
          text: itemReport.fastestTime.toString(),
          width: 5,
          styles: PosStyles(align: PosAlign.right, bold: true),
        ),
      ]);
      ticket.row([
        PosColumn(
          text: 'Average Time:',
          width: 7,
          //styles: PosStyles(align: PosAlign.left),
        ),
        PosColumn(
          text: itemReport.avgTime.toString(),
          width: 5,
          styles: PosStyles(align: PosAlign.right, bold: true),
        ),
      ]);
      ticket.row([
        PosColumn(
          text: 'Slowest Time:',
          width: 7,
          //styles: PosStyles(align: PosAlign.left),
        ),
        PosColumn(
          text: itemReport.slowestTime.toString(),
          width: 5,
          styles: PosStyles(align: PosAlign.right, bold: true),
        ),
      ]);
      ticket.hr(ch: '-');
    }



    ticket.text("---End of Report---",
      styles: PosStyles(
          align: PosAlign.center,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
          bold: true
      ),
    );

    ticket.feed(1);
    ticket.cut();
    return ticket;
  }

  Future<void> printTicketTest() async {
    String isConnected = await BluetoothThermalPrinter.connectionStatus;

    //List<ProductReports> productReports = await DatabaseHelper().getProductReports();
    // for(ProductReports totalItems in productReports){
    //  print(totalItems.quantity);
    // }
    if (isConnected == "true") {

      Ticket bytes = await getTicketTest();
      final result = await BluetoothThermalPrinter.writeBytes(bytes.bytes);
      // print("Print $result");
    } else {

    }
  }

  Future<void> setPrinter() async {
    List blueTooth = await BluetoothThermalPrinter.getBluetooths;
    //print(mac); DC:0D:30:B7:9B:E0

    for(int i = 0; i < blueTooth.length ; i++){
      String result = await BluetoothThermalPrinter.connect(blueTooth[i].toString().split("#")[1]);
      String isConnected = await BluetoothThermalPrinter.connectionStatus;

      if(isConnected == "true"){
        Ticket bytes = await getTicketTest();
        var results = await BluetoothThermalPrinter.writeBytes(bytes.bytes);
      }
    }



    // String result = await BluetoothThermalPrinter.connect(mac);
    // Ticket bytes = await getTicketTest();
    // final results = await BluetoothThermalPrinter.writeBytes(bytes.bytes);
  }

  Future<Ticket> getTicketTest() async {
    CapabilityProfile profile = await CapabilityProfile.load();
    final Ticket ticket = Ticket(PaperSize.mm58, profile);
    var numberFormat = NumberFormat("#,##0.00", "en_US");

    // BusinessInfo kitchenUser = await UserSessions.getKitchenDetails();
    // StoreDetails storeDetails = await DatabaseHelper().getStoreDetails();
    // HeadOfficeDetails officeDetails = await DatabaseHelper()
    //     .getHeadOfficeDetails();
    // final img.Image image = img.decodeImage(officeDetails.businessIconBlob);
    // ticket.image(img.copyResize(image, width: 200));
    //
    // String dateIssued = "${new DateFormat('MM/d/y hh:mma').format(
    //     DateTime.now().toLocal())}";
    // String dateLogin = await UserSessions.getLastLogin();
    // String loginParsedDate = "${new DateFormat('MM/d/y hh:mma').format(
    //     DateTime.parse(dateLogin).toLocal())}";

    //ticket.feed(20);

    ticket.drawer();
    //ticket.feed(1);
    //ticket.cut();
    return ticket;
  }


  Future<void> printTicketThermalTest() async {
    // String isConnectedStatus = await BluetoothThermalPrinter.connectionStatus;
    //
    // if(isConnectedStatus == "true"){
    //   Ticket bytes = await getTicketTest();
    //   await BluetoothThermalPrinter.writeBytes(bytes.bytes);
    // }


    bluetooth.isConnected.then((isConnected) async {

      if(isConnected){
        bluetooth.printCustom("Thank You",2,1);
        bluetooth.printNewLine();

        //bluetooth.writeBytes(bytes.bytes);
        bluetooth.paperCut();
        //bluetooth.writeBytes(bytes.bytes);
      }

    });

    //final result = await BluetoothThermalPrinter.writeBytes(bytes.bytes);
  }


}