import 'dart:async';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geofencing_api/geofencing_api.dart';

import '../utilities/permission_handler.dart';

class GeofencingService {
 static final Set<GeofenceRegion> _region = {
    GeofenceCircularRegion(
      id: 'DotPlus',
      radius: 30,
      center: LatLng(25.626795, 85.109601),
    )
  };
  static final _service = FlutterBackgroundService();

  static Future<void> _initializeService() async {
    await _service.configure(
        iosConfiguration: IosConfiguration(
            onForeground: _onStart,
            onBackground: _iosBackgroundService,
            autoStart: true
        ),
        androidConfiguration: AndroidConfiguration(
            onStart: _onStart,
            autoStart: true,
            autoStartOnBoot: true,
            foregroundServiceTypes: [AndroidForegroundType.location],
            isForegroundMode: true));
  }
  @pragma('vn:entry-point')
  static _onStart(ServiceInstance service)async{
    DartPluginRegistrant.ensureInitialized();
    if(service is AndroidServiceInstance){
      service.on('setForegroundService').listen((onData){
        service.setAsForegroundService();
      });
      service.on('setBackgroundService').listen((onData){
        service.setAsBackgroundService();
      });
    }
    service.on('stop').listen((onData){
      service.stopSelf();
    });
    // initGeofencing();

    Timer.periodic(Duration(seconds: 1), (timer)async{
      if(service is AndroidServiceInstance){
        if(await service.isForegroundService()){
          service.setForegroundNotificationInfo(title: 'Geofencing Attendance', content: 'This is service is running for fetching your location to mark your attendance');
        }
      }
      initGeofencing();
      service.invoke('update');
    });
  }

  static Future<void> startService()async{
    if(!await _service.isRunning()){
      _initializeService();
    }
  }
  static Future<void> startBackgroundService()async{
    _service.invoke('setBackgroundService');
  }

  static Future<void> startForegroundService()async{
    _service.invoke('setForegroundService');
  }

  static Future<void> stopService()async{
    if(await _service.isRunning()){
      _service.invoke('stop');
    }
  }

  @pragma('vn:entry-point')
  static Future<bool> _iosBackgroundService(ServiceInstance service)async{
    WidgetsFlutterBinding.ensureInitialized();
    DartPluginRegistrant.ensureInitialized();
    return true;
  }

  static void initGeofencing() async {
    var status = await getLocationPermission();
    if (status == LocationPermissionStatus.granted) {
      _geofencingSetup();
      _geofencingStart();
    }
  }

  static void _geofencingSetup() async {
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

  static void _geofencingStart() async {
    Geofencing.instance
        .addGeofenceStatusChangedListener((region, status, location) async {
      if (status == GeofenceStatus.enter) {
        print('enter');
        // setState(() {
        //   btnStatusTxt = 'Punch In';
        //   btnColor = Colors.green;
        //   String dateTime = DateFormat('dd-MMM-yyyy h:m:s a').format(location.timestamp);
        //   _timeStamp
        //       .add(TimeStamp(time: dateTime, type: 'IN'));
        // });
      } else if (status == GeofenceStatus.exit) {
        print('exit');
        // setState(() {
        //   btnStatusTxt = 'Punch Out';
        //   btnColor = Colors.red;
        //   _timeStamp
        //       .add(TimeStamp(time: location.timestamp.toString(), type: 'OUT'));
        // });
      }
    });
    if(!Geofencing.instance.isRunningService){
      Geofencing.instance.start(regions: _region);
    }

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

  static void _onError(Object object, StackTrace trace) {
    print('Object: $object , StackTrace: $trace');
  }
}
