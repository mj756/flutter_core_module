import 'package:flutter/material.dart';

extension CustomWidgetExtension on Widget
{
  Widget tappable({required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: this,
    );
  }
  Widget safeArea({required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: this,
    );
  }
  Widget commonPage({required BuildContext context,required Widget child,PreferredSizeWidget? appBar,Widget? drawer,Widget? endDrawer,Widget? bottomNavigationBar,EdgeInsets? padding}) {
    return SafeArea(
      child: Scaffold(
        bottomNavigationBar: bottomNavigationBar,
        appBar: appBar,
       drawer: drawer,
       endDrawer: endDrawer,
       body: Padding(
         padding: padding ?? const EdgeInsets.all(10),
         child: this,
       ),
      ),
    );
  }
  Widget clipRRect({double radius = 8}) =>ClipRRect(borderRadius: BorderRadius.circular(radius), child: this);
  Widget sized({double? width, double? height}) =>SizedBox(width: width, height: height, child: this);

}