library material_search;

import 'package:flutter/material.dart';

typedef bool MaterialSearchFilter<T>(T v, String c);
typedef int MaterialSearchSort<T>(T v, String c);

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
    this.filter,
    this.sort,
    this.onSelect,
    this.loading: false,
  }) : super(key: key);

  final String placeholder;

  final List<MaterialSearchResult<T>> results;
  final MaterialSearchFilter<T> filter;
  final MaterialSearchSort<T> sort;
  final ValueChanged<T> onSelect;
  final bool loading;

  @override
  _MaterialSearchState<T> createState() => new _MaterialSearchState<T>();
}

class _MaterialSearchState<T> extends State<MaterialSearch> {
  String _criteria = '';
  TextEditingController _controller = new TextEditingController();

  _filter(T v, String c) {
    return v.toString().toLowerCase().trim()
      .contains(new RegExp(r'' + c.toLowerCase().trim() + ''));
  }

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        _criteria = _controller.value.text;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var results = widget.results
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
        widget.loading
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

class MaterialSearchInput<T> extends StatelessWidget {
  const MaterialSearchInput({
    Key key,
    this.placeholder,
    this.results,
    this.filter,
    this.sort,
    this.onSelect,
    this.valueText,
    this.loading: false,
  }) : super(key: key);

  final String placeholder;

  final List<MaterialSearchResult<T>> results;
  final MaterialSearchFilter<T> filter;
  final MaterialSearchSort<T> sort;
  final ValueChanged<T> onSelect;
  final bool loading;

  final String valueText;

  _showMaterialSearch(BuildContext context) {
    Navigator.of(context).push(new MaterialPageRoute<T>(
      builder: (BuildContext context) => new Material(
        child: new MaterialSearch(
          placeholder: placeholder,
          results: results,
          filter: filter,
          sort: sort,
          loading: loading,
          onSelect: (T value) => Navigator.of(context).pop(value),
        ),
      )
    )).then((T value) {
      onSelect(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle valueStyle = Theme.of(context).textTheme.subhead;

    return new InkWell(
      onTap: () => _showMaterialSearch(context),
      child: new InputDecorator(
        decoration: new InputDecoration(
          labelText: placeholder,
          labelStyle: (valueText != null && valueText.length > 0) ? null : valueStyle,
        ),
        baseStyle: valueStyle,
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            new Text(valueText, style: valueStyle),
          ],
        ),
      ),
    );
  }
}