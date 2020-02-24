class Passenger {
  String id;
  String firstName;
  String lastName;
  String mobile;

  Passenger({this.id, this.firstName, this.lastName, this.mobile});

  Passenger.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        firstName = json['firstName'],
        lastName = json['lastName'],
        mobile = json['mobile'];

  Map<String, dynamic> toJson() =>
    {
      'id': id,
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
  String firstName;
  String lastName;
  String firstNameEn;
  String lastNameEn;
  String mobile;
  String photoUrl;
  int score;

  Driver({this.firstName, this.lastName, this.firstNameEn, this.lastNameEn, this.mobile, this.photoUrl, this.score});

  Driver.fromJson(Map<String, dynamic> json)
      : 
        firstName = json['firstName'],
        lastName = json['lastName'],
        firstNameEn = json['firstNameEn'],
        lastNameEn = json['lastNameEn'],
        mobile = json['mobile'],
        photoUrl = json['photoUrl'];
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