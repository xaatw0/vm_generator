library vm_generator;

import 'dart:async';

import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';
import 'package:source_gen/source_gen.dart';

Builder vmBuilderFactory(BuilderOptions options) {
  return PartBuilder([VmGenerator()], '.gvm.dart');
}

class VmGenerator extends Generator {
  @override
  FutureOr<String> generate(LibraryReader library, BuildStep buildStep) async {
    if (library.classes.isEmpty || library.classes.first.interfaces.isEmpty) {
      return '';
    }

    final classElement = library.classes.first;
    final superClass = classElement.interfaces.first;

    final getters = superClass.accessors.where((e) => e.isGetter);

    final klass = Mixin((b) {
      b.name = '_\$${classElement.name}';
      b.fields.add(
        Field(
          (b) => b
            ..late = true
            ..name = '_ref'
            ..modifier = FieldModifier.final$
            ..type = Reference('WidgetRef'),
        ),
      );
      for (final getter in getters) {
        final defaultValue = getter.type.returnType.toString() == 'int'
            ? '0'
            : getter.type.returnType.toString() == 'String'
                ? "''"
                : getter.type.returnType.toString() == 'bool'
                    ? "false"
                    : getter.type.returnType.toString().startsWith('List')
                        ? "[]"
                        : null;

        final providerName = '_${getter.name}Provider';

        // int get count;
        // final _countProvider = StateProvider<int>((ref) => 0);
        b.fields.add(Field((b) => b
          ..modifier = FieldModifier.final$
          ..name = providerName
          ..assignment = Code(
              'StateProvider<${getter.type.returnType}>((ref)=>$defaultValue)')));

        // int get count;
        // →_count(value)
        b.methods.add(
          Method((b) => b
            ..name = '_${getter.name}'
            ..requiredParameters.add(Parameter((b) => b
              ..name = 'value'
              ..type = Reference(getter.type.returnType.toString())))
            ..returns = Reference('void')
            ..body =
                Code('  _ref.read($providerName.notifier).state = value; ')),
        );

        // int get count
        // → int get count
        b.methods.add(
          Method((b) => b
            ..name = '${getter.name}'
            ..type = MethodType.getter
            ..returns = Reference(getter.type.returnType.toString())
            ..body = Code('return _ref.watch($providerName);')),
        );
      }

      // → _init(Widget ref);
      b.methods.add(
        Method((b) => b
          ..name = '_init'
          ..requiredParameters.add(Parameter((b) => b
            ..name = 'ref'
            ..type = Reference('WidgetRef')))
          ..returns = Reference('void')
          ..body = Code('_ref=ref;')),
      );
    });

    final emitter = DartEmitter(useNullSafetySyntax: true);

    return DartFormatter().format('${klass.accept(emitter)}');
  }
}
