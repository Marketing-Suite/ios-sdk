//
//  KeychainAccessTests.swift
//  EMSMobileSDKTests
//
//  Created by Mark Dennis Diwa on 07/01/2020.
//  Copyright © 2020 Experian Marketing Services. All rights reserved.
//

@testable import EMSMobileSDK
@testable import LocalAuthentication
import XCTest

class KeychainAccessTests: XCTestCase {
    
    let mockPasswordString = "MockPasswordString"
    let mockReplacePasswordString = "MockReplaceString"
    let mockPasswordServiceName = "MockPasswordServiceName"
    let mockPasswordAccount = "MockPasswordAccount"
    
    let mockJSONServiceName = "MockJSONServiceName"
    let mockJSONAccount = "MockJSONAccount"
    var mockJSON = ["username": "mockUsername", "password": "mockPassword"]
    var mockReplaceJSON = ["username": "mockReplaceUsername", "password": "mockReplacePassword"]
    
    let mockDataServiceName = "MockDataServiceName"
    let mockDataAccount = "MockDataAccount"
    
    var mockData: Data? {
        return "mockStringForData".data(using: String.Encoding.utf8)
    }
    var mockReplaceData: Data? {
        return "mockStringForData".data(using: String.Encoding.utf8)
    }
    
    // MARK: - Write, Read and Delete Tests
    func testKeychainPasswordWriteReadDelete() {
        let mockContext = LAContext()
        let mockKeychainItem = KeychainItem(serviceName: mockPasswordServiceName, account: mockPasswordAccount)
        XCTAssertNotNil(try? mockKeychainItem.writePassword(mockPasswordString,
                                                            context: mockContext))

        XCTAssertEqual(try? mockKeychainItem.readPassword(context: mockContext,
                                                          message: "mockMessage"), mockPasswordString)
        
        XCTAssertNotNil(try? mockKeychainItem.delete())
        XCTAssertNil(try? mockKeychainItem.readPassword())
    }
    
    func testKeychainJSONWriteReadDelete() {
        let mockKeychainItem = KeychainItem(serviceName: mockJSONServiceName, account: mockJSONAccount)
        XCTAssertNotNil(try? mockKeychainItem.write(json: mockJSON))
        
        XCTAssertEqual(try? mockKeychainItem.readJSON() as? [String: String], mockJSON)
        
        XCTAssertNotNil(try? mockKeychainItem.delete())
        XCTAssertNil(try? mockKeychainItem.readJSON())
    }
    
    func testKeychainDataWriteReadDelete() {
        guard let data = mockData else {
            XCTFail("mockData is nil")
            return
        }
        let mockKeychainItem = KeychainItem(serviceName: mockDataServiceName, account: mockDataAccount)
        XCTAssertNotNil(try? mockKeychainItem.write(data: data))
        
        XCTAssertEqual(try? mockKeychainItem.read(), mockData)
        
        XCTAssertNotNil(try? mockKeychainItem.delete())
        XCTAssertNil(try? mockKeychainItem.read())
    }
    
    // MARK: - Overwrite Tests
    func testKeychainOverwritePassword() {
        let mockKeychainItem = KeychainItem(serviceName: mockPasswordServiceName, account: mockPasswordAccount)
        XCTAssertNotNil(try? mockKeychainItem.writePassword(mockPasswordString))
        XCTAssertEqual(try? mockKeychainItem.readPassword(), mockPasswordString)
        
        XCTAssertNotNil(try? mockKeychainItem.writePassword(mockReplacePasswordString))
        XCTAssertEqual(try? mockKeychainItem.readPassword(), mockReplacePasswordString)
        XCTAssertNotNil(try? mockKeychainItem.delete())
        XCTAssertNil(try? mockKeychainItem.readPassword())
    }
    
    func testKeychainOverwriteJSON() {
        let mockKeychainItem = KeychainItem(serviceName: mockJSONServiceName, account: mockJSONAccount)
        XCTAssertNotNil(try? mockKeychainItem.write(json: mockJSON))
        XCTAssertEqual(try? mockKeychainItem.readJSON() as? [String: String], mockJSON)
        
        XCTAssertNotNil(try? mockKeychainItem.write(json: mockReplaceJSON))
        XCTAssertEqual(try? mockKeychainItem.readJSON() as? [String: String], mockReplaceJSON)
        XCTAssertNotNil(try? mockKeychainItem.delete())
        XCTAssertNil(try? mockKeychainItem.readJSON())
    }
    
    func testKeychainOverwriteData() {
        guard let data = mockData, let replaceData = mockReplaceData else {
            XCTFail("mockData/mockReplaceData is nil")
            return
        }
        let mockKeychainItem = KeychainItem(serviceName: mockDataServiceName, account: mockDataAccount)
        XCTAssertNotNil(try? mockKeychainItem.write(data: data))
        XCTAssertEqual(try? mockKeychainItem.read(), mockData)
        
        XCTAssertNotNil(try? mockKeychainItem.write(data: replaceData))
        XCTAssertEqual(try? mockKeychainItem.read(), mockReplaceData)
        XCTAssertNotNil(try? mockKeychainItem.delete())
        XCTAssertNil(try? mockKeychainItem.read())
    }
    
    func testKeychainError() {
        let keychainError = KeychainError(status: -34) //errSecDiskFull
        // Please test on ios version above and below 11.3
        if #available(iOS 11.3, *) {
            XCTAssertEqual(keychainError.localizedDescription, "The disk is full.")
        } else {
            XCTAssertEqual(keychainError.localizedDescription, "Keychain Error OSStatus: \(errSecDiskFull)")
        }
        
    }
    
    func testDeclareAccessControlWithUserPrescence() {
        let accessControl = KeychainItem.accessControlWithUserPrescence
        let mockAccessControl = SecAccessControlCreateWithFlags(nil,
                                                                kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly,
                                                                .userPresence,
                                                                nil)
        
        XCTAssertEqual(accessControl, mockAccessControl)
    }
    
}
