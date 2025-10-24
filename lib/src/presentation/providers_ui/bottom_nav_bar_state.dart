import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'bottom_nav_bar_state.g.dart';

@Riverpod(keepAlive: true)
class BottomNavBarState extends _$BottomNavBarState {
  @override
  int build() => 0;

  void select(int index) {
    state = index;
  }
}
