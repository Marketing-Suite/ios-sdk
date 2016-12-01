//
//  GetEnvironmentData.swift
//  EMSRefApp
//
//  Created by Allen Bailey on 9/29/16.
//  Copyright © 2016 com.experian. All rights reserved.
//

import UIKit

public class EnvironmentDataPrefs:NSObject {
    
    public class func getEnv() -> EnvironmentData {
        
        let prefs = NSUserDefaults.standardUserDefaults()
        let environmentData = EnvironmentData()

        environmentData.name = prefs.stringForKey(Constants.NAME)
        environmentData.region = prefs.stringForKey(Constants.REGION)
        environmentData.envName = prefs.stringForKey(Constants.ENVNAME)
        environmentData.envStatus = prefs.stringForKey(Constants.ENVSTATUS)
        environmentData.envNotes = prefs.stringForKey(Constants.ENVNOTES)
        environmentData.endPointPush = prefs.stringForKey(Constants.ENDPOINTPUSH)
        environmentData.custID = prefs.stringForKey(Constants.CUSTID)
        environmentData.appIDiOS = prefs.stringForKey(Constants.APPIDIOS)
        environmentData.appIDAndroid = prefs.stringForKey(Constants.APPIDANDROID)
        environmentData.appIDWindows = prefs.stringForKey(Constants.APPIDWINDOWS)
        
        return environmentData
    }
    
    public func saveEnv(environmentData: EnvironmentData) {
        
        let prefs = NSUserDefaults.standardUserDefaults()
        
        // Save Configuration Data
        prefs.setValue(environmentData.uuID, forKey: Constants.UUID)
        prefs.setValue(environmentData.name, forKey: Constants.NAME)
        prefs.setValue(environmentData.region, forKey: Constants.REGION)
        prefs.setValue(environmentData.envName, forKey: Constants.ENVNAME)
        prefs.setValue(environmentData.envStatus, forKey: Constants.ENVSTATUS)
        prefs.setValue(environmentData.envNotes, forKey: Constants.ENVNOTES)
        prefs.setValue(environmentData.endPointPush, forKey: Constants.ENDPOINTPUSH)
        prefs.setValue(environmentData.custID, forKey: Constants.CUSTID)
        prefs.setValue(environmentData.appIDiOS, forKey: Constants.APPIDIOS)
        prefs.setValue(environmentData.appIDAndroid, forKey: Constants.APPIDANDROID)
        prefs.setValue(environmentData.appIDWindows, forKey: Constants.APPIDWINDOWS)
        prefs.setValue(environmentData.prid, forKey: Constants.PRID)
        //prefs.synchronize()
        
    }
}
