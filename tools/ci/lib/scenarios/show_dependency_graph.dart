import 'package:ci/domain/command.dart';
import 'package:ci/domain/dependency.dart';
import 'package:ci/domain/element.dart';
import 'package:ci/exceptions/exceptions.dart';
import 'package:ci/exceptions/exceptions_strings.dart';
import 'package:ci/services/parsers/command_parser.dart';
import 'package:ci/services/parsers/pubspec_parser.dart';
import 'package:ci/tasks/core/scenario.dart';
import 'package:ci/tasks/utils.dart';

/// Строки для визуализации зависимостей в консоле.
const String _arrowDep = ' | ';
const String _arrow = ' ---->';

/// Выводит в консоль граф зависимостей елемента.
///
/// dart ci deps / dart ci deps --name=anyName
class ShowDependencyGraph extends Scenario {
  static const String commandName = 'deps';
  static const String nameOption = CommandParser.defaultNameOption;

  @override
  Map<String, String> getCommandsHelp() => {
        commandName: 'Show module dependency graph.',
      };

  ShowDependencyGraph(
    Command command,
    PubspecParser pubspecParser,
  ) : super(command, pubspecParser);

  @override
  Future<void> validate(Command command) async {
    var args = command.arguments;

    /// валидация аргументов
    var isArgCorrect = await validateCommandParamForElements(args);

    if (!isArgCorrect) {
      return Future.error(
        CommandParamsValidationException(
          getCommandFormatExceptionText(
            commandName,
            'ожидалось deps --all или deps --name=anyName',
          ),
        ),
      );
    }
  }

  @override
  Future<List<Element>> preExecute() async {
    var elements = await super.preExecute();

    /// Фильтруем по переданным параметрам список элементов
    return filterElementsByCommandParams(
      elements,
      command.arguments,
    );
  }

  @override
  Future<void> doExecute(List<Element> elements) async {
    /// Хранит данные для вывода в консоль
    final str = StringBuffer();
    for (var element in elements) {
      _createOutputOnConsole(element, str, -_arrowDep.length);
      str.write('\n');
    }
    print(str);
  }

  /// Если у элемнета есть зависимости "флаттер стандарта", то генерим строку для вывода в консоль.
  void _createOutputOnConsole(Element element, StringBuffer str, int indentLength) {
    str.write(element.name);
    if (_getDependency(element).isNotEmpty) {
      str.write(_arrow);
      indentLength += element.name.length + _arrow.length + _arrowDep.length;
      _dependencyOutputOnConsole(
        element,
        str,
        indentLength,
      );
    }
  }

  ///  Зависимости рекурсивно добавляем в вывод
  void _dependencyOutputOnConsole(Element element, StringBuffer str, int indentLength) {
    var dependencies = _getDependency(element);
    for (var i = 0; i < dependencies.length; i++) {
      i == 0 ? str.write(_arrowDep) : str.write('\n' + ' ' * indentLength + _arrowDep);
      _createOutputOnConsole(dependencies[i].element, str, indentLength);
    }
  }

  /// Список зависимостей "флаттер стандарта" у элемента
  List<Dependency> _getDependency(Element element) {
    var dependencies = <Dependency>[];
    for (var dependency in element.dependencies) {
      if (!dependency.thirdParty) {
        dependencies.add(dependency);
      }
    }
    return dependencies;
  }

  @override
  String get getCommandName => commandName;
}
