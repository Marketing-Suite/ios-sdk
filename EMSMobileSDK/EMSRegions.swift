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
    case Sandbox // = "cs.sbox.eccmp.com"
    case EMEA// = "xts.ccmp.com"
    case Japan // = "sandaws1.emssand.com"
    public static func count() -> Int { return 4 }
    public static func keys() -> [String] { return ["NorthAmerica", "Sandbox", "EMEA", "Japan"] }
    
    public static func value(region: EMSRegions) -> String {
        switch (region) {
        case EMSRegions.NorthAmerica:
            return "https://xts.eccmp.com"
        case EMSRegions.Sandbox:
            return "http://cs.sbox.eccmp.com"
        case EMSRegions.EMEA:
            return "https://xts.ccmp.eu"
        case EMSRegions.Japan:
            return "http://xts.ccmp.experian.co.jp"
        }
    }
    
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
