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
    
    func testInit() {
        XCTAssertNotNil(emsAPI)
        XCTAssertNotNil(emsAPI.backgroundSession)
        let configuration = emsAPI.backgroundSession.session.configuration
        XCTAssertEqual(configuration.identifier, "com.experian.emsmobilesdk")
    }

    func testSubscribe() {
        let custID = 100
        let appID = "33f84e87-36df-426f-9ee0-a5c0b0b5433c"
        let region = EMSRegions.northAmerica
        let storedToken = "fe5da804bb6167fa8a1fe44164828d5bfd853521ebc93f683de7bc4edf9a360d"
        let expectation = self.expectation(description: "subscribe")
        emsAPI.subscribe(region: region, customerID: custID, applicationID: appID, deviceToken: storedToken) { response in
            print("RESPONSE = \(response)")
            expectation.fulfill()
        }
        waitForExpectations(timeout: 10, handler: nil)
    }

}
