import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:for_kish/api/map.dart';
import 'package:for_kish/helpers/types.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:rxdart/rxdart.dart';

MapControllerHookState useMapControllerHook() {
  return Hook.use(_MapControllerHook());
}

class _MapControllerHook extends Hook<MapControllerHookState> {
  MapControllerHookState createState() => MapControllerHookState();
}

class MapControllerHookState extends HookState<MapControllerHookState, _MapControllerHook> {
  final _d = Distance();

  MapController _controller;
  bool firstTry = true;
  Position _currentLocation;
  StreamSubscription<Position> _positionStream;

  final _locationOnChange = new BehaviorSubject<LatLng>();
  bool _requestingLocation;
  Location _location;

  Location _pickup;
  Location _destination;
  MapRoute _route;
  bool _requestingOffers;
  List<Offer> _offers;
  Offer _selectedOffer;
  bool _requestingRide;
  bool _requestCancelled;
  Ride _ride;
  RideApproach _rideApproach;
  RideProgress _rideProgress;

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
          _controller.move(LatLng(position.latitude, position.longitude), _controller.zoom);
          firstTry = false;
        }
        // print(position == null ? 'Unknown' : position.latitude.toString() + ', ' + position.longitude.toString());
      }
    );

    _locationOnChange.debounceTime(Duration(milliseconds: 250)).listen((center) {
      // print(center.toString());
      queryForNewLocation(center);
    });

    _controller = MapController();

    _requestingLocation = false;

    _pickup = null;
    _destination = null;
    _requestingOffers = false;
    _requestingRide = false;
    _requestCancelled = false;
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

  void setPickup(Location p){
    if(_ride!=null || _requestingRide) return;
    setState((){
      this._pickup = p;
    });
    requestOffers();
  }

  Location getPickup(){
    return this._pickup;
  }

  void setDestination(Location l){
    if(_ride!=null || _requestingRide) return;
    setState((){
      this._destination = l;
    });
    requestOffers();
  }

  Location getDestination(){
    return this._destination;
  }

  void confirmed() {
    if(getPickup()==null){
      setPickup(getLocation());
      if(getDestination()==null){
        LatLng newLocation = _d.offset(LatLng(getLocation().lat, getLocation().lng), 100, 270);
        _controller.move(newLocation, _controller.zoom);
      }
    }else if(getDestination()==null){
      setDestination(getLocation());
      if(getPickup()==null){
        LatLng newLocation = _d.offset(LatLng(getLocation().lat, getLocation().lng), 100, 270);
        _controller.move(newLocation, _controller.zoom);
      }
    }
  }

  MapRoute get route => _route;

  void setRequestingOffers(bool c){
    setState((){
      this._requestingOffers = c;
    });
  }

  bool getRequestingOffers(){
    return this._requestingOffers;
  }

  void setOffers(List<Offer> c){
    setState((){
      this._offers = c;
    });
  }

  List<Offer> getOffers(){
    return this._offers;
  }

  void setSelectedOffer(Offer c){
    setState((){
      this._selectedOffer = c;
    });
  }

  Offer getSelectedOffer(){
    return this._selectedOffer;
  }

  void setRequestingRide(bool c){
    setState((){
      this._requestingRide = c;
    });
    if(_requestingRide){
      requestRide();
    }
  }

  bool getRequestingRide(){
    return this._requestingRide;
  }

  void setRide(Ride c){
    setState((){
      this._ride = c;
    });
  }

  Ride getRide(){
    return this._ride;
  }

  void setRideApproach(RideApproach c){
    setState((){
      this._rideApproach = c;
    });
  }

  RideApproach getRideApproach(){
    return this._rideApproach;
  }

  void setRideProgress(RideProgress c){
    setState((){
      this._rideProgress = c;
    });
  }

  RideProgress getRideProgress(){
    return this._rideProgress;
  }


  @override
  MapControllerHookState build(BuildContext context) {
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

  void requestOffers() async {
    if(_destination==null || _pickup==null){
      setState((){
        this._route = null;
        this._requestingOffers = false;
        this._offers = null;
        this._selectedOffer = null;
      });
      return;
    }

    queryRoute();

    _controller.fitBounds(LatLngBounds(
      LatLng(_pickup.lat, _pickup.lng),
      LatLng(_destination.lat, _destination.lng),
    ), options: FitBoundsOptions(
      padding: const EdgeInsets.only(top: 250.0, bottom: 300, left: 30, right: 30),
    ));

    setState((){
      this._requestingOffers = true;
      this._offers = null;
      this._selectedOffer = null;
    });
    try{
      final offers = await fetchOffers(this._pickup, this._destination);
      setState((){
        this._requestingOffers = false;
        this._offers = offers;
        this._selectedOffer = offers.firstWhere( (o) => o.enabled, orElse: () => null );
      });
    }catch(err){
      setState((){
        this._requestingOffers = false;
        this._offers = null;
        this._selectedOffer = null;
      });
    }
  }

  void queryRoute() async {
    try{
      final route = await fetchRoute(this._pickup, this._destination);
      setState((){
        this._route = route;
      });
    }catch(err){
      setState((){
        this._route = null;
      });
    }
  }

  void requestRide() async {
    if(_destination==null || _pickup==null || _selectedOffer == null)
      return;
    setState((){
      this._requestCancelled = false;
      this._requestingRide = true;
      this._ride = null;
      this._rideApproach = null;
      this._rideProgress = null;
    });
    try{
      final rideAndApproch = await fetchRide(this._pickup, this._destination, this._selectedOffer);
      // K1 : it might be the case the use requet , cancel , and request again, I have to find out which answer is canceled.
      if(this._requestCancelled){
        return;
      }
      setState((){
        this._requestingRide = false;
        this._ride = rideAndApproch.ride;
        this._rideApproach = rideAndApproch.rideApproach;
        this._rideProgress = null;
      });
    }catch(err){
      setState((){
        this._requestingRide = false;
        this._ride = null;
        this._rideApproach = null;
        this._rideProgress = null;
      });
    }
  }

  void cancelRide() {
    setState((){
      this._requestCancelled = true;
      this._requestingRide = false;
      this._ride = null;
      this._rideApproach = null;
      this._rideProgress = null;
    });
  }

}
