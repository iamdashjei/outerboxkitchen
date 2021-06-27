import 'dart:io';

import 'package:blue_thermal_printer/blue_thermal_printer.dart' as ble;
import 'package:bluetooth_thermal_printer/bluetooth_thermal_printer.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:outerboxkitchen/src/database/database_helper.dart';
import 'package:outerboxkitchen/src/features/dashboard/widgets/test_print.dart';
import 'package:outerboxkitchen/src/models/business_info.dart';
import 'package:outerboxkitchen/src/models/headoffice_details.dart';
import 'package:outerboxkitchen/src/models/product_reports.dart';
import 'package:outerboxkitchen/src/models/store_details.dart';
import 'package:outerboxkitchen/src/utils/hex_color.dart';
import 'package:image/image.dart' as img;
import 'package:outerboxkitchen/src/utils/user_sessions.dart';
import 'package:path_provider/path_provider.dart';

class BluetoothApp extends StatefulWidget {
  @override
  _BluetoothAppState createState() => _BluetoothAppState();
}

class _BluetoothAppState extends State<BluetoothApp> {

  ble.BlueThermalPrinter bluetoothBLE = ble.BlueThermalPrinter.instance;
  List<ble.BluetoothDevice> _devices = [];
  ble.BluetoothDevice _device;
  bool _connected = false;
  String pathImage;
  TestPrint testPrint;

  @override
  void initState() {
    super.initState();
    initPlatformState();
    //initSavetoPath();
    testPrint= TestPrint();
  }

  bool connected = false;
  List availableBluetoothDevices = [];

  Future<void> getBluetooth() async {
    final List bluetooths = await BluetoothThermalPrinter.getBluetooths;
    print("Print $bluetooths");
    setState(() {
      availableBluetoothDevices = bluetooths;
    });
  }

  Future<void> setConnect(String mac) async {
    final String result = await BluetoothThermalPrinter.connect(mac);
    print("state conneected $result");
    if (result == "true") {
      setState(() {
        connected = true;
      });
    }
  }

