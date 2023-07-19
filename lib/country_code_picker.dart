library countrycodepicker;

import 'package:flutter/material.dart';
import 'package:flutter_sim_country_code/flutter_sim_country_code.dart';

import 'country.dart';
import 'functions.dart';

const TextStyle _defaultItemTextStyle = const TextStyle(fontSize: 16);
const TextStyle _defaultItemCodeStyle = const TextStyle(
  fontSize: 16,
  color: Color(0xFFA1A7A2),
);
const TextStyle _defaultSearchInputStyle = const TextStyle(
  backgroundColor: Colors.transparent,
  color: Color(0xFF121212),
  fontSize: 16.0,
  fontWeight: FontWeight.w400,
  height: 1.1,
);
const String _kDefaultSearchHintText = 'Search';
const String countryCodePackageName = 'country_calling_code_picker';

class CountryPickerWidget extends StatefulWidget {
  /// This callback will be called on selection of a [Country].
  final ValueChanged<Country>? onSelected;

  /// [itemTextStyle] can be used to change the TextStyle of the Text in ListItem. Default is [_defaultItemTextStyle]
  final TextStyle itemTextStyle;

  /// [itemCodeStyle] can be used to change the TextStyle of the Text in ListItem. Default is [_defaultItemCodeStyle]
  final TextStyle itemCodeStyle;

  /// [searchInputStyle] can be used to change the TextStyle of the Text in SearchBox. Default is [searchInputStyle]
  final TextStyle searchInputStyle;

  /// [searchInputDecoration] can be used to change the decoration for SearchBox.
  final InputDecoration? searchInputDecoration;

  /// Flag icon size (width). Default set to 32.
  final double flagIconSize;

  ///Can be set to `true` for showing the List Separator. Default set to `false`
  final bool showSeparator;

  ///Can be set to `true` for opening the keyboard automatically. Default set to `false`
  final bool focusSearchBox;

  ///This will change the hint of the search box. Alternatively [searchInputDecoration] can be used to change decoration fully.
  final String searchHintText;

  const CountryPickerWidget({
    Key? key,
    this.onSelected,
    this.itemTextStyle = _defaultItemTextStyle,
    this.itemCodeStyle = _defaultItemCodeStyle,
    this.searchInputStyle = _defaultSearchInputStyle,
    this.searchInputDecoration,
    this.searchHintText = _kDefaultSearchHintText,
    this.flagIconSize = 24,
    this.showSeparator = false,
    this.focusSearchBox = false,
  }) : super(key: key);

  @override
  _CountryPickerWidgetState createState() => _CountryPickerWidgetState();
}

class _CountryPickerWidgetState extends State<CountryPickerWidget> {
  FocusNode _focusNode = FocusNode();
  Color _borderColor = Colors.transparent;
  List<Country> _list = [];
  List<Country> _filteredList = [];
  TextEditingController _controller = new TextEditingController();
  ScrollController _scrollController = new ScrollController();
  bool _isLoading = false;
  Country? _currentCountry;

  void _onSearch(text) {
    if (text == null || text.isEmpty) {
      setState(() {
        _filteredList.clear();
        _filteredList.addAll(_list);
      });
    } else {
      setState(() {
        _filteredList = _list
            .where((element) =>
        element.name
            .toLowerCase()
            .contains(text.toString().toLowerCase()) ||
            element.callingCode
                .toLowerCase()
                .contains(text.toString().toLowerCase()) ||
            element.countryCode
                .toLowerCase()
                .startsWith(text.toString().toLowerCase()))
            .map((e) => e)
            .toList();
      });
    }
  }

  @override
  void initState() {
    _scrollController.addListener(() {
      FocusScopeNode currentFocus = FocusScope.of(context);
      if (!currentFocus.hasPrimaryFocus) {
        currentFocus.unfocus();
      }
    });
    _focusNode.addListener(() {
      setState(() {
        _borderColor = _focusNode.hasFocus
            ? Colors.black.withOpacity(0.15)
            : Colors.transparent;
      });
    });
    loadList();
    super.initState();
  }

