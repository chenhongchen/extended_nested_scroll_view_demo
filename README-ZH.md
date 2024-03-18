# extended_nested_scroll_view

[![pub package](https://img.shields.io/pub/v/extended_nested_scroll_view.svg)](https://pub.dartlang.org/packages/extended_nested_scroll_view) [![GitHub stars](https://img.shields.io/github/stars/fluttercandies/extended_nested_scroll_view)](https://github.com/fluttercandies/extended_nested_scroll_view/stargazers) [![GitHub forks](https://img.shields.io/github/forks/fluttercandies/extended_nested_scroll_view)](https://github.com/fluttercandies/extended_nested_scroll_view/network)  [![GitHub license](https://img.shields.io/github/license/fluttercandies/extended_nested_scroll_view)](https://github.com/fluttercandies/extended_nested_scroll_view/blob/master/LICENSE)  [![GitHub issues](https://img.shields.io/github/issues/fluttercandies/extended_nested_scroll_view)](https://github.com/fluttercandies/extended_nested_scroll_view/issues) <a target="_blank" href="https://jq.qq.com/?_wv=1027&k=5bcc0gy"><img border="0" src="https://pub.idqqimg.com/wpa/images/group.png" alt="flutter-candies" title="flutter-candies"></a>

文档语言: [English](README.md) | [中文简体](README-ZH.md)

扩展NestedScrollView来修复了下面的问题

1.[pinned的Header的问题](https://github.com/flutter/flutter/issues/22393)

2.[body里面TabView列表滚动同步，互相影响的问题](https://github.com/flutter/flutter/issues/21868)

3.在NestedScrollView的body中不通过设置ScrollController(设置了会跟内部Controller冲突)来完成下拉刷新，增量加载，滚动到顶部

[掘金](https://juejin.im/post/5bea43ade51d45544844010a)

[Web demo for ExtendedNestedScrollView](https://fluttercandies.github.io/extended_nested_scroll_view/)

- [extended\_nested\_scroll\_view](#extended_nested_scroll_view)
- [Example for issue 1](#example-for-issue-1)
- [Example for issue 2](#example-for-issue-2)
  - [ExtendedVisibilityDetector](#extendedvisibilitydetector)
- [Do without ScrollController in NestedScrollView's body](#do-without-scrollcontroller-in-nestedscrollviews-body)
- [☕️Buy me a coffee](#️buy-me-a-coffee)
# Example for issue 1

 在pinnedHeaderSliverHeightBuilder回调中设置全部pinned的header的高度，
 demo里面高度为 状态栏高度+SliverAppbar的高度
``` dart
 var tabBarHeight = primaryTabBar.preferredSize.height;
      var pinnedHeaderHeight =
          //statusBar height
          statusBarHeight +
              //pinned SliverAppBar height in header
              kToolbarHeight;

 return NestedScrollView(
        pinnedHeaderSliverHeightBuilder: () {
          return pinnedHeaderHeight;
        },
       
```
# Example for issue 2

我们通常使用下面的方法来保持列表的滚动状态: 

| 场景                      | onlyOneScrollInBody | 描述                                                  |
| ----------------------------- | ------------------- | ------------------------------------------------------------ |
| AutomaticKeepAliveClientMixin | true                | ScrollPosition 不会被释放, 将 onlyOneScrollInBody 设置为 true， 这样我们才能知道哪个列表是当前活动的. |
| PageStorageKey                | false               | ScrollPosition 会被释放, PageStorageKey 只是记录了滚动状态, ExtendedNestedScrollView 中的  scroll positions 只会有一个. |



``` dart
    ExtendedNestedScrollView(
       onlyOneScrollInBody: true,
    )
``` 
## ExtendedVisibilityDetector

提供 ExtendedVisibilityDetector 组件来指出当前可见的列表

``` dart
   ExtendedVisibilityDetector(
      uniqueKey: const Key('Tab1'),
      child: ListView(),
   )
```

# Do without ScrollController in NestedScrollView's body

因为无法给NestedScrollView的body中的列表设置ScrollController(这样会破坏NestedScrollView内部的InnerScrollController的行为)，所以我这里给大家提供了Demos来展示怎么不通过ScrollController来完成

* [下拉刷新](https://github.com/fluttercandies/extended_nested_scroll_view/tree/master/example/lib/pages/complex/pull_to_refresh.dart)
  
* [增量加载](https://github.com/fluttercandies/extended_nested_scroll_view/tree/master/example/lib/pages/complex/load_more.dart) 
  
* [滚动到顶部](https://github.com/fluttercandies/extended_nested_scroll_view/tree/master/example/lib/pages/complex/scroll_to_top.dart) 

* [动态改变PinnedHeaderHeight](https://github.com/fluttercandies/extended_nested_scroll_view/tree/master/example/lib/pages/simple/dynamic_pinned_header_height.dart) 

# ☕️Buy me a coffee

![img](http://zmtzawqlp.gitee.io/my_images/images/qrcode.png)
