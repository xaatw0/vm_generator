import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'count_up_vm_interface.dart';
import 'count_up_vm_dummy.dart';

class CountUpPage extends ConsumerStatefulWidget {
  CountUpPage({super.key, required this.title});

  final String title;

  @override
  ConsumerState<CountUpPage> createState() => _CountUpPageState();
}

class _CountUpPageState extends ConsumerState<CountUpPage> {
  final _vm = CountUpVm();

  @override
  void initState() {
    super.initState();
    _vm.init(ref);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '${_vm.count}',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _vm.onAddTapped,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
