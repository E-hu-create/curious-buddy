import 'dart:io';

import 'package:curious_buddy/ui/parent_zone/widgets/data_overview.dart';
import 'package:flutter_test/flutter_test.dart';

/// Guards the settings that keep a child's data on the phone.
void main() {
  final manifest = File(
    'android/app/src/main/AndroidManifest.xml',
  ).readAsStringSync();
  final rules = File(
    'android/app/src/main/res/xml/data_extraction_rules.xml',
  ).readAsStringSync();

  test('the manifest turns backup off and links the rules', () {
    expect(manifest, contains('android:allowBackup="false"'));
    expect(manifest, contains('android:fullBackupContent="false"'));
    expect(
      manifest,
      contains('android:dataExtractionRules="@xml/data_extraction_rules"'),
    );
  });

  test('both kinds of transfer exclude every place data can live', () {
    String section(String name) => RegExp(
      '<$name>(.*?)</$name>',
      dotAll: true,
    ).firstMatch(rules)!.group(1)!;

    for (final name in ['cloud-backup', 'device-transfer']) {
      final body = section(name);
      for (final domain in [
        'root',
        'file',
        'database',
        'sharedpref',
        'external',
        'device_root',
        'device_file',
        'device_database',
        'device_sharedpref',
      ]) {
        expect(
          body,
          contains('<exclude domain="$domain" path="."'),
          reason: '$name / $domain',
        );
      }
      expect(body, isNot(contains('<include')), reason: name);
    }
  });

  test('the Parent Zone does not promise more than Android does', () {
    expect(DataOverviewSection.where, contains('phone-to-phone'));
    expect(DataOverviewSection.where, contains('may still copy it'));
  });
}
