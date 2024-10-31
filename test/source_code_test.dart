import 'package:flutter_test/flutter_test.dart';
import 'package:source_code/source_code.dart';
import 'package:source_code/source_code_platform_interface.dart';
import 'package:source_code/source_code_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockSourceCodePlatform
    with MockPlatformInterfaceMixin
    implements SourceCodePlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final SourceCodePlatform initialPlatform = SourceCodePlatform.instance;

  test('$MethodChannelSourceCode is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelSourceCode>());
  });

  test('getPlatformVersion', () async {
    SourceCode sourceCodePlugin = SourceCode();
    MockSourceCodePlatform fakePlatform = MockSourceCodePlatform();
    SourceCodePlatform.instance = fakePlatform;

    expect(await sourceCodePlugin.getPlatformVersion(), '42');
  });
}
