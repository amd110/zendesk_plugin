import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'source_code_platform_interface.dart';

/// An implementation of [SourceCodePlatform] that uses method channels.
class MethodChannelSourceCode extends SourceCodePlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('source_code');

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
