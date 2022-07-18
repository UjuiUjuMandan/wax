import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_search_bar/flutter_search_bar.dart';
import 'package:wax/basic/methods.dart';
import 'package:wax/configs/host.dart';
import 'package:wax/protos/properties.pb.dart';
import 'package:wax/screens/downloads_screen.dart';
import 'package:wax/screens/pro_screen.dart';
import 'package:wax/screens/search_screen.dart';

import '../basic/cates.dart';
import '../configs/is_pro.dart';
import 'components/actions.dart';
import 'components/browser_bottom_sheet.dart';
import 'components/comic_pager.dart';

class BrowserScreen extends StatefulWidget {
  final String tag;

  const BrowserScreen({this.tag = "", Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _BrowserScreenState();
}

class _BrowserScreenState extends State<BrowserScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    hostEvent.subscribe(_setState);
    proEvent.subscribe(_setState);
    super.initState();
  }

  @override
  void dispose() {
    hostEvent.unsubscribe(_setState);
    proEvent.unsubscribe(_setState);
    super.dispose();
  }

  _setState(_) {
    setState(() {});
  }

  late final SearchBar _searchBar = SearchBar(
    hintText: '搜索',
    inBar: false,
    setState: setState,
    onSubmitted: (value) {
      if (value.isNotEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SearchScreen(keyword: value),
          ),
        );
      }
    },
    buildDefaultAppBar: (BuildContext context) {
      return AppBar(
        title: Text(_title()),
        actions: [
          ...alwaysInActions(),
          IconButton(
            onPressed: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (BuildContext context) {
                return const DownloadsScreen();
              }));
            },
            icon: const Icon(Icons.download),
          ),
          proAction(),
          _searchBar.getSearchAction(context),
          chooseCateAction(context),
          const BrowserBottomSheetAction(),
        ],
      );
    },
  );

  late final _tag = widget.tag;
  var _cate = "";

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: _searchBar.build(context),
      body: ComicPager(
        key: Key("$host:$_tag:$_cate"),
        onPage: _onPage,
      ),
    );
  }

  String _title() {
    if (_tag != "") {
      return _tag;
    }
    if (_cate != "") {
      return catesVnMap[_cate] ?? "";
    }
    return "全部漫画";
  }

  Future<FetchComicResult> _onPage(int page) async {
    if (_tag != "") {
      return methods.fetchComic(
        "tag",
        _tag,
        page,
      );
    }
    if (_cate != "") {
      return methods.fetchComic(
        "cate",
        _cate,
        page,
      );
    }
    return methods.fetchComic("", "", page);
  }

  Widget chooseCateAction(BuildContext context) {
    return IconButton(
      onPressed: () async {
        final c = await chooseCate(context);
        setState(() {
          _cate = c;
        });
      },
      icon: const Icon(Icons.category),
    );
  }

  Widget proAction() {
    return IconButton(
      onPressed: () {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (BuildContext context) {
          return const ProScreen();
        }));
      },
      icon: Icon(
        isPro ? Icons.offline_bolt : Icons.offline_bolt_outlined,
      ),
    );
  }
}
