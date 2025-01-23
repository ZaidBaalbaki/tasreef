import 'package:easy_exchange/ui/pages/converter.page.dart';
import 'package:easy_exchange/ui/pages/rates.page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BottomNavigationBarWidget extends StatelessWidget {
  const BottomNavigationBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<BottomNavigationBarProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          body: IndexedStack(
            index: provider.currentIndex,
            children: const [
              RatesPage(),
              ConverterPage(),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: provider.currentIndex,
            onTap: provider.setCurrentIndex,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.list),
                label: 'Rates',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.swap_horiz),
                label: 'Convert',
              ),
            ],
          ),
        );
      },
    );
  }
}

class BottomNavigationBarProvider extends ChangeNotifier {
  int _currentIndex = 0;

  int get currentIndex => _currentIndex;

  void setCurrentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }
}