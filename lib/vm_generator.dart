library vm_generator;

import 'dart:async';

import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';
import 'package:source_gen/source_gen.dart';
import 'package:pub_semver/pub_semver.dart';

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
        if (getter.isStatic) {
          continue;
        }

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
        final postReturnType =
            getter.type.returnType.toString().endsWith('?') ? '' : '?';
        b.methods.add(
          Method((b) => b
            ..name = '_${getter.name}'
            ..optionalParameters.add(Parameter((b) => b
              ..name = 'value'
              ..named = false
              ..type = Reference('${getter.type.returnType}$postReturnType')))
            ..returns = Reference(getter.type.returnType.toString())
            ..body = Code('''
      if (value !=null){
        _ref.read($providerName.notifier).state = value; 
      }
       return _ref.read($providerName);

                    ''')),
        );

        // resetValue
        if (defaultValue == null) {
          final pascal = getter.name.substring(0, 1).toUpperCase() +
              getter.name.substring(1);
          b.methods.add(Method((b) => b
            ..name = '_reset$pascal'
            ..returns = Reference('void')
            ..body = Code('_ref.read($providerName.notifier).state = null;')));
        }
        // int get count
        // → int get count
        b.methods.add(
          Method((b) => b
            ..name = getter.name
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
            ..type = const Reference('WidgetRef')))
          ..returns = const Reference('void')
          ..body = const Code('_ref=ref;')),
      );
    });

    final emitter = DartEmitter(useNullSafetySyntax: true);

    return DartFormatter(languageVersion: Version(3, 17, 0))
        .format('${klass.accept(emitter)}');
  }
}
