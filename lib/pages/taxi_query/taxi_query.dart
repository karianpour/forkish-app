import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:for_kish/models/taxi.dart';
import 'package:latlong/latlong.dart';
import 'package:for_kish/helpers/number.dart';
import 'package:for_kish/helpers/types.dart';
import 'package:for_kish/pages/address/address_query.dart';
import 'package:functional_widget_annotation/functional_widget_annotation.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/map_hook.dart';

part 'taxi_query.g.dart';

final LatLng center = LatLng(26.532065, 53.977069); // center of kish island
// const leafLetAccessToken = "pk.eyJ1Ijoia2FyaWFucG91ciIsImEiOiJjazZkbGJtMWYwODNzM2VudmVpdzU5dDJhIn0.LCWmMFkfKR_qDeed8Gsnhw";
const leafLetAccessToken = "pk.eyJ1Ijoia2FyaWFucG91ciIsImEiOiJjazZnY21iMW4wMnV0M21wOGFwazl0MXVkIn0.58NkL2VWsgUo16JGBz2CZw";

@widget
Widget taxiQuery(BuildContext context) {
  final state = useMap();
  final taxi = Provider.of<Taxi>(context);
  taxi.setMapController(state);

  return Stack(
    children: <Widget>[
      MapArea(state: state),
      HereMarker(state: state),
      if(!taxi.loaded) Center(child: CircularProgressIndicator(),),
      if(taxi.loaded) TaxiStateRefresher(taxi: taxi),
      if(taxi.loaded && taxi.getPickup()==null || taxi.getDestination()==null) CenterMarker(state: state),
      if(taxi.loaded && taxi.getRide()==null) AddressPanel(state: state),
      // if(taxi.loaded && taxi.getPickup()==null) PickupAlert(state: state),
      // if(taxi.loaded && taxi.getPickup()!=null && taxi.getDestination()==null) DestinationAlert(state: state),
      if(taxi.loaded && taxi.getPickup()!=null && taxi.getDestination()!=null && !taxi.getRequestingRide() && taxi.getRide()==null) OfferSelection(state: state),
      if(taxi.loaded && taxi.getRequestingRide()) RideQueryPanel(state: state,),
      if(taxi.loaded && taxi.getRide()!=null) RidePanel(state: state),
    ],
  );
}

class TaxiStateRefresher extends StatelessWidget {
  const TaxiStateRefresher({
    Key key,
    @required this.taxi,
  }) : super(key: key);

  final Taxi taxi;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: (120.0 + ((taxi.getPickup()==null ? 0 : 48) + 48) * (taxi.getRide()==null ? 1 : 0)),
      left: 0,
      right: 0,
      child: Container(
        alignment: AlignmentDirectional.centerEnd,
        child: FlatButton(
          onPressed: (){
            taxi.reinitialize();
          },
          child: Icon(Icons.refresh, color: Colors.black),
        ),
      ),
    );
  }
}

class CenterMarker extends StatelessWidget {
  const CenterMarker({
    Key key,
    @required this.state,
  }) : super(key: key);

  final MapState state;

  @override
  Widget build(BuildContext context) {
    final taxi = Provider.of<Taxi>(context);

    return Center(
      child: GestureDetector(
        onTap: (){
          if(!state.getRequestingLocation())
            taxi.confirmed();
        },
        child: SizedBox(
          height: 80,
          child: Align(
            child: Container(
              child: Image.asset(
                'assets/map/marker.png',
                height: 48,
                color: state.getRequestingLocation() ? Colors.grey : Colors.blue,
              ),
            ),
            alignment: Alignment.topCenter,
          ),
        ),
      ),
    );
  }
}

class HereMarker extends StatelessWidget {
  const HereMarker({
    Key key,
    @required this.state,
  }) : super(key: key);

