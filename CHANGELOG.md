## 2.2.2

- `clearVisitorInfo()` 改为等原生 SDK 完成身份重置后才返回（Android 使用 `resetIdentity(CompletionCallback)`，iOS 使用 `resetIdentity(_:)` 的完成回调）。之前在重置完成前就返回，新身份可能在旧身份清理过程中被设置。
- `endChat()` 改为等原生 SDK 确认聊天已结束后才返回；结束失败时抛出 `PlatformException`，不再总是返回成功。
- Chat 尚未初始化时，以上两个方法仍会立即返回成功。

## 2.2.1

- Android: downgraded `com.zendesk:chat` from 3.8.0 to 3.7.2 and `com.zendesk:messaging` from 5.8.0 to 5.7.3, because 3.8.0 / 5.8.0 require `compileSdk` 37. The app can stay on `compileSdk` 36 again.
- Example: restored `compileSdk` to `flutter.compileSdkVersion` and removed the no-longer-needed `META-INF` packaging exclusion.

## 2.2.0

- Added `Zendesk.clearVisitorInfo()` to clear visitor info and reset the visitor identity.
- Added `Zendesk.endChat()` to end the chat in progress.
- iOS: pinned `ZendeskChatSDK` to 5.0.8.
- Android: upgraded build tooling (Gradle 8.14.3, AGP 8.11.1, Kotlin 2.2.20) to work with Flutter 3.47.5.

## 2.1.2

- Update format. (Just run `dart format .`)

## 2.1.1

- Fixed ios package name

## 2.1.0

- Migrated to chat sdk version 3.5.0
- Migrated to messaging sdk version 5.5.0
- Migrated to chat-providers sdk version 3.5.0

## 2.0.0

- Migrated to null safety

## 1.2.1

- Update navigation title to "Contact Us"

## 1.2.0

BREAKING CHANGE: Updated `navigationBarColor` to `primaryColor`

- Added support for adding and removing tags on a chat
- Added support for various chat settings:
  - `isPreChatFormEnabled`
  - `isAgentAvailabilityEnabled`
  - `isChatTranscriptPromptEnabled`
  - `isOfflineFormEnabled`

## 1.0.1

- Update documentation

## 1.0.0

- Initial release
