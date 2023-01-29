import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:jeongjo_tracking/pages/course_info_page.dart';

class CourseSelectPage extends StatefulWidget {
  const CourseSelectPage({super.key});

  @override
  State<CourseSelectPage> createState() => _CourseSelectPageState();
}

class _CourseSelectPageState extends State<CourseSelectPage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              myContainer("courseSelect1", context),
              myContainer("courseSelect2", context),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              myContainer("courseSelect3", context),
              myContainer("courseSelect4", context),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              myContainer("courseSelect5", context),
              myContainer("courseSelect6", context),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              myContainer("courseSelect7", context),
              myContainer("courseSelect8", context)
            ],
          ),
        ),
      ],
    );
  }
}

Widget myContainer(String courseName, context) {
  return Expanded(
    child: InkWell(
      onTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => CourseInfoPage(courseName)),
        );
      },
      child: Center(
        child: Text(courseName.tr()),
      ),
    ),
  );
}