  final MapState state;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 40,
      left: 20,
      right: 20,
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: GestureDetector(
          onTap: (){
            state.moveToMyLocation();
          },
          child: SizedBox(
            height: 28,
            child: Container(
              child: Image.asset('assets/map/here.png')
            ),
          ),
        ),
      ),
    );
  }
}

class RidePanel extends StatelessWidget {
  const RidePanel({
    Key key,
    @required this.state,
  }) : super(key: key);

  final MapState state;

  @override
  Widget build(BuildContext context) {
    final taxi = Provider.of<Taxi>(context);

    return Positioned(
      bottom: 40,
      left: 20,
      right: 20,
      // height: 250,
      child: Column(
        children: <Widget>[
          if(taxi.getRideApproach().rideReady && taxi.getRideProgress().onboard != true) Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Container(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.only(top: 8, bottom: 8, left: 8, right: 8),
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(255, 255, 255, 1),
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [BoxShadow(
                        color: Colors.grey,
                        blurRadius: 5.0,
                        spreadRadius: 2.0,
                        offset: Offset(5, 5),
                      )]
                    ),
                    child: Text(translate('taxi_query.ride_ready')),
                  ),
                  if(taxi.getRideApproach().passengerReady != true) RaisedButton(
                    child: Text(translate('taxi_query.i_am_commig')),
                    onPressed: (){
                      taxi.confirmRide();
                    },
                  ),
                ],
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Color.fromRGBO(255, 255, 255, 1),
              borderRadius: BorderRadius.circular(4),
              boxShadow: [BoxShadow(
                color: Colors.grey,
                blurRadius: 5.0,
                spreadRadius: 2.0,
                offset: Offset(5, 5),
              )]
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                // mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Row(
                    // crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Expanded(
                        child: buildDriver(context),
                      ),
                      buildActions(taxi),
                    ],
                  ),
                  buildRideData(context),
                ],
              ),
            ),
          ),
          SizedBox(height: 20),
          Container(
            width: double.infinity,
            child: RaisedButton(
              child: Text(translate('taxi_query.cancel_ride')),
              onPressed: (){},
              onLongPress: (){
                taxi.cancelRide();
              },
            ),
          ),
        ],
      ),
    );
  }

  Container buildActions(Taxi taxi) {
    return Container(
      padding: EdgeInsets.all(8.0),
      width: 80,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          RaisedButton(
            padding: EdgeInsets.all(0),
            child: Icon(Icons.call),
            onPressed: () async {
              print('call ${taxi.getRide().driver.mobile}');
              if(await canLaunch("tel:${taxi.getRide().driver.mobile}")){
                var r = await launch("tel:${taxi.getRide().driver.mobile}");
                print("result : $r");
              }else{
                print('cant lunch');
              }
            },
          ),
          RaisedButton(
            padding: EdgeInsets.all(0),
            child: Icon(Icons.more),
            onPressed: (){
              print('call');
            },
          ),
        ],
      ),
    );
  }

  Column buildDriver(BuildContext context) {
    final locale = LocalizedApp.of(context).delegate.currentLocale.languageCode;
    final taxi = Provider.of<Taxi>(context);
    final score = taxi.getRide().driver.score;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            CircleAvatar(
              radius: 32,
              backgroundImage: AssetImage('assets/sample/brad_pit.jpeg'),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 8),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    (locale == 'fa' || locale == 'ar') ? '${taxi.getRide().driver.firstname} ${taxi.getRide().driver.lastname}' 
                      : '${taxi.getRide().driver.firstnameEn} ${taxi.getRide().driver.lastnameEn}'
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.star, color: score > 0 ? Colors.yellow: Colors.black54, size: 16),
                        Icon(Icons.star, color: score > 1 ? Colors.yellow: Colors.black54, size: 16),
                        Icon(Icons.star, color: score > 2 ? Colors.yellow: Colors.black54, size: 16),
                        Icon(Icons.star, color: score > 3 ? Colors.yellow: Colors.black54, size: 16),
                        Icon(Icons.star, color: score > 4 ? Colors.yellow: Colors.black54, size: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        Container(
          padding: EdgeInsets.only(top: 8, bottom: 12),
          child: KishVehiclePlate(vehicle: taxi.getRide().vehicle)
        ),
      ],
    );
  }

  Container buildRideData(BuildContext context) {
    final taxi = Provider.of<Taxi>(context);
    return Container(
      // height: 80,
      // width: double.infinity,
      padding: const EdgeInsets.only(top: 4),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(width: 1, color: Colors.black54))
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: <Widget>[
            RideDatalet(
              label: translate("taxi_query.distance"), 
              data: translate("taxi_query.distanceKilometer", args: {"distance": formatNumber(context, taxi.getRideApproach().distance / 1000)}),
            ),
            RideDatalet(
              label: translate("taxi_query.eta"), 
              data: translate("taxi_query.etaMinute", args: {"eta": formatNumber(context, (taxi.getRideApproach().eta / 60).ceil())}),
            ),
            RideDatalet(
              label: translate("taxi_query.figure"), 
              data: translate('taxi_query.price', args: {'price': formatNumber(context, taxi.getRide().price)}),
            ),
            RideDatalet(
              label: translate("taxi_query.paymentMethod"), 
              data: translate(taxi.getRide().paymentType.toString()),
            ),
          ],
        ),
      ),
    );
  }
}

