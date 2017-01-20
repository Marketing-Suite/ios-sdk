//
//  EMSMobileSDKTests.swift
//  EMSMobileSDKTests
//
//  Created by Paul Ballard on 1/12/17.
//  Copyright © 2017 Experian Marketing Services. All rights reserved.
//

import XCTest
@testable import EMSMobileSDK

class EMSMobileSDKTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testInit()
    {
        let sdk = EMSMobileSDK()
        XCTAssertNotNil(sdk.backgroundSession)
    }
    
    
    
    func testHexEncoding() {
        let result = EMSMobileSDK.default.hexEncodedString(data: "ABCDEFG".data(using: .ascii)!)
        XCTAssertEqual(result, "41424344454647")
    }
    
//    func testSendEMSMessageGET() {
//        let expect = expectation(description: "SendEMSMessage")
//        
//        try? EMSMobileSDK.default.SendEMSMessage(url: "https://httpbin.org/get", method: .get, body: nil, completionHandler:
//            { response in
//                XCTAssertEqual(response.response?.statusCode, 201, "Status code not 201")
//                expect.fulfill()
//        })
//        waitForExpectations(timeout: 5.0, handler: nil)
//    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        //self.measure {
            // Put the code you want to measure the time of here.
        }
    }