  void loadList() async {
    setState(() {
      _isLoading = true;
    });
    _list = await getCountries(context);
    try {
      String? code = await FlutterSimCountryCode.simCountryCode;
      _currentCountry =
          _list.firstWhere((element) => element.countryCode == code);
      final country = _currentCountry;
      if (country != null) {
        _list.removeWhere(
                (element) => element.callingCode == country.callingCode);
        _list.insert(0, country);
      }
    } catch (e) {} finally {
      setState(() {
        _filteredList = _list.map((e) => e).toList();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          margin: const EdgeInsets.only(left: 16, right: 16),
          height: 40.0,
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.only(left: 8, right: 8),
                  decoration: BoxDecoration(
                    color: Color(0xFFF7F7F5),
                    borderRadius: BorderRadius.all(Radius.circular(4.0)),
                    border: Border.all(
                      color: _borderColor,
                      width: 1.0,
                    ),
                  ),
                  child: TextField(
                    focusNode: _focusNode,
                    style: widget.searchInputStyle,
                    autofocus: widget.focusSearchBox,
                    cursorColor: Color(0xFF71F84A),
                    decoration: widget.searchInputDecoration ??
                        InputDecoration(
                          prefixIcon: Icon(
                            Icons.search,
                            color: _controller.text.isNotEmpty
                                ? Color(0xFF121212)
                                : Color(0xFFA7A7A7),
                            size: 24,
                          ),
                          prefixIconConstraints: BoxConstraints(
                            minWidth: 24,
                          ),
                          suffixIcon: Visibility(
                            visible: _controller.text.isNotEmpty,
                            child: InkWell(
                              child: Icon(
                                Icons.clear,
                                color: _controller.text.isNotEmpty
                                    ? Color(0xFF121212)
                                    : Color(0xFFA7A7A7),
                                size: 20,
                              ),
                              onTap: () =>
                                  setState(() {
                                    _controller.clear();
                                    _filteredList.clear();
                                    _filteredList.addAll(_list);
                                  }),
                            ),
                          ),
                          border: UnderlineInputBorder(
                            borderRadius:
                            const BorderRadius.all(Radius.circular(4.0)),
                            borderSide: BorderSide(
                              width: 0.0,
                              style: BorderStyle.none,
                            ),
                          ),
                          hintText: widget.searchHintText,
                          hintStyle: TextStyle(
                            backgroundColor: Colors.transparent,
                            color: Color(0xFFA7A7A7),
                            fontSize: 16.0,
                            fontWeight: FontWeight.w400,
                            height: 1.1,
                          )
                        ),
                    textInputAction: TextInputAction.done,
                    controller: _controller,
                    onChanged: _onSearch,
                  ),
                ),
              ),
              SizedBox(width: 12.0),
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  height: 40,
                  alignment: Alignment.center,
                  color: Colors.transparent,
                  child: Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF121212),
                  ),
                ),),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 16,
        ),
        Expanded(
          child: _isLoading
              ? Center(child: CircularProgressIndicator())
              : ListView.separated(
            padding: EdgeInsets.only(top: 16, bottom: 16.0),
            controller: _scrollController,
            itemCount: _filteredList.length,
            separatorBuilder: (_, index) =>
            widget.showSeparator ? Divider() : Container(),
            itemBuilder: (_, index) {
              return InkWell(
                onTap: () {
                  widget.onSelected?.call(_filteredList[index]);
                },
                child: Container(
                  padding: EdgeInsets.only(
                    bottom: 12,
                    top: 12,
                    left: 16,
                    right: 16,
                  ),
                  child: Row(
                    children: <Widget>[
                      Image.asset(
                        _filteredList[index].flag,
                        package: countryCodePackageName,
                        width: widget.flagIconSize,
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      Expanded(
                          child: Text(
                            '${_filteredList[index].name}',
                            style: widget.itemTextStyle,
                          )),
                      Spacer(),
                      Text(
                        '${_filteredList[index].callingCode} ',
                        style: widget.itemCodeStyle,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        )
      ],
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _controller.dispose();
    super.dispose();
  }
}
