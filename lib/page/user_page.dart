import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tiktok/controller/main_page_scroll_controller.dart';
import 'package:flutter_tiktok/model/video_model.dart';
import 'package:flutter_tiktok/page/widget/user_info_widget.dart';
import 'package:flutter_tiktok/page/widget/user_item_grid_widget.dart';
import 'package:flutter_tiktok/res/colors.dart';
import 'package:get/get.dart';
import 'package:oktoast/oktoast.dart';

class UserPage extends StatefulWidget {
  PageController _scrollPageController;
  bool _isLoginUser;
  UserPage({PageController pageController,bool isLoginUser}){
    this._scrollPageController = pageController;
    this._isLoginUser = isLoginUser;
  }

  @override
  _UserPageState createState() {
    return _UserPageState();
  }
}

class _UserPageState extends State<UserPage> with TickerProviderStateMixin {
  MainPageScrollController _mainController = Get.find();
  TabController _tabController;
  PageController _pageController = PageController(keepPage: true);
  ScrollController _scrollController = ScrollController();
  bool showTitle = false;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _scrollController.addListener(() {
      double position =_scrollController.offset;
      print('offset:${position}');
      if(position >  145 && !showTitle){
        setState(() {
          showTitle = true;
        });
      }else if(position <  145 && showTitle){
        setState(() {
          showTitle = false;
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
    _pageController.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //设置状态栏的颜色和图标模式
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        physics: BouncingScrollPhysics(),
        slivers: [
          _getSliverAppBar(),
          _getSliverUserInfo(),
          _getTabBarLayout(),
          _getTabViewLayout(),
        ],
      ),
    );
  }

  _getSliverAppBar(){
    return  SliverAppBar(
      brightness:Brightness.light,
      backgroundColor:ColorRes.color_1,
      pinned: true,
      expandedHeight: 200,
      leading: widget._isLoginUser?null:IconButton(
        onPressed: (){
          widget._scrollPageController.animateToPage(0, duration: Duration(milliseconds: 400), curve: Curves.linear);
        },
        icon: Icon(Icons.arrow_back_ios_rounded,color: Colors.white,),
      ),
      actions: [
        widget._isLoginUser?
            IconButton(
              onPressed: (){
              },
              icon: Icon(Icons.view_headline_rounded,color: Colors.white,),
            )
            : IconButton(
              onPressed: (){
              },
            icon: Icon(Icons.more_horiz_rounded,color: Colors.white,),
        ),
      ],
      elevation: 0,
      stretch: true,
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: [StretchMode.zoomBackground],
        collapseMode: CollapseMode.parallax,
        title: showTitle?Text(_mainController.userModelCurrent.value.name):null,
        centerTitle:true,
        background: Image.asset(
          _mainController.userModelCurrent.value.headerBgImage,
          fit: BoxFit.cover,
        ),
      ),
      // stretchTriggerOffset:145,
      onStretchTrigger:(){
        print('onStretchTrigger');
        return;
        },
    );
  }

  _getSliverUserInfo() {
    return SliverToBoxAdapter(
      child: UserInfoWidget(widget._isLoginUser),
    );
  }

  _getTabBarLayout() {
    return SliverPersistentHeader(
      pinned: true,
      delegate: StickyTabBarDelegate(
        child: PreferredSize(
          preferredSize: Size.fromHeight(48),
          child: Container(
            color: ColorRes.color_1,
            child: TabBar(
              controller: _tabController,
              indicatorColor: ColorRes.color_4,
              labelStyle: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.white),
              unselectedLabelStyle:TextStyle(fontSize: 15,color: Colors.grey),
              tabs: <Widget>[
                Tab(
                  child: Text('作品 ${_mainController.userModelCurrent.value.worksVideo.length}',),
                ),
                Tab(
                  child: Text('喜欢 ${_mainController.userModelCurrent.value.likeVideo.length}',
                  ),
                ),
              ],
              onTap: (index){
                _pageController.animateToPage(index, duration: Duration(milliseconds: 200), curve: Curves.linear);
              },
            ),
          ),
        ),
      ),
    );
  }

  _getTabViewLayout() {
    //计算Item的高度
    double itemWidth = MediaQuery.of(context).size.width / 3;
    double itemHeight = itemWidth / 9 * 16;

    return SliverToBoxAdapter(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width,
          minWidth: MediaQuery.of(context).size.width,
          maxHeight:itemHeight * _mainController.userModelCurrent.value.worksVideo.length / 3,
        ),
        child:  PageView.builder(
              controller: _pageController,
              itemCount:2,
              itemBuilder: (context,index){
                return _getPageLayout(index);
              },
              onPageChanged: (index){
                _tabController.animateTo(index);
              },
            ),
        ),
    );
  }

  //获取PageView的煤业
  Widget _getPageLayout(int index) {
    List<String> gifList = index == 0? _mainController.userModelCurrent.value.worksVideoGif:_mainController.userModelCurrent.value.likeVideoGif;
    return Container(
      color: ColorRes.color_1,
      child: GridView.builder(
          //处理GridView顶部空白
          padding: EdgeInsets.zero,
          itemCount: gifList.length,
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            //横轴元素个数
              crossAxisCount: 3,
              //纵轴间距
              mainAxisSpacing: 1,
              //横轴间距
              crossAxisSpacing: 1,
              //子组件宽高长度比例
              childAspectRatio: 9/16),
              itemBuilder: (BuildContext context, int index) {
                return UserItemGridWidget(
                  url: gifList[index],
                  onTap: (){
                    showToast('点击了$index');
                  },
                );
              },
          ),
    );
  }



}

class StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final PreferredSize child;

  StickyTabBarDelegate({@required this.child});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return this.child;
  }

  @override
  double get maxExtent => this.child.preferredSize.height;

  @override
  double get minExtent => this.child.preferredSize.height;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
