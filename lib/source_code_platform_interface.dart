import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'source_code_method_channel.dart';

abstract class SourceCodePlatform extends PlatformInterface {
  /// Constructs a SourceCodePlatform.
  SourceCodePlatform() : super(token: _token);

  static final Object _token = Object();

  static SourceCodePlatform _instance = MethodChannelSourceCode();

  /// The default instance of [SourceCodePlatform] to use.
  ///
  /// Defaults to [MethodChannelSourceCode].
  static SourceCodePlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [SourceCodePlatform] when
  /// they register themselves.
  static set instance(SourceCodePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
