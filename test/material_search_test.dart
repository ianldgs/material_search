// This is a basic Flutter widget test.
// To perform an interaction with a widget in your test, use the WidgetTester utility that Flutter
// provides. For example, you can send tap and scroll gestures. You can also use WidgetTester to
// find child widgets in the widget tree, read text, and verify that the values of widget properties
// are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:material_search/material_search.dart';

const _names =  const [
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

class SelectMock<T> extends Mock {
  onSelect(T value) {}
}

void main() {
  testWidgets('MaterialSearch Selection', (WidgetTester tester) async {
    var selectMock = new SelectMock<String>();

    await tester.pumpWidget(
      new StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return new MaterialApp(
            home: new Material(
              child: new MaterialSearch(
                placeholder: 'Find something',
                results: _names.map((String v) => new MaterialSearchResult<String>(
                  icon: Icons.person,
                  value: v,
                  text: v,
                )).toList(),
                onSelect: selectMock.onSelect,
              ),
            ),
          );
        },
      ),
    );

    _names.forEach((String name) {
      expect(find.text(name), findsOneWidget);
    });

    expect(find.text('Find something'), findsOneWidget);
    expect(find.byIcon(Icons.clear), findsNothing);

    await tester.enterText(find.byType(TextField), _names[2]);
    await tester.pump();

    //clear button, to empty the search
    //only shown when some text is typed
    expect(find.byIcon(Icons.clear), findsOneWidget);

    expect(find.text(_names[2]), findsNWidgets(2)); //the text input and the result

    _names
      .where((String name) => name != _names[2])
      .forEach((String name) {
        expect(find.text(name), findsNothing);
      });

    //TODO: tap on the first result and assert onSelect has been called

    return;
  });

  testWidgets('MaterialSearchInput Validation', (WidgetTester tester) async {
    final formKey = new GlobalKey<FormState>();

    await tester.pumpWidget(
      new StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return new MaterialApp(
            home: new Material(
              child: new Form(
                key: formKey,
                child: new Column(
                  children: <Widget>[
                    new MaterialSearchInput<String>(
                      placeholder: 'Find something',
                      validator: (dynamic value) => value == null ? 'Required field' : null,
                      results: _names.map((String v) => new MaterialSearchResult<String>(
                        icon: Icons.person,
                        value: v,
                        text: v,
                      )).toList(),
                    ),
                    new MaterialButton(
                      child: new Text('Validate'),
                      onPressed: () {
                        formKey.currentState.validate();
                      }
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );

    expect(find.text('Find something'), findsOneWidget);
    expect(find.text('Required field'), findsNothing);

    await tester.tap(find.byType(MaterialButton));
    await tester.pump();

    expect(find.text('Required field'), findsOneWidget);

    return;
  });
}
