
@objc(SecureStoragePlugin) class SecureStoragePlugin : CDVPlugin {
    
    var operationQueue: OperationQueue!
    
    override func pluginInitialize() {
        operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 1
        operationQueue.name = "it.airgap.SecureStorageQueue"
    }
    
    private func getStorageForAlias(alias: String, isParanoia: Bool) -> SecureStorage {
        let tag = ("it.airgap.keys.biometrics.key-" + alias).data(using: .utf8)!
        return SecureStorage(tag: tag, paranoiaMode: isParanoia)
    }
    
    @objc func initialize(_ command: CDVInvokedUrlCommand) {
        operationQueue.addOperation {
            let alias = command.arguments[0] as! String
            let isParanoia = command.arguments[1] as! Bool
            let secureStorage = self.getStorageForAlias(alias: alias, isParanoia: isParanoia)
            self.commandDelegate!.send(
                CDVPluginResult(
                    status: CDVCommandStatus_OK,
                    messageAs: true
                ),
                callbackId: command.callbackId
            )
        }
    }
    
    @objc func isDeviceSecure(_ command: CDVInvokedUrlCommand) {
        operationQueue.addOperation {
            let secureStorage = self.getStorageForAlias(alias: "isDeviceSecure", isParanoia: false)
            var error: UnsafeMutablePointer<Unmanaged<CFError>?>?
            let securedKey = secureStorage.getOrCreateBiometricSecuredKey(error: error)
            let pluginResult: CDVPluginResult
            if (securedKey != nil) {
                pluginResult = CDVPluginResult(
                    status: CDVCommandStatus_OK,
                    messageAs: true
                )
            } else {
                pluginResult = CDVPluginResult(
                    status: CDVCommandStatus_OK,
                    messageAs: false
                )
            }
            
            self.commandDelegate!.send(
                pluginResult,
                callbackId: command.callbackId
            )
        }
    }
    
    @objc func secureDevice(_ command: CDVInvokedUrlCommand) {
        operationQueue.addOperation {
            guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
                return
            }
    
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                    print("Settings opened: \(success)") // Prints true
                })
            }
            
            self.commandDelegate!.send(
                CDVPluginResult(
                    status: CDVCommandStatus_OK,
                    messageAs: true
                ),
                callbackId: command.callbackId
            )
        }
    }
    
    @objc func removeAll(_ command: CDVInvokedUrlCommand) {
        operationQueue.addOperation {
            let alias = command.arguments[0] as! String
            let isParanoia = command.arguments[1] as! Bool
            let secureStorage = self.getStorageForAlias(alias: alias, isParanoia: isParanoia)
            
            secureStorage.dropSecuredKey()
            
            self.commandDelegate!.send(
                CDVPluginResult(
                    status: CDVCommandStatus_OK,
                    messageAs: true
                ),
                callbackId: command.callbackId
            )
        }
    }
    
    @objc func removeItem(_ command: CDVInvokedUrlCommand) {
        operationQueue.addOperation {
            let alias = command.arguments[0] as! String
            let isParanoia = command.arguments[1] as! Bool
            let key = command.arguments[2] as! String
            
            let secureStorage = self.getStorageForAlias(alias: alias, isParanoia: isParanoia)
            var error: Unmanaged<CFError>?
            
            secureStorage.delete(key: key, error: &error)
            
            let pluginResult: CDVPluginResult
            
            if (error != nil) {
                pluginResult = CDVPluginResult(
                    status: CDVCommandStatus_ERROR
                )
                print(error)
            } else {
                pluginResult = CDVPluginResult(
                    status: CDVCommandStatus_OK,
                    messageAs: true
                )
            }
            
            self.commandDelegate!.send(
                pluginResult,
                callbackId: command.callbackId
            )
        }
    }
    
    @objc func setItem(_ command: CDVInvokedUrlCommand) {
        operationQueue.addOperation {
            let alias = command.arguments[0] as! String
            let isParanoia = command.arguments[1] as! Bool
            let key = command.arguments[2] as! String
            let value = command.arguments[3] as! String
            
            let secureStorage = self.getStorageForAlias(alias: alias, isParanoia: isParanoia)
            var error: Unmanaged<CFError>?
            
            secureStorage.store(key: key, value: value, error: &error)
            
            let pluginResult: CDVPluginResult
            
            if (error != nil) {
                pluginResult = CDVPluginResult(
                    status: CDVCommandStatus_ERROR
                )
                print(error)
            } else {
                pluginResult = CDVPluginResult(
                    status: CDVCommandStatus_OK,
                    messageAs: true
                )
            }
            
            self.commandDelegate!.send(
                pluginResult,
                callbackId: command.callbackId
            )
        }
        
    }
    
    @objc func getItem(_ command: CDVInvokedUrlCommand) {
        operationQueue.addOperation {
            let alias = command.arguments[0] as! String
            let isParanoia = command.arguments[1] as! Bool
            let key = command.arguments[2] as! String
            
            var error: Unmanaged<CFError>?
            let secureStorage = self.getStorageForAlias(alias: alias, isParanoia: isParanoia)
            let value = secureStorage.retrieve(key: key, error: &error)
            
            let pluginResult: CDVPluginResult
            
            if (error != nil) {
                pluginResult = CDVPluginResult(
                    status: CDVCommandStatus_ERROR
                )
                print(error)
            } else {
                pluginResult = CDVPluginResult(
                    status: CDVCommandStatus_OK,
                    messageAs: value
                )
            }
            
            self.commandDelegate!.send(
                pluginResult,
                callbackId: command.callbackId
            )
        }
    }
    
}

