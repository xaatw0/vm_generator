import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract interface class CountUpVm {
  int get count;
  int get count2;
  Object? get nullableObj;

  static final staticFinal = Exception();
  static const kStaticConst = 'staticConst';

  void init(WidgetRef ref);
  void onAddTapped();
  void onAdd2Tapped();

  void onNoChange();
  int noChangeValue();
}
