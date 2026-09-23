import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Directories (relative to the package root) that must only use the
/// standalone `material_ui` / `cupertino_ui` packages.
const _checkedDirectories = ['lib', 'test', 'example'];

const _skippedDirectoryNames = {'.dart_tool', 'build'};

final _sdkDesignImport = RegExp(
  r'''^\s*(import|export)\s+['"]package:flutter/(material|cupertino)\.dart['"]''',
);

void main() {
  test(
      'no file imports package:flutter/material.dart or '
      'package:flutter/cupertino.dart', () {
    final violations = <String>[];

    for (final directory in _checkedDirectories) {
      for (final file in _dartFilesIn(Directory(directory))) {
        final lines = file.readAsLinesSync();
        for (var i = 0; i < lines.length; i++) {
          if (_sdkDesignImport.hasMatch(lines[i])) {
            violations.add('${file.path}:${i + 1}: ${lines[i].trim()}');
          }
        }
      }
    }

    expect(
      violations,
      isEmpty,
      reason: 'Use package:material_ui/material_ui.dart or '
          'package:cupertino_ui/cupertino_ui.dart instead:\n'
          '${violations.join('\n')}',
    );
  });
}

Iterable<File> _dartFilesIn(Directory directory) sync* {
  if (!directory.existsSync()) return;
  for (final entity in directory.listSync(followLinks: false)) {
    final name = entity.uri.pathSegments.lastWhere((s) => s.isNotEmpty);
    if (entity is Directory && !_skippedDirectoryNames.contains(name)) {
      yield* _dartFilesIn(entity);
    } else if (entity is File && name.endsWith('.dart')) {
      yield entity;
    }
  }
}
