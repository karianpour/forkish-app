import 'package:latlong/latlong.dart';

class Passenger {
  String id;
  String firstname;
  String lastname;
  String mobile;

  Passenger({this.id, this.firstname, this.lastname, this.mobile});

  Passenger.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        firstname = json['firstname'],
        lastname = json['lastname'],
        mobile = json['mobile'];

  Map<String, dynamic> toJson() =>
    {
      'id': id,
      'firstname': firstname,
      'lastname': lastname,
      'mobile': mobile,
    };

}

class LocationList {
  List<Location> locations;

  LocationList({this.locations});
}

class Location {
  double lat;
  double lng;
  String name;
  String address;
  Location({this.name, this.address, this.lat, this.lng});

  Location.fromJson(Map<String, dynamic> json)
      : 
        lat = json['lat'],
        lng = json['lng'],
        name = json['name'],
        address = json['address'];

  Map<String, dynamic> toJson() =>
    {
      'lat': lat,
      'lng': lng,
      'name': name,
      'address': address,
    };
}

enum VehicleType {
  sedan,
  van,
  hatchback,
}

VehicleType findVehicleType(String name){
  return VehicleType.values.firstWhere((vt)=> vt.toString()=='VehicleType.$name', orElse: (){
    print('Vehicle Type for $name not found, returning null');
    return null;
  });
}

String getVehicleTypeName(VehicleType vt) {
  return vt?.toString()?.replaceFirst('VehicleType.', '');
}

class Offer {
  VehicleType vehicleType;
  double price;
  double distance;
  double time;
  bool enabled;

  Offer({this.vehicleType, this.price, this.distance, this.time, this.enabled});

  Offer.fromJson(Map<String, dynamic> json)
    : vehicleType = findVehicleType(json['vehicleType']),
      price = double.tryParse(json['price'].toString()),
      distance = double.tryParse(json['distance'].toString()),
      time = double.tryParse(json['time'].toString()),
      enabled = json['enabled']
      ;

}

class Vehicle {
  String mainNumber;
  String classNumber;
  VehicleType vehicleType;

  Vehicle({this.mainNumber, this.classNumber, this.vehicleType});

  Vehicle.fromJson(Map<String, dynamic> json)
    :
    mainNumber = json['plateNo'], //TODO plateno
    classNumber = json['PlateNo'], //TODO plateno
    vehicleType = findVehicleType(json['vehicleType'])
  ;
}

class Driver {
  String firstname;
  String lastname;
  String firstnameEn;
  String lastnameEn;
  String mobile;
  String photoUrl;
  int score;

  Driver({this.firstname, this.lastname, this.firstnameEn, this.lastnameEn, this.mobile, this.photoUrl, this.score});

  Driver.fromJson(Map<String, dynamic> json)
      : 
        firstname = json['firstname'],
        lastname = json['lastname'],
        firstnameEn = json['firstnameEn'],
        lastnameEn = json['lastnameEn'],
        mobile = json['mobile'],
        photoUrl = json['photoUrl'],
        score = json['score'] ?? 0;
}

enum PaymentType {
  cash,
  credit,
}

findPaymentType(String name) {
  return PaymentType.values.firstWhere( (pt) => pt.toString() == 'PaymentType.$name', orElse: (){
    print('No payment type where found for $name, so I return null.');
    return null;
  });
}

String getPaymentTypeName(PaymentType vt) {
  return vt?.toString()?.replaceFirst('PaymentType.', '');
}

class Ride {
  Driver driver;
  Vehicle vehicle;
  double price;
  PaymentType paymentType;

  Ride({this.driver, this.vehicle, this.price, this.paymentType});

  Ride.fromJson(Map<String, dynamic> json)
    : 
      driver = json['driver'] != null ? Driver.fromJson(json['driver']) : null, 
      vehicle = json['vehicle'] != null ? Vehicle.fromJson(json['vehicle']) : null, 
      price = double.tryParse(json['price'].toString()),
      paymentType = findPaymentType(json['paymentType'])
          ;
      }
      
class RideApproach{
  int distance;
  int eta;
  LatLng location;
  int heading;
  int speed;
  bool rideReady;
  bool passengerReady;

  RideApproach({this.distance, this.eta, this.location, this.heading, this.speed, this.rideReady, this.passengerReady});

  RideApproach.fromJson(Map<String, dynamic> json)
    :
      distance = json['distance'],
      eta = json['eta'],
      location = LatLng(
        double.tryParse(json['location']['lat'].toString()),
        double.tryParse(json['location']['lng'].toString())
      ),
      heading = json['heading'],
      speed = json['speed'],
      rideReady = json['rideReady'],
      passengerReady = json['passengerReady']
    ;
}

class RideProgress{
  bool onboard;
  LatLng location;
  int heading;
  int speed;

  RideProgress({this.onboard, this.location, this.heading, this.speed});

  RideProgress.fromJson(Map<String, dynamic> json)
    :
      onboard = json['onboard'],
      location = LatLng(
        double.tryParse(json['location']['lat'].toString()),
        double.tryParse(json['location']['lng'].toString())
      ),
      heading = json['heading'],
      speed = json['speed']
    ;
}

class RideAndApproach {
  Ride ride;
  RideApproach rideApproach;
  RideProgress rideProgress;

  RideAndApproach(this.ride, this.rideApproach, this.rideProgress);
}

class MapRoute {
  List<LatLng> points;
  double distance;
  double duration;

  MapRoute({this.distance, this.duration, this.points});

  MapRoute.fromJson(Map<String, dynamic> json)
    : points = json['points'] == null ? null : 
       json['points'].map( 
         (point) => LatLng(
           double.tryParse(point['lat']),
           double.tryParse(point['lng'])
         )
      ),
      distance = double.tryParse(json['distance']),
      duration = double.tryParse(json['duration'])
      ;
}
