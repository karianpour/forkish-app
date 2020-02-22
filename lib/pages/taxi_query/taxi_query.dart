import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:for_kish/helpers/number.dart';
import 'package:for_kish/helpers/types.dart';
import 'package:for_kish/pages/address/address_query.dart';
import 'package:functional_widget_annotation/functional_widget_annotation.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/map_hook.dart';

part 'taxi_query.g.dart';

final LatLng center = LatLng(26.532065, 53.977069); // center of kish island
// const leafLetAccessToken = "pk.eyJ1Ijoia2FyaWFucG91ciIsImEiOiJjazZkbGJtMWYwODNzM2VudmVpdzU5dDJhIn0.LCWmMFkfKR_qDeed8Gsnhw";
const leafLetAccessToken = "pk.eyJ1Ijoia2FyaWFucG91ciIsImEiOiJjazZnY21iMW4wMnV0M21wOGFwazl0MXVkIn0.58NkL2VWsgUo16JGBz2CZw";

@widget
Widget taxiQuery(BuildContext context) {
  final state = useMapControllerHook();

  return Stack(
    children: <Widget>[
      MapArea(state: state),
      if(state.getPickup()==null || state.getDestination()==null) CenterMarker(state: state),
      if(state.getRide()==null) AddressPanel(state: state),
      if(state.getPickup()==null) PickupAlert(state: state),
      if(state.getPickup()!=null && state.getDestination()==null) DestinationAlert(state: state),
      if(state.getPickup()!=null && state.getDestination()!=null && !state.getRequestingRide() && state.getRide()==null) OfferSelection(state: state),
      if(state.getRequestingRide()) RideQueryPanel(state: state,),
      if(state.getRide()!=null) RidePanel(state: state),
    ],
  );
}

class CenterMarker extends StatelessWidget {
  const CenterMarker({
    Key key,
    @required this.state,
  }) : super(key: key);

