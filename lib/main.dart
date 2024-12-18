import 'dart:async';
import 'package:flutter/material.dart';
import 'package:june/june.dart';
import 'widgets/player.dart';
import 'package:path/path.dart';
//import 'package:sqflite/sqflite.dart';
//import 'package:mqtt_client/mqtt_client.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io' show Platform;
import 'widgets/robot.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

enum Status { init, registered, game }

class Player {
  String name;
  Player(this.name, {this.tile = -1, this.lives = -1, status = Status.init});

  Status status = Status.registered;

  int gameTime = 0;
  int lives = -1;
  int tile = -1;
}

class PlayersVM extends JuneState {
  int openPlaces = 0;
  List<Player> activePlayers = [
    Player("Player 1", tile: 1, lives: 0, status: Status.game),
    Player("Player 2", tile: 2, lives: 1, status: Status.game),
    Player("Player 3", tile: 3, lives: 3, status: Status.game),
    Player("Player 4", tile: 4, lives: 4, status: Status.game),
    Player("Player 5", tile: 5, lives: 3, status: Status.game),
    Player("Player 6", tile: 6, lives: 5, status: Status.game),
    Player("Player 7", tile: 7, lives: 0, status: Status.game),
    Player("Player 8", tile: 8, lives: 1, status: Status.game),
    Player("Player 9", tile: 9, lives: 3, status: Status.game),
    Player("Player 10", tile: 10, lives: 4, status: Status.game),
    Player("Player 11", tile: 11, lives: 3, status: Status.game),
    Player("Player 12", tile: 12, lives: 5, status: Status.game)
  ];
  List<Player> registeredPlayers = [
    Player("Player 1", status: Status.registered),
    Player("Player 2", status: Status.registered),
    Player("Player 3", status: Status.registered),
    Player("Player 4", status: Status.registered),
    Player("Player 5", status: Status.registered),
    Player("Player 6", status: Status.registered)
  ];
}

class SettingsVM extends JuneState {
  final brokerAddressController = TextEditingController();
  final brokerPortController = TextEditingController();
  final clientIdController = TextEditingController();

  set brokerAddress(String address) {
    brokerAddressController.text = address;
  }

  String get brokerAddress => brokerAddressController.text;

  set brokerPort(String port) {
    brokerPortController.text = port;
  }

  String get brokerPort => brokerPortController.text;

  set clientId(String id) {
    clientIdController.text = id;
  }

  String get clientId => clientIdController.text;

  @override
  void dispose() {
    brokerAddressController.dispose();
    brokerPortController.dispose();
    clientIdController.dispose();
    super.dispose();
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  final db = await databaseFactory
      .openDatabase(join(await getDatabasesPath(), 'settings.db'));

  await initDB(db);
  await loadInitialSettings(db);
  await testCode();
  runApp(const OverviewPage());
}

Future<void> testCode() async {
  PlayersVM vm = June.getState(() => PlayersVM());
  Timer.periodic(const Duration(seconds: 1), (Timer t) {
    for (var player in vm.activePlayers) {
      player.gameTime += 1;
    }
    vm.openPlaces += 1;
    vm.setState();
  });
}

Future<void> initDB(db) async {
  await db.execute('''
  CREATE TABLE IF NOT EXISTS Settings (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT,
      value TEXT,
      secure INTEGER
  )
  ''');
  await db.insert('Settings',
      <String, Object?>{'name': 'CLIENT_ID', 'value': 'A', 'secure': 0},
      conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('Settings',
      <String, Object?>{'name': 'BROKER_URI', 'value': 'A', 'secure': 0},
      conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('Settings',
      <String, Object?>{'name': 'BROKER_PORT', 'value': 'A', 'secure': 0},
      conflictAlgorithm: ConflictAlgorithm.ignore);
}

Future<void> loadInitialSettings(db) async {
  //setup settings page
  SettingsVM vm = June.getState(() => SettingsVM());
  vm.brokerAddress = (await db.query("Settings",
          columns: ["value"], where: "name = ?", whereArgs: ["BROKER_URI"]))
      .first["value"] as String;
  vm.brokerPort = (await db.query("Settings",
          columns: ["value"], where: "name = ?", whereArgs: ["BROKER_PORT"]))
      .first["value"] as String;
  vm.clientId = (await db.query("Settings",
          columns: ["value"], where: "name = ?", whereArgs: ["CLIENT_ID"]))
      .first["value"] as String;
  vm.setState();
}

class ScannerPage extends StatelessWidget {
  const ScannerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanner Page'),
      ),
      body: Center(
          child: JuneBuilder(() => SettingsVM(),
              builder: (vm) => Column(
                    children: [
                      const RobotWidget(),
                      const Divider(height: 20),
                      const Card(
                          child:
                              Column(mainAxisSize: MainAxisSize.min, children: [
                        ListTile(
                          titleTextStyle: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                          leading: Icon(Icons.place),
                          title: Text('User Player 1 on Tile 1'),
                        ),
                      ])),
                      ElevatedButton(
                        onPressed: () {
                          // handle save button press
                        },
                        child: const Text('Ok'),
                      ),
                    ],
                  ))),
    );
  }
}

class SettingsController extends ChangeNotifier {
  void updateSettings() {
    notifyListeners();
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings Page'),
      ),
      body: Center(
          child: JuneBuilder(
        () => SettingsVM(),
        builder: (vm) => Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Text(
              'MQTT Connection Settings',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: vm.clientIdController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Client ID',
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: vm.brokerAddressController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Broker Address',
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: vm.brokerPortController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Port',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // handle save button press
                  },
                  child: const Text('Test Connection'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // handle save button press
                  },
                  child: const Text('Save'),
                ),
              ],
            )
          ],
        ),
      )),
    );
  }
}

class OverviewPage extends StatelessWidget {
  const OverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true),
      home: const TabBarPlayer(),
    );
  }
}

class TabBarPlayer extends StatelessWidget {
  const TabBarPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        initialIndex: 1,
        length: 2,
        child: JuneBuilder(
          () => PlayersVM(),
          builder: (vm) => Scaffold(
              appBar: AppBar(
                title: const Text('Players'),
                bottom: const TabBar(
                  tabs: <Widget>[
                    Tab(
                      icon: Icon(Icons.person),
                      text: "Registered",
                    ),
                    Tab(
                      icon: Icon(Icons.person_2),
                      text: "Active",
                    )
                  ],
                ),
                actions: <Widget>[
                  IconButton(
                    icon: const Icon(Icons.bluetooth_connected),
                    tooltip: 'System State',
                    onPressed: () {
                      // handle the press
                    },
                  )
                ],
              ),
              body: TabBarView(
                children: <Widget>[
                  ListView.builder(
                      itemCount: vm.registeredPlayers.length,
                      itemBuilder: (context, index) {
                        var p = vm.registeredPlayers[index];
                        return PlayerListItem(
                          tile: p.tile,
                          name: p.name,
                          lives: p.lives,
                          timeInGame: p.gameTime,
                        );
                      }),
                  ListView.builder(
                      itemCount: vm.activePlayers.length,
                      itemBuilder: (context, index) {
                        var p = vm.activePlayers[index];
                        return PlayerListItem(
                          tile: p.tile,
                          name: p.name,
                          lives: p.lives,
                          timeInGame: p.gameTime,
                        );
                      })
                ],
              ),
              bottomNavigationBar: BottomAppBar(
                  shape: const CircularNotchedRectangle(),
                  child: Center(
                    child:
                        Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                      if (vm.openPlaces == 0)
                        const Icon(Icons.error, color: Colors.red),
                      Text('${vm.openPlaces} places open',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: vm.openPlaces > 0
                                  ? Colors.black
                                  : Colors.red)),
                    ]), // ,
                  )),
              floatingActionButton: FloatingActionButton.extended(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ScannerPage()),
                  );
                },
                tooltip: 'Register Player',
                label: const Text('Register Player'),
                icon: const Icon(Icons.add),
              ),
              drawer: Drawer(
                  child: ListView(children: <Widget>[
                ListTile(
                  title: const Text('Connection Settings'),
                  leading: const Icon(Icons.settings),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SettingsPage()),
                    );
                  },
                ),
              ]))),
        ));
  }
}
