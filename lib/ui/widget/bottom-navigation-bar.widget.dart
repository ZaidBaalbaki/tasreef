import 'package:easy_exchange/ui/pages/converter.page.dart';
import 'package:easy_exchange/ui/pages/graphs.page.dart';
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
          appBar: AppBar(
            title: Text(
              _getAppBarTitle(provider.currentIndex),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            centerTitle: true,
            elevation: 0,
          ),
          body: IndexedStack(
            index: provider.currentIndex,
            children: const [
              RatesPage(),
              ConverterPage(),
              GraphsPage(),
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
              BottomNavigationBarItem(
                icon: Icon(Icons.show_chart),
                label: 'Graphs',
              ),
            ],
          ),
        );
      },
    );
  }

  String _getAppBarTitle(int index) {
    return switch (index) {
      0 => 'Currency Rates',
      1 => 'Currency Converter',
      2 => 'Exchange Graphs',
      _ => 'Easy Exchange',
    };
  }
}

class BottomNavigationBarProvider extends ChangeNotifier {
  int _currentIndex = 0;

  int get currentIndex => _currentIndex;

  void setCurrentIndex(int index) {
    if (_currentIndex != index) {
      _currentIndex = index;
      notifyListeners();
    }
  }
}