  final MapControllerHookState state;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: (){
          if(!state.getRequestingLocation())
            state.confirmed();
        },
        child: SizedBox(
          height: 80,
          child: Align(
            child: Container(
              foregroundDecoration: !state.getRequestingLocation() ? null : BoxDecoration(
                color: Colors.grey,
                backgroundBlendMode: BlendMode.saturation,
              ),
              child: Image.asset('assets/map/marker.png')
            ),
            alignment: Alignment.topCenter,
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

  final MapControllerHookState state;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 40,
      left: 20,
      right: 20,
      // height: 250,
      child: Column(
        children: <Widget>[
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
                        child: buildDriver(),
                      ),
                      buildActions(),
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
              child: Text(
                translate('taxi_query.cancel_ride'),
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              color: Colors.blue,
              onPressed: (){},
              onLongPress: (){
                state.cancelRide();
              },
            ),
          ),
        ],
      ),
    );
  }

  Container buildActions() {
    return Container(
      padding: EdgeInsets.all(8.0),
      width: 80,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          RaisedButton(
            child: Icon(Icons.call, color: Colors.white,),
            // child: Text(
            //   translate('taxi_query.callDriver'),
            //   style: TextStyle(
            //     color: Colors.white,
            //   ),
            // ),
            color: Colors.blue,
            onPressed: () async {
              print('call ${state.getRide().driver.phone}');
              if(await canLaunch("tel:${state.getRide().driver.phone}")){
                var r = await launch("tel:${state.getRide().driver.phone}");
                print("result : $r");
              }else{
                print('cant lunch');
              }
            },
          ),
          RaisedButton(
            child: Icon(Icons.more, color: Colors.white,),
            // child: Text(
            //   translate('taxi_query.options'),
            //   style: TextStyle(
            //     color: Colors.white,
            //   ),
            // ),
            color: Colors.blue,
            onPressed: (){
              print('call');
            },
          ),
        ],
      ),
    );
  }

  Column buildDriver() {
    final score = state.getRide().driver.score;
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
                  Text(state.getRide().driver.name),
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
          child: KishVehiclePlate(vehicle: state.getRide().vehicle)
        ),
      ],
    );
  }

  Container buildRideData(BuildContext context) {
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
              data: translate("taxi_query.distanceKilometer", args: {"distance": formatNumber(context, state.getRideApproach().distance / 1000)}),
            ),
            RideDatalet(
              label: translate("taxi_query.eta"), 
              data: translate("taxi_query.etaMinute", args: {"eta": formatNumber(context, (state.getRideApproach().eta / 60).ceil())}),
            ),
            RideDatalet(
              label: translate("taxi_query.figure"), 
              data: translate('taxi_query.price', args: {'price': formatNumber(context, state.getRide().price)}),
            ),
            RideDatalet(
              label: translate("taxi_query.paymentMethod"), 
              data: translate(state.getRide().paymentType.toString()),
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
  final MapControllerHookState state;

  @override
  Widget build(BuildContext context) {
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
              child: Text(
                translate('taxi_query.cancel_request'),
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              color: Colors.blue,
              onPressed: (){},
              onLongPress: (){
                state.cancelRide();
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

  final MapControllerHookState state;

  @override
  Widget build(BuildContext context) {
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
              child: state.getOffers() != null ? SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: <Widget>[
                    for(var offer in state.getOffers()) Padding(
                      padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 8, bottom: 8),
                      child: TaxiOffer(offer: offer, state: state),
                    ),
                  ],
                ),
              ) : state.getRequestingOffers() ? 
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
                child: Text(
                  translate('taxi_query.request'),
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                color: Colors.blue,
                onPressed: state.getSelectedOffer() == null ? null : (){
                  state.setRequestingRide(true);
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
  final MapControllerHookState _state;

  const TaxiOffer({
    Key key,
    Offer offer,
    MapControllerHookState state,
  }) : this._offer = offer, this._state = state, super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        if(_offer.enabled) _state.setSelectedOffer(_offer);
      },
      child: Container(
        width: 90,
        padding: EdgeInsets.only(left: 8, right: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          border: Border.all(width: _state.getSelectedOffer()!=_offer ? 0 : 2),
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

  final MapControllerHookState state;

  @override
  Widget build(BuildContext context) {
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
        swPanBoundary: LatLng(26.485096, 53.869411),
        nePanBoundary: LatLng(26.604128, 54.059012),
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
            if(state.getPickup()!=null) Marker(
              width: 40.0,
              height: 40.0,
              point: LatLng(state.getPickup().lat, state.getPickup().lng),
              builder: (ctx) =>
              Container(
                child: Image.asset('assets/map/pickup.png'),
              ),
              anchorPos: AnchorPos.align(AnchorAlign.top),
            ),
            if(state.getDestination()!=null) Marker(
              width: 40.0,
              height: 40.0,
              point: LatLng(state.getDestination().lat, state.getDestination().lng),
              builder: (ctx) =>
              Container(
                child: Image.asset('assets/map/destination.png'),
              ),
              anchorPos: AnchorPos.align(AnchorAlign.top),
            ),
          ],
        ),
        if(state.route!=null) PolylineLayerOptions(
          polylines: [
            Polyline(
              points: state.route.points,
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

  final MapControllerHookState state;

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

  final MapControllerHookState state;

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

  final MapControllerHookState state;

  @override
  Widget build(BuildContext context) {
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
            if(state.getPickup()==null) Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: SizedBox(
                    height: 20,
                    width: 20,
                    child: Image.asset('assets/map/marker.png'),
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
            if(state.getPickup()!=null) Row(
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
                      "${state.getPickup()?.name ?? ''}",
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                if(state.getPickup()!=null && state.getRide()==null && !state.getRequestingRide()) RawMaterialButton(
                  constraints: BoxConstraints(),
                  padding: EdgeInsets.all(0),
                  onPressed: (){
                    state.setPickup(null);
                  },
                  child: Icon(Icons.clear, size: 20),
                ),
              ],
            ),
            if(state.getPickup()!=null && state.getDestination()==null) Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: SizedBox(
                    height: 20,
                    width: 20,
                    child: Image.asset('assets/map/marker.png'),
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
            if(state.getDestination()!=null) Row(
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
                      "${state.getDestination().name}",
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                if(state.getDestination()!=null && state.getRide()==null && !state.getRequestingRide()) RawMaterialButton(
                  constraints: BoxConstraints(),
                  padding: EdgeInsets.all(0),
                  onPressed: (){
                    state.setDestination(null);
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