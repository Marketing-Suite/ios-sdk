
//
//  DeviceToken.swift
//  EMSRefApp
//
//  Created by No Bodi on 10/1/16.
//  Copyright © 2016 com.experian. All rights reserved.
//

import UIKit

// MARK: - EMSPush: NSObject

public class EMSPush: NSObject {
    
    public override init(){
        
    }
    
    public func setToken(deviceToken: NSData)  {
        
        let prefs = NSUserDefaults.standardUserDefaults()
        
        var tokenString = ""
        let tokenChars = UnsafePointer<CChar>(deviceToken.bytes)
        
        for i in 0..<deviceToken.length {
            tokenString += String(format: "%02.2hhx", arguments: [tokenChars[i]])
        }
        
        let randNumber = 100 + Int(arc4random_uniform(UInt32(1000 - 100 + 1)))
        
        // Create UUID for low security Auth Token
        let uUID = NSUUID().UUIDString + String(randNumber)
        
        prefs.setValue(tokenString, forKey: Constants.DEVICETOKEN)
        prefs.setValue(uUID, forKey: Constants.AUTHTOKEN)
        
        // Set Flag Values loaded from JSON
        prefs.setBool(false, forKey: Constants.JSONLOADED)
        
        // Reset Error
        prefs.setValue("", forKey: Constants.PUSHERROR)
        
        // Check if devault needed for endpoint
        let endPointDefault:String = prefs.stringForKey(Constants.ENDPOINTPUSH)!
        
        if (endPointDefault.characters.count == 0){
            prefs.setValue("cs.sbox.eccmp.com", forKey: Constants.ENDPOINTPUSH)
            prefs.setValue("cs.sbox.eccmp.com", forKey: Constants.DEFAULTENDPOINTPUSH)
            prefs.setValue("100", forKey: Constants.CUSTID)
            prefs.setValue("a5090db4-03c6-43dc-9b53-2d6030a23c6e", forKey: Constants.APPIDIOS)
        }
        
        prefs.synchronize()
    }
    
    public func getToken() -> String {
    
        var returnToken = ""
        
        let prefs = NSUserDefaults.standardUserDefaults()
        if let token = prefs.stringForKey(Constants.DEVICETOKEN)
        {
            returnToken = token
        }
    
        return returnToken
    }
    
    public func saveUserInfo ( userInfo: [NSObject : AnyObject] ){
        
        let prefs = NSUserDefaults.standardUserDefaults()
        prefs.setValue(userInfo, forKey: Constants.USERINFO)
        prefs.setBool(true, forKey: Constants.NEWAPNS)
        //prefs.synchronize()
        
        // APNS Notification
        NSLog("AppDelegate: didReceiveRemoteNotification -> Broadcast")
        NSNotificationCenter.defaultCenter()
            .postNotificationName("apnsNotificationKey", object: self)
    }
    
    public func setError ( error: NSError ) {
        
        let prefs = NSUserDefaults.standardUserDefaults()
        let errorString = error.localizedDescription
        prefs.setValue(errorString, forKey: Constants.PUSHERROR)
        //prefs.synchronize()
    }
 
    // getError
    public func getError ( ) -> String  {
        
        var errorReturn = ""
        
        let prefs = NSUserDefaults.standardUserDefaults()
        if let errorString = prefs.stringForKey(Constants.PUSHERROR)
        {
            errorReturn = errorString
        }

        return errorReturn
    }
    
    // Get UUID
    public func getUuid ( ) -> String  {
        
        var returnString:String = ""
        
        let prefs = NSUserDefaults.standardUserDefaults()
        if let uuid = prefs.stringForKey(Constants.UUID)
        {
            returnString = uuid
        }
        
        return returnString
    }


    // TODO: convert userInfo to datatype to match iOS

    // setError
    /*
    func setError(error: String)  {
        
        let prefs = NSUserDefaults.standardUserDefaults()
        prefs.setValue(error, forKey: Constants.PUSHERROR)
        prefs.synchronize()
    }
 */
    
    // setDefaultEndPoint
    public func setDefaultEndPoint(defaultEndPoint: String)  {
        
        let prefs = NSUserDefaults.standardUserDefaults()
        prefs.setValue(defaultEndPoint, forKey: Constants.DEFAULTENDPOINTPUSH)
        prefs.synchronize()
    }
    
    // getDefaultEndPoint
    public func getDefaultEndPoint ( ) -> String  {
        
        var returnString:String = ""
        
        let prefs = NSUserDefaults.standardUserDefaults()
        if let defaultEndPoint = prefs.stringForKey(Constants.UUID)
        {
            returnString = defaultEndPoint
        }
        
        return returnString
    }
    
    // setJSONUrl
    public func setJSONUrl(jSONUrl: String)  {
        
        let prefs = NSUserDefaults.standardUserDefaults()
        prefs.setValue(jSONUrl, forKey: Constants.CONFIGURL)
        prefs.synchronize()
    }
    
    // getJSONUrl
    public func getJSONUrl ( ) -> String  {
        
        var returnString:String = ""
        
        let prefs = NSUserDefaults.standardUserDefaults()
        if let jSONUrl = prefs.stringForKey(Constants.CONFIGURL)
        {
            returnString = jSONUrl
        }
        
        return returnString
    }
    
    // setCustomerID
    public func setCustomerID(customerID: String)  {
        
        let prefs = NSUserDefaults.standardUserDefaults()
        prefs.setValue(customerID, forKey: Constants.CUSTID)
        prefs.synchronize()
    }
    
    // getCustomerID
    public func getCustomerID ( ) -> String  {
        
        var returnString:String = ""
        
        let prefs = NSUserDefaults.standardUserDefaults()
        if let customerID = prefs.stringForKey(Constants.CUSTID)
        {
            returnString = customerID
        }
        
        return returnString
    }
    
