package com.teppei.kikuchi.zendesk.plugin

import android.app.Activity
import android.os.Handler
import android.os.Looper
import com.zendesk.service.ErrorResponse
import com.zendesk.service.ZendeskCallback
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import zendesk.chat.Chat
import zendesk.chat.ChatConfiguration
import zendesk.chat.ChatEngine
import zendesk.chat.ChatMenuAction
import zendesk.chat.VisitorInfo
import zendesk.classic.messaging.MessagingActivity


/** ZendeskPlugin */
class ZendeskPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    // / The MethodChannel that will the communication between Flutter and native Android
    // /
    // / This local reference serves to register the plugin with the Flutter Engine and unregister it
    // / when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel
    private var activity: Activity? = null

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "zendesk")
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onDetachedFromActivity() {
        activity = null
    }


    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "getPlatformVersion" -> {
                result.success("Android ${android.os.Build.VERSION.RELEASE}")
            }

            "initialize" -> {
                initialize(call)
                result.success(true)
            }

            "setVisitorInfo" -> {
                setVisitorInfo(call)
                result.success(true)
            }

            "startChat" -> {
                startChat(call)
                result.success(true)
            }

            "addTags" -> {
                addTags(call)
                result.success(true)
            }

            "removeTags" -> {
                removeTags(call)
                result.success(true)
            }

            "clearVisitorInfo" -> {
                clearVisitorInfo(result)
            }

            "endChat" -> {
                endChat(result)
            }

            else -> {
                result.notImplemented()
            }
        }
    }

    private fun initialize(call: MethodCall) {
        val accountKey = call.argument<String>("accountKey") ?: ""
        val applicationId = call.argument<String>("appId") ?: ""

        activity?.let { Chat.INSTANCE.init(it, accountKey, applicationId) }
    }

    private fun setVisitorInfo(call: MethodCall) {
        val name = call.argument<String>("name") ?: ""
        val email = call.argument<String>("email") ?: ""
        val phoneNumber = call.argument<String>("phoneNumber") ?: ""
        val department = call.argument<String>("department") ?: ""

        val profileProvider = Chat.INSTANCE.providers()?.profileProvider()
        val chatProvider = Chat.INSTANCE.providers()?.chatProvider()

        val visitorInfo = VisitorInfo.builder()
            .withName(name)
            .withEmail(email)
            .withPhoneNumber(phoneNumber) // numeric string
            .build()
        profileProvider?.setVisitorInfo(visitorInfo, null)
        chatProvider?.setDepartment(department, null)
    }

    /** 主线程 Handler：SDK 回调可能在后台线程，MethodChannel 结果必须在主线程返回。 */
    private val mainHandler = Handler(Looper.getMainLooper())

    /**
     * 清空访客信息与部门，并重置访客身份。
     *
     * 等 SDK 回调身份重置完成后才返回 [result]，调用方随后设置新身份才是安全的；
     * Chat 尚未初始化时没有可重置的身份，直接返回成功。
     */
    private fun clearVisitorInfo(result: Result) {
        val providers = Chat.INSTANCE.providers()
        if (providers == null) {
            result.success(true)
            return
        }
        val emptyVisitorInfo = VisitorInfo.builder()
            .withName("")
            .withEmail("")
            .withPhoneNumber("")
            .build()
        providers.profileProvider()?.setVisitorInfo(emptyVisitorInfo, null)
        providers.chatProvider()?.clearDepartment(null)
        Chat.INSTANCE.resetIdentity { _ -> mainHandler.post { result.success(true) } }
    }

    /**
     * 结束进行中的聊天，SDK 确认结束后才返回 [result]。
     *
     * Chat 尚未初始化时直接返回成功；SDK 失败时以 [Result.error] 返回，
     * 错误码为 HTTP 状态码（非 HTTP 错误为 -1）。
     */
    private fun endChat(result: Result) {
        val chatProvider = Chat.INSTANCE.providers()?.chatProvider()
        if (chatProvider == null) {
            result.success(true)
            return
        }
        chatProvider.endChat(object : ZendeskCallback<Void>() {
            override fun onSuccess(value: Void?) {
                mainHandler.post { result.success(true) }
            }

            override fun onError(error: ErrorResponse?) {
                mainHandler.post {
                    result.error(error?.status?.toString() ?: "", error?.reason, null)
                }
            }
        })
    }

    private fun addTags(call: MethodCall) {
        val tags = call.argument<List<String>>("tags") ?: listOf()
        val profileProvider = Chat.INSTANCE.providers()?.profileProvider()
        profileProvider?.addVisitorTags(tags, null)
    }

    private fun removeTags(call: MethodCall) {
        val tags = call.argument<List<String>>("tags") ?: listOf()
        val profileProvider = Chat.INSTANCE.providers()?.profileProvider()
        profileProvider?.removeVisitorTags(tags, null)
    }

    private fun startChat(call: MethodCall) {
        val isPreChatFormEnabled = call.argument<Boolean>("isPreChatFormEnabled") ?: true
        val isAgentAvailabilityEnabled =
            call.argument<Boolean>("isAgentAvailabilityEnabled") ?: true
        val isChatTranscriptPromptEnabled =
            call.argument<Boolean>("isChatTranscriptPromptEnabled") ?: true
        val isOfflineFormEnabled = call.argument<Boolean>("isOfflineFormEnabled") ?: true
        val title = call.argument<String>("title") ?: ""
        val chatConfigurationBuilder = ChatConfiguration.builder()
        chatConfigurationBuilder
            .withAgentAvailabilityEnabled(isAgentAvailabilityEnabled)
            .withTranscriptEnabled(isChatTranscriptPromptEnabled)
            .withOfflineFormEnabled(isOfflineFormEnabled)
            .withPreChatFormEnabled(isPreChatFormEnabled)
            .withChatMenuActions(ChatMenuAction.END_CHAT)

        val chatConfiguration = chatConfigurationBuilder.build()
        activity?.let {
            MessagingActivity.builder()
                .withToolbarTitle(title)
                .withEngines(ChatEngine.engine())
                .show(it, chatConfiguration)
        }
    }
}