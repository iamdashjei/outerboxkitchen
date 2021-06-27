import 'dart:async';

import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:bluetooth_enable/bluetooth_enable.dart';
import 'package:bluetooth_thermal_printer/bluetooth_thermal_printer.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pusher/pusher.dart';
import 'package:outerboxkitchen/src/database/database_helper.dart';
import 'package:outerboxkitchen/src/features/dashboard/widgets/bluetooth_serial_widget.dart';
import 'package:outerboxkitchen/src/features/dashboard/widgets/item_view_v2.dart';
import 'package:outerboxkitchen/src/features/dashboard/widgets/printer.dart';
import 'package:outerboxkitchen/src/features/dashboard/widgets/table_view_v2.dart';
import 'package:outerboxkitchen/src/features/dashboard/widgets/test_print.dart';
import 'package:outerboxkitchen/src/features/login/screens/app_authentication.dart';
import 'package:outerboxkitchen/src/features/login/screens/login_redirect_pincode.dart';
import 'package:outerboxkitchen/src/features/settings/settings_page.dart';
import 'package:outerboxkitchen/src/models/current_user.dart';
import 'package:outerboxkitchen/src/models/store_firebase.dart';
import 'package:outerboxkitchen/src/models/table_join_order.dart';
import 'package:outerboxkitchen/src/utils/user_sessions.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart' as ble;


