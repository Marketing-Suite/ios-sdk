//
//  EMSRegions.swift
//  Pods
//
//  Created by Paul Ballard on 1/15/17.
//
//

import Foundation
/**
 This enum contains the definitions for the CCMP Regions and URLs used for each
 Options are:
 * North America
 * Sandbox
 * EMEA
 * Japan
*/
@objc
public enum EMSRegions: Int {
    case northAmerica// = "xts.eccmp.com"
    case sandbox // = "cs.sbox.eccmp.com"
    case emea// = "xts.ccmp.com"
    case japan // = "sandaws1.emssand.com"
    public static func count() -> Int { return 4 }
    public static func keys() -> [String] { return ["NorthAmerica", "Sandbox", "EMEA", "Japan"] }
    
    /// Retrieve the XTS value of the EMSRegion enum as a URL
    public static func XTS(region: EMSRegions) -> String {
        switch region {
        case EMSRegions.northAmerica:
            return "https://xts.eccmp.com"
        case EMSRegions.sandbox:
            return "http://cs.sbox.eccmp.com"
        case EMSRegions.emea:
            return "https://xts.ccmp.eu"
        case EMSRegions.japan:
            return "https://xts.marketingsuite.jp"
        }
    }
    
    /// Retrieve the ATS value of the EMSRegion enum as a URL
    public static func ATS(region: EMSRegions) -> String {
        switch region {
        case EMSRegions.northAmerica:
            return "https://ats.eccmp.com"
        case EMSRegions.sandbox:
            return "http://cs.sbox.eccmp.com"
        case EMSRegions.emea:
            return "https://ats.ccmp.eu"
        case EMSRegions.japan:
            return "https://ats.marketingsuite.jp"
        }
    }
    
    /// Retrieve the EMSRegion from the string representation of the name of the EMSRegion
    public static func fromName(name: String) -> EMSRegions {
        switch name {
        case "NorthAmerica":
            return EMSRegions.northAmerica
        case "Sandbox":
            return EMSRegions.sandbox
        case "EMEA":
            return EMSRegions.emea
        case "Japan":
            return EMSRegions.japan
        default:
            return EMSRegions.northAmerica
        }
    }
    
    /// Retrieve the string representation of the name of the EMSRegion
    public func name() -> String {
        switch self.rawValue {
        case EMSRegions.northAmerica.rawValue:
            return "NorthAmerica"
        case EMSRegions.sandbox.rawValue:
            return "Sandbox"
        case EMSRegions.emea.rawValue:
            return "EMEA"
        case EMSRegions.japan.rawValue:
            return "Japan"
        default:
            return ""
        }
    }
}
