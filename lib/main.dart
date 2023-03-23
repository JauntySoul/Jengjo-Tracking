import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:jeongjo_tracking/pages/certificate_page.dart';
import 'package:jeongjo_tracking/pages/course_select_page.dart';
import 'package:jeongjo_tracking/pages/more_menu_page.dart';
import 'package:jeongjo_tracking/pages/tracking_page.dart';

// 스플래시 스크린 적용법 :
// flutter_native_splash.yaml 수정 후 아래 코드 터미널에서 실행
// flutter pub run flutter_native_splash:create

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await dotenv.load(fileName: 'assets/config/.env');
  initStampStatus();

  runApp(EasyLocalization(
      supportedLocales: const [Locale('en', 'US'), Locale('ko', 'KR')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en', 'US'),
      child: const MyApp()));
}

FlutterSecureStorage storage = const FlutterSecureStorage();
int selectedIndexGlobal = 0;
String selectedCourseGlobal = '';
Map stampStatusGlobal = {};

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JHC Korea Tracking App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List pages = [
    const CourseSelectPage(),
    TrackingPage(selectedCourseGlobal),
    const CertificatePage(),
    const MoreMenuPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
      ),
      body: Center(
        child: pages[selectedIndexGlobal],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        onTap: (int index) {
          setState(() {
            selectedIndexGlobal = index;
          });
        },
        currentIndex: selectedIndexGlobal,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: const Icon(Icons.map),
            label: 'navItem1'.tr(),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.explore),
            label: 'navItem2'.tr(),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.assignment),
            label: 'navItem3'.tr(),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.more_horiz),
            label: 'navItem4'.tr(),
          ),
        ],
      ),
    );
  }
}

void initStampStatus() async {
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
}