class KishVehiclePlate extends StatelessWidget {
  const KishVehiclePlate({
    Key key,
    @required this.vehicle,
  }) : super(key: key);

  final Vehicle vehicle;

  @override
  Widget build(BuildContext context) {
    final withClass = vehicle.classNumber!=null && vehicle.classNumber.length>0;
    return Container(
      height: 30,
      width: withClass ? 130 : 105,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        border: Border.all(width: 2),
        color: Colors.orange,
      ),
      child: Row(
        textDirection: TextDirection.ltr,
        children: <Widget>[
          Container(
            width: 40,
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Center(child: Text('Kish')),
          ),
          Container(
            width: 56,
            child: Center(child: Text(vehicle.mainNumber))
          ),
          if(withClass) 
            Container(
              width: 30, 
              decoration: BoxDecoration(
                border: Border(left: BorderSide(width: 1)),
              ),
              child: Center(child: Text(vehicle.classNumber))
            ),
        ],
      ),
    );
  }
}

class RideDatalet extends StatelessWidget {
  const RideDatalet({
    Key key,
    @required this.label,
    @required this.data,
  }) : super(key: key);

  final String label;
  final String data;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              label,
              style: TextStyle(
                color: Colors.black54,
              ),
            ),
          ),
          Text(data),
        ],
      ),
    );
  }
}

class RideQueryPanel extends StatelessWidget {
  const RideQueryPanel({
    Key key,
    @required this.state,
  }) : super(key: key);
  final MapState state;

