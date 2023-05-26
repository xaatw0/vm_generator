import 'package:example/pages/countup/count_up_logic.dart';

import 'count_up_vm_interface.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'count_up_vm.g.dart';

class CountUpVm with _$CountUpVmImpl implements CountUpVmInterface {
  final _logic = CountUpLogic();
  final _logic2 = CountUpLogic();

  @override
  void init(WidgetRef ref) {
    _init(ref);
    _onUpdate();
  }

  @override
  void onAddTapped() {
    _logic.countUp();
    _onUpdate();
  }

  void _onUpdate() {
    _count(_logic.counter);
  }

  @override
  void onAdd2Tapped() {
    _logic2.countUp();
    _count2(_logic2.counter);
  }
}