  Future<void> printTicket() async {
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


  Future<Ticket> getTicket() async {
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
    productNames.add(totalItems.product);
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

  Future<Ticket> getTicketTest() async {
    CapabilityProfile profile = await CapabilityProfile.load();
    final Ticket ticket = Ticket(PaperSize.mm58, profile);
    var numberFormat = NumberFormat("#,##0.00", "en_US");

    BusinessInfo kitchenUser = await UserSessions.getKitchenDetails();
    StoreDetails storeDetails = await DatabaseHelper().getStoreDetails();
    HeadOfficeDetails officeDetails = await DatabaseHelper()
        .getHeadOfficeDetails();
    final img.Image image = img.decodeImage(officeDetails.businessIconBlob);
    ticket.image(img.copyResize(image, width: 200));

    String dateIssued = "${new DateFormat('MM/d/y hh:mma').format(
        DateTime.now().toLocal())}";
    String dateLogin = await UserSessions.getLastLogin();
    String loginParsedDate = "${new DateFormat('MM/d/y hh:mma').format(
        DateTime.parse(dateLogin).toLocal())}";

    //ticket.feed(20);

    ticket.drawer();
    ticket.feed(1);
    ticket.cut();
    return ticket;
  }



  // @override
  // Widget build(BuildContext context) {
  //   return MaterialApp(
  //     home: Scaffold(
  //       appBar: AppBar(
  //         backgroundColor: HexColor("#E49C0C"),
  //         title: const Text('Printer Settings'),
  //       ),
  //       body: Container(
  //         padding: EdgeInsets.all(20),
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Text("Search Paired Bluetooth"),
  //             TextButton(
  //               onPressed: () {
  //                 this.getBluetooth();
  //               },
  //               child: Text("Search"),
  //             ),
  //             Container(
  //               height: 200,
  //               child: ListView.builder(
  //                 itemCount: availableBluetoothDevices.length > 0
  //                     ? availableBluetoothDevices.length
  //                     : 0,
  //                 itemBuilder: (context, index) {
  //                   return ListTile(
  //                     onTap: () {
  //                       String select = availableBluetoothDevices[index];
  //                       List list = select.split("#");
  //                       // String name = list[0];
  //                       String mac = list[1];
  //                       this.setConnect(mac);
  //                     },
  //                     title: Text('${availableBluetoothDevices[index]}'),
  //                     subtitle: Text("Click to connect"),
  //                   );
  //                 },
  //               ),
  //             ),
  //             SizedBox(
  //               height: 30,
  //             ),
  //             TextButton(
  //               onPressed: this.printTicket,
  //               child: Text("Print Ticket"),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }


  initSavetoPath()async{
    //read and write
    //image max 300px X 300px
    // final filename = 'kumpares.png';
    // var bytes = await rootBundle.load("assets/images/kumpares.png");
    // String dir = (await getApplicationDocumentsDirectory()).path;
    // writeToFile(bytes,'$dir/$filename');
    // setState(() {
    //   pathImage='$dir/$filename';
    // });
  }

  Future<void> initPlatformState() async {
    bool isConnected= await bluetoothBLE.isConnected;
    List<ble.BluetoothDevice> devices = [];
    try {
      devices = await bluetoothBLE.getBondedDevices();
    } on PlatformException {
      // TODO - Error
    }

    bluetoothBLE.onStateChanged().listen((state) {
      switch (state) {
        case ble.BlueThermalPrinter.CONNECTED:
          setState(() {
            _connected = true;
          });
          break;
        case ble.BlueThermalPrinter.DISCONNECTED:
          setState(() {
            _connected = false;
          });
          break;
        default:
          print(state);
          break;
      }
    });

    if (!mounted) return;
    setState(() {
      _devices = devices;
    });

    if(isConnected) {
      setState(() {
        _connected=true;
      });
    }
  }

  List<DropdownMenuItem<ble.BluetoothDevice>> _getDeviceItems() {
    List<DropdownMenuItem<ble.BluetoothDevice>> items = [];
    if (_devices.isEmpty) {
      items.add(DropdownMenuItem(
        child: Text('NONE'),
      ));
    } else {
      _devices.forEach((device) {
        items.add(DropdownMenuItem(
          child: Text(device.name + " " + device.address),
          value: device,
        ));
      });
    }
    return items;
  }


  void _connect() {
    if (_device == null) {
      show('No device selected.');
    } else {
      bluetoothBLE.isConnected.then((isConnected) {
        if (!isConnected) {
          bluetoothBLE.connect(_device).catchError((error) {
            setState(() => _connected = false);
          });
          setState(() => _connected = true);
        }
      });
    }
  }


  void _disconnect() {
    bluetoothBLE.disconnect();
    setState(() => _connected = true);
  }

//write to app path
  Future<void> writeToFile(ByteData data, String path) {
    final buffer = data.buffer;
    return new File(path).writeAsBytes(
        buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
  }

  Future show(
      String message, {
        Duration duration: const Duration(seconds: 3),
      }) async {
    await new Future.delayed(new Duration(milliseconds: 100));
    Scaffold.of(context).showSnackBar(
      new SnackBar(
        content: new Text(
          message,
          style: new TextStyle(
            color: Colors.white,
          ),
        ),
        duration: duration,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Blue Thermal Printer'),
        ),
        body: Container(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView(
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(width: 10,),
                    Text(
                      'Device:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 30,),
                    Expanded(
                      child: DropdownButton(
                        items: _getDeviceItems(),
                        onChanged: (value) => setState(() => _device = value),
                        value: _device,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10,),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    RaisedButton(
                      color: Colors.brown,
                      onPressed:(){
                        initPlatformState();
                      },
                      child: Text('Refresh', style: TextStyle(color: Colors.white),),
                    ),
                    SizedBox(width: 20,),
                    RaisedButton(
                      color: _connected ?Colors.red:Colors.green,
                      onPressed:
                      _connected ? _disconnect : _connect,
                      child: Text(_connected ? 'Disconnect' : 'Connect', style: TextStyle(color: Colors.white),),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 50),
                  child:  RaisedButton(
                    color: Colors.brown,
                    onPressed:(){
                    //  testPrint.sample();
                    },
                    child: Text('PRINT TEST', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}