  @override
  Widget build(BuildContext context) {
    final taxi = Provider.of<Taxi>(context);

    return Positioned(
      bottom: 40,
      left: 20,
      right: 20,
      child: Column(
        children: <Widget>[
          Container(
            height: 160,
            decoration: BoxDecoration(
              color: Color.fromRGBO(255, 255, 255, 1),
              borderRadius: BorderRadius.circular(4),
              boxShadow: [BoxShadow(
                color: Colors.grey,
                blurRadius: 5.0,
                spreadRadius: 2.0,
                offset: Offset(5, 5),
              )]
            ),
            child: Center(child: CircularProgressIndicator()),
          ),
          SizedBox(height: 20),
          Container(
            width: double.infinity,
            child: RaisedButton(
              child: Text(translate('taxi_query.cancel_request')),
              onPressed: (){},
              onLongPress: (){
                taxi.cancelRide();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class OfferSelection extends StatelessWidget {
  const OfferSelection({
    Key key,
    @required this.state,
  }) : super(key: key);

  final MapState state;

  @override
  Widget build(BuildContext context) {
    final taxi = Provider.of<Taxi>(context);

    return Positioned(
      bottom: 40,
      left: 20,
      right: 20,
      child: Container(
        child: Column(
          children: <Widget>[
            Container (
              width: double.infinity,
              // height: 170,
              decoration: BoxDecoration(
                color: Color.fromRGBO(255, 255, 255, 1),
                borderRadius: BorderRadius.circular(4),
                boxShadow: [BoxShadow(
                  color: Colors.grey,
                  blurRadius: 5.0,
                  spreadRadius: 2.0,
                  offset: Offset(5, 5),
                )]
              ),
              child: taxi.getOffers() != null ? SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: <Widget>[
                    for(var offer in taxi.getOffers()) Padding(
                      padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 8, bottom: 8),
                      child: TaxiOffer(offer: offer),
                    ),
                  ],
                ),
              ) : taxi.getRequestingOffers() ? 
                Container(
                 height: 160,
                 width: double.infinity, child: Center(child: CircularProgressIndicator())
                )
                :
                Container(width: double.infinity, child: Center(child: Text('error'))),
            ),
            SizedBox(height: 20),
            Container(
              width: double.infinity,
              child: RaisedButton(
                child: Text(translate('taxi_query.request')),
                onPressed: taxi.getSelectedOffer() == null ? null : (){
                  taxi.setRequestingRide(true);
                },
              ),
            ),
          ],
        ),
      )
    );
  }
}

class TaxiOffer extends StatelessWidget {
  final Offer _offer;

  const TaxiOffer({
    Key key,
    Offer offer,
  }) : this._offer = offer, super(key: key);

  @override
  Widget build(BuildContext context) {
    final taxi = Provider.of<Taxi>(context);
    return GestureDetector(
      onTap: (){
        if(_offer.enabled) taxi.setSelectedOffer(_offer);
      },
      child: Container(
        width: 90,
        padding: EdgeInsets.only(left: 8, right: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          border: Border.all(width: taxi.getSelectedOffer()!=_offer ? 0 : 2),
        ),
        foregroundDecoration: _offer.enabled ? null : BoxDecoration(
          color: Colors.grey,
          backgroundBlendMode: BlendMode.saturation,
        ),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
              child: Container(
                padding: EdgeInsets.only(bottom: 2, top: 2, left: 10, right: 10),
                decoration: BoxDecoration(
                  color: _offer.enabled ? Colors.black : Colors.grey,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  translate(_offer.vehicleType.toString()),
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            CircleAvatar(
              radius: 32,
              child: CircleAvatar(
                radius: 30,
                child: Image.asset('assets/${_offer.vehicleType.toString().replaceFirst('.', '/')}.png'),
                // child: Image.asset('assets/VehicleType/sedan.png'),
                backgroundColor: _offer.enabled ? Colors.white : Colors.grey,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
              child: Text(
                translate('taxi_query.price', args: {'price': formatNumber(context, _offer.price)}),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MapArea extends StatelessWidget {
  const MapArea({
    Key key,
    @required this.state,
  }) : super(key: key);

  final MapState state;

  @override
  Widget build(BuildContext context) {
    final taxi = Provider.of<Taxi>(context);

    return FlutterMap(
      mapController: state.controller,
      options: MapOptions(
        center: center,
        minZoom: 10,
        maxZoom: 18,
        zoom: 15.0,
        onPositionChanged: (mp, r){
          state.centerChanged(mp.center);
        },
        // swPanBoundary: LatLng(26.485096, 53.869411),
        // nePanBoundary: LatLng(26.604128, 54.059012),
      ),
      layers: [
        TileLayerOptions(
          urlTemplate: "https://api.tiles.mapbox.com/v4/"
              "{id}/{z}/{x}/{y}@2x.png?access_token={accessToken}",
          additionalOptions: {
            'accessToken': leafLetAccessToken,
            'id': 'mapbox.streets',
          },
        ),
        CircleLayerOptions(
          circles: [
            if(state.currentLocation()!=null) CircleMarker(
              point: LatLng(state.currentLocation().latitude, state.currentLocation().longitude),
              radius: 7,
              color: Colors.blue,
            ),
          ],
        ),
        MarkerLayerOptions(
          markers: [
            if(taxi.getPickup()!=null) Marker(
              width: 40.0,
              height: 40.0,
              point: LatLng(taxi.getPickup().lat, taxi.getPickup().lng),
              builder: (ctx) =>
              Container(
                child: Image.asset('assets/map/pickup.png'),
              ),
              anchorPos: AnchorPos.align(AnchorAlign.top),
            ),
            if(taxi.getDestination()!=null) Marker(
              width: 40.0,
              height: 40.0,
              point: LatLng(taxi.getDestination().lat, taxi.getDestination().lng),
              builder: (ctx) =>
              Container(
                child: Image.asset('assets/map/destination.png'),
              ),
              anchorPos: AnchorPos.align(AnchorAlign.top),
            ),
            if(taxi.getRideApproach()!=null) Marker(
              width: 40.0,
              height: 40.0,
              point: taxi.getRideApproach().location,
              builder: (ctx) =>
              Container(
                child: Transform.rotate(
                  angle: pi * (taxi.getRideApproach().heading + 175) / 180,
                  child: Image.asset('assets/map/driver.png', color: Colors.black),
                ),
              ),
              anchorPos: AnchorPos.align(AnchorAlign.top),
            ),
          ],
        ),
        if(taxi.route!=null) PolylineLayerOptions(
          polylines: [
            Polyline(
              points: taxi.route.points,
              strokeWidth: 4,
              color: Colors.purple,
            ),
          ],
        ),
      ],
    );
  }
}

class DestinationAlert extends StatelessWidget {
  const DestinationAlert({
    Key key,
    @required this.state,
  }) : super(key: key);

  final MapState state;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 80,
      left: 20,
      right: 20,
      height: 40,
      child: Container(
        decoration: BoxDecoration(
          color: Color.fromRGBO(255, 255, 255, 1),
          borderRadius: BorderRadius.circular(4),
          boxShadow: [BoxShadow(
            color: Colors.grey,
            blurRadius: 5.0,
            spreadRadius: 2.0,
            offset: Offset(5, 5),
          )]
        ),
        child: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                height: 20,
                width: 20,
                child: Image.asset('assets/map/destination.png'),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsetsDirectional.only(end: 10),
                child: GestureDetector(
                  onTap: () async{
                    final selected = await showSearch(context: context, delegate: AddressSearch(translate('taxi_query.destination.label'), lat: this.state.controller.center.latitude, lng: this.state.controller.center.longitude));
                    if(selected != null){
                      // state.setLocation(selected);
                      state.controller.move(LatLng(selected.lat, selected.lng), 17);
                    }
                  },
                  child: Text(
                    translate('taxi_query.destination.question'),
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PickupAlert extends StatelessWidget {
  const PickupAlert({
    Key key,
    @required this.state,
  }) : super(key: key);

  final MapState state;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 80,
      left: 20,
      right: 20,
      height: 40,
      child: Container(
        decoration: BoxDecoration(
          color: Color.fromRGBO(255, 255, 255, 1),
          borderRadius: BorderRadius.circular(4),
          boxShadow: [BoxShadow(
            color: Colors.grey,
            blurRadius: 5.0,
            spreadRadius: 2.0,
            offset: Offset(5, 5),
          )]
        ),
        child: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                height: 20,
                width: 20,
                child: Image.asset('assets/map/pickup.png'),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsetsDirectional.only(end: 10),
                child: GestureDetector(
                  onTap: () async{
                    final selected = await showSearch(context: context, delegate: AddressSearch(translate('taxi_query.pickup.label'), lat: this.state.controller.center.latitude, lng: this.state.controller.center.longitude));
                    if(selected != null){
                      // state.setLocation(selected);
                      state.controller.move(LatLng(selected.lat, selected.lng), 17);
                    }
                  },
                  child: Text(
                    translate('taxi_query.pickup.question'),
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AddressPanel extends StatelessWidget {
  const AddressPanel({
    Key key,
    @required this.state,
  }) : super(key: key);

  final MapState state;

  @override
  Widget build(BuildContext context) {
    final taxi = Provider.of<Taxi>(context);
    return Positioned(
      top: 100,
      left: 20,
      right: 20,
      // height: 40,
      child: Container(
        decoration: BoxDecoration(
          color: Color.fromRGBO(255, 255, 255, 1),
          borderRadius: BorderRadius.circular(4),
          boxShadow: [BoxShadow(
            color: Colors.grey,
            blurRadius: 5.0,
            spreadRadius: 2.0,
            offset: Offset(5, 5),
          )]
        ),
        child: Column(
          children: <Widget>[
            if(taxi.getPickup()==null) GestureDetector(
                onTap: () async{
                  final selected = await showSearch(context: context, delegate: AddressSearch(translate('taxi_query.pickup.label'), lat: this.state.controller.center.latitude, lng: this.state.controller.center.longitude));
                  if(selected != null){
                    state.controller.move(LatLng(selected.lat, selected.lng), 17);
                  }
                },
                child: Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: SizedBox(
                      height: 20,
                      width: 20,
                      child: Image.asset('assets/map/pickup.png', color: Colors.blue),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 14.0, bottom: 14.0),
                      child: state.getRequestingLocation() ? Center(child: SizedBox(height: 21, width: 21, child: CircularProgressIndicator())) : Text(
                        "${state.getLocation()?.name ?? ''}",
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if(taxi.getPickup()!=null) Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: SizedBox(
                    height: 20,
                    width: 20,
                    child: Image.asset('assets/map/pickup.png'),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 14.0, bottom: 14.0),
                    child: Text(
                      "${taxi.getPickup()?.name ?? ''}",
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                if(taxi.getPickup()!=null && taxi.getRide()==null && !taxi.getRequestingRide()) RawMaterialButton(
                  constraints: BoxConstraints(),
                  padding: EdgeInsets.all(0),
                  onPressed: (){
                    taxi.setPickup(null);
                  },
                  child: Icon(Icons.clear, size: 20),
                ),
              ],
            ),
            if(taxi.getPickup()!=null && taxi.getDestination()==null) GestureDetector(
                onTap: () async{
                  final selected = await showSearch(context: context, delegate: AddressSearch(translate('taxi_query.destination.label'), lat: this.state.controller.center.latitude, lng: this.state.controller.center.longitude));
                  if(selected != null){
                    state.controller.move(LatLng(selected.lat, selected.lng), 17);
                  }
                },
                child: Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: SizedBox(
                      height: 20,
                      width: 20,
                      child: Image.asset('assets/map/destination.png', color: Colors.blue),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 14.0, bottom: 14.0),
                      child: state.getRequestingLocation() ? Center(child: SizedBox(height: 21, width: 21, child: CircularProgressIndicator())) : Text(
                        "${state.getLocation()?.name ?? ''}",
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if(taxi.getDestination()!=null) Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: SizedBox(
                    height: 20,
                    width: 20,
                    child: Image.asset('assets/map/destination.png'),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 14.0, bottom: 14.0),
                    child: Text(
                      "${taxi.getDestination().name}",
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                if(taxi.getDestination()!=null && taxi.getRide()==null && !taxi.getRequestingRide()) RawMaterialButton(
                  constraints: BoxConstraints(),
                  padding: EdgeInsets.all(0),
                  onPressed: (){
                    taxi.setDestination(null);
                  },
                  child: Icon(Icons.clear, size: 20),
                ),
              ],
            ),
          ],
        ),
      )
    );
  }
}