import 'dart:convert';
import 'dart:io';
import 'dart:async';

import 'package:for_kish/helpers/types.dart';
import 'package:for_kish/models/taxi.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong/latlong.dart';
import 'package:uuid/uuid.dart';

import 'backend_address.dart';

var uuid = Uuid();

class PassengerState {
  bool hasAnyState = false;
  Location pickup;
  Location destination;
  MapRoute route;
  bool requestingOffers;
  String id;
  List<Offer> offers;
  Offer selectedOffer;
  bool requestingRide;
  bool requestCancelled;
  Ride ride;
  RideApproach rideApproach;
  RideProgress rideProgress;

  PassengerState.fromJson(Map<String, dynamic> json){
    if(json['passengerRequest']!=null){
      hasAnyState = true;
      var pr = json['passengerRequest'];
      id = pr['id'];
      pickup = Location.fromJson(pr['pickup']);
      destination = Location.fromJson(pr['destination']);
      offers = pr['offers'] != null ? offersFromJson(pr['offers']) : null;
      route = pr['route'] != null ? MapRoute.fromJson(pr['route']) : null;
      requestingRide = pr['requestingRide'] == true;
      requestingOffers = false;
      requestCancelled = false;
    }
    if(json['rideProgress'] != null){
      hasAnyState = true;
      var rp = json['rideProgress'];
      id = rp['id'];
      ride = Ride.fromJson(rp['ride']);
      rideProgress = RideProgress.fromJson(rp['rideProgress']);
      rideApproach = RideApproach.fromJson(rp['rideApproach']);
      pickup = Location.fromJson(rp['pickup']);
      destination = Location.fromJson(rp['destination']);
      requestingRide = false;
      requestingOffers = false;
      requestCancelled = false;
    }
  }
}

WebSocket _ws;
bool _isConnecting = false;
bool _isAlive = false;
String _token;
Taxi _taxi;

void setWebSocketToken(String token){
  _token = token;
}

void registerTaxi(Taxi taxi){
  _taxi = taxi;
}

Future<bool> ensureWsConnection() async {
  if(!_isAlive){
    var connected = await connect();
    return connected;
  }
  return true;
}

Future<bool> connect() async {
  try{
    if(_isConnecting) return false;
    _isConnecting = true;
    _ws = await WebSocket.connect('$wsBaseUrl/passenger/ws');
    _isConnecting = false;
    if (_ws?.readyState == WebSocket.open) {
      _isAlive = true;
      heartbeat();

      _ws.listen(
        (data) {
          // print('\t\t -- ${data?.toString()}');
          if(data=='pong'){
            pong();
          }else{
            try{
              final jsonData = Map<String, dynamic>.from(jsonDecode(data));
              final method = jsonData['method']?.toString();
              final payload = jsonData['payload'];
              
              if(method=='authenticated'){
                handleAuthenticated(payload);
              }else if(method=='initialState'){
                handleInitialState(payload);
              }else if(method=='queryResult'){
                handleQueryResult(payload);
              }else if(method=='rideFound'){
                handleRideFound(payload);
              }else if(method=='driverArrived'){
                handleDriverArrived(payload);
              }else if(method=='confirmResult'){
                handleRideConfirmed(payload);
              }else if(method=='boarded'){
                handleBoarded(payload);
              }else if(method=='left'){
                handleLeft(payload);
              }else if(method=='driverMoved'){
                handleDriverMoved(payload);
              }else if(method=='driverCanceled'){
                handleDriverCanceled(payload);
              }else{
                print('unused method $method');
              }
            }catch(err){
              print(err);
            }
          }
        },
        onDone: () {
          _isAlive = false;
          print('Websocket closed.');
          tryReconnect();
        },
        onError: (err) => print('Websocket Error -- ${err.toString()}'),
        cancelOnError: true,
      );

      _ws.add(jsonEncode({
        'method': 'authenticate',
        'payload': _token,
      }));
      return true;
    }else{
      tryReconnect();
    }
  }catch(err){
    print(err);
  }
  return false;
}

void pong(){
  _isAlive = true;
}

void heartbeat(){
  Timer.periodic(Duration(seconds: 30), (timer) {
    if(_isAlive == false){
      timer?.cancel();
      try{
        _ws?.close(1, 'no ping pong');
      }catch(err){
        print('error while closeing websoket');
      }
      return;
    }
    _isAlive = false;
    _ws.add('ping');
  });
}

void tryReconnect(){
  if(_isAlive) return;
  Timer(Duration(seconds: 5), (){
    ensureWsConnection();
  });
}

void handleAuthenticated(payload){
  print('authenticated');
}

void handleInitialState(payload){
  print('initial');
  print(payload);
  var passengerState = PassengerState.fromJson(payload); 
  _taxi.setupState(passengerState);
}

void handleDriverMoved(dynamic payload){
  if(payload['point']!=null){
    var location = LatLng(
      double.tryParse(payload['point']['lat'].toString()),
      double.tryParse(payload['point']['lng'].toString()),
    );
    _taxi.driverMoved(location);
  }
}