class DashboardPage extends StatefulWidget {
  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => DashboardPage());
  }
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin<DashboardPage>{
  Future _session;
  TabController _controller;
  String title = "BY TABLE";
  // OrdersByTableBloc _ordersByTableBloc;
  // OrdersByItemBloc _ordersByItemBloc;
  //LocalDatabase appDatabase = new LocalDatabase();

  AudioCache audioCache = AudioCache();
  AudioPlayer advancedPlayer = AudioPlayer();

  Event lastEvent;
  Channel channel;

  String bluetoothDevice = 'printer';
  bool isPrinterConnected = false;
  String isConnected = 'false';
  Timer _timer;

  String username = '';
  String userAvatar = '';
  String currentPrinterId;
  String macIdSelect = '';
  String printerId;

  List<StoreTableParentOrderFirebase> parentItems = [];
  List availableBluetoothDevices = [];
  List<String> stringDeviceId = [];
  List<String> recentEmails = [];
  List<String> printerIds = [];

  FlutterBlue flutterBlue = FlutterBlue.instance;
  BluetoothDevice device;

  var subscription;

  ble.BlueThermalPrinter bluetoothBLE = ble.BlueThermalPrinter.instance;
  ble.BluetoothDevice _device;
  TestPrint testPrint;



  @override
  void initState() {

    _controller = new TabController(length: 2, vsync: this);
    _session = UserSessions.getLoggedIn();

    _controller.addListener(_handleSelected);
    UserSessions.getPrinterConnected().then((value) => isPrinterConnected = value != null);
    UserSessions.getBluetoothDevice().then((value) => bluetoothDevice = value);
    audioCache.disableLog();

    //enableBT();
    printConnectionThread();
    testPrint= TestPrint();

    super.initState();
  }

  void printConnectionThread()  async {


    //Printer().printTicketTest();
    // await FlutterStatusbarcolor.setStatusBarColor(Colors.orange);
    // FlutterStatusbarcolor.setStatusBarWhiteForeground(true);
    recentEmails = await UserSessions.getRecentUsers();
    _timer = Timer.periodic(Duration(seconds: 1), ( tick ) async {
      printerId = await UserSessions.getPrinterID();

      bool isConnectedDevice= await bluetoothBLE.isConnected;
      List<ble.BluetoothDevice> devices = [];
      try {
        devices = await bluetoothBLE.getBondedDevices();
      } on PlatformException {
        // TODO - Error
      }

      if(!isConnectedDevice){
        for(ble.BluetoothDevice itemDevice in devices){
         // print(itemDevice.connected);
          _connect(itemDevice);
        }
      }




      bluetoothBLE.onStateChanged().listen((state) {
        switch (state) {
          case ble.BlueThermalPrinter.CONNECTED:
            print("CONNECTED");
            setState(() {

              isConnected = "true";
            });
            break;
          case ble.BlueThermalPrinter.DISCONNECTED:
            print("DISCONNECTED");
            bluetoothBLE.disconnect();
            setState(() {
              isConnected = "false";
            });
            break;
          default:
            print(state);
            break;
        }
      });


      if(isConnectedDevice){
        setState(() {
          isConnected = "true";
        });
      } else {
        setState(() {
          isConnected = "false";
        });
      }



      // Printer().getBluetooth().then((value) {
      //   //print(value);
      //   if(value == true){
      //     if(!mounted) return;
      //     setState(() {
      //       isConnected = 'true';
      //     });
      //
      //   } else {
      //     if(!mounted) return;
      //     setState(() {
      //       isConnected = 'false';
      //     });
      //   }
      // });
    });
  }

   _connect(ble.BluetoothDevice deviceItem) {
    bluetoothBLE.isConnected.then((isConnectedDevice) {
      print("isConnected? " + isConnectedDevice.toString());
      if(isConnectedDevice == false){
        bluetoothBLE.connect(deviceItem).catchError((error) {
          print("ERROR CATCH WHILE CONNECTING");
          _device = deviceItem;

          //testPrint.sample();
        }).whenComplete(() {
          _device = deviceItem;
          //print(_device.address);
        });
      }

    });

  }

  bool _addStateToDevice(BluetoothDevice device)  {
      device.state.listen((event) {
        if(event.index == BluetoothDeviceState.connected.index){
         // print("Connected");
          setState(() {
            isConnected = 'true';
          });
          return true;
        } else {
          return connectDevice(device);
        }
      });

      return false;
  }

  _scanResultDevice(){
    flutterBlue.scanResults.listen((List<ScanResult> results){

      if(results.length > 0){
        for (ScanResult result in results) {
          String selectDevice = result.device.name + "#" + result.device.id.id;
          //print(result.device.name);
          //print(result.device.name + "#" + result.device.id.id);
          if(result.device.name.toLowerCase() == "printer001" || result.device.name.toLowerCase().contains("rpp")){
           // print("Printer found");

            if(stringDeviceId.contains(selectDevice)){
              //print("True");
              bool status = _addStateToDevice(result.device);

              // flutterBlue.stopScan();
            } else{
              setState(() {
                isConnected = 'false';
              });
              //  flutterBlue.stopScan();
            }

          }
        }
      } else {

        setState(() {
          isConnected = 'false';
        });
      }

    });

    flutterBlue.stopScan();
  }


  Future<bool> connectDevice(BluetoothDevice device) async{
    await device.connect();
    UserSessions.savePrinterID(device.name+"#"+device.id.id);
    await BluetoothThermalPrinter.connect(device.id.id);
    setState(() {
      isConnected = 'true';
    });
    return true;
  }

  BluetoothDevice checkDeviceState(String deviceId)  {
    BluetoothDevice device;
    flutterBlue.connectedDevices.asStream().listen((List<BluetoothDevice> listDevices) async {

      for(BluetoothDevice deviceItem in listDevices){
        String selectDevice = deviceItem.name + "#" + deviceItem.id.id;
        if(deviceId == selectDevice){
          device = deviceItem;
        }
      }

    });


    return device;
  }


  void playErrorOnSound() async {
    await advancedPlayer.release();
    await advancedPlayer.setReleaseMode(ReleaseMode.RELEASE);
    advancedPlayer.play(await audioCache.getAbsoluteUrl('mp3/error.mp3'), isLocal: true);
  }

  Future<void> enableBT() async {
    BluetoothEnable.enableBluetooth.then((value) {
      print(value);
    });
  }


  @override
  void dispose() {
    advancedPlayer.dispose();
    _controller.dispose();
    _timer.cancel();
    //subscription.cancel();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FutureBuilder<CurrentUser>(
        future: _session,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            //print("Snapshot data => " + snapshot.data.status);
            if (snapshot.data.status == "Login") {
              return Scaffold(
                //providers: [],
                // providers: [
                //   BlocProvider<OrdersByTableBloc>(
                //     create: (BuildContext context) => _ordersByTableBloc,
                //   ),
                //   BlocProvider<OrdersByItemBloc>(
                //     create: (BuildContext context) => _ordersByItemBloc,
                //   ),
                // ],
                body: DefaultTabController(
                  length: 2,
                  child: Scaffold(
                    appBar: AppBar(
                      centerTitle: true,
                      title: Text(
                        "$title",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      leading: PopupMenuButton<String>(
                        child:Row(
                          children: [
                            // CircleAvatar(
                            //   radius: 20.0,
                            //   backgroundImage:
                            //   NetworkImage("${snapshot.data.userAvatar}"),
                            //   backgroundColor: Colors.transparent,
                            // ),
                            //Text("${snapshot.data.username}", style: TextStyle(color: Colors.white),),
                            SizedBox(width: 15),
                            Icon(Icons.menu, color: Colors.white,),
                          ],
                        ),
                        onSelected: handleClick,
                        itemBuilder: (BuildContext context) {
                          return {'Settings', 'Logout'}.map((String choice) {
                            return PopupMenuItem<String>(
                              value: choice,
                              child: Text("$choice"),
                            );
                          }).toList();
                        },
                      ),
                      actions: <Widget>[
                          isConnected == 'true'? IconButton(icon: Icon(Icons.print_rounded),
                              color: Colors.green, onPressed: () {
                                    print("Enabled click");
                                    Printer().printTicketThermalTest();
                              })
                              : IconButton(icon: Icon(Icons.print_disabled_rounded),
                              color: Colors.grey, onPressed: ()  {

                                //Printer().printTicketThermalTest();
                                //Ticket bytes = await Printer().getTicketTest();

                                    // print("Disabled click");
                                    // Navigator.of(context).push(MaterialPageRoute(
                                    //   builder: (context) =>
                                    //       BluetoothApp(),
                                    // ));
                              }),
                          SizedBox(width: 15),

                      ],
                    ),
                    body: TabBarView(controller: _controller, children: [
                      Container(
                        child: TableViewV2(
                        ),
                      ),
                      Container(
                        child: ItemViewV2(

                        ),
                      ),
                    ]),
                  ),
                ),
              );
            } else {
              return AppAuthentication();
            }
          } else if (snapshot.hasError && snapshot.error != null) {
            return Center(child: Text(snapshot.error));
          } else {
            return AppAuthentication();
          }
        });
  }

  // handle clicks
  void handleClick(String value) async {
    switch (value) {
      case 'Logout':
        List<TableJoinOrder> taskStatus = await DatabaseHelper().getJoinTableOrdersToItemOrder();
        if(taskStatus.length == 0){
          UserSessions.setLoggedOut();
          _timer.cancel();
          //appDatabase.deleteAll();
          //BlocProvider.of<LoginBloc>(context).add(A());
          Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) =>
              LoginRedirectPinCodeScreen(email: recentEmails.last,)), (Route<dynamic> route) => false);
        } else {
          showTaskNotCompleteAlertDialog(context);

        }

        break;
      case 'Settings':
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => SettingsPage()));
        break;


      // case 'Print':
      //
      //   print("Print here");
      //   break;
    }
  }

  // Handle Selected
  void _handleSelected() {

    setState(() {
      getPrinter();
      title = _controller.index == 0 ? "BY TABLE" : "BY ITEM";
      if (_controller.index == 0) {
        //_ordersByTableBloc.add(LoadTableEvent(appDatabase: appDatabase));
      } else {
        //_ordersByItemBloc.add(LoadItemEvent(appDatabase: appDatabase));
      }
    });
  }

  getPrinter() async {
    isConnected = await BluetoothThermalPrinter.connectionStatus;
  }

  showTaskNotCompleteAlertDialog(BuildContext context){

    // set up the button
    Widget okButton = FlatButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Center(child: Text("Warning", style: TextStyle(fontSize: 20))),
      content: Text("Cannot log-out until all task are complete." , style: TextStyle(fontSize: 17)),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        playErrorOnSound();
        return alert;
      },
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;

}
