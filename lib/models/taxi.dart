import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:for_kish/api/taxi.dart';
import 'package:for_kish/helpers/types.dart';
import 'package:for_kish/models/map_hook.dart';
import 'package:latlong/latlong.dart';

class Taxi with ChangeNotifier {
  final _d = Distance();

  bool _loaded = false;
  Location _pickup;
  Location _destination;
  MapRoute _route;
  bool _requestingOffers;
  String _id;
  List<Offer> _offers;
  Offer _selectedOffer;
  bool _requestingRide;
  bool _requestCancelled;
  Ride _ride;
  RideApproach _rideApproach;
  RideProgress _rideProgress;

  MapState _controller;

  Taxi();

  void load(String passengerId){
    if(_loaded) return;
    registerTaxi(this);
    fetchTaxiState();
  }

  void reinitialize(){
    _loaded = false;
    fetchTaxiState();
    notifyListeners();
  }

  void setupState(PassengerState passengerState){
    if(passengerState!=null && passengerState.hasAnyState){
      _pickup = passengerState.pickup;
      _destination = passengerState.destination;
      _route = passengerState.route;
      _id = passengerState.id;
      _offers = passengerState.offers;
      _selectedOffer = _offers?.firstWhere( (o) => o.enabled, orElse: () => null );

      _ride = passengerState.ride;
      _rideApproach = passengerState.rideApproach;
      _rideProgress = passengerState.rideProgress;

      _requestingOffers = passengerState.requestingOffers;
      _requestingRide = passengerState.requestingRide;
      _requestCancelled = passengerState.requestCancelled;
    }else{
      _pickup = null;
      _destination = null;
      _route = null;
      _requestingOffers = false;
      _id = null;
      _offers = null;
      _selectedOffer = null;
      _requestingRide = false;
      _requestCancelled = false;
      _ride = null;
      _rideApproach = null;
      _rideProgress = null;

    }
    this._loaded = true;
    notifyListeners();
  }

  bool get loaded => _loaded;

  void setPickup(Location p){
    if(_ride!=null || _requestingRide) return;
    this._pickup = p;
    notifyListeners();
    requestOffers();
  }

  Location getPickup(){
    return this._pickup;
  }

  void setDestination(Location l){
    if(_ride!=null || _requestingRide) return;
    this._destination = l;
    notifyListeners();
    requestOffers();
  }

  Location getDestination(){
    return this._destination;
  }

  void confirmed() {
    if(getPickup()==null){
      setPickup(_controller.getLocation());
      if(getDestination()==null){
        LatLng newLocation = _d.offset(LatLng(_controller.getLocation().lat, _controller.getLocation().lng), 100, 90);
        _controller.controller.move(newLocation, _controller.controller.zoom);
      }
    }else if(getDestination()==null){
      setDestination(_controller.getLocation());
      if(getPickup()==null){
        LatLng newLocation = _d.offset(LatLng(_controller.getLocation().lat, _controller.getLocation().lng), 100, 90);
        _controller.controller.move(newLocation, _controller.controller.zoom);
      }
    }
  }

  MapRoute get route => _route;

  void setRequestingOffers(bool c){
    this._requestingOffers = c;
    notifyListeners();
  }

  bool getRequestingOffers(){
    return this._requestingOffers;
  }

  String getId(){
    return this._id;
  }

  List<Offer> getOffers(){
    return this._offers;
  }

  void setSelectedOffer(Offer c){
    this._selectedOffer = c;
    notifyListeners();
  }

  Offer getSelectedOffer(){
    return this._selectedOffer;
  }

  void setRequestingRide(bool c){
    this._requestingRide = c;
    notifyListeners();
    if(_requestingRide){
      requestRide();
    }
  }

  bool getRequestingRide(){
    return this._requestingRide;
  }

  Ride getRide(){
    return this._ride;
  }

  RideApproach getRideApproach(){
    return this._rideApproach;
  }

  RideProgress getRideProgress(){
    return this._rideProgress;
  }

  void requestOffers() async {
    if(_destination==null || _pickup==null){
      this._route = null;
      this._requestingOffers = false;
      this._id = null;
      this._offers = null;
      this._selectedOffer = null;
      notifyListeners();
      return;
    }

    this._controller.moveCamera(_pickup, _destination);

    this._requestingOffers = true;
    this._id = null;
    this._offers = null;
    this._selectedOffer = null;
    notifyListeners();
    try{
      await fetchQuery(this._pickup, this._destination);
    }catch(err){
      this._requestingOffers = false;
      this._id = null;
      this._offers = null;
      this._selectedOffer = null;
      notifyListeners();
    }
  }

  void queryResult(String id, List<Offer> offers, MapRoute route){
    this._requestingOffers = false;
    this._id = id;
    this._offers = offers;
    this._route = route;
    this._selectedOffer = offers.firstWhere( (o) => o.enabled, orElse: () => null );
    notifyListeners();
  }

  void requestRide() async {
    if(_destination==null || _pickup==null || _selectedOffer == null)
      return;
    this._requestCancelled = false;
    this._requestingRide = true;
    this._ride = null;
    this._rideApproach = null;
    this._rideProgress = null;
    notifyListeners();
    await fetchRide(this._id, _selectedOffer.vehicleType, this._controller.currentLocation());
  }

  void rideResult(RideAndApproach rideAndApproach){
    try{
      //TODO K1 : it might be the case the use request , cancel , and request again, I have to find out which answer is canceled.
      if(this._requestCancelled){
        return;
      }
      this._requestingRide = false;
      this._ride = rideAndApproach.ride;
      this._rideApproach = rideAndApproach.rideApproach;
      this._rideProgress = rideAndApproach.rideProgress;
      notifyListeners();
    }catch(err){
      this._requestingRide = false;
      this._ride = null;
      this._rideApproach = null;
      this._rideProgress = null;
      notifyListeners();
    }
  }

  void confirmRide() async {
    if(_rideApproach == null)
      return;
    await fetchConfirmRide(this._id, this._controller.currentLocation());
  }

  void confirmRideResult(bool confirmed){
    if(_rideApproach == null)
      return;
    this._rideApproach.passengerReady = confirmed;
    notifyListeners();
  }

  void driverArrived(){
    this._rideApproach.rideReady = true;
    notifyListeners();
  }

  void onboard(){
    this._rideProgress.onboard = true;
    notifyListeners();
  }

  void accomplished(){
    this._pickup = null;
    this._destination = null;
    this._route = null;
    this._requestingOffers = false;
    this._id = null;
    this._offers = null;
    this._selectedOffer = null;
    this._requestingRide = false;
    this._requestCancelled = false;
    this._ride = null;
    this._rideApproach = null;
    this._rideProgress = null;
    notifyListeners();
  }

  void driverMoved(LatLng location){
    if(!this._rideApproach.rideReady){
      this._rideApproach.location = location;
    }else{
      this._rideProgress.location = location;
    }
    notifyListeners();
  }

  void cancelRide() {
    fetchCancelRide(this._id, this._controller.currentLocation());
    this._pickup = null;
    this._destination = null;
    this._route = null;
    this._requestingOffers = false;
    this._id = null;
    this._offers = null;
    this._selectedOffer = null;
    this._requestingRide = false;
    this._requestCancelled = true;
    this._ride = null;
    this._rideApproach = null;
    this._rideProgress = null;
    notifyListeners();
  }

  void setMapController(MapState controller) {
    this._controller = controller;
    // this._controller?.informMeAboutLocationChanged(locationChanged);
    // if(_controller!=null && _pickup!=null && _destination!=null){
    //   _controller.moveCamera(_pickup, _destination);
    // }
  }
}