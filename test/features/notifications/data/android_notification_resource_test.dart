import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('release builds keep the notification status icon', () {
    final keepFile = File('android/app/src/main/res/raw/keep.xml');

    expect(keepFile.existsSync(), isTrue);
    expect(keepFile.readAsStringSync(), contains('@drawable/ic_stat_calendar'));
  });
}
