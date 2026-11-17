import os.log
import Flutter
import UIKit
import ChatSDK
import ChatProvidersSDK
import CommonUISDK
import MessagingSDK


public class ZendeskPlugin: NSObject, FlutterPlugin {
    var chatAPIConfig: ChatAPIConfiguration?
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "zendesk", binaryMessenger: registrar.messenger())
        let instance = ZendeskPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let dic = call.arguments as? Dictionary<String, Any>
        
        switch call.method {
        case "getPlatformVersion":
            result("iOS yo " + UIDevice.current.systemVersion)
        case "initialize":
            initialize(dictionary: dic!)
            result(true)
        case "setVisitorInfo":
            setVisitorInfo(dictionary: dic!)
            result(true)
        case "startChat":
            do {
                try startChat(dictionary: dic!)
            } catch _ {
                os_log("error:")
            }
            result(true)
        case "addTags":
            addTags(dictionary: dic!)
            result(true)
        case "removeTags":
            removeTags(dictionary: dic!)
            result(true)
        case "clearVisitorInfo":
            clearVisitorInfo(result: result)
        case "endChat":
            endChat(result: result)
        default:
            result("iOS " + UIDevice.current.systemVersion)
        }
    }
    
    func initialize(dictionary: Dictionary<String, Any>) {
        guard let accountKey = dictionary["accountKey"] as? String,
              let appId = dictionary["appId"] as? String
        else { return }
        
        Chat.initialize(accountKey: accountKey, appId: appId)
        initChatConfig()
    }
    
    func setVisitorInfo(dictionary: Dictionary<String, Any>) {
        guard let name = dictionary["name"] as? String,
              let email = dictionary["email"] as? String,
              let phoneNumber = dictionary["phoneNumber"] as? String
        else { return }
        let department = dictionary["department"] as? String ?? ""
        chatAPIConfig?.department = department
        chatAPIConfig?.visitorInfo = VisitorInfo(name: name, email: email, phoneNumber: phoneNumber)
        Chat.instance?.configuration = chatAPIConfig!
    }
    
    /// 清空访客信息与部门，并重置访客身份。
    ///
    /// 等 SDK 回调身份重置完成后才返回 `result`，调用方随后设置新身份才是安全的；
    /// Chat 尚未初始化时没有可重置的身份，直接返回成功。
    func clearVisitorInfo(result: @escaping FlutterResult) {
        chatAPIConfig?.visitorInfo = nil
        chatAPIConfig?.department = nil
        if let config = chatAPIConfig {
            Chat.instance?.configuration = config
        }
        guard let chat = Chat.instance else {
            result(true)
            return
        }
        chat.resetIdentity {
            DispatchQueue.main.async { result(true) }
        }
    }

    /// 结束进行中的聊天，SDK 确认结束后才返回 `result`。
    ///
    /// Chat 尚未初始化时直接返回成功；SDK 失败时返回错误码为 `end_chat_failed` 的错误。
    func endChat(result: @escaping FlutterResult) {
        guard let chatProvider = Chat.chatProvider else {
            result(true)
            return
        }
        chatProvider.endChat { (res: Result<Bool, DeliveryStatusError>) in
            DispatchQueue.main.async {
                switch res {
                case .success:
                    result(true)
                case .failure(let error):
                    result(FlutterError(code: "end_chat_failed", message: "\(error)", details: nil))
                }
            }
        }
    }

    func addTags(dictionary: Dictionary<String, Any>) {
        let tags = dictionary["tags"] as? Array<String> ?? []
        chatAPIConfig?.tags.append(contentsOf: tags)
        Chat.instance?.configuration = chatAPIConfig!
    }
    
    func removeTags(dictionary: Dictionary<String, Any>) {
        let tags = dictionary["tags"] as? Array<String> ?? []
        chatAPIConfig?.tags.removeAll(where: { t  in return tags.contains(t) })
        Chat.instance?.configuration = chatAPIConfig!
    }
    
    func startChat(dictionary: Dictionary<String, Any>) throws {
        guard let isPreChatFormEnabled = dictionary["isPreChatFormEnabled"] as? Bool,
              let isAgentAvailabilityEnabled = dictionary["isAgentAvailabilityEnabled"] as? Bool,
              let isChatTranscriptPromptEnabled = dictionary["isChatTranscriptPromptEnabled"] as? Bool,
              let isOfflineFormEnabled = dictionary["isOfflineFormEnabled"] as? Bool
        else {return}
        
        if let primaryColor = dictionary["primaryColor"] as? Int {
            CommonTheme.currentTheme.primaryColor = uiColorFromHex(rgbValue: primaryColor)
        }
        // Name for Bot messages
        let messagingConfiguration = MessagingConfiguration()
        messagingConfiguration.name = "Chat Bot"
        
        // Chat configuration
        let chatConfiguration = ChatConfiguration()
        chatConfiguration.isPreChatFormEnabled = isPreChatFormEnabled
        chatConfiguration.isAgentAvailabilityEnabled = isAgentAvailabilityEnabled
        chatConfiguration.isChatTranscriptPromptEnabled = isChatTranscriptPromptEnabled
        chatConfiguration.isOfflineFormEnabled = isOfflineFormEnabled
        
        // Build view controller
        let chatEngine = try ChatEngine.engine()
        let viewController = try Messaging.instance.buildUI(engines: [chatEngine], configs: [messagingConfiguration, chatConfiguration])
        let title = dictionary["title"] as? String
        viewController.title = title
        
        // Present view controller
        let rootViewController = UIApplication.shared.windows.filter({ (w) -> Bool in
            return w.isHidden == false
        }).first?.rootViewController
        presentViewController(rootViewController: rootViewController, view: viewController);
    }
    
    
    func presentViewController(rootViewController: UIViewController?, view: UIViewController) {
        if (rootViewController is UINavigationController) {
            (rootViewController as! UINavigationController).pushViewController(view, animated: true)
        } else {
            let navigationController: UINavigationController! = UINavigationController(rootViewController: view)
            rootViewController?.present(navigationController, animated: true, completion: nil)
        }
    }
    
    func uiColorFromHex(rgbValue: Int) -> UIColor {
        let red =   CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0
        let blue =  CGFloat(rgbValue & 0x0000FF) / 255.0
        let alpha = CGFloat(1.0)
        
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    func initChatConfig() {
        if (chatAPIConfig == nil) {
            chatAPIConfig = ChatAPIConfiguration()
        }
    }
}
