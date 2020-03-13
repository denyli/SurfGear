import 'dart:io';

import 'package:init_project/domain/command.dart';
import 'package:init_project/domain/path_directory.dart';
import 'package:init_project/services/manager/message_console_manager.dart';
import 'package:io/io.dart';
import 'package:path/path.dart' as p;
import 'package:plain_optional/plain_optional.dart';
import 'package:pubspec_yaml/pubspec_yaml.dart';

/// Путь до папки с template
const String _pathPackagesTemplate = 'packages/template';

/// Репозиторий
const String _urls = 'https://bitbucket.org/surfstudio/flutter-standard.git';

/// Для поиска файлов *.dart
const String _fileDart = '.dart';

/// Для поиска файлов *.yaml
const String _fileYAML = '.yaml';

/// Регулярка для замены на название пароекта
RegExp _expDependency = RegExp('template');

String _pubspecFile = 'pubspec.yaml';

/// Создает шаблонный проект
class CreateTemplateProject {
  final ShowMessageManager _showMessageConsole;

  CreateTemplateProject(
    this._showMessageConsole,
  );

  Future<void> run(Command command, PathDirectory pathDirectory) async {
    try {
      _showMessageConsole.printMessageConsole('Prepare project...');
      await _copyTemplateFolder(pathDirectory);
      final files = await _searchFile(command, pathDirectory);
      await _replaceTextInFile(command, files);
      await _searchPubspec(files);
    } catch (e) {
      rethrow;
    }
  }

  /// Копируем template
  Future<void> _copyTemplateFolder(PathDirectory pathDirectory) async {
    final pathFolder = p.join(pathDirectory.pathTemp, _pathPackagesTemplate);
    await copyPath(pathFolder, pathDirectory.path);
  }

  /// Ищем файлы
  Future<List<File>> _searchFile(Command command, PathDirectory pathDirectory) async {
    final List<File> files = [];
    final dirProject = Directory(p.join(pathDirectory.path, 'lib'))
        .listSync(recursive: true, followLinks: false)
          ..addAll(Directory(pathDirectory.path).listSync(recursive: false, followLinks: false));

    var fileSystemEntities = await _getFiles(dirProject);

    files.addAll(fileSystemEntities);

    return files as List<File>;
  }

  Future<List<File>> _getFiles(List<FileSystemEntity> dirs) async {
    final List<File> files = [];
    for (var dir in dirs) {
      String fileName = p.basename(dir.path);
      if (await FileSystemEntity.isFile(dir.path)) {
        if (fileName.contains(_fileDart) || fileName.contains(_fileYAML)) {
          files.add(File(dir.path));
        }
      }
    }
    return files;
  }

  /// Перезаписывем текст в файле, заменяя зависимости
  Future<void> _replaceTextInFile(Command command, List<File> files) async {
    for (var file in files) {
      try {
        var sourceText = await file.readAsString();
        var outText = sourceText.replaceAll(_expDependency, command.nameProject);
        await file.writeAsString(outText);
      } catch (e) {
        rethrow;
      }
    }
  }

  Future<void> _searchPubspec(List<File> files) async {
    try {
      for (var file in files) {
        var nameFile = p.basename(file.path);
        if (nameFile == _pubspecFile) {
          await _replacePubspec(file);
          break;
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _replacePubspec(File file) async {
    try {
      final pubspecYaml = PubspecYaml.loadFromYamlString(file.readAsStringSync());

      var replacePubspec = pubspecYaml.copyWith(
          version: Optional('0.0.1+1'),
          dependencies: _replaceDependencies(pubspecYaml.dependencies.toList()));

      print(file.path);
      print(replacePubspec.toYamlString());
      await file.writeAsStringSync(replacePubspec.toYamlString());
    } catch (e) {
      rethrow;
    }
  }

  /// TODO: костыль?
  Iterable<PackageDependencySpec> _replaceDependencies(List<PackageDependencySpec> dependencies) {
    for (var i = 0; dependencies.length > i; ++i) {
      if (dependencies[i].path != null) {
        var dep = dependencies[i];
        dependencies[i] = PackageDependencySpec.git(
          GitPackageDependencySpec(
            package: dep.path.package,
            url: _urls,
            ref: Optional('dev'),
            path: Optional(p.join('packages', dep.path.package)),
          ),
        );
      }
    }

    return dependencies;
  }
}
