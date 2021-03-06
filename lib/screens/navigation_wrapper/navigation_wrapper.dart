import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:principle_app/screens/calendar/calander.dart';

import 'package:principle_app/screens/homepage/homepage.dart';

import 'package:principle_app/screens/navigation_wrapper/drawer.dart';
import 'package:principle_app/screens/notification/notifications.dart';
import 'package:principle_app/screens/profile/profile.dart';
import 'package:principle_app/simple_utils/widgets.dart';
import 'package:principle_app/template.dart';

import 'custom_bottom_navigation.dart';

class HomePageWrapper extends StatefulWidget {
  @override
  _HomePageWrapperState createState() => _HomePageWrapperState();
}

class _HomePageWrapperState extends State<HomePageWrapper>
    with SingleTickerProviderStateMixin {
  AnimationController animController;
  Animation<double> scale;
  Animation<double> scaleReverce;
  Animation<Offset> slide;
  PageController _pageController;
  int currentpage = 0;
  ValueNotifier<int> op = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();
    _pageController = PageController(keepPage: true, initialPage: 0)
      ..addListener(pagePositionListner);
    animController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400),
    );
    animController.addListener(() {
      isTouchable.value = animController.status != AnimationStatus.completed;
    });
    print('pagesss');
    // print(_pageController.addListener(() { }));
  }

  pagePositionListner() {
    op.value != (_pageController.page + .5).toInt()
        ? op.value = (_pageController.page + 0.5).toInt()
        : null;
    print(currentpage);
    setState(() {
      currentpage = op.value;
    });
  }

  ValueNotifier<bool> isTouchable = ValueNotifier(true);

  @override
  Widget build(BuildContext context) {
    initializeAnimations();
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Stack(
        children: [
          //drawer background filter
          drawer(),
          //dashboard page
          AnimatedBuilder(
            animation: animController,
            builder: (c, child) {
              return drawerTransition(child);
            },
            child: Scaffold(
              appBar: buildAppBar(),
              body: GestureDetector(
                onHorizontalDragUpdate: drawerSwipeHandler,
                child: SafeArea(
                  child: Container(
                    height: height(context),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          flex: 1,
                          child: ValueListenableBuilder(
                            valueListenable: isTouchable,
                            builder: (BuildContext context,
                                bool isDashboardTouchable, Widget child) {
                              return Stack(
                                children: [
                                  child,
                                  if (!isDashboardTouchable) untouchableFilter()
                                ],
                              );
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: pageContent(),
                                ),
                              ],
                            ),
                          ),
                        ),
                        CustomBottomNavigation(
                          selectedItemColor: Colors.white,
                          navItems: {
                            "Home": Icons.home,
                            "Notification": Icons.notifications,
                            "Calendar": Icons.calendar_today,
                            "Profile": Icons.person,
                          },
                          onTabChange: (page) {
                            _pageController.jumpToPage(page);
                          },
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget pageContent() {
    return Column(
      children: [
        Expanded(
            child: PageView(
            physics: NeverScrollableScrollPhysics(),
            controller: _pageController,
            children: [
              HomePage(),
              NotificationsPage(),
              CalenderPage(),
              Profile(),
            ],
          ),
        )
      ],
    );
  }

  Container untouchableFilter() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white70,
      ),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      elevation: 0,
      centerTitle: true,
      title: currentpage == 0
          ?  Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 1.0),
                child: TextField(
                  autofocus: false,
                  onChanged: (value) {
                    //filterContactResults(value);
                    //filterOrganizationResults(value);
                  },
                  //controller: editingController,
                  decoration: InputDecoration(
                      contentPadding: EdgeInsets.all(8.0),
                      filled: true,
                      fillColor: Colors.white,
                      labelText: "Search teacher or student",
                      //hintText: "Search",
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.tealAccent),
                          borderRadius: BorderRadius.all(
                              Radius.circular(8.0)))),
                ),
              ),
              Positioned(
                top: 0,
                bottom: 0,
                right: 0,
                child: IconButton(splashColor: Colors.transparent,
                  icon: Icon(Icons.clear),
                  color: Colors.grey,
                  onPressed: () {
                    setState(() {
                      //editingController.clear();
                    });
                  },),
              )
            ],
          ) 
          : Container(),
      leading: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: () {
              animController.status == AnimationStatus.completed
                  ? animController.reverse()
                  : animController.forward();
            },
            icon: SizedBox(
                width: 22,
                height: 50,
                child: FittedBox(fit: BoxFit.contain, child: menu())),
          ),
        ],
      ),
    );
  }

  Widget drawer() {
    return Material(
      child: SafeArea(
        child: Container(
          color: Colors.white,
          width: MediaQuery.of(context).size.width,
          child: AnimatedBuilder(
            builder: (BuildContext context, Widget child) {
              return ScaleTransition(
                scale: scaleReverce,
                child: child,
              );
            },
            child: Align(
              alignment: Alignment.topLeft,
              child: AppDrawer(name: schoolName),
            ),
            animation: scale,
          ),
        ),
      ),
    );
  }

  double height(BuildContext context) {
    return MediaQuery.of(context).size.height -
        MediaQuery.of(context).padding.top -
        MediaQuery.of(context).padding.bottom;
  }

  void drawerSwipeHandler(detail) {
    if (animController.status == AnimationStatus.completed &&
        detail.delta.dx < -10) animController.reverse();
  }

  Transform drawerTransition(Widget child) {
    return Transform.scale(
      scale: scale.value,
      child: Transform.translate(
          offset: slide.value,
          child: Material(
              color: Colors.white,
              elevation: slide.value.dx / 40,
              borderRadius: BorderRadius.circular(slide.value.dx / 15),
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(slide.value.dx / 15),
                  child: child))),
    );
  }

  initializeAnimations() {
    slide = Tween<Offset>(
            end: Offset(MediaQuery.of(context).size.width * .65, 0),
            begin: Offset.zero)
        .animate(
            CurvedAnimation(parent: animController, curve: Curves.easeInExpo));
    scale = Tween<double>(end: .8, begin: 1.0).animate(
        CurvedAnimation(parent: animController, curve: Curves.easeOutExpo));
    scaleReverce = Tween<double>(end: 1, begin: .6).animate(
        CurvedAnimation(parent: animController, curve: Curves.easeInCubic));
  }
}
