import 'package:flutter/material.dart';
import 'package:for_kish/api/map.dart';
import 'package:for_kish/helpers/types.dart';

class AddressSearch extends SearchDelegate<Location> {
  double lat;
  double lng;

  AddressSearch(String label, {@required this.lat, @required this.lng}): super(searchFieldLabel: label);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(icon: Icon(Icons.clear), onPressed: (){
        query = "";
      })
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      // icon: AnimatedIcon(
      //   icon: AnimatedIcons.menu_arrow, 
      //   progress: transitionAnimation,
      // ),
      icon: Icon(Icons.arrow_back),
      onPressed: (){
        close(context, null);
      }
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return null;
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final result = fetchAddress(query, lat, lng);
    return Column(
      children: <Widget>[
        FutureBuilder(
          future: result,
          builder: (BuildContext context,
              AsyncSnapshot<LocationList> snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return Expanded(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
                break;
              default:
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  return Expanded(
                    child: ListView.separated(
                      separatorBuilder: (context, index) => Divider(
                        color: Colors.grey,
                      ),
                      itemCount: snapshot.data.locations.length,
                      itemBuilder: (context, index) {
                        final Location result =
                            snapshot.data.locations[index];
                        return ListTile(
                          title: Text(result.name,
                              style: TextStyle(
                                  fontWeight: FontWeight.w700, fontSize: 18)),
                          subtitle: Text(result.address),
                          onTap: (){
                            close(context, result);
                          },
                        );
                      },
                    ),
                  );
                }
            }
          },
        )
      ],
    );
  }
}