import 'dart:async';

import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

typedef String FormFieldFormatter<T>(T v);
typedef bool MaterialSearchFilter<T>(T v, String c);
typedef int MaterialSearchSort<T>(T a, T b, String c);
typedef Future<List<MaterialSearchResult>> MaterialResultsFinder(String c);

class MaterialSearchResult<T> extends StatelessWidget {
  const MaterialSearchResult({
    Key key,
    this.value,
    this.text,
    this.icon,
  }) : super(key: key);

  final T value;
  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return new Container(
      child: new Row(
        children: <Widget>[
          new Container(width: 70.0, child: new Icon(icon)),
          new Expanded(child: new Text(text, style: Theme.of(context).textTheme.subhead)),
        ],
      ),
      height: 56.0,
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
    this.limit: 10,
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
  final int limit;
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
        if (widget.getResults != null) {
          _getResultsDebounced();
        }
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

      //TODO: debounce widget.results too
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
    _resultsTimer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    var results = (widget.results ?? _results)
      .where((MaterialSearchResult result) {
        if (widget.filter != null) {
          return widget.filter(result.value, _criteria);
        }
        //only apply default filter if used the `results` option
        //because getResults may already have applied some filter if `filter` option was omited.
        else if (widget.results != null) {
          return _filter(result.value, _criteria);
        }

        return true;
      })
      .toList();

    if (widget.sort != null) {
      results.sort((a, b) => widget.sort(a.value, b.value, _criteria));
    }

    results = results
      .take(widget.limit)
      .toList();

    IconThemeData iconTheme = Theme.of(context).iconTheme.copyWith(color: Colors.black);

    return new Scaffold(
      appBar: new AppBar(
        backgroundColor: Colors.white,
        iconTheme: iconTheme,
        title: new TextField(
          controller: _controller,
          autofocus: true,
          decoration: new InputDecoration.collapsed(hintText: widget.placeholder),
          style: Theme.of(context).textTheme.title,
        ),
        actions: _criteria.length == 0 ? [] : [
          new IconButton(
            icon: new Icon(Icons.clear),
            onPressed: () {
              setState(() {
                _controller.text = _criteria = '';
              });
            }
          ),
        ],
      ),
      body: _loading
        ? new Center(
            child: new Padding(
              padding: const EdgeInsets.only(top: 50.0),
              child: new CircularProgressIndicator()
            ),
          )
        : new SingleChildScrollView(
            child: new Column(
              children: results.map((MaterialSearchResult result) {
                return new InkWell(
                  onTap: () => widget.onSelect(result.value),
                  child: result,
                );
              }).toList(),
            ),
          ),
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

class MaterialSearchInput<T> extends FormField<T> {
  MaterialSearchInput({
    Key key,
    FormFieldSetter<T> onSaved,
    FormFieldValidator<T> validator,
    bool autovalidate: true,

    this.placeholder,
    this.formatter,
    this.results,
    this.getResults,
    this.filter,
    this.sort,
    this.onSelect,
  }) : super(
    key: key,
    onSaved: onSaved,
    validator: validator,
    autovalidate: autovalidate,
    builder: (FormFieldState<T> field) {
      final _MaterialSearchInputState<T> state = field;

      return state._build(state.context);
    },
  );

  final String placeholder;
  final FormFieldFormatter<T> formatter;

  final List<MaterialSearchResult<T>> results;
  final MaterialResultsFinder getResults;
  final MaterialSearchFilter<T> filter;
  final MaterialSearchSort<T> sort;
  final ValueChanged<T> onSelect;

  @override
  _MaterialSearchInputState<T> createState() => new _MaterialSearchInputState<T>();
}

class _MaterialSearchInputState<T> extends State<MaterialSearchInput<T>> with FormFieldState<T> {
  _buildMaterialSearchPage(BuildContext context) {
    return new _MaterialSearchPageRoute<T>(
      settings: new RouteSettings(
        name: 'material_search',
        isInitialRoute: false,
      ),
      builder: (BuildContext context) {
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
    );
  }

  _showMaterialSearch(BuildContext context) {
    Navigator.of(context)
      .push(_buildMaterialSearchPage(context))
      .then((Object value) {
        onChanged(value);
        widget.onSelect(value);
      });
  }

  bool get _isEmpty {
    return value == null;
  }

  Widget _build(BuildContext context) {
    final TextStyle valueStyle = Theme.of(context).textTheme.subhead;

    return new InkWell(
      onTap: () => _showMaterialSearch(context),
      child: new InputDecorator(
        isEmpty: _isEmpty,
        decoration: new InputDecoration(
          labelStyle: _isEmpty ? null : valueStyle,
          labelText: widget.placeholder,
          errorText: errorText,
        ),
        baseStyle: valueStyle,
        child: _isEmpty ? null : new Text(
          widget.formatter != null ? widget.formatter(value) : value.toString(),
          style: valueStyle
        ),
      ),
    );
  }
}