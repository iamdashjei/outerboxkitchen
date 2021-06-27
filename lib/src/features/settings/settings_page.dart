import 'package:bluetooth_thermal_printer/bluetooth_thermal_printer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:outerboxkitchen/src/utils/user_sessions.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  List availableBluetoothDevices = new List();
  String btPrinter = "No printer connected";
  bool connected = false;

  @override
  void initState() {
    // _prefs.then((SharedPreferences prefs) {
    //   btPrinter = (prefs.getString('btPrinter') ?? "");
    // });
    super.initState();
    getBluetooth();
  }

  Future<void> getBluetooth() async {
    final List bluetooths = await BluetoothThermalPrinter.getBluetooths;
    setState(() {
      availableBluetoothDevices = bluetooths;
    });
  }

  Future<void> setConnect(String mac, String name) async {
    final String result = await BluetoothThermalPrinter.connect(mac);
    // final SharedPreferences prefs = await _prefs;
    //
    // setState(() {
    //   prefs.setString("btPrinter", mac).then((bool success) {});
    // });
    UserSessions.setBluetoothDevice(mac);
    if (result == "true") {
      setState(() {
        btPrinter = name;
        UserSessions.setPrinterConnected();
        connected = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Settings",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Container(
        margin: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: Colors.orangeAccent[100],
                  border: Border.all(
                    color: Colors.orangeAccent[100],
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(30))),
              child: Row(
                children: [
                  Text(
                    "$btPrinter",
                    style: TextStyle(fontSize: 24, color: Colors.white),
                  ),
                  Spacer(),
                  CupertinoSwitch(
                    activeColor: Colors.orange,
                    value: connected,
                    onChanged: null,
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Text("Paired devices",
              style: TextStyle(fontSize: 18),
            ),
            Expanded(
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
                      this.setConnect(mac, name);
                    },
                    title: Text('${availableBluetoothDevices[index]}'),
                    subtitle: Text("Click to connect"),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
