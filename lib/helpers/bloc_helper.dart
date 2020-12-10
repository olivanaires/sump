import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:rxdart/rxdart.dart';

class BlocHelper extends BlocBase {

  final _selectedTab = BehaviorSubject<int>(seedValue: 0);
  Stream<int> get selectedTab => _selectedTab.stream;

  BlocHelper() {
    _selectedTab.add(0);
  }

  @override
  void dispose() {
    _selectedTab.close();
  }

  void tabChange(int value) {
    _selectedTab.sink.add(value);
  }

}
