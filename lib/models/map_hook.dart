import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:for_kish/api/map.dart';
import 'package:for_kish/helpers/types.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:rxdart/rxdart.dart';

MapState useMap() {
  return Hook.use(_MapHook());
}

class _MapHook extends Hook<MapState> {
  MapState createState() => MapState();
}

class MapState extends HookState<MapState, _MapHook> {

  MapController _controller;
  bool firstTry = true;
  Position _currentLocation;
  StreamSubscription<Position> _positionStream;

  final _locationOnChange = new BehaviorSubject<LatLng>();
  bool _requestingLocation;
  Location _location;

  @override
  void initHook() {
    super.initHook();

    var locationOptions = LocationOptions(accuracy: LocationAccuracy.high, distanceFilter: 50);

    _positionStream = Geolocator().getPositionStream(locationOptions).listen(
      (Position position) {
        setState((){
          _currentLocation = position;
        });
        if(firstTry){
          _controller.move(LatLng(position.latitude, position.longitude), _controller.zoom ?? 13);
          firstTry = false;
        }
        // print(position == null ? 'Unknown' : position.latitude.toString() + ', ' + position.longitude.toString());
      }, 
      onError: (err) {
        print('location cannot be obtained with error');
        print(err);
      }
    );

    _locationOnChange.debounceTime(Duration(milliseconds: 250)).listen((center) {
      // print(center.toString());
      queryForNewLocation(center);
    });

    _controller = MapController();

    _requestingLocation = false;
  }

  MapController get controller => _controller;

  Position currentLocation() => _currentLocation;

  void setRequestingLocation(bool c){
    setState((){
      this._requestingLocation = c;
    });
  }

  bool getRequestingLocation(){
    return this._requestingLocation;
  }

  void setLocation(Location p){
    setState((){
      this._location = p;
    });
  }

  Location getLocation(){
    return this._location;
  }

  void moveToMyLocation() {
    if(_currentLocation!=null){
      LatLng newLocation = LatLng(_currentLocation.latitude, _currentLocation.longitude);
      _controller.move(newLocation, _controller.zoom);
    }
  }


  @override
  MapState build(BuildContext context) {
    return this;
  }

  @override
  void dispose() {
    // _wrapper.dispose();
    _positionStream.cancel();
    super.dispose();
  }

  void centerChanged(LatLng center) {
    _locationOnChange.add(center);
  }

  void queryForNewLocation(LatLng center) async {
    try{
      setState((){
        this._requestingLocation = true;
        this._location = null;
      });
      final location = await fetchLocation(center.latitude, center.longitude);
      setState((){
        this._requestingLocation = false;
        this._location = location;
      });
    }catch(err){
      print(err);
      setState((){
        this._requestingLocation = false;
        this._location = null;
      });
    }
  }

  void moveCamera(Location pickup, Location destination) async {
    if(!_controller.ready){
      await _controller.onReady;
    }
    print('moveCamera');
    _controller.fitBounds(LatLngBounds(
      LatLng(pickup.lat, pickup.lng),
      LatLng(destination.lat, destination.lng),
    ), options: FitBoundsOptions(
      padding: const EdgeInsets.only(top: 250.0, bottom: 300, left: 30, right: 30),
    ));

    // _controller?.fitBounds(LatLngBounds(
    //   LatLng(pickup.lat, pickup.lng),
    //   LatLng(destination.lat, destination.lng),
    // ), options: FitBoundsOptions(
    //   padding: const EdgeInsets.only(top: 350.0, bottom: 200, left: 30, right: 30),
    // ));
  }

}
