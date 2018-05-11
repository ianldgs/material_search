# material_search

Implements part of the material search pattern with flutter widgets.
https://material.io/guidelines/patterns/search.html

![Example](https://storage.googleapis.com/material-design/publish/material_v_12/assets/0Bzhp5Z4wHba3T1NKb1ltZkdUYzQ/patterns-search-expandable3.png)

## Getting Started

For help getting started with Flutter, view our online [documentation](http://flutter.io/).

For help on editing package code, view the [documentation](https://flutter.io/developing-packages/).

## Example

### App

Checkout the [Example app](/example/lib/main.dart)

### Raw Material Search

```dart
import 'package:material_search/material_search.dart';

const _list = const [
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

void main() {
  runApp(new Scaffold(
    body: new MaterialSearch<String>(
      placeholder: 'Search', //placeholder of the search bar text input

      getResults: (String criteria) async {
        var list = await _fetchList(criteria);
        return list.map((name) => new MaterialSearchResult<String>(
          value: name, //The value must be of type <String>
          text: name, //String that will be show in the list
          icon: Icons.person,
        )).toList();
      },
      //or
      results: _list.map((name) => new MaterialSearchResult<String>(
        value: name, //The value must be of type <String>
        text: name, //String that will be show in the list
        icon: Icons.person,
      )).toList(),

      //optional. default filter will look like this:
      filter: (String value, String criteria) {
        return value.toString().toLowerCase().trim()
          .contains(new RegExp(r'' + criteria.toLowerCase().trim() + ''));
      },
      //optional
      sort: (String value, String criteria) {
        return 0;
      },
      //callback when some value is selected, optional.
      onSelect: (String selected) {
        print(selected);
      },
      //callback when the value is submitted, optional.
      onSubmit: (String value) {
        print(value);
      },
    ),
  ));
}
```

### Material Search Input

```dart
import 'package:material_search/material_search.dart';

const _list = const [
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

void main() {
  String _selected;

  runApp(new Scaffold(
    body: new MaterialSearchInput<String>(
      //placeholder of the input and of the search bar text input
      placeholder: 'Search',
      //text of the input, to indicate which value is selected
      valueText: _selected ?? '',

      getResults: (String criteria) async {
        var list = await _fetchList(criteria);
        return list.map((name) => new MaterialSearchResult<String>(
          value: name, //The value must be of type <String>
          text: name, //String that will be show in the list
          icon: Icons.person,
        )).toList();
      },
      //or
      results: _list.map((name) => new MaterialSearchResult<String>(
        value: name, //The value must be of type <String>
        text: name, //String that will be show in the list
        icon: Icons.person,
      )).toList(),

      //optional. default filter will look like this:
      filter: (String value, String criteria) {
        return value.toString().toLowerCase().trim()
          .contains(new RegExp(r'' + criteria.toLowerCase().trim() + ''));
      },
      //optional
      sort: (String value, String criteria) {
        return 0;
      },
      //callback when some value is selected
      onSelect: (String selected) {
        if (selected == null) {
          //user closed the MaterialSearch without selecting any value
          return;
        }

        setState(() {
          _selected = selected;
        });
      },
    ),
  ));
}
```

## Notes

`MaterialSearchInput` takes the same arguments as `MaterialSearch`, and a few more.