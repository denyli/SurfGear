import 'package:shell/shell.dart';

/// Проверяем, установлен ли git
class CheckInstallGit {
  Future<void> check() async {
    var shell = new Shell();
    var processResult = await shell.run('gt', ['help']);
    if (processResult.exitCode != 0) {
      return Future.error('git not found, install git of https://git-scm.com');
    }
  }
}
