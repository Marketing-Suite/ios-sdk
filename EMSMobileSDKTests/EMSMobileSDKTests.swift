//
//  EMSMobileSDKTests.swift
//  EMSMobileSDKTests
//
//  Created by Paul Ballard on 1/12/17.
//  Copyright © 2017 Experian Marketing Services. All rights reserved.
//

/*
import XCTest
import Alamofire
@testable import EMSMobileSDK

class EMSMobileSDKTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testInit(){
        let sdk = EMSMobileSDK()
        XCTAssertNotNil(sdk.backgroundSession)
    }
    
    
    
    func testHexEncoding() {
        let result = EMSMobileSDK.default.hexEncodedString(data: "ABCDEFG".data(using: .ascii)!)
        XCTAssertEqual(result, "41424344454647")
    }
    
    func testInitialization() {
        let custID = 100
        let appID = "33f84e87-36df-426f-9ee0-a5c0b0b5433c"
        let region = EMSRegions.NorthAmerica
        EMSMobileSDK.default.Initialize(customerID: custID, appID: appID, region: region, options: nil)
        XCTAssertEqual(custID, EMSMobileSDK.default.customerID)
        XCTAssertEqual(appID, EMSMobileSDK.default.applicationID)
        XCTAssertNotNil(EMSMobileSDK.default.backgroundSession)
    }
    
    func testInitializationUserDefaults(){
        let custID = 100
        let appID = "33f84e87-36df-426f-9ee0-a5c0b0b5433c"
        let region = EMSRegions.NorthAmerica
        let storedToken = "fe5da804bb6167fa8a1fe44164828d5bfd853521ebc93f683de7bc4edf9a360d"
        UserDefaults.standard.set(storedToken, forKey:"DeviceTokenHex")
        EMSMobileSDK.default.Initialize(customerID: custID, appID: appID, region: region, options: nil)
        XCTAssertTrue(storedToken == EMSMobileSDK.default.deviceTokenHex!)
    } 
}
*/
