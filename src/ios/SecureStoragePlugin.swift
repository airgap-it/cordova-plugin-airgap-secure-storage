import Foundation
import LocalAuthentication

@objc(SecureStoragePlugin) class SecureStoragePlugin : CDVPlugin {
    
    var operationQueue: OperationQueue!
    
    override func pluginInitialize() {
        operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 1
        operationQueue.name = "it.airgap.SecureStorageQueue"
    }
    
    private func storage(forAlias alias: String, isParanoia: Bool) -> SecureStorage {
        let tag = ("it.airgap.keys.biometrics.key-" + alias).data(using: .utf8)!
        return SecureStorage(tag: tag, paranoiaMode: isParanoia)
    }
    
    @objc func initialize(_ command: CDVInvokedUrlCommand) {
        operationQueue.addOperation {
            let alias = command.arguments[0] as! String
            let isParanoia = command.arguments[1] as! Bool
			_ = self.storage(forAlias: alias, isParanoia: isParanoia)
            self.commandDelegate.send(
                CDVPluginResult(status: CDVCommandStatus_OK, messageAs: true),
                callbackId: command.callbackId
            )
        }
    }
    
    @objc func isDeviceSecure(_ command: CDVInvokedUrlCommand) {
        operationQueue.addOperation {
			let result = LAContext().canEvaluatePolicy(.deviceOwnerAuthentication, error: nil)
			let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: result)
            
            self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
        }
    }
    
    @objc func secureDevice(_ command: CDVInvokedUrlCommand) {
        operationQueue.addOperation {
			guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
    
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl) { (success) in
                    print("Settings opened: \(success)") // Prints true
                }
            }
            
            self.commandDelegate.send(
                CDVPluginResult(status: CDVCommandStatus_OK, messageAs: true),
                callbackId: command.callbackId
            )
        }
    }
    
    @objc func removeAll(_ command: CDVInvokedUrlCommand) {
        operationQueue.addOperation {
            let alias = command.arguments[0] as! String
            let isParanoia = command.arguments[1] as! Bool
            let secureStorage = self.storage(forAlias: alias, isParanoia: isParanoia)
            
            _ = secureStorage.dropSecuredKey()
            
            self.commandDelegate.send(
                CDVPluginResult(status: CDVCommandStatus_OK, messageAs: true),
				callbackId: command.callbackId
            )
        }
    }
    
    @objc func removeItem(_ command: CDVInvokedUrlCommand) {
        operationQueue.addOperation {
            let alias = command.arguments[0] as! String
            let isParanoia = command.arguments[1] as! Bool
            let key = command.arguments[2] as! String
            
            let secureStorage = self.storage(forAlias: alias, isParanoia: isParanoia)
			let pluginResult: CDVPluginResult
			do {
				try secureStorage.delete(key: key)
				pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: true)
			} catch {
				pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR)
				print(error)
			}
            
            self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
        }
    }
    
    @objc func setItem(_ command: CDVInvokedUrlCommand) {
        operationQueue.addOperation {
            let alias = command.arguments[0] as! String
            let isParanoia = command.arguments[1] as! Bool
            let key = command.arguments[2] as! String
            let value = command.arguments[3] as! String
            
            let secureStorage = self.storage(forAlias: alias, isParanoia: isParanoia)

			let pluginResult: CDVPluginResult
			do {
				try secureStorage.store(key: key, value: value)
				pluginResult = CDVPluginResult(
					status: CDVCommandStatus_OK,
					messageAs: true
				)
			} catch {
				pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR)
				print(error)
			}
            
            self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
        }
        
    }
    
    @objc func getItem(_ command: CDVInvokedUrlCommand) {
        operationQueue.addOperation {
            let alias = command.arguments[0] as! String
            let isParanoia = command.arguments[1] as! Bool
            let key = command.arguments[2] as! String

            let secureStorage = self.storage(forAlias: alias, isParanoia: isParanoia)
			let pluginResult: CDVPluginResult
			do {
				let value = try secureStorage.retrieve(key: key)
				pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: value)
			} catch {
				pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR)
				print(error)
			}

            self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
        }
    }
    
}

