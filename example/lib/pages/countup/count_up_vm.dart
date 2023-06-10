import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract interface class CountUpVm {
  int get count;
  int get count2;

  void init(WidgetRef ref);
  void onAddTapped();
  void onAdd2Tapped();
}
