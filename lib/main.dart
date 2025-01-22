import 'package:easy_exchange/ui/widget/bottom-navigation-bar.widget.dart';
import 'package:easy_exchange/util/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const EasyExchange());
}

class EasyExchange extends StatelessWidget {
  const EasyExchange({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.dark,
    ));

    return MaterialApp(
      title: 'Easy Exchange',
      theme: ThemeData(
        primaryColor: primaryColor,
        scaffoldBackgroundColor: const Color(0xFFFFFFFF),
        fontFamily: 'TitilliumWeb',
        textTheme: TextTheme(
          titleLarge: TextStyle(
            color: primaryColor,
            fontSize: 26.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        appBarTheme: const AppBarTheme(
          color: Colors.white,
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: ChangeNotifierProvider<BottomNavigationBarProvider>(
        create: (BuildContext context) => BottomNavigationBarProvider(),
        child: const BottomNavigationBarWidget(),
      ),
    );
  }
}
