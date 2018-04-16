import 'package:flutter/material.dart';

import 'package:material_search/material_search.dart';

void main() => runApp(new ExampleApp());

class ExampleApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Material Search Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(title: 'Material Search Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _names =  [
    'Igor Minar',
    'Brad Green',
    'Dave Geddes',
    'Naomi Black',
    'Greg Weber',
    'Dean Sofer',
    'Wes Alvaro',
    'John Scott',
    'Daniel Nadasi',
  ];

  String _name = 'No one';

  _buildMaterialSearchPage(BuildContext context) {
    return new MaterialPageRoute<String>(
      settings: new RouteSettings(
        name: 'material_search',
        isInitialRoute: false,
      ),
      builder: (BuildContext context) {
        return new Material(
          child: new MaterialSearch<String>(
            placeholder: 'Search',
            results: _names.map((String v) => new MaterialSearchResult<String>(
              icon: Icons.person,
              value: v,
              text: "Mr(s). $v",
            )).toList(),
            filter: (dynamic value, String criteria) {
              return value.toLowerCase().trim()
                .contains(new RegExp(r'' + criteria.toLowerCase().trim() + ''));
            },
            onSelect: (dynamic value) => Navigator.of(context).pop(value),
          ),
        );
      }
    );
  }

  _showMaterialSearch(BuildContext context) {
    Navigator.of(context)
      .push(_buildMaterialSearchPage(context))
      .then((dynamic value) {
        setState(() => _name = value as String);
      });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
        actions: <Widget>[
          new IconButton(
            onPressed: () {
              _showMaterialSearch(context);
            },
            tooltip: 'Search',
            icon: new Icon(Icons.search),
          )
        ],
      ),
      body: new Center(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
              child: new MaterialSearchInput<String>(
                placeholder: 'Name',
                results: _names.map((String v) => new MaterialSearchResult<String>(
                  icon: Icons.person,
                  value: v,
                  text: "Mr(s). $v",
                )).toList(),
                filter: (dynamic value, String criteria) {
                  return value.toLowerCase().trim()
                    .contains(new RegExp(r'' + criteria.toLowerCase().trim() + ''));
                },
                onSelect: (dynamic value) {
                  print(value);
                },
              ),
            ),
            new Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
              child: new Text("You found: ${_name ?? 'No one'}"),
            ),
          ],
        ),
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: () {
          _showMaterialSearch(context);
        },
        tooltip: 'Search',
        child: new Icon(Icons.search),
      ),
    );
  }
}
