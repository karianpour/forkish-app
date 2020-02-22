class Passenger {
  String firstName;
  String lastName;
  String mobile;

  Passenger({this.firstName, this.lastName, this.mobile});

  Passenger.fromJson(Map<String, dynamic> json)
      : firstName = json['firstName'],
        lastName = json['lastName'],
        mobile = json['mobile'];

  Map<String, dynamic> toJson() =>
    {
      'firstName': firstName,
      'lastName': lastName,
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
  String location;
  Location({this.name, this.location, this.lat, this.lng});
}

enum VehicleType {
  sedan,
  van,
  hatchback,
}

class Offer {
  VehicleType vehicleType;
  double price;
  bool enabled;

  Offer({this.vehicleType, this.price, this.enabled});
}

class Vehicle {
  String mainNumber;
  String classNumber;
  VehicleType vehicleType;

  Vehicle({this.mainNumber, this.classNumber, this.vehicleType});
}

class Driver {
  String name;
  String phone;
  String photoUrl;
  int score;

  Driver({this.name, this.phone, this.photoUrl, this.score});
}

enum PaymentType {
  cash,
  credit,
}

class Ride {
  Driver driver;
  Vehicle vehicle;
  double price;
  PaymentType paymentType;

  Ride({this.driver, this.vehicle, this.price, this.paymentType});
}

class RideApproach{
  int distance;
  int eta;
  Location location;
  int bearing;
  bool rideReady;

  RideApproach({this.distance, this.eta, this.location, this.bearing, this.rideReady});
}

class RideProgress{
  bool onboard;
  Location location;
  int bearing;

  RideProgress({this.onboard, this.location, this.bearing});
}

class RideAndApproach {
  Ride ride;
  RideApproach rideApproach;

  RideAndApproach({this.ride, this.rideApproach});
}