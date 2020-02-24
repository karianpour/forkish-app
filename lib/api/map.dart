import 'dart:convert';
import 'package:for_kish/helpers/types.dart';
import 'package:http/http.dart' as http;
import 'package:latlong/latlong.dart';


// curl -X GET "https://map.ir/fast-reverse?lat=26.54&lon=53.99" -H "accept: application/json" -H "x-api-key: eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsImp0aSI6IjQ3M2VkZjNjYmEyZGEzMTg0YmVlM2FhZmFlNzFmMWU2ODY5MzRmN2U2OGQ4M2ExMTVlNDk1ZGYwNjAxNTVlOWUyMGM4ZjRjMmYxNDA1YzhkIn0.eyJhdWQiOiI3NzgyIiwianRpIjoiNDczZWRmM2NiYTJkYTMxODRiZWUzYWFmYWU3MWYxZTY4NjkzNGY3ZTY4ZDgzYTExNWU0OTVkZjA2MDE1NWU5ZTIwYzhmNGMyZjE0MDVjOGQiLCJpYXQiOjE1ODA2NDMyMTQsIm5iZiI6MTU4MDY0MzIxNCwiZXhwIjoxNTgzMTQ4ODE0LCJzdWIiOiIiLCJzY29wZXMiOlsiYmFzaWMiXX0.mD7yXohI94Ltv35DLPzclW9ynxW_cp-uXFXHhCky_IUR4EcrlnLdtXitCwVdiKI4zbmuVIMmdzS69VdSytCH5Ow-2v_B-iZBhIRUs1UrT3m0bNymOGuMneHMxze7qR02S0euLVEfK2TwNKZsM7hL7MvEk3lbLcxE0uP3UjtUPDwRFHqDI5S51A5c2Mn8aW2ZONu0nu1Cvh2A6VR2QCXYpaK9gYnoAuvSGkCXZFa_4tEHUDFXxvKugFuv9eJ4JIIQGoIE0EEMUHvy9EHdw7XxGV6--9iUXC6HPvhpLi6a7nvzoR_RNXn1a--wkFUH4E2G173oFoyZlmwtEbAPiZ-8RQ"

const MAPIR_API_KEY = "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsImp0aSI6IjQ3M2VkZjNjYmEyZGEzMTg0YmVlM2FhZmFlNzFmMWU2ODY5MzRmN2U2OGQ4M2ExMTVlNDk1ZGYwNjAxNTVlOWUyMGM4ZjRjMmYxNDA1YzhkIn0.eyJhdWQiOiI3NzgyIiwianRpIjoiNDczZWRmM2NiYTJkYTMxODRiZWUzYWFmYWU3MWYxZTY4NjkzNGY3ZTY4ZDgzYTExNWU0OTVkZjA2MDE1NWU5ZTIwYzhmNGMyZjE0MDVjOGQiLCJpYXQiOjE1ODA2NDMyMTQsIm5iZiI6MTU4MDY0MzIxNCwiZXhwIjoxNTgzMTQ4ODE0LCJzdWIiOiIiLCJzY29wZXMiOlsiYmFzaWMiXX0.mD7yXohI94Ltv35DLPzclW9ynxW_cp-uXFXHhCky_IUR4EcrlnLdtXitCwVdiKI4zbmuVIMmdzS69VdSytCH5Ow-2v_B-iZBhIRUs1UrT3m0bNymOGuMneHMxze7qR02S0euLVEfK2TwNKZsM7hL7MvEk3lbLcxE0uP3UjtUPDwRFHqDI5S51A5c2Mn8aW2ZONu0nu1Cvh2A6VR2QCXYpaK9gYnoAuvSGkCXZFa_4tEHUDFXxvKugFuv9eJ4JIIQGoIE0EEMUHvy9EHdw7XxGV6--9iUXC6HPvhpLi6a7nvzoR_RNXn1a--wkFUH4E2G173oFoyZlmwtEbAPiZ-8RQ";

Future<Location> fetchLocation(double lat, double lng) async {
  var url = 'https://map.ir/fast-reverse?lat=$lat&lon=$lng';

  var response = await http.get(url, headers: {
    "accept": "application/json",
    "x-api-key": MAPIR_API_KEY,
  });

  if (response.statusCode == 200) {
    var jsonResponse = json.decode(response.body);
    var name = jsonResponse['name'] as String;
    if(name==null || name.length == 0) name = jsonResponse['primary'];
    if(name==null || name.length == 0) name = jsonResponse['city'];
    return Location(lat: lat, lng: lng, name: name, location: jsonResponse['address']);
  } else {
    return null;
  }
}

