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
    case northAmerica
    case emea
    case japan
    
    /// Retrieve the string representation of the name of the EMSRegion
    public var name: String {
        switch self {
        case .northAmerica:
            return "NorthAmerica"
        case .emea:
            return "EMEA"
        case .japan:
            return "Japan"
        }
    }
    
    /// Retrieve the XTS value of the EMSRegion enum as a URL String
    public var xts: String {
        switch self {
        case .northAmerica:
            return "https://xts.eccmp.com"
        case .emea:
            return "https://xts.ccmp.eu"
        case .japan:
            return "https://xts.marketingsuite.jp"
        }
    }
    
    /// Retrieve the ATS value of the EMSRegion enum as a URL String
    public var ats: String {
        switch self {
        case .northAmerica:
            return "https://ats.eccmp.com"
        case .emea:
            return "https://ats.ccmp.eu"
        case .japan:
            return "https://ats.marketingsuite.jp"
        }
    }
    
    /// Retrieve the EMSRegion from the string representation of the name of the EMSRegion
    public init?(with name: String) {
        switch name {
        case "NorthAmerica":
            self = .northAmerica
        case "EMEA":
            self = .emea
        case "Japan":
            self = .japan
        default:
            return nil
        }
    }
}
