

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';


enum LocationPermissionStatus {
  granted,
  denied,
  permanentlyDenied,
  serviceDisabled,
}

Future<LocationPermissionStatus> getLocationPermission() async {

  if (!await Permission.location.serviceStatus.isEnabled) {
    return LocationPermissionStatus.serviceDisabled;
  }

  final locationStatus = await Permission.location.status;
  final locationAlwaysStatus = await Permission.locationAlways.status;

  if (locationStatus.isDenied || locationAlwaysStatus.isDenied) {
    final result = await Permission.location.request();
    if (result.isGranted) {
      final alwaysResult = await Permission.locationAlways.request();
      if (alwaysResult.isGranted) {
        return LocationPermissionStatus.granted;
      } else {
        return LocationPermissionStatus.denied;
      }
    } else {
      return LocationPermissionStatus.denied;
    }
  } else if (locationStatus.isPermanentlyDenied || locationAlwaysStatus.isPermanentlyDenied) {
    openAppSettings();
    return LocationPermissionStatus.permanentlyDenied;
  } else if (locationAlwaysStatus.isGranted) {
    return LocationPermissionStatus.granted;
  }

  return LocationPermissionStatus.denied; // Fallback case
}