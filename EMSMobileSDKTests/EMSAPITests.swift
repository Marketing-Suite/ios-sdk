//
//  EMSAPITests.swift
//  EMSMobileSDKTests
//
//  Created by Julius Carlo Vitug on 09/01/2020.
//  Copyright © 2020 Experian Marketing Services. All rights reserved.
//

@testable import EMSMobileSDK
import XCTest

class EMSAPITests: XCTestCase {

    let emsAPI = EMSAPI()
    let custID = 100
    let appID = "33f84e87-36df-426f-9ee0-a5c0b0b5433c"
    let region = EMSRegions.sandbox
    let storedToken = "fe5da804bb6167fa8a1fe44164828d5bfd853521ebc93f683de7bc4edf9a360d"
    let prid = "15ce76e5-15aa-4fa5-bc63-f911ee21b847"
    
    func testInit() {
        XCTAssertNotNil(emsAPI)
        XCTAssertNotNil(emsAPI.session)
    }

    func testSubscribe() {
        let expectation = self.expectation(description: "subscribe")
        emsAPI.subscribe(region: region, customerID: custID, applicationID: appID, deviceToken: storedToken) { (_, _, _) in
            expectation.fulfill()
        }
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testSubscribeInvalidParams() {
        let expectation = self.expectation(description: "subscribewithinvalidparams")
        emsAPI.subscribe(region: region, customerID: custID, applicationID: "   ", deviceToken: storedToken) { (_, _, _) in
            expectation.fulfill()
        }
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testResubscribe() {
        let expectation = self.expectation(description: "resubscribe")
        emsAPI.resubscribe(region: region,
                           customerID: custID,
                           applicationID: appID,
                           deviceToken: "fe5da804bb6167fa8a1fe44164828d5bfd853521ebc93f683de7bc4edf9a36JJ",
                           prid: prid) { (_, _, _) in
                            expectation.fulfill()
        }
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testResubscribeEmptyPRID() {
        let expectation = self.expectation(description: "resubscribe")
        emsAPI.resubscribe(region: region,
                           customerID: custID,
                           applicationID: appID,
                           deviceToken: storedToken,
                           prid: nil) { (_, _, _) in
                            expectation.fulfill()
        }
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testResubscribeInvalidParams() {
        let expectation = self.expectation(description: "resubscribeinvalidparams")
        emsAPI.resubscribe(region: region,
                           customerID: custID,
                           applicationID: "     ",
                           deviceToken: "fe5da804bb6167fa8a1fe44164828d5bfd853521ebc93f683de7bc4edf9a36JJ",
                           prid: prid) { (_, _, _) in
                            expectation.fulfill()
        }
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testUnsubscribe() {
        let expectation = self.expectation(description: "unsubscribe")
        emsAPI.unsubscribe(region: region, customerID: custID, applicationID: appID, deviceToken: storedToken) { (_, _, _) in
            expectation.fulfill()
        }
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testUnsubscribeInvalidParams() {
        let expectation = self.expectation(description: "unsubscribeinvalidparams")
        emsAPI.unsubscribe(region: region, customerID: custID, applicationID: "   ", deviceToken: storedToken) { (_, _, _) in
            expectation.fulfill()
        }
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testEmsPost() {
        let expectation = self.expectation(description: "emspost")
        emsAPI.emsPost(region: region, customerID: custID, formId: 100, data: nil) { _ in
            expectation.fulfill()
        }
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testEmsPostData() {
        let expectation = self.expectation(description: "emspostdata")
        emsAPI.emsPost(region: region, customerID: custID, formId: 100, data: ["key": "test"]) { _ in
            expectation.fulfill()
        }
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testEmsPostInvalidData() {
        let expectation = self.expectation(description: "emspostinvaliddata")
        emsAPI.emsPost(region: region, customerID: -123, formId: 100, data: ["key": "test"]) { _ in
            expectation.fulfill()
        }
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testLogDeepLink() {
        let expectation = self.expectation(description: "logdeeplink")
        emsAPI.logDeepLink("https://developer.apple.com/") { _ in
            expectation.fulfill()
        }
        waitForExpectations(timeout: 10, handler: nil)
        
        emsAPI.logDeepLink("", completionHandler: { _ in })
    }

    func testLogEMSOpen() {
        let expectation = self.expectation(description: "logemsopen")
        emsAPI.logEMSOpen(url: "https://developer.apple.com/") { (_) in
            expectation.fulfill()
        }
        waitForExpectations(timeout: 10, handler: nil)
        
        emsAPI.logEMSOpen(url: "", completionHandler: { _ in })
    }
}
