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
@objc public enum EMSRegions : Int {
    case NorthAmerica// = "xts.eccmp.com"
    case Sandbox // = "cs.sbox.eccmp.com"
    case EMEA// = "xts.ccmp.com"
    case Japan // = "sandaws1.emssand.com"
    public static func count() -> Int { return 4 }
    public static func keys() -> [String] { return ["NorthAmerica", "Sandbox", "EMEA", "Japan"] }
    
    /// Retrieve the XTS value of the EMSRegion enum as a URL
    public static func XTS(region: EMSRegions) -> String {
        switch (region) {
        case EMSRegions.NorthAmerica:
            return "https://xts.eccmp.com"
        case EMSRegions.Sandbox:
            return "http://cs.sbox.eccmp.com"
        case EMSRegions.EMEA:
            return "https://xts.ccmp.eu"
        case EMSRegions.Japan:
            return "https://xts.ccmp.experian.co.jp"
        }
    }
    
    /// Retrieve the ATS value of the EMSRegion enum as a URL
    public static func ATS(region: EMSRegions) -> String {
        switch (region) {
        case EMSRegions.NorthAmerica:
            return "https://ats.eccmp.com"
        case EMSRegions.Sandbox:
            return "http://cs.sbox.eccmp.com/ats"
        case EMSRegions.EMEA:
            return "https://ats.ccmp.eu"
        case EMSRegions.Japan:
            return "https://ats.ccmp.experian.com.jp"
        }
    }
    
    /// Retrieve the EMSRegion from the string representation of the name of the EMSRegion
    public static func fromName(name: String) -> EMSRegions {
        switch (name)
        {
        case "NorthAmerica":
            return EMSRegions.NorthAmerica
        case "Sandbox":
            return EMSRegions.Sandbox
        case "EMEA":
            return EMSRegions.EMEA
        case "Japan":
            return EMSRegions.Japan
        default:
            return EMSRegions.NorthAmerica
        }
    }
    
    /// Retrieve the string representation of the name of the EMSRegion
    public func name() -> String
    {
        switch(self.rawValue)
        {
        case EMSRegions.NorthAmerica.rawValue:
            return "NorthAmerica"
        case EMSRegions.Sandbox.rawValue:
            return "Sandbox"
        case EMSRegions.EMEA.rawValue:
            return "EMEA"
        case EMSRegions.Japan.rawValue:
            return "Japan"
        default:
            return ""
        }
    }
}
