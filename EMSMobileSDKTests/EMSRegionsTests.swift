//
//  EMSRegionsTests.swift
//  EMSMobileSDKTests
//
//  Created by Mark Dennis Diwa on 09/01/2020.
//  Copyright © 2020 Experian Marketing Services. All rights reserved.
//

@testable import EMSMobileSDK
import XCTest

class EMSRegionsTests: XCTestCase {

    func testRegionNorthAmerica() {
        let region = EMSRegions.northAmerica
        
        XCTAssertEqual(region.name, "NorthAmerica")
        XCTAssertEqual(region.xts, "https://xts.eccmp.com")
        XCTAssertEqual(region.ats, "https://ats.eccmp.com")
    }
    
    func testRegionSandbox() {
        let region = EMSRegions.sandbox
        
        XCTAssertEqual(region.name, "Sandbox")
        XCTAssertEqual(region.xts, "http://cs.sbox.eccmp.com")
        XCTAssertEqual(region.ats, "http://cs.sbox.eccmp.com")
    }
    
    func testRegionEMEA() {
        let region = EMSRegions.emea
        
        XCTAssertEqual(region.name, "EMEA")
        XCTAssertEqual(region.xts, "https://xts.ccmp.eu")
        XCTAssertEqual(region.ats, "https://ats.ccmp.eu")
    }
    
    func testRegionJapan() {
        let region = EMSRegions.japan
        
        XCTAssertEqual(region.name, "Japan")
        XCTAssertEqual(region.xts, "https://xts.marketingsuite.jp")
        XCTAssertEqual(region.ats, "https://ats.marketingsuite.jp")
    }
    
    func testRegionInitializationUsingName() {
        let northAmerica = EMSRegions(with: "NorthAmerica")
        let sandbox = EMSRegions(with: "Sandbox")
        let emea = EMSRegions(with: "EMEA")
        let japan = EMSRegions(with: "Japan")
        let mock = EMSRegions(with: "mock")
        
        XCTAssertEqual(northAmerica, EMSRegions.northAmerica)
        XCTAssertEqual(sandbox, EMSRegions.sandbox)
        XCTAssertEqual(emea, EMSRegions.emea)
        XCTAssertEqual(japan, EMSRegions.japan)
        XCTAssertEqual(mock, nil)
    }

}
