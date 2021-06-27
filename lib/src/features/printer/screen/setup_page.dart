import 'package:bluetooth_thermal_printer/bluetooth_thermal_printer.dart';
import 'package:flutter/material.dart';
import 'package:outerboxkitchen/src/utils/user_sessions.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SetupPage extends StatefulWidget {
  @override
  _SetupPageState createState() => _SetupPageState();
}

class _SetupPageState extends State<SetupPage> {

  bool connected = false;
  List availableBluetoothDevices = new List();
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  String btPrinter;
  bool showWebView = false;

  @override
  void initState() {
    _prefs.then((SharedPreferences prefs) {
      btPrinter = (prefs.getString('btPrinter') ?? "");
    });
    super.initState();
    getBluetooth();
  }

  Future<void> getBluetooth() async {
    final List bluetooths = await BluetoothThermalPrinter.getBluetooths;
    print("Print $bluetooths");
    setState(() {
      availableBluetoothDevices = bluetooths;
    });
  }

  Future<void> setConnect(String mac) async {
    final String result = await BluetoothThermalPrinter.connect(mac);
    final SharedPreferences prefs = await _prefs;

    setState(() {
      prefs.setString("btPrinter", mac).then((bool success) {});
    });
    if (result == "true") {
      setState(() {
        UserSessions.setPrinterConnected();
        connected = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Search Paired Bluetooth"),
                OutlineButton(
                  onPressed: () {
                    // UserSessions.setPrinterConnected();
                    this.getBluetooth();
                  },
                  child: Text("Search"),
                ),
                Container(
                  height: 200,
                  child: ListView.builder(
                    itemCount: availableBluetoothDevices.length > 0
                        ? availableBluetoothDevices.length
                        : 0,
                    itemBuilder: (context, index) {
                      return ListTile(
                        onTap: () {
                          String select = availableBluetoothDevices[index];
                          List list = select.split("#");
                          String name = list[0];
                          String mac = list[1];
                          this.setConnect(mac);
                        },
                        title: Text('${availableBluetoothDevices[index]}'),
                        subtitle: Text("Click to connect"),
                      );
                    },
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

}
