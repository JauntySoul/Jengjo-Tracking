import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:jeongjo_tracking/main.dart';

class MoreMenuPage extends StatelessWidget {
  const MoreMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        await storage.deleteAll();
        Map stampStatus = await storage.readAll();
        List courseList = jsonDecode(
            await rootBundle.loadString('assets/json/courseList.json'))['list'];
        List compareList = [];

        for (var element in courseList) {
          List spotList = jsonDecode(
              await rootBundle.loadString('assets/json/$element.json'))['spot'];
          for (var element in spotList) {
            compareList.add(element['name']);
          }
        }

        for (var element in compareList) {
          if (!stampStatus.containsKey(element)) {
            stampStatus[element] = 'false';
            await storage.write(key: element, value: 'false');
          }
        }

        stampStatusGlobal = stampStatus;
      },
      child: const Text('초기화'),
    );
  }
}
