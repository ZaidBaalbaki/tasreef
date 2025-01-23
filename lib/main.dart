import 'package:easy_exchange/ui/widget/bottom-navigation-bar.widget.dart';
import 'package:easy_exchange/util/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const EasyExchange());
}

class EasyExchange extends StatelessWidget {
  const EasyExchange({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Easy Exchange',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: primaryColor),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: FutureBuilder(
        future: Future.delayed(const Duration(milliseconds: 1000)),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              backgroundColor: Colors.white,
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Loading Easy Exchange...',
                      style: TextStyle(
                        color: primaryColor,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          return ChangeNotifierProvider<BottomNavigationBarProvider>(
            create: (BuildContext context) => BottomNavigationBarProvider(),
            child: const BottomNavigationBarWidget(),
          );
        },
      ),
    );
  }
}
