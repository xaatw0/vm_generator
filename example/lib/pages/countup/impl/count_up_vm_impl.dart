import 'package:example/pages/countup/impl/count_up_logic.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../count_up_vm.dart';

part 'count_up_vm_impl.gvm.dart';

class CountUpVmImpl with _$CountUpVmImpl implements CountUpVm {
  final _logic = CountUpLogic();
  final _logic2 = CountUpLogic();

  @override
  void init(WidgetRef ref) {
    _init(ref);
    _onUpdate();
    _nullableObj();
    _nullableObj(Object());
    _resetNullableObj();
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

  @override
  int noChangeValue() {
    return _count();
  }

  @override
  void onNoChange() {
    _count(_count() + 1);
  }
}
