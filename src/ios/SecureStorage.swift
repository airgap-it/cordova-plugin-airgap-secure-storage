//
//  SecureStorage.swift
//  SecureStorage
//
//  Created by Alessandro De Carli on 23.02.18.
//  Copyright © 2018 ___Alessandro De Carli___. All rights reserved.
//

import Foundation
import Security

class SecureStorage {

    let tag: Data
    let accessControlFlags: SecAccessControlCreateFlags
	private var secretKeyQuery: [String: Any] {
		return [
			kSecClass as String: kSecClassKey,
			kSecAttrApplicationTag as String: tag,
			kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
			kSecReturnRef as String: true
		]
	}
    
    init(tag: Data, paranoiaMode: Bool = false){
        self.tag = tag
        if (paranoiaMode){
            accessControlFlags = [.privateKeyUsage, .userPresence, .applicationPassword]
        } else {
            accessControlFlags = [.privateKeyUsage, .userPresence]
        }
    }

    private func generateNewBiometricSecuredKey() throws -> SecKey {
		var error: Unmanaged<CFError>? = nil
        guard let access = SecAccessControlCreateWithFlags(kCFAllocatorDefault, kSecAttrAccessibleWhenUnlockedThisDeviceOnly, accessControlFlags, &error) else {
			throw Error(error: error?.autorelease().takeUnretainedValue())
        }
        
        let attributes: [String: Any] = [
            kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
            kSecAttrKeySizeInBits as String: 256,
            kSecAttrTokenID as String: kSecAttrTokenIDSecureEnclave,
            kSecPrivateKeyAttrs as String: [
                kSecAttrIsPermanent as String: true,
                kSecAttrApplicationTag as String: tag,
                kSecAttrAccessControl as String: access
            ]
        ]
        
        guard let privateKey = SecKeyCreateRandomKey(attributes as CFDictionary, &error) else {
            throw Error(error: error?.autorelease().takeUnretainedValue())
        }
        
        return privateKey
    }

    private func getOrCreateBiometricSecuredKey() throws -> SecKey {
        var item: CFTypeRef?
        let status = SecItemCopyMatching(secretKeyQuery as CFDictionary, &item)
		guard status == errSecSuccess else {
			return try generateNewBiometricSecuredKey()
		}
        return (item as! SecKey)
    }
    
    func dropSecuredKey() -> Bool {
        let status = SecItemDelete(secretKeyQuery as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else { return false }
        return true
    }

    func store(key: String, value: String) throws {
        let secretKey = try getOrCreateBiometricSecuredKey()
        
        guard let eCCPublicKey = SecKeyCopyPublicKey(secretKey) else {
            throw Error.pubKeyCopyFailure
        }
        
        guard let messageData = value.data(using: .utf8) else {
            throw Error.dataConversionFailure
        }

		var error: Unmanaged<CFError>? = nil
        guard let encryptedData = SecKeyCreateEncryptedData(eCCPublicKey, .eciesEncryptionStandardX963SHA256AESGCM, messageData as CFData, &error) else {
			print("pub ECC error encrypting")
			throw Error(error: error?.autorelease().takeUnretainedValue())
		}
        
        let addKeyChainAttributes: [String: Any] = [
			kSecClass as String: kSecClassGenericPassword,
			kSecAttrAccount as String: key,
			kSecValueData as String: encryptedData
		]
        var status = SecItemAdd(addKeyChainAttributes as CFDictionary, nil)
		if status == errSecDuplicateItem {
			let queryParameters: [String: Any] = [
				kSecClass as String: kSecClassGenericPassword,
				kSecAttrAccount as String: key
			]
			let updateKeyChainAttributes: [String: Any] = [kSecValueData as String: encryptedData]
			status = SecItemUpdate(queryParameters as CFDictionary, updateKeyChainAttributes as CFDictionary)
		}
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw Error.osStatus(status)
        }
    }
    
    func retrieve(key: String) throws -> String {
        let secretKey = try getOrCreateBiometricSecuredKey()
        
        var item: CFTypeRef?
        let queryParameters: [String: Any] = [
			kSecClass as String: kSecClassGenericPassword,
			kSecAttrAccount as String: key,
			kSecReturnData as String: true
		]

        let status = SecItemCopyMatching(queryParameters as CFDictionary, &item)
        guard status == errSecSuccess else {
			throw Error.osStatus(status)
		}

		var error: Unmanaged<CFError>? = nil
        guard let decryptedData = SecKeyCreateDecryptedData(secretKey, .eciesEncryptionStandardX963SHA256AESGCM, item as! CFData, &error) else {
			throw Error(error: error?.autorelease().takeUnretainedValue())
        }
        
		guard let result = String(data: decryptedData as Data, encoding: .utf8) else {
			throw Error.stringConversionFailure
		}

		return result
    }

	func delete(key: String) throws {
		let queryParameters: [String: Any] = [
			kSecClass as String: kSecClassGenericPassword,
			kSecAttrAccount as String: key,
			kSecReturnData as String: true
		]
		let status = SecItemDelete(queryParameters as CFDictionary)

		guard status == errSecSuccess else {
			throw Error.osStatus(status)
		}
	}

	enum Error: Swift.Error {
		case unknown
		case `internal`(Swift.Error)
		case pubKeyCopyFailure
		case dataConversionFailure
		case stringConversionFailure
		case osStatus(OSStatus)

		init(error: Swift.Error?) {
			if let error = error {
				self = .internal(error)
			} else {
				self = .unknown
			}
		}
	}
}
