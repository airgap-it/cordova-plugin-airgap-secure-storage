//
//  SecureStorage.swift
//  SecureStorage
//
//  Created by Alessandro De Carli on 23.02.18.
//  Copyright © 2018 ___Alessandro De Carli___. All rights reserved.
//

import Foundation
import Security

class SecureStorage{
    let tag: Data
    let accessControlFlags: SecAccessControlCreateFlags
    
    init(tag: Data, paranoiaMode: Bool = false){
        self.tag = tag
        if(paranoiaMode){
            self.accessControlFlags = [ .privateKeyUsage, .userPresence, .applicationPassword ]
        } else {
            self.accessControlFlags = [ .privateKeyUsage, .userPresence ]
        }
    }
    
    private func getSecretKeyQuery() ->  [String: Any]{
        return [kSecClass as String: kSecClassKey,
                kSecAttrApplicationTag as String: self.tag,
                kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
                kSecReturnRef as String: true]
    }
    
    private func generateNewBiometricSecuredKey(error: UnsafeMutablePointer<Unmanaged<CFError>?>?) -> SecKey? {
        guard let access = SecAccessControlCreateWithFlags(kCFAllocatorDefault,
                                                           kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
                                                           self.accessControlFlags,
                                                           error) else {
                                                            return nil;
        }
        
        let attributes: [String: Any] = [
            kSecAttrKeyType as String:            kSecAttrKeyTypeECSECPrimeRandom,
            kSecAttrKeySizeInBits as String:      256,
            kSecAttrTokenID as String:            kSecAttrTokenIDSecureEnclave,
            kSecPrivateKeyAttrs as String: [
                kSecAttrIsPermanent as String:      true,
                kSecAttrApplicationTag as String:   self.tag,
                kSecAttrAccessControl as String:    access
            ]
        ]
        
        guard let privateKey = SecKeyCreateRandomKey(attributes as CFDictionary, error) else {
            return nil
        }
        
        return privateKey
    }
    
    func getOrCreateBiometricSecuredKey(error: UnsafeMutablePointer<Unmanaged<CFError>?>?) -> SecKey? {
        var item: CFTypeRef?
        let status = SecItemCopyMatching(self.getSecretKeyQuery() as CFDictionary, &item)
        
        if status == errSecSuccess {
            return item as! SecKey
        } else {
            return self.generateNewBiometricSecuredKey(error: error)
        }
    }
    
    func dropSecuredKey() -> Bool {
        let status = SecItemDelete(self.getSecretKeyQuery() as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else { return false }
        return true
    }
    
    func store(key: String, value: String, error: UnsafeMutablePointer<Unmanaged<CFError>?>?) -> Bool {
        guard let secretKey = self.getOrCreateBiometricSecuredKey(error: error) else {
            return false
        }
        
        guard let eCCPublicKey = SecKeyCopyPublicKey(secretKey) else {
            return false
        }
        
        guard let messageData = value.data(using: String.Encoding.utf8) else {
            return false
        }
        
        guard let encryptedData = SecKeyCreateEncryptedData(
            eCCPublicKey,
            SecKeyAlgorithm.eciesEncryptionStandardX963SHA256AESGCM,
            messageData as CFData,
            error) else {
                print("pub ECC error encrypting")
                return false
        }
        
        let queryParameters: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                              kSecAttrAccount as String: key]
        
        let addKeyChainAttributes: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                                 kSecAttrAccount as String: key,
                                                 kSecValueData as String: encryptedData]
        
        var status = SecItemAdd(addKeyChainAttributes as CFDictionary, nil)
        if status == errSecDuplicateItem {
            let updateKeyChainAttributes: [String: Any] = [kSecValueData as String: encryptedData]
            status = SecItemUpdate(queryParameters as CFDictionary, updateKeyChainAttributes as CFDictionary)
        }
        
        guard status == errSecSuccess || status == errSecItemNotFound else {
            return false
        }
        
        return true
    }
    
    func retrieve(key: String, error: UnsafeMutablePointer<Unmanaged<CFError>?>?) -> String? {
        guard let secretKey = self.getOrCreateBiometricSecuredKey(error: error) else {
            return nil
        }
        
        var item: CFTypeRef?
        
        let queryParameters: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                              kSecAttrAccount as String: key,
                                              kSecReturnData as String: true]
        
        let status = SecItemCopyMatching(queryParameters as CFDictionary, &item)
        guard status == errSecSuccess else { return nil }
        guard let decryptedData = SecKeyCreateDecryptedData(
            secretKey,
            SecKeyAlgorithm.eciesEncryptionStandardX963SHA256AESGCM,
            item as! CFData,
            error) else {
                return nil
        }
        
        return String(data:decryptedData as Data, encoding: String.Encoding.utf8)
    }
    
    func delete(key: String, error: UnsafeMutablePointer<Unmanaged<CFError>?>?) -> Bool {
        let queryParameters: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                              kSecAttrAccount as String: key,
                                              kSecReturnData as String: true]
        
        let status = SecItemDelete(queryParameters as CFDictionary)
        
        guard status == errSecSuccess else { return false }
        
        return true
    }
}

