import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:is_wear/is_wear.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:wear/responsive_context_extension.dart';
import 'package:wear_plus/wear_plus.dart';

late final bool isWear;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  isWear = (await IsWear().check()) ?? false;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: isWear
          ? const Size(390, 390)
          : MediaQuery.sizeOf(context).width > 600
              ? Size(MediaQuery.sizeOf(context).width,
                  MediaQuery.sizeOf(context).height)
              : const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Responsive App',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            textTheme: Typography.englishLike2018.apply(fontSizeFactor: 1.sp),
          ),

          builder: (context, widget) {
            return ResponsiveBreakpoints.builder(
              child: widget!,
              breakpoints: [
                const Breakpoint(
                  start: 0,
                  end: 390,
                  name: 'WEAR',
                ),
                const Breakpoint(
                  start: 0,
                  end: 391,
                  name: 'MOBILE',
                ),
                const Breakpoint(
                  start: 601,
                  end: 1000,
                  name: 'TABLET',
                ),
                const Breakpoint(
                  start: 1001,
                  end: double.infinity,
                  name: 'DESKTOP',
                ),
              ],
            );
          },
          home: isWear
              ? AmbientMode(
                  builder: (context, mode, child) => child!,
                  child: const HomeScreen(),
                )
              : const HomeScreen(),
        );
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    bool isPortraitOrientation =
        MediaQuery.of(context).orientation == Orientation.portrait;
    return Scaffold(
      appBar: AppBar(title: const Text('Home Screen')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 10,
        children: [
          Text(
            'Is Portrait Orientation: $isPortraitOrientation',
            style: TextStyle(
              color: Colors.red,
              fontSize: 24.sp,
            ),
          ),
          10.verticalSpace,
          Text(
            'Is Waer: ${isWear}',
            style: TextStyle(
              color: Colors.red,
              fontSize: 24.sp,
            ),
          ),
          10.verticalSpace,
          Text(
            'Is Phone/Mobile: ${context.isMobile}',
            style: TextStyle(
              color: Colors.red,
              fontSize: 24.sp,
            ),
          ),
          10.verticalSpace,
          Text(
            'Is Tab: ${context.isTablet}',
            style: TextStyle(
              color: Colors.red,
              fontSize: 24.sp,
            ),
          ),
          10.verticalSpace,
          Text(
            'Is Desktop: ${context.isDesktop}',
            style: TextStyle(
              color: Colors.red,
              fontSize: 24.sp,
            ),
          ),
        ],
      ),
    );
  }
}
