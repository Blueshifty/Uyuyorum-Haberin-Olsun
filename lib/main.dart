// For performing some operations asynchronously
import 'dart:async';

// For using PlatformException
import 'package:flutter/services.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

// For Sqflite

import 'package:uyuyorum_haberin_olsun/model/message.dart';
import 'package:uyuyorum_haberin_olsun/util/database_helper.dart';

// For Contacts

import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: DefaultTabController(
      length: 3,
      child: Scaffold(
          appBar: AppBar(
            bottom: TabBar(
              tabs: [
                Tab(icon: Icon(Icons.message)),
                Tab(icon: Icon(Icons.bluetooth_searching)),
                Tab(icon: Icon(Icons.portrait))
              ],
            ),
            centerTitle: true,
            title: Text('Uyuyorum Haberin Olsun'),
          ),
          body: TabBarView(
            children: <Widget>[
              MessagePage(),
              BluetoothApp(),
              AccessContacts(),
            ],
          )),
    ));
  }
}

class BluetoothApp extends StatefulWidget {
  @override
  _BluetoothAppState createState() => _BluetoothAppState();
}

class _BluetoothAppState extends State<BluetoothApp> {

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  FlutterBluetoothSerial bluetooth = FlutterBluetoothSerial.instance;


  List<BluetoothDevice> _devicesList = [];
  BluetoothDevice _device;
  bool _connected = false;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    bluetoothConnectionState();
  }


  Future<void> bluetoothConnectionState() async {
    List<BluetoothDevice> devices = [];

    try {
      devices = await bluetooth.getBondedDevices();
    } on PlatformException {
      print("Hata");
    }

   

    bluetooth.onStateChanged().listen((state) {
      if (state.underlyingValue == 10) {
        setState(() {
          _connected = true;
          _pressed = false;
        });
      }
      if (state.underlyingValue == 13) {
        setState(() {
          _connected = false;
          _pressed = false;
        });
      }
    });

  
    if (!mounted) {
      return;
    }

    setState(() {
      _devicesList = devices;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Bluetooth Cihazlarını Görüntüleme"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Container(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                "CİHAZLAR",
                style: TextStyle(fontSize: 24, color: Colors.blue),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'Cihaz:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  DropdownButton(
                    items: _getDeviceItems(),
                    onChanged: (value) => setState(() => _device = value),
                    value: _device,
                  ),
                  RaisedButton(
                    onPressed:
                        _pressed ? null : _connected ? _disconnect : _connect,
                    child: Text(_connected ? 'Bağlantıyı Kes' : 'Bağlan'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: Text(
                    "NOT: Bluetooth'u Açmayı Unutmayın.",
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.red),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }


  List<DropdownMenuItem<BluetoothDevice>> _getDeviceItems() {
    List<DropdownMenuItem<BluetoothDevice>> items = [];
    if (_devicesList.isEmpty) {
      items.add(DropdownMenuItem(
        child: Text('NONE'),
      ));
    } else {
      _devicesList.forEach((device) {
        items.add(DropdownMenuItem(
          child: Text(device.name),
          value: device,
        ));
      });
    }
    return items;
  }

  void _connect() {
    if (_device == null) {
      show('No device selected');
    } else {
      bluetooth.isConnected.then((isConnected) {
        if (!isConnected) {
          bluetooth
              .connect(_device)
              .timeout(Duration(seconds: 10))
              .catchError((error) {
            setState(() => _pressed = false);
          });
          setState(() => _pressed = true);
        }
      });
    }
  }


  void _disconnect() {
    bluetooth.disconnect();
    setState(() => _pressed = true);
  }

  void _sendOnMessageToBluetooth() {
    bluetooth.isConnected.then((isConnected) {
      if (isConnected) {
        bluetooth.write("1");
        show('Device Turned On');
      }
    });
  }

  void _sendOffMessageToBluetooth() {
    bluetooth.isConnected.then((isConnected) {
      if (isConnected) {
        bluetooth.write("0");
        show('Device Turned Off');
      }
    });
  }


  Future show(
    String message, {
    Duration duration: const Duration(seconds: 3),
  }) async {
    await new Future.delayed(new Duration(milliseconds: 100));
    _scaffoldKey.currentState.showSnackBar(
      new SnackBar(
        content: new Text(
          message,
        ),
        duration: duration,
      ),
    );
  }
}

class MessagePage extends StatelessWidget {
  final db = new DatabaseHelper();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'SQLite CRUD Testing',
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RaisedButton(
                child: Text(
                  'Database Yarat',
                  style: TextStyle(fontSize: 20),
                ),
                onPressed: () {
                  _createDatabase(db);
                }),
            RaisedButton(
              child: Text(
                'Mesajları Görüntüle',
                style: TextStyle(fontSize: 20),
              ),
              onPressed: () {
                _getAllMessages(db);
              },
            ),
            RaisedButton(
              child: Text(
                'Bir Tane Mesaj Göster',
                style: TextStyle(fontSize: 20),
              ),
              onPressed: () {
                _getMessage(db);
              },
            ),
            RaisedButton(
              child: Text(
                'Mesajı Güncelle',
                style: TextStyle(fontSize: 20),
              ),
              onPressed: () {
                _updateMessage(db);
              },
            ),
            RaisedButton(
              child: Text(
                'Mesajı Sil',
                style: TextStyle(fontSize: 20),
              ),
              onPressed: () {
                _deleteMessage(db);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _createDatabase(DatabaseHelper db) async {
    List messages;
    await db.saveMessage(new Message("Mehmet Bir", "Uyuyorum Kardeşim"));
    await db.saveMessage(new Message("Burak Tavsanli", "Kanka Uyuyorum"));
    await db.saveMessage(new Message("Emre Kececi", "Kanka Isim Var"));
    print("DATABASE OLUSTURULDU");
    messages = await db.getAllMessages();
    messages.forEach((message) => print(message));
  }

  void _getAllMessages(DatabaseHelper db) async {
    List messages;
    messages = await db.getAllMessages();
    messages.forEach((message) => print(message));
  }

  void _getMessage(DatabaseHelper db) async {
    Message message = await db.getMessage(2);
    print(message.toMap());
  }

  void _updateMessage(DatabaseHelper db) async {
    List messages;
    Message updatedMessage = Message.fromMap(
        {'id': 1, 'contactName': 'Enes Guldemir', 'message': 'Canim Uyuyorum'});
    await db.updateMessage(updatedMessage);
    messages = await db.getAllMessages();
    messages.forEach((message) => print(message));
  }

  void _deleteMessage(DatabaseHelper db) async {
    List messages;
    await db.deleteMessage(2);
    messages = await db.getAllMessages();
    messages.forEach((message) => print(message));
  }
}

class AccessContacts extends StatefulWidget {
  @override
  _AccessContactsState createState() => _AccessContactsState();
}

class _AccessContactsState extends State<AccessContacts> {
  Iterable<Contact> _contacts;

  @override
  void initState() {
    super.initState();
    getContacts();
  }

  getContacts() async {
    PermissionStatus permissionStatus = await _getPermission();
    if (permissionStatus == PermissionStatus.granted) {
      var contacts = await ContactsService.getContacts();
      setState(() {
        _contacts = contacts;
      });
    } else {
      throw PlatformException(
        code: 'PERMISSION_DENIED',
        message: 'Access to location data denied',
        details: null,
      );
    }
  }

  Future<PermissionStatus> _getPermission() async {
    PermissionStatus permission = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.contacts);
    if (permission != PermissionStatus.granted &&
        permission != PermissionStatus.disabled) {
      print("i dont have permission");
      Map<PermissionGroup, PermissionStatus> permisionStatus =
          await PermissionHandler()
              .requestPermissions([PermissionGroup.contacts]);
      return permisionStatus[PermissionGroup.contacts] ??
          PermissionStatus.unknown;
    } else {
      return permission;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('REHBER'),
        centerTitle: true,
      ),
      body: _contacts != null
          ? ListView.builder(
              itemCount: _contacts?.length ?? 0,
              itemBuilder: (context, index) {
                Contact c = _contacts?.elementAt(index);
                return ListTile(
                  leading: (c.avatar != null && c.avatar.length > 0)
                      ? CircleAvatar(
                          backgroundImage: MemoryImage(c.avatar),
                        )
                      : CircleAvatar(child: Text(c.initials())),
                  title: Text(c.displayName ?? ''),
                );
              },
            )
          : CircularProgressIndicator(),
    );
  }
}
