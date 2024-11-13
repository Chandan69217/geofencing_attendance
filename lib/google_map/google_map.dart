import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geofencing_api/geofencing_api.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as Map;

// ignore: must_be_immutable
class GoogleMapWidget extends StatefulWidget {
  Set<GeofenceRegion> region;
  GoogleMapWidget({super.key, required this.region});
  @override
  State<GoogleMapWidget> createState() => _MapState();
}

class _MapState extends State<GoogleMapWidget> with WidgetsBindingObserver {
  Set<Map.Marker> marker = Set();
  Map.GoogleMapController? googleMapController;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  initCamera(Map.LatLng latLog) {
    setState(() {
      marker = {
        Map.Marker(markerId: Map.MarkerId('DotPlus'), position: latLog)
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Map.GoogleMap(
      initialCameraPosition: Map.CameraPosition(
          target: Map.LatLng(25.626795, 85.109601), zoom: 18.0),
      markers: marker,
      onMapCreated: (controller) {
        this.googleMapController = controller;
      },
      myLocationEnabled: true,

// polygons: {
//   Map.Polygon(
//       polygonId: Map.PolygonId(widget.region.first.id),
//       points: [
//         Map.LatLng(24.977770, 84.660673),
//         Map.LatLng(24.977544, 84.660585),
//         Map.LatLng(24.977507, 84.660706),
//         Map.LatLng(24.977550, 84.660721),
//         Map.LatLng(24.977571, 84.660669),
//         Map.LatLng(24.977746, 84.660736),
//       ],
//       strokeColor: Colors.green,
//       fillColor: Colors.green.shade100,
//       strokeWidth: 1)
// },
      circles: {
        Map.Circle(
            circleId: Map.CircleId('DopPlus'),
            center: Map.LatLng(25.626795, 85.109601),
            strokeWidth: 1,
            strokeColor: Colors.green,
            fillColor: Colors.green.shade100,
            radius: 30)
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }
}
