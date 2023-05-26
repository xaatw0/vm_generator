import 'package:flutter_riverpod/src/consumer.dart';

import 'count_up_vm_interface.dart';

class CountUpVmDummy implements CountUpVmInterface {
  @override
  int get count => 1000;

  @override
  void init(WidgetRef ref) {}

  @override
  void onAddTapped() {}

  @override
  // TODO: implement count2
  int get count2 => throw UnimplementedError();

  @override
  void onAdd2Tapped() {
    // TODO: implement onAdd2Tapped
  }
}
