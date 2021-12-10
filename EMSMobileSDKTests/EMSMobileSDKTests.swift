//
//  EMSMobileSDKTests.swift
//  EMSMobileSDKTests
//
//  Created by Paul Ballard on 1/12/17.
//  Copyright © 2017 Experian Marketing Services. All rights reserved.
//

@testable import EMSMobileSDK
import XCTest

class EMSMobileSDKTests: XCTestCase {
    
    let custID = 100
    let appID = "33f84e87-36df-426f-9ee0-a5c0b0b5433c"
    let region = EMSRegions.northAmerica
    let storedToken = "fe5da804bb6167fa8a1fe44164828d5bfd853521ebc93f683de7bc4edf9a360d"
    let prid = "15ce76e5-15aa-4fa5-bc63-f911ee21b847"
    
    let keychainPRID = KeychainItem(serviceName: "com.cheetahdigital.emsmobilesdk",
                                    account: "EMSMobileSDK.PRID")
    let keychainDeviceTokenHex = KeychainItem(serviceName: "com.cheetahdigital.emsmobilesdk",
                                              account: "EMSMobileSDK.DeviceTokenHex")
    
    override func setUp() {
        super.setUp()
        try? keychainPRID.writePassword(prid)
        try? keychainDeviceTokenHex.writePassword(storedToken)
        EMSMobileSDK.default.region = region
        EMSMobileSDK.default.customerID = custID
        EMSMobileSDK.default.applicationID = appID
    }
    
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
        EMSMobileSDK.default.region = region
        EMSMobileSDK.default.remoteNotificationReceived(userInfo: ["ems_open": "https://google.com"])
    }
    
    func testSubscribe() {
        try? keychainPRID.delete()
        try? keychainDeviceTokenHex.delete()
        
        let expectation = self.expectation(description: "subscribe")
        EMSMobileSDK.default.subscribe(deviceToken: storedToken.hexData ?? Data()) { (_, _) in
            expectation.fulfill()
        }
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testResubscribe() {
        try? keychainDeviceTokenHex.delete()
        
        let expectation = self.expectation(description: "resubscribe")
        EMSMobileSDK.default.subscribe(deviceToken: storedToken.hexData ?? Data()) { (_, _) in
            expectation.fulfill()
        }
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testUnsubscribe() {
        let expectation = self.expectation(description: "unsubscribe")
        EMSMobileSDK.default.unsubscribe { (_, _) in
            expectation.fulfill()
        }
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testUpdateEMSSubscriptionIfNeeded() {
        EMSMobileSDK.default.updateEMSSubscriptionIfNeeded()
        
        UserDefaults.standard.set(true, forKey: "EMSPreviousPushSetting")
        EMSMobileSDK.default.updateEMSSubscriptionIfNeeded()
        
        UserDefaults.standard.set(false, forKey: "EMSPreviousPushSetting")
    }
    
    func testAPIPost() {
        let expectation = self.expectation(description: "APIPost")
        EMSMobileSDK.default.APIPost(formId: 1, data: nil, completionHandler: { _ in
            expectation.fulfill()
        })
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testHandleDeeplink() {
        let wrongDeepLink = EMSMobileSDK.default.handleDeepLink(continue: NSUserActivity(activityType: "mockactivity"))
        XCTAssertNotNil(wrongDeepLink)
        
        let webActivity = NSUserActivity(activityType: NSUserActivityTypeBrowsingWeb)
        webActivity.webpageURL = URL(string: "https://www.google.com?dl=test")
        let deeplink = EMSMobileSDK.default.handleDeepLink(continue: webActivity)
        XCTAssertNotNil(deeplink)
    }
}

extension String {

    var hexData: Data? {
        var data = Data(capacity: count / 2)

        let regex = try? NSRegularExpression(pattern: "[0-9a-f]{1,2}", options: .caseInsensitive)
        regex?.enumerateMatches(in: self, range: NSRange(startIndex..., in: self)) { match, _, _ in
            let byteString = (self as NSString).substring(with: match!.range)
            let number = UInt8(byteString, radix: 16)!
            data.append(number)
        }

        guard !data.isEmpty else { return nil }

        return data
    }

}