// curl -X GET "https://map.ir/search/v2/autocomplete?text=%D8%AF%D8%A7%D9%85%D9%88%D9%86&%24select=roads%2Cpoi&%24filter=province%20eq%20%D8%AA%D9%87%D8%B1%D8%A7%D9%86&lat=26.53&lon=53.97" -H "accept: application/json"


Future<LocationList> fetchAddress(String query, double lat, double lng) async{
  // await Future.delayed(Duration(milliseconds: 500));
  // // throw("error test");
  // return LocationList(
  //   locations: [
  //     Location(name: 'صدف', location: 'کیش', lat: 26.542772582989233, lng: 53.99377681419415),
  //     Location(name: 'میدان دامون', location: 'کیش', lat: 26.564119755213273, lng: 53.98794763507246),
  //   ]
  // );
  var url = 'https://map.ir/search/v2/autocomplete';

  Map<String, dynamic> body = {
    "text": query,
    "\$filter": "polygon eq true",
    "lat": lat,
    "lon": lng,
    "polygon": {
      "type": "Polygon",
      "coordinates": [
        [
          [
            53.885879516601555,
            26.47979255197244
          ],
          [
            54.06028747558594,
            26.47979255197244
          ],
          [
            54.06028747558594,
            26.5958952526538
          ],
          [
            53.885879516601555,
            26.5958952526538
          ],
          [
            53.885879516601555,
            26.47979255197244
          ]
        ]
      ]
    }
  };

  var bodyJson = json.encode(body);

  var response = await http.post(url, 
    headers: {
      "accept": "application/json",
      "Content-Type": "application/json",
      "x-api-key": MAPIR_API_KEY,
    },
    body: bodyJson,
  );

  if (response.statusCode == 200) {
    var jsonResponse = json.decode(response.body);
    List<Location> locations = jsonResponse['value'].map<Location>(
      (dynamic i) =>
        Location(lat: i["geom"]["coordinates"][1], lng: i["geom"]["coordinates"][0], name: i["title"], location: i['district'] ?? i['county'] ?? "")
    ).toList();
    return LocationList(locations: locations);
  } else {
    return LocationList(locations: []);
  }
}

// curl -X GET "https://map.ir/routes/route/v1/driving/51.421047%2C35.732936%3B51.422185%2C35.731821?alternatives=false&steps=false" -H "accept: application/json" -H "x-api-key: api_key"
class MapRoute {
  List<LatLng> points;
  double distance;
  double duration;

  MapRoute({this.distance, this.duration, this.points});
}

Future<MapRoute> fetchRoute(Location pickup, Location destination) async {
  var url = 'https://map.ir/routes/route/v1/driving/${pickup.lng}%2C${pickup.lat}%3B${destination.lng}%2C${destination.lat}?alternatives=false&steps=true&overview=simplified';

  var response = await http.get(url, headers: {
    "accept": "application/json",
    "x-api-key": MAPIR_API_KEY,
  });

  if (response.statusCode == 200) {
    var jsonResponse = json.decode(response.body);

    if(jsonResponse['routes'].length > 0){
      var route = jsonResponse['routes'][0];
      var distance = route['distance'];
      var duration = route['duration'];

      var steps = jsonResponse['routes'][0]['legs'][0]['steps'];
      var points = steps.map<LatLng>(
        (step){
          var location = step['maneuver']['location'];
          return LatLng(location[1], location[0]);
        }
      );

      return MapRoute(distance: distance, duration: duration, points: points.toList());
    }
  }
  return null;
}

Future<List<Offer>> fetchOffers(Location pickup, Location destination) async{
  await Future.delayed(Duration(milliseconds: 2000));
  // throw("error test");
  return <Offer> [
    Offer(vehicleType: VehicleType.sedan, price: 25000, enabled: true),
    Offer(vehicleType: VehicleType.hatchback, price: 15000, enabled: false),
    Offer(vehicleType: VehicleType.van, price: 55000, enabled: false),
  ];
}

Future<RideAndApproach> fetchRide(Location pickup, Location destination, Offer selectedOffer) async{
  await Future.delayed(Duration(seconds: 10));
  // throw("error test");
  return RideAndApproach(
    ride: Ride(
      driver: Driver(firstName: 'کیوان', lastName: 'آرین‌پور', firstNameEn: 'Kayvan', lastNameEn: 'Arianpour', mobile: "+989121161998", photoUrl: "", score: 4),
      vehicle: Vehicle(vehicleType: VehicleType.sedan, classNumber: "22", mainNumber: "12345"),
      paymentType: PaymentType.cash,
      price: 25000,
    ),
    rideApproach: RideApproach(distance: 5700, eta: 560, location: Location(lat: 26.564119755213248, lng: 53.98794763507246), bearing: 55, rideReady: false),
  );
}