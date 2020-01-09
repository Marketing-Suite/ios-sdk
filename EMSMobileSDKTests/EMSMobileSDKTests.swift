//
//  EMSMobileSDKTests.swift
//  EMSMobileSDKTests
//
//  Created by Paul Ballard on 1/12/17.
//  Copyright © 2017 Experian Marketing Services. All rights reserved.
//

import Alamofire
@testable import EMSMobileSDK
import XCTest

class EMSMobileSDKTests: XCTestCase {
    
    let custID = 100
    let appID = "33f84e87-36df-426f-9ee0-a5c0b0b5433c"
    let region = EMSRegions.northAmerica
    let storedToken = "fe5da804bb6167fa8a1fe44164828d5bfd853521ebc93f683de7bc4edf9a360d"
    let prid = "15ce76e5-15aa-4fa5-bc63-f911ee21b847"
    
    func testInitialization() {
        EMSMobileSDK.default.initialize(customerID: custID,
                                        appID: appID,
                                        region: region,
                                        options: [UIApplication.LaunchOptionsKey.remoteNotification: [:]])
        XCTAssertEqual(custID, EMSMobileSDK.default.customerID)
        XCTAssertEqual(appID, EMSMobileSDK.default.applicationID)
        XCTAssertEqual(region, EMSMobileSDK.default.region)
    }
    
    func testRemoteNotificationReceived() {
        let mobileSDK = EMSMobileSDK.default
        mobileSDK.region = .northAmerica
        mobileSDK.remoteNotificationReceived(userInfo: ["ems_open": "https://google.com"])
    }
    
    func testSubscribe() {
        let mobileSDK = EMSMobileSDK.default
        mobileSDK.region = .northAmerica
        mobileSDK.customerID = custID
        mobileSDK.applicationID = appID
        let expectation = self.expectation(description: "subscribe")
        mobileSDK.subscribe(deviceToken: storedToken.data(using: .utf8) ?? Data()) { (_, _) in
            expectation.fulfill()
        }
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testUnsubscribe() {
        let keychainDeviceTokenHex = KeychainItem(serviceName: "com.cheetahdigital.emsmobilesdk",
                                                  account: "EMSMobileSDK.DeviceTokenHex")
        try? keychainDeviceTokenHex.writePassword(storedToken)
        let mobileSDK = EMSMobileSDK.default
        mobileSDK.region = .northAmerica
        mobileSDK.customerID = custID
        mobileSDK.applicationID = appID
        let expectation = self.expectation(description: "unsubscribe")
        mobileSDK.unsubscribe { (_, _) in
            expectation.fulfill()
        }
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testUpdateEMSSubscriptionIfNeeded() {
        let keychainDeviceTokenHex = KeychainItem(serviceName: "com.cheetahdigital.emsmobilesdk",
                                                  account: "EMSMobileSDK.DeviceTokenHex")
        try? keychainDeviceTokenHex.writePassword(storedToken)
        let keychainPRID = KeychainItem(serviceName: "com.cheetahdigital.emsmobilesdk",
                                        account: "EMSMobileSDK.PRID")
        try? keychainPRID.writePassword(prid)
        try? keychainDeviceTokenHex.writePassword(storedToken)
        let mobileSDK = EMSMobileSDK.default
        mobileSDK.region = .northAmerica
        mobileSDK.customerID = custID
        mobileSDK.applicationID = appID
        
        mobileSDK.updateEMSSubscriptionIfNeeded()
        
        UserDefaults.standard.set(true, forKey: "EMSPreviousPushSetting")
        mobileSDK.updateEMSSubscriptionIfNeeded()
        
        UserDefaults.standard.set(false, forKey: "EMSPreviousPushSetting")
    }
    
    func testAPIPost() {
        let mobileSDK = EMSMobileSDK.default
        mobileSDK.region = .northAmerica
        let expectation = self.expectation(description: "APIPost")
        mobileSDK.APIPost(formId: 1, data: nil, completionHandler: { _ in
            expectation.fulfill()
        })
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testHandleDeeplink() {
        let mobileSDK = EMSMobileSDK.default
        mobileSDK.region = .northAmerica
        
        let wrongDeepLink = mobileSDK.handleDeepLink(continue: NSUserActivity(activityType: "mockactivity"))
        XCTAssertNotNil(wrongDeepLink)
        
        let webActivity = NSUserActivity(activityType: NSUserActivityTypeBrowsingWeb)
        webActivity.webpageURL = URL(string: "https://www.google.com?dl=test")
        let deeplink = mobileSDK.handleDeepLink(continue: webActivity)
        XCTAssertNotNil(deeplink)
    }
}
