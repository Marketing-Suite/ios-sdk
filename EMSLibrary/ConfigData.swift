//
//  ConfigData.swift
//  EMSRefApp
//
//  Created by Allen Bailey on 5/10/16.
//  Copyright © 2016 com.experian. All rights reserved.
//

import Foundation

// MARK: - ConfigData: NSObject

public class ConfigData : NSObject {
    
    public var customerId: String? = ""
    public var applicationId: String? = ""
    public var environment: String? = ""
    public var oAuthKey: String? = ""
    public var oAuthSecret: String? = ""
    public var deviceToken: String? = ""
}