    // setApplicationID
    public func setApplicationID(applicationID: String)  {
        
        let prefs = NSUserDefaults.standardUserDefaults()
        prefs.setValue(applicationID, forKey: Constants.APPIDIOS)
        prefs.synchronize()
    }
    
    // getApplicationID
    public func getApplicationID ( ) -> String  {
        
        var returnString:String = ""
        
        let prefs = NSUserDefaults.standardUserDefaults()
        if let applicationID = prefs.stringForKey(Constants.APPIDIOS)
        {
            returnString = applicationID
        }
        
        return returnString
    }
    
    // setEndPoint
    public func setEndPoint(endPoint: String)  {
        
        let prefs = NSUserDefaults.standardUserDefaults()
        prefs.setValue(endPoint, forKey: Constants.ENDPOINTPUSH)
        prefs.synchronize()
    }
    
    // getEndPoint
    public func getEndPoint ( ) -> String  {
        
        var returnString:String = ""
        
        let prefs = NSUserDefaults.standardUserDefaults()
        if let endPoint = prefs.stringForKey(Constants.ENDPOINTPUSH)
        {
            returnString = endPoint
        }
        
        return returnString
    }
    
    // setPushRegistrationID
    public func setPushRegistrationID(pushRegistrationID: String)  {
        
        let prefs = NSUserDefaults.standardUserDefaults()
        prefs.setValue(pushRegistrationID, forKey: Constants.PRID)
        prefs.synchronize()
    }
    
    // getPushRegistrationID
    public func getPushRegistrationID ( ) -> String  {
        
        var returnString:String = "none"
        
        let prefs = NSUserDefaults.standardUserDefaults()
        if let pushRegistrationID = prefs.stringForKey(Constants.PRID)
        {
            returnString = pushRegistrationID
        }
        
        return returnString
    }
    
    // set fm
    public func setFM(fM: String)  {
        
        let prefs = NSUserDefaults.standardUserDefaults()
        prefs.setValue(fM, forKey: Constants.FM)
        prefs.synchronize()
    }
    
    // get fm
    public func getFM ( ) -> String  {
        
        var returnString:String = "none"
        
        let prefs = NSUserDefaults.standardUserDefaults()
        if let fM = prefs.stringForKey(Constants.FM)
        {
            returnString = fM
        }
        
        return returnString
    }
    
    // set WU
    public func setWU(wU: String)  {
        
        let prefs = NSUserDefaults.standardUserDefaults()
        prefs.setValue(wU, forKey: Constants.WU)
        prefs.synchronize()
    }
    
    // get WU
    public func getWU ( ) -> String  {
        
        var returnString:String = "none"
        
        let prefs = NSUserDefaults.standardUserDefaults()
        if let wU = prefs.stringForKey(Constants.WU)
        {
            returnString = wU
        }
        
        return returnString
    }
    
    // set user id
    public func setsUserID(sUserID: String)  {
        
        let prefs = NSUserDefaults.standardUserDefaults()
        prefs.setValue(sUserID, forKey: Constants.USERID)
        prefs.synchronize()
    }
    
    // get user id
    public func getsUserID ( ) -> String  {
        
        var returnString:String = ""
        
        let prefs = NSUserDefaults.standardUserDefaults()
        if let sUserID = prefs.stringForKey(Constants.USERID)
        {
            returnString = sUserID
        }
        
        return returnString
    }
    
    // set message id
    public func setsMessageID(sMessageID: String)  {
        
        let prefs = NSUserDefaults.standardUserDefaults()
        prefs.setValue(sMessageID, forKey: Constants.MESSAGEID)
        prefs.synchronize()
    }
    
    // get message id
    public func getsMessageID ( ) -> String  {
        
        var returnString:String = ""
        
        let prefs = NSUserDefaults.standardUserDefaults()
        if let sMessageID = prefs.stringForKey(Constants.MESSAGEID)
        {
            returnString = sMessageID
        }
        
        return returnString
    }
    
    // set message
    public func setsMessage(sMessage: String)  {
        
        let prefs = NSUserDefaults.standardUserDefaults()
        prefs.setValue(sMessage, forKey: Constants.MESSAGEID)
        prefs.synchronize()
    }
    
    // get message
    public func getsMessage ( ) -> String  {
        
        var returnString:String = "none"
        
        let prefs = NSUserDefaults.standardUserDefaults()
        if let sMessage = prefs.stringForKey(Constants.MESSAGE)
        {
            returnString = sMessage
        }
        
        return returnString
    }
    
    // set mobile token
    public func setsMobileToken(sMobileToken: String)  {
        
        let prefs = NSUserDefaults.standardUserDefaults()
        prefs.setValue(sMobileToken, forKey: Constants.MOBILETOKEN)
        prefs.synchronize()
    }
    
    // get mobile token
    public func getsMobileToken ( ) -> String  {
        
        var returnString:String = "none"
        
        let prefs = NSUserDefaults.standardUserDefaults()
        if let sMobileToken = prefs.stringForKey(Constants.MOBILETOKEN)
        {
            returnString = sMobileToken
        }
        
        return returnString
    }
    
    // set custom param
    public func setCustomParam(customParam: String)  {
        
        let prefs = NSUserDefaults.standardUserDefaults()
        prefs.setValue(customParam, forKey: Constants.CUSTOMPARAM)
        prefs.synchronize()
    }
    
    // get custom param
    public func getCustomParam ( ) -> String  {
        
        var returnString:String = ""
        
        let prefs = NSUserDefaults.standardUserDefaults()
        if let customParam = prefs.stringForKey(Constants.CUSTOMPARAM)
        {
            returnString = customParam
        }
        
        return returnString
    }

}
