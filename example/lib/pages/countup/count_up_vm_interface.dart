import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract interface class CountUpVmInterface {
  int get count;

  void init(WidgetRef ref);
  void onAddTapped();
}
