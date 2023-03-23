import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:jeongjo_tracking/main.dart';

class CourseInfoPage extends StatelessWidget {
  final String courseName;
  const CourseInfoPage(this.courseName, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await _onBackPressed(context);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(courseName.tr()),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              selectedIndexGlobal = 0;
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => const MyHomePage()));
            },
          ),
        ),
        body: const SingleChildScrollView(
          child: Text('Course Info'),
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.all(10.0),
          child: ElevatedButton(
            onPressed: () {
              selectedCourseGlobal =
                  selectedCourseGlobal != courseName ? courseName : '';
              selectedIndexGlobal = selectedCourseGlobal == '' ? 0 : 1;
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => const MyHomePage()));
            },
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25.0),
              ),
              fixedSize: const Size(double.maxFinite, 50.0),
            ),
            child: Text(selectedCourseGlobal != courseName
                ? 'goTracking'.tr()
                : 'stopTracking'.tr()),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }

  Future<void> _onBackPressed(BuildContext context) async {
    selectedIndexGlobal = 0;
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const MyHomePage()));
  }
}
