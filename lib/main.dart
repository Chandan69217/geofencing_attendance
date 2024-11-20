import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geofencing_api/geofencing_api.dart';
import 'package:geofencing_attendance/background_service/Geofencing_services.dart';
import 'package:geofencing_attendance/utilities/permission_handler.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'google_map/google_map.dart';
const _url = 'https://github.com/Chandan69217/geofencing_attendance.git';

class TimeStamp {
  String time;
  String type;
  TimeStamp({required this.time, required this.type});
}

void main()async{
    WidgetsFlutterBinding.ensureInitialized();
    // Permission.notification.request();
    // await GeofencingService.startService();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // GeofencingApi(context).setupGeofencing();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Geofencing Attendance',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
      ),
      home: const MyHomePage(title: 'Home'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, this.title});
  final String? title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String btnStatusTxt = 'Punch Out';
  Color btnColor = Colors.red;
  static const _methodChannelService = MethodChannel('com.geofencing_attendance.service');
  static const _methodChannelGeofenceEvent = MethodChannel('com.geofencing_attendance.geofenceEvent');
  final Set<GeofenceRegion> _region = {
    GeofenceCircularRegion(
      id: 'DotPlus',
      radius: 30,
      center: LatLng(25.626795, 85.109601),
    )
  };
  List<TimeStamp> _timeStamp = [];

  @override
  void initState() {
    super.initState();
    //initGeofencing();
    _listenGeofeceEvents();
  }

  Future<void> _listenGeofeceEvents() async {
    _methodChannelGeofenceEvent.setMethodCallHandler((call) async{
      print('called');
      if(call.method == "geofenceEvent"){
        setState(() {
          btnStatusTxt = call.arguments;
        });
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.title!),
          actions: <Widget>[
            IconButton(onPressed: (){ _methodChannelService.invokeMethod('start');}, icon: Icon(Icons.play_circle_outline)),
            IconButton(onPressed: (){_methodChannelService.invokeMethod('stop');}, icon: Icon(Icons.stop_circle_outlined)),
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: _showInfoDialog,
            ),
          ],
        ),
        body: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.4,
              child: GoogleMapWidget(
                region: _region,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            ElevatedButton(
              onPressed: () {},
              child: Text(btnStatusTxt),
              style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(btnColor),
                  foregroundColor: WidgetStatePropertyAll(Colors.white)),
            ),
            SizedBox(
              height: 10,
            ),
            Expanded(
              child: ListView.builder(
                  itemCount: _timeStamp.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text('TimeStamp'),
                      subtitle: Text(_timeStamp[index].time),
                      trailing: CircleAvatar(
                        child: Text(_timeStamp[index].type),
                      ),
                    );
                  }),
            )
          ],
        ));
  }

  Future<void> _showInfoDialog() {
    return showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Geofencing Attendance'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                const Text('Github project repo url'),
                InkWell(
                  child: const Text(
                    _url,
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  onTap: () => launchUrl(Uri.parse(_url)),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _geofencingSetup() async {
    try {
      Geofencing.instance.setup(
        statusChangeDelay: 100,
        interval: 1000,
        accuracy: 1000,
      );
    } catch (object, trace) {
      _onError(object, trace);
    }
  }

  void _geofencingStart() async {
    Geofencing.instance
        .addGeofenceStatusChangedListener((region, status, location) async {
      if (status == GeofenceStatus.enter) {
        setState(() {
          btnStatusTxt = 'Punch In';
          btnColor = Colors.green;
          String dateTime = DateFormat('dd-MMM-yyyy h:m:s a').format(location.timestamp);
          _timeStamp
              .add(TimeStamp(time: dateTime, type: 'IN'));
        });
      } else if (status == GeofenceStatus.exit) {
        setState(() {
          btnStatusTxt = 'Punch Out';
          btnColor = Colors.red;
          _timeStamp
              .add(TimeStamp(time: location.timestamp.toString(), type: 'OUT'));
        });
      }
    });
    Geofencing.instance.start(regions: _region);
  }

  void _stopGeofencing() async {
    try {
      Geofencing.instance.removeGeofenceStatusChangedListener(
          (region, status, location) async {});
      Geofencing.instance.stop(keepsRegions: false);
    } catch (object, trace) {
      _onError(object, trace);
    }
  }

  void _onError(Object object, StackTrace trace) {
    print('Object: $object , StackTrace: $trace');
  }

  @override
  void dispose() {
    super.dispose();
    if (Geofencing.instance.isRunningService) {
      _stopGeofencing();
    }
  }

  void initGeofencing() async {
    var status = await getLocationPermission();
    if (status == LocationPermissionStatus.granted) {
      _geofencingSetup();
      _geofencingStart();
    }
  }
}