void handleDriverArrived(payload){
  if(payload['rideProgressId'] == _taxi.getId()){
    _taxi.driverArrived();
  }
}

void handleBoarded(dynamic payload){
  if(payload['rideProgressId'] == _taxi.getId()){
    _taxi.onboard();
  }
}

void handleLeft(dynamic payload){
  if(payload['rideProgressId'] == _taxi.getId()){
    _taxi.accomplished();
  }
}

void handleDriverCanceled(payload){
  _taxi.canceledByDriver();
}

Future<void> fetchTaxiState() async {
  if(_token==null) {
    _taxi.setupState(null);
  }
  if(!await ensureWsConnection()) {
    _taxi.setupState(null);
  }
  var msg = jsonEncode({
    'method': 'initialState',
    'payload': null,
  });
  _ws.add(msg);
  // await Future.delayed(Duration(milliseconds: 200));
  // return DriverState.fromJson({
  //   "active": false,
  //   "ride": null,
  //   "accepted": null,
  //   "arrived": null,
  //   "pickedup": null,
  //   "accomplished": null,
  // });
}

Future<void> fetchQuery(Location pickup, Location destination) async{
  // await Future.delayed(Duration(milliseconds: 2000));
  // // throw("error test");
  // return <Offer> [
  //   Offer(vehicleType: VehicleType.sedan, price: 25000, enabled: true),
  //   Offer(vehicleType: VehicleType.hatchback, price: 15000, enabled: false),
  //   Offer(vehicleType: VehicleType.van, price: 55000, enabled: false),
  // ];
  if(!await ensureWsConnection()) return false;
  var msg = jsonEncode({
    'method': 'query',
    'payload': {
      'id': uuid.v4(),
      'pickup': pickup,
      'destination': destination,
    },
  });
  _ws.add(msg);
}

void handleQueryResult(payload){
  var id = payload['id'];
  var offers = payload['offers'] != null ? offersFromJson(payload['offers']) : null;
  var route = payload['route'] != null ? MapRoute.fromJson(payload['route']) : null;

  if(offers!=null){
    _taxi.queryResult(id, offers, route);
  }
}

List<Offer> offersFromJson(List<dynamic> offers) {
  final os = offers.map((offer){
    return Offer.fromJson(offer);
  });
  return os.toList();
}

Future<void> fetchRide(String id, VehicleType vehicleType, Position currentPosition) async{
  // await Future.delayed(Duration(seconds: 10));
  // // throw("error test");
  // return RideAndApproach(
  //   ride: Ride(
  //     driver: Driver(firstname: 'کیوان', lastname: 'آرین‌پور', firstnameEn: 'Kayvan', lastnameEn: 'Arianpour', mobile: "+989121161998", photoUrl: "", score: 4),
  //     vehicle: Vehicle(vehicleType: VehicleType.sedan, classNumber: "22", mainNumber: "12345"),
  //     paymentType: PaymentType.cash,
  //     price: 25000,
  //   ),
  //   rideApproach: RideApproach(distance: 5700, eta: 560, location: Location(lat: 26.564119755213248, lng: 53.98794763507246), heading: 55, speed:20, rideReady: false),
  // );
  if(!await ensureWsConnection()) return false;
  var msg = jsonEncode({
    'method': 'request',
    'payload': {
      'passengerRequestId': id,
      'vehicleType': getVehicleTypeName(vehicleType),
      'lat': currentPosition.latitude,
      'lng': currentPosition.longitude,
    },
  });
  _ws.add(msg);
}

void handleRideFound(payload){
  try{
    var ride = Ride.fromJson(payload['offer']['ride']);
    var rideApproach = RideApproach.fromJson(payload['offer']['rideApproach']);
    var rideProgress = RideProgress.fromJson(payload['offer']['rideProgress']);
    var rideAndApproach = RideAndApproach(ride, rideApproach, rideProgress);
    _taxi.rideResult(rideAndApproach);
  }catch(err){
    print(err);
  }
}

Future<void> fetchCancelRide(String rideId, Position currentPosition) async {
  // await Future.delayed(Duration(milliseconds: 1000));
  // print('cancel');

  if(!await ensureWsConnection()) return false;
  var msg = jsonEncode({
    'method': 'cancel',
    'payload': {
      'rideProgressId': rideId,
      'lat': currentPosition.latitude,
      'lng': currentPosition.longitude,
    },
  });
  _ws.add(msg);
}

Future<void> fetchConfirmRide(String rideId, Position currentPosition) async {
  if(!await ensureWsConnection()) return false;
  var msg = jsonEncode({
    'method': 'confirm',
    'payload': {
      'rideProgressId': rideId,
      'lat': currentPosition.latitude,
      'lng': currentPosition.longitude,
    },
  });
  _ws.add(msg);
}

void handleRideConfirmed(payload){
  try{
    if(payload == true)
      _taxi.confirmRideResult(true);
  }catch(err){
    print(err);
  }
}
