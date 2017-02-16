//
//  EMSRegions.swift
//  Pods
//
//  Created by Paul Ballard on 1/15/17.
//
//

import Foundation

@objc public enum EMSRegions : Int {
    case NorthAmerica// = "xts.eccmp.com"
    case NorthAmericaSB// = "cs.sbox.eccmp.com"
    case EMEA// = "xts.ccmp.com"
    case USStandard// = "sandaws1.emssand.com"
    public static func count() -> Int { return 4 }
    public static func keys() -> [String] { return ["NorthAmerica", "NorthAmericaSB", "EMEA", "USStandard"] }
    
    public static func value(region: EMSRegions) -> String {
        switch (region) {
        case EMSRegions.NorthAmerica:
            return "https://xts.eccmp.com"
        case EMSRegions.NorthAmericaSB:
            return "http://cs.sbox.eccmp.com"
        case EMSRegions.EMEA:
            return "https://xts.ccmp.com"
        case EMSRegions.USStandard:
            return "http://sandaws1.emssand.com"
        }
    }
    
    public static func fromName(name: String) -> EMSRegions {
        switch (name)
        {
        case "NorthAmerica":
            return EMSRegions.NorthAmerica
        case "NorthAmericaSB":
            return EMSRegions.NorthAmericaSB
        case "EMEA":
            return EMSRegions.EMEA
        case "USStandard":
            return EMSRegions.USStandard
        default:
            return EMSRegions.NorthAmerica
        }
    }
    
    public var name: String { get { return String(describing: self) }
    }
}
