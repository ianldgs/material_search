library material_search;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

typedef bool MaterialSearchFilter<T>(T v, String c);
typedef int MaterialSearchSort<T>(T v, String c);
typedef Future<List<MaterialSearchResult>> MaterialResultsFinder(String c);

class MaterialSearchResult<T> extends StatelessWidget {
  const MaterialSearchResult({
    Key key,
    this.value,
    this.text,
  }) : super(key: key);

  final T value;
  final String text;

  @override
  Widget build(BuildContext context) {
    return new Container(
      child: new Text(text, style: Theme.of(context).textTheme.subhead),
      padding: new EdgeInsets.only(left: 48.0),
      height: 52.0,
      alignment: Alignment.centerLeft,
    );
  }
}

class MaterialSearch<T> extends StatefulWidget {
  MaterialSearch({
    Key key,
    this.placeholder,
    this.results,
    this.getResults,
    this.filter,
    this.sort,
    this.onSelect,
  }) : assert(() {
         if (results == null && getResults == null
             || results != null && getResults != null) {
           throw new AssertionError('Either provide a function to get the results, or the results.');
         }

         return true;
       }()),
       super(key: key);

  final String placeholder;

  final List<MaterialSearchResult<T>> results;
  final MaterialResultsFinder getResults;
  final MaterialSearchFilter<T> filter;
  final MaterialSearchSort<T> sort;
  final ValueChanged<T> onSelect;

  @override
  _MaterialSearchState<T> createState() => new _MaterialSearchState<T>();
}

class _MaterialSearchState<T> extends State<MaterialSearch> {
  bool _loading = false;
  List<MaterialSearchResult<T>> _results = [];

  String _criteria = '';
  TextEditingController _controller = new TextEditingController();

  _filter(T v, String c) {
    return v.toString().toLowerCase().trim()
      .contains(new RegExp(r'' + c.toLowerCase().trim() + ''));
  }

  @override
  void initState() {
    super.initState();

    if (widget.getResults != null) {
      _getResultsDebounced();
    }

    _controller.addListener(() {
      setState(() {
        _criteria = _controller.value.text;
        _getResultsDebounced();
      });
    });
  }

  Timer _resultsTimer;
  Future _getResultsDebounced() async {
    if (_results.length == 0) {
      setState(() {
        _loading = true;
      });
    }

    if (_resultsTimer != null && _resultsTimer.isActive) {
      _resultsTimer.cancel();
    }

    _resultsTimer = new Timer(new Duration(milliseconds: 400), () async {
      if (!mounted) {
        return;
      }

      setState(() {
        _loading = true;
      });

      var results = await widget.getResults(_criteria);

      if (!mounted) {
        return;
      }

      setState(() {
        _loading = false;
        _results = results;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _resultsTimer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    var results = (widget.results ?? _results)
      .where((MaterialSearchResult result) {
        return widget.filter != null
          ? widget.filter(result.value, _criteria)
          : _filter(result.value, _criteria);
      })
      .toList();

    if (widget.sort != null) {
      results.sort((a, b) => widget.sort(a.value, _criteria));
    }

    results = results
      .take(5)
      .toList();

    return new Column(
      children: <Widget>[
        new Container(
          decoration: new BoxDecoration(
            color: Colors.white,
            boxShadow: kElevationToShadow[3]
          ),
          margin: const EdgeInsets.only(top: 24.0),
          padding: const EdgeInsets.only(top: 5.0, bottom: 4.0),
          child: new Row(
            children: <Widget>[
              new BackButton(),
              new Expanded(child: new TextField(
                controller: _controller,
                autofocus: true,
                decoration: new InputDecoration.collapsed(hintText: widget.placeholder),
                style: Theme.of(context).textTheme.title,
              )),
              _criteria.length > 0
                ? new IconButton(
                    icon: new Icon(Icons.clear),
                    onPressed: () {
                      setState(() {
                        _controller.text = _criteria = '';
                      });
                    }
                  )
                : new Column(children: []),
            ],
          ),
        ),
        _loading
            ? new Padding(
                padding: const EdgeInsets.only(top: 50.0),
                child: new CircularProgressIndicator()
              )
            : new Container(
              margin: const EdgeInsets.only(top: 10.0),
              child: new SingleChildScrollView(
                child: new Column(
                  children: results.map((MaterialSearchResult result) {
                    return new InkWell(
                      onTap: () => widget.onSelect(result.value),
                      child: result,
                    );
                  }).toList(),
                ),
              ),
            ),
      ],
    );
  }
}

class _MaterialSearchPageRoute<T> extends MaterialPageRoute<T> {
  _MaterialSearchPageRoute({
    @required WidgetBuilder builder,
    RouteSettings settings: const RouteSettings(),
    maintainState: true,
    bool fullscreenDialog: false,
  }) : assert(builder != null),
       super(builder: builder, settings: settings, maintainState: maintainState, fullscreenDialog: fullscreenDialog);
}

class MaterialSearchInput<T> extends StatefulWidget {
  const MaterialSearchInput({
    Key key,
    this.placeholder,
    this.results,
    this.getResults,
    this.filter,
    this.sort,
    this.onSelect,
    this.valueText,
  }) : super(key: key);

  final String placeholder;

  final List<MaterialSearchResult<T>> results;
  final MaterialResultsFinder getResults;
  final MaterialSearchFilter<T> filter;
  final MaterialSearchSort<T> sort;
  final ValueChanged<T> onSelect;

  final String valueText;

  @override
  _MaterialSearchInputState<T> createState() => new _MaterialSearchInputState<T>();
}

class _MaterialSearchInputState<T> extends State<MaterialSearchInput> {
  _MaterialSearchPageRoute _materialPageRoute;

  _materialSearchBuilder(BuildContext context) {
    return new Material(
      child: new MaterialSearch<T>(
        placeholder: widget.placeholder,
        results: widget.results,
        getResults: widget.getResults,
        filter: widget.filter,
        sort: widget.sort,
        onSelect: (T value) => Navigator.of(context).pop(value),
      ),
    );
  }

  _buildMaterialSearchPage(BuildContext context) {
    return _materialPageRoute = new _MaterialSearchPageRoute<T>(
        settings: new RouteSettings(
          name: 'material_search',
          isInitialRoute: false,
        ),
        builder: _materialSearchBuilder
    );
  }

  _showMaterialSearch(BuildContext context) {
    Navigator.of(context).push(_buildMaterialSearchPage(context)).then((T value) {
      widget.onSelect(value);
    }).whenComplete(() {
      _materialPageRoute = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle valueStyle = Theme.of(context).textTheme.subhead;

    return new InkWell(
      onTap: () => _showMaterialSearch(context),
      child: new InputDecorator(
        decoration: new InputDecoration(
          labelText: widget.placeholder,
          labelStyle: (widget.valueText != null && widget.valueText.length > 0) ? null : valueStyle,
        ),
        baseStyle: valueStyle,
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            new Text(widget.valueText, style: valueStyle),
          ],
        ),
      ),
    );
  }
}