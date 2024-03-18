import 'dart:async';
import 'dart:math';
import 'package:example/common/push_to_refresh_header.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:ff_annotation_route_library/ff_annotation_route_library.dart';
import 'package:flutter/material.dart';
import 'package:loading_more_list/loading_more_list.dart';
import 'package:pull_to_refresh_notification/pull_to_refresh_notification.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:sticky_headers/sticky_headers.dart';

@FFRoute(
  name: 'fluttercandies://pulltorefreshouter',
  routeName: 'pull to refresh outer',
  description:
      'how to pull to refresh for NestedScrollView without ScrollController',
  exts: <String, dynamic>{
    'group': 'Complex',
    'order': 1,
  },
)
class PullToRefreshOuterDemo extends StatefulWidget {
  @override
  _PullToRefreshOuterDemoState createState() => _PullToRefreshOuterDemoState();
}

class _PullToRefreshOuterDemoState extends State<PullToRefreshOuterDemo>
    with TickerProviderStateMixin {
  late final TabController _primaryTC;
  int _length1 = 50;
  final int _length2 = 50;
  DateTime _lastRefreshTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _primaryTC = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _primaryTC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildScaffoldBody(),
    );
  }

  Widget _buildScaffoldBody() {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double pinnedHeaderHeight =
        //statusBar height
        statusBarHeight +
            //pinned SliverAppBar height in header
            kToolbarHeight;
    return PullToRefreshNotification(
      color: Colors.blue,
      onRefresh: () => Future<bool>.delayed(const Duration(seconds: 1), () {
        setState(() {
          _length1 += 10;
          _lastRefreshTime = DateTime.now();
        });
        return true;
      }),
      maxDragOffset: maxDragOffset,
      child: GlowNotificationWidget(
        ExtendedNestedScrollView(
          headerSliverBuilder: (BuildContext c, bool f) {
            return <Widget>[
              const SliverAppBar(
                pinned: true,
                title: Text('pull to refresh in header'),
              ),
              PullToRefreshContainer(
                (PullToRefreshScrollNotificationInfo? info) {
                  return SliverToBoxAdapter(
                    child: PullToRefreshHeader(info, _lastRefreshTime),
                  );
                },
              ),
              SliverToBoxAdapter(
                child: Container(
                  color: Colors.red,
                  alignment: Alignment.center,
                  height: 200,
                  child: const Text('other things'),
                ),
              ),
            ];
          },
          //1.[pinned sliver header issue](https://github.com/flutter/flutter/issues/22393)
          pinnedHeaderSliverHeightBuilder: () {
            return pinnedHeaderHeight;
          },
          body: Column(
            children: <Widget>[
              TabBar(
                controller: _primaryTC,
                labelColor: Colors.blue,
                indicatorColor: Colors.blue,
                indicatorSize: TabBarIndicatorSize.label,
                indicatorWeight: 2.0,
                isScrollable: false,
                unselectedLabelColor: Colors.grey,
                tabs: const <Tab>[
                  Tab(text: 'Tab0'),
                  Tab(text: 'Tab1'),
                  Tab(text: 'Tab1'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  controller: _primaryTC,
                  children: <Widget>[
                    _buildListView(1, _length1),
                    _buildListView(2, _length2),
                    FoodListView(),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListView(int index, int length) {
    return ListView.builder(
      //store Page state
      key: PageStorageKey<String>('Tab$index'),
      physics: const ClampingScrollPhysics(),
      itemBuilder: (BuildContext c, int i) {
        return Container(
          alignment: Alignment.center,
          height: 60.0,
          child: Text(
            Key('Tab$index').toString() + ': ListView$i of $length',
          ),
        );
      },
      itemCount: length,
      padding: const EdgeInsets.all(0.0),
    );
  }
}

const leftItemHeight = 40.0;
const leftItemWidth = 80.0;
const rightItemHeight = 80.0;
const rightGroupHeadHeight = 40;
const groupNum = 100;

class FoodListView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _FoodListViewState();
  }
}

class _FoodListViewState extends State<FoodListView> {
  ScrollController _scrollController = ScrollController();
  ValueNotifier<int> _currentIndex = ValueNotifier<int>(0);

  /// Controller to scroll or jump to a particular item.
  final ItemScrollController _itemScrollController = ItemScrollController();

  /// Controller to scroll a certain number of pixels relative to the current
  /// scroll offset.
  final ScrollOffsetController _scrollOffsetController =
      ScrollOffsetController();

  /// Listener that reports the position of items when the list is scrolled.
  final ItemPositionsListener _itemPositionsListener =
      ItemPositionsListener.create();

  Widget _list(Orientation orientation) => ScrollablePositionedList.builder(
        itemCount: _groups.length,
        itemBuilder: (context, index) => _item(index, orientation),
        itemScrollController: _itemScrollController,
        itemPositionsListener: _itemPositionsListener,
        scrollOffsetController: _scrollOffsetController,
        physics: const ClampingScrollPhysics(),
        shrinkWrap: true,
        reverse: false,
        scrollDirection: orientation == Orientation.portrait
            ? Axis.vertical
            : Axis.horizontal,
      );

  /// Generate item number [i].
  Widget _item(int i, Orientation orientation) {
    double height = _groups[i].foods.length * rightItemHeight;
    double width = MediaQuery.of(context).size.width - leftItemWidth;
    Widget child = Column(
        mainAxisSize: MainAxisSize.min,
        children: _groups[i]
            .foods
            .map((e) => Container(
                  height: rightItemHeight,
                  child: Column(
                    children: [
                      Expanded(
                        child: Container(
                          color: Colors.white,
                          child: Center(
                            child: Text(e.foodName),
                          ),
                        ),
                      ),
                      Container(height: 1, width: width, color: Colors.grey),
                    ],
                  ),
                ))
            .toList());
    Widget content;
    if (i == (_groups.length - 1)) {
      double screenH = MediaQuery.of(context).size.height;
      final double statusBarHeight = MediaQuery.of(context).padding.top;
      final double pinnedHeaderHeight = statusBarHeight + kToolbarHeight;
      final kTabHeight = 46.0;
      double blankH = screenH -
          pinnedHeaderHeight -
          kTabHeight -
          height -
          rightGroupHeadHeight;
      double totalH = blankH > 0 ? height + blankH : height;
      content = SizedBox(
        width: width,
        height: totalH,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            child,
            if (blankH > 0) SizedBox(height: blankH),
          ],
        ),
      );
    } else {
      content = SizedBox(
        height: height,
        width: width,
        child: child,
      );
    }
    return StickyHeader(
        header: Container(
          height: leftItemHeight,
          color: Colors.blueGrey[700],
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          alignment: Alignment.centerLeft,
          child: Text(
            _groups[i].groupTitle,
            style: const TextStyle(color: Colors.white),
          ),
        ),
        content: content);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _currentIndex.dispose();
    super.dispose();
  }

  late final List<FoodGroup> _groups;

  @override
  void initState() {
    super.initState();
    List groups = [];
    for (int i = 0; i < groupNum; i++) {
      Map group = {};
      groups.add(group);
      group['title'] = '第_${i}_组';
      List foods = [];
      group['foods'] = foods;
      int num = Random().nextInt(10) + 1;
      for (int j = 0; j < num; j++) {
        Map food = {};
        food['foodName'] = 'foodName_${i}_${j}';
        foods.add(food);
      }
    }
    _groups = groups.map((e) => FoodGroup.fromJson(e)).toList();
    _itemPositionsListener.itemPositions.addListener(_updatePositions);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            ValueListenableBuilder<int>(
                valueListenable: _currentIndex,
                builder: (BuildContext context, int value, Widget? child) {
                  return GestureDetector(
                    onVerticalDragUpdate: (_) {},
                    child: SizedBox(
                      width: 80,
                      height: 10000,
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(0.0),
                        // physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (BuildContext c, int i) {
                          return GestureDetector(
                            onTap: () {
                              updateSelectIndex(i);
                              // _itemScrollController.jumpTo(index: i);
                            },
                            child: Container(
                              alignment: Alignment.center,
                              color: i == value ? Colors.grey : Colors.white,
                              height: leftItemHeight,
                              child: Text(_groups[i].groupTitle),
                            ),
                          );
                        },
                        itemCount: _groups.length,
                      ),
                    ),
                  );
                }),
            Expanded(child: _list(Orientation.portrait)),
          ],
        ),
      ],
    );
  }

  void _updatePositions() {
    if (_clickIndex == true) {
      _clickIndex = false;
      return;
    }
    var positions = _itemPositionsListener.itemPositions.value;
    if (positions.isNotEmpty) {
      int min = positions
          .where((ItemPosition position) => position.itemTrailingEdge > 0)
          .reduce((ItemPosition min, ItemPosition position) =>
              position.itemTrailingEdge < min.itemTrailingEdge ? position : min)
          .index;
      if (min != _currentIndex.value) {
        double scrollExtent = min * leftItemHeight;
        double maxScrollExtent =
            _scrollController.position.maxScrollExtent.toDouble();
        double extent =
            scrollExtent > maxScrollExtent ? maxScrollExtent : scrollExtent;
        _scrollController.animateTo(extent,
            duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
        _currentIndex.value = min;
      }
      print('curIndex == $min');
    }
  }

  bool _clickIndex = false;

  updateSelectIndex(int index) {
    _itemScrollController.jumpTo(index: index);
    _currentIndex.value = index;
    _clickIndex = true;
  }
}

class FoodGroup {
  String groupTitle;
  List<FoodModel> foods;

  FoodGroup({required this.groupTitle, required this.foods}) {}

  factory FoodGroup.fromJson(Map json) {
    return FoodGroup(
        groupTitle: json['title'],
        foods:
            (json['foods'] as List).map((e) => FoodModel.fromJson(e)).toList());
  }
}

class FoodModel {
  String foodName;

  FoodModel({required this.foodName});

  factory FoodModel.fromJson(Map json) {
    return FoodModel(foodName: json['foodName']);
  }
}