import 'package:flutter_riverpod/src/consumer.dart';

import 'count_up_vm_interface.dart';

class CountUpVmDummy implements CountUpVmInterface {
  @override
  int get count => 1000;

  @override
  void init(WidgetRef ref) {}

  @override
  void onAddTapped() {}
}
