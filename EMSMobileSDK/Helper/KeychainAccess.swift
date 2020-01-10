//
//  KeychainAccess.swift
//  EMSMobileSDK
//
//  Created by Mark Dennis Diwa on 07/01/2020.
//  Copyright © 2020 Experian Marketing Services. All rights reserved.
//

import Foundation
import LocalAuthentication

public struct KeychainError: Error {
    public var status: OSStatus

    public var localizedDescription: String {
        if #available(iOS 11.3, *) {
            return SecCopyErrorMessageString(status, nil) as String? ?? "Keychain Error OSStatus: \(status)"
        }
        return "Keychain Error OSStatus: \(status)"
        
    }
}

public struct KeychainItem {
    public let serviceName: String
    public let account: String
    
    public init(serviceName: String, account: String) {
        self.serviceName = serviceName
        self.account = account
    }
    
    public static var accessControlWithUserPrescence: SecAccessControl? {
        return SecAccessControlCreateWithFlags(nil,
                                               kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly,
                                               .userPresence,
                                               nil)
    }
    
    public func read(context: LAContext? = nil, message: String? = nil) throws -> Data? {
        var query = keychainQuery()
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        query[kSecReturnAttributes as String] = true
        query[kSecReturnData as String] = true
        
        if let context = context {
            query[kSecUseAuthenticationContext as String] = context
        }
        if let message = message {
            query[kSecUseOperationPrompt as String] = message
        }
        
        var queryResult: AnyObject?
        let status = withUnsafeMutablePointer(to: &queryResult) {
            SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
        }
        
        guard status == errSecSuccess else { throw KeychainError(status: status) }
        
        guard let existingItem = queryResult as? [String: Any],
            let data = existingItem[kSecValueData as String] as? Data
            else {
                return nil
        }
        
        return data
    }
    
    public func readPassword(context: LAContext? = nil, message: String? = nil) throws -> String? {
        
        guard let data = try read(context: context, message: message),
            let password = String(data: data, encoding: String.Encoding.utf8) else { return nil }
        
        return password
    }
    
    public func readJSON(context: LAContext? = nil, message: String? = nil) throws -> [String: Any]? {
        guard let data = try read(context: context, message: message) else { return nil }
        
        return try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
    }
    
    public func write(data: Data, with access: SecAccessControl? = nil, context: LAContext? = nil) throws {
        var query = keychainQuery()
        
        if let access = access {
            query[kSecAttrAccessControl as String] = access as Any
        }
        if let context = context {
            query[kSecUseAuthenticationContext as String] = context
        }
    
        guard (try? read(context: context)) != nil else {
            query[kSecValueData as String] = data
            let status = SecItemAdd(query as CFDictionary, nil)
            
            guard status == errSecSuccess else {
                throw KeychainError(status: status)
            }
            return
        }
        
        var attributesToUpdate = [String: Any]()
        attributesToUpdate[kSecValueData as String] = data
        let status = SecItemUpdate(query as CFDictionary, attributesToUpdate as CFDictionary)
        
        guard status == errSecSuccess else {
            throw KeychainError(status: status)
        }
    }
    
    public func writePassword(_ password: String, with access: SecAccessControl? = nil, context: LAContext? = nil) throws {
        guard let encodedPassword = password.data(using: String.Encoding.utf8) else { return }
        try write(data: encodedPassword, with: access, context: context)
    }
    
    public func write(json: [String: Any], with access: SecAccessControl? = nil, context: LAContext? = nil) throws {
        let data = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
        try write(data: data, with: access, context: context)
    }
    
    public func delete() throws {
        let query = keychainQuery()
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess else { throw KeychainError(status: status) }
    }
    
    public func keychainQuery() -> [String: Any] {
        var query = [String: Any]()
        query[kSecClass as String] = kSecClassGenericPassword
        query[kSecAttrService as String] = serviceName
        query[kSecAttrAccount as String] = account
        return query
    }
}
