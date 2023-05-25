library vm_generator;

import 'dart:async';

import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';
import 'package:source_gen/source_gen.dart';

Builder dataBuilderFactory(BuilderOptions options) {
  return PartBuilder([VmGenerator()], '.impl.dart');
}

class VmGenerator extends Generator {
  @override
  FutureOr<String> generate(LibraryReader library, BuildStep buildStep) async {
    final classElement = library.classes.first;

    final superClass = classElement.supertype;

    final getters = superClass?.accessors.where((e) => e.isGetter) ?? [];

    final klass = Mixin((b) {
      b.name = '\$${classElement.name}Impl';
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
                : null;

        b.fields.add(Field((b) => b
          ..modifier = FieldModifier.final$
          ..name = '_${getter.name}Provider'
          ..assignment = Code(
              'StateProvider<${getter.type.returnType}>((ref)=>$defaultValue)')));

        b.methods.add(
          Method((b) => b
            ..name = 'update${getter.name}'
            ..requiredParameters.add(Parameter((b) => b
              ..name = 'value'
              ..type = Reference(getter.type.returnType.toString())))
            ..returns = Reference('void')
            ..body = Code(
                ' _ref.read(_${getter.name}Provider.notifier).state = value;')),
        );
      }

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
