//
//  EMSMobileSDK.swift
//  EMSMobileSDK
//
//  Created by Paul Ballard on 1/12/17.
//  Copyright © 2017 Experian Marketing Services. All rights reserved.
//

import Foundation
import Alamofire
import UIKit

/** ##Monitor Delegate##
 This delegate is used to receive debug and information messages from the SDK.  It should only be used for debugging
 and not for functional logic as it can change at any time.
 */
@objc public protocol EMSMobileSDKWatcherDelegate: class {
    func sdkMessage(sender: EMSMobileSDK, message: String)
}

/**
    This is the base class for accessing the EMS Mobile SDK.  It is a singleton and is referenced via
 `EMSMobileSDK.default`
 */
@objc public class EMSMobileSDK : NSObject
{
    /// Singleton Reference for accessing EMSMobileSDK
    public static let `default` = EMSMobileSDK()
    
    // Delegate Property
    public weak var watcherDelegate:EMSMobileSDKWatcherDelegate?
    
    // fields
    var backgroundSession: Alamofire.SessionManager
    /// The Customer ID set in the Initialize function
    public var customerID: Int = 0
    /// The Application ID set in the Initialize function
    ///  **This application ID is found in the Mobile App Group settings on CCMP**
    public var applicationID: String = ""
    /// The Region to use for all interations with CCMP, set in the Initialize function.
    public var region: EMSRegions = EMSRegions.Sandbox
    /// The PRID returned fro device registration with CCMP
    public private(set) dynamic var prid: String?
    /// The current DeviceToken for this device expressed as Hex
    public private(set) dynamic var deviceTokenHex: String?
    /// The current DeviceToken for this device as returned by APNS
    public private(set) dynamic var deviceToken: Data? = nil
    
    //Logging messages to Debug and WatcherDelegate
    private func Log(_ message: String)
    {
        //For Debugging
        print ("EMS: " + message)
        //For any UI Listeners
        self.watcherDelegate?.sdkMessage(sender: self, message: message)
    }
    
    // Constructor/Destructor
    override init() {
        //Configure SessionManager
        let configuration = URLSessionConfiguration.background(withIdentifier: "com.experian.emsmobilesdk")
        self.backgroundSession = Alamofire.SessionManager(configuration: configuration)
        super.init()
        
        //Retrieve Defaults
        self.prid = UserDefaults.standard.string(forKey: "PRID")
        if (self.prid != nil) { Log("Retrieved Stored PRID: " + self.prid!) }
        self.deviceTokenHex = UserDefaults.standard.string(forKey: "DeviceTokenHex")
        if (self.deviceTokenHex != nil) { Log("Retrieved Stored DeviceToken(Hex): " + self.deviceTokenHex!) }
    }
    
    deinit {
        Log("SDK DeInit")
    }
    
    func hexEncodedString(data: Data) -> String {
        return data.map { String(format: "%02hhx", $0) }.joined()
    }
    
    /**
        Used to subscribe a device to CCMP push notifications
        **NOTE:  The Initialize function must be called before calling the Subscribe function**
        - Parameter deviceToken:  The DeviceToken returned from APNS
    */
    public func Subscribe(deviceToken: Data) throws -> Void {
        var tokenString: String = ""
        var method: HTTPMethod = .post
        
        self.deviceToken = deviceToken
        tokenString = hexEncodedString(data: deviceToken)
        Log("Subscribing Token: " + tokenString)
        
        if (tokenString != self.deviceTokenHex)
        {
            var urlString: String
            self.deviceTokenHex = tokenString
            UserDefaults.standard.set(tokenString, forKey: "DeviceTokenHex")
            if (self.prid != nil)
            {
                urlString = "\(EMSRegions.value(region: self.region))/xts/registration/cust/\(self.customerID)/application/\(self.applicationID)/registration/\(self.prid!)/token"
                method = .put
            }
            else
            {
                urlString = "\(EMSRegions.value(region: self.region))/xts/registration/cust/\(self.customerID)/application/\(self.applicationID)/token"
                method = .post
            }
            try SendEMSMessage(url: urlString, method: method, body: ["DeviceToken": tokenString], completionHandler: EMSPRIDRegistrationResponse)
        }
        return
    }
    
    private func EMSPRIDRegistrationResponse(response: DataResponse<Any>) throws
    {
        if let status = response.response?.statusCode {
            switch(status){
            case 200, 201:
                if let result = response.result.value {
                    self.Log("JSON Received: " + String(describing: response.result.value!))
                    let JSON = result as! NSDictionary
                    let prid = JSON["Push_Registration_Id"] as! String
                    self.prid = prid
                    UserDefaults.standard.set(prid, forKey: "PRID")
                    self.Log("PRID: " + String(describing: prid))
                    self.Log("Device Subscribed")
                }
            case 400:
                throw EMSCommsError.invalidRequest
            case 401:
                throw EMSCommsError.notAuthenticated(userName: "")
            case 403:
                throw EMSCommsError.notAuthorized(userName: "")
            default:
                self.Log("Error with response status: \(status)")
            }
        }
    }

    /**
     Used to unsubscribe a device to CCMP push notifications
     */
    public func UnSubscribe() throws -> Void {
        if (self.deviceTokenHex != nil)
        {
            let urlString : String = "http://\(EMSRegions.value(region: self.region))/xts/registration/cust/\(self.customerID)/application/\(self.applicationID)/token/\(String(describing: self.deviceTokenHex))"
            try
                SendEMSMessage(url: urlString, method: .delete, body: nil, completionHandler: { response in
                    if let status = response.response?.statusCode {
                        switch(status){
                        case 201:
                            if response.result.value != nil {
                                self.Log("JSON Received: " + String(describing: response.result.value))
                                self.prid = nil
                                self.deviceTokenHex = nil
                                UserDefaults.standard.set(self.deviceTokenHex, forKey: "DeviceTokenHex")
                                UserDefaults.standard.set(self.prid, forKey: "PRID")
                                self.Log("Device Unsubscribed")
                            }
                        case 400:
                            throw EMSCommsError.invalidRequest
                        case 401:
                            throw EMSCommsError.notAuthenticated(userName: "")
                        case 403:
                            throw EMSCommsError.notAuthorized(userName: "")
                        default:
                            self.Log("Error with response status: \(status)")
                        }
                    }
                })
        }
        return
    }

    /**
        This function is used to initialize the SDK values for subsequent calls to CCMP
        - Parameter customerID:  This is your Customer ID in the CCMP application
        - Parameter appID:  This is the Application ID created for this app in CCMP
        - Parameter region:  This is the reqion that your CCMP instance is hosted in.  
        - Parameter options:  This is the collection of UILaunchOptionsKeys passed into the application on didFinishLaunching or nil if no options supplied.  This is used primarily for registring the launch of the application from a PUSH notification.
    */
    public func Initialize(customerID: Int, appID: String, region: EMSRegions = EMSRegions.Sandbox, options: [UIApplicationLaunchOptionsKey : Any]?){
        self.customerID = customerID
        self.applicationID = appID
        self.region = region
        if (options != nil)
        {
            if let userInfo = options?[UIApplicationLaunchOptionsKey.remoteNotification] as? [AnyHashable: Any]
            {
                //Woken up by Push Notification - Notify CCMP
                Log("Awoken by Remote Notification")
                try? RemoteNotificationReceived(userInfo: userInfo)
            }
        }
        Log("Initialized with CustomerID: \(self.customerID), AppID: \(self.applicationID), Region: \(self.region.rawValue)")
    }
    /**
     This function is called to allow the EMS Mobile SDK to process any push notifications relevant to CCMP
     > Note:  Only messages that contain CCMP specific functionality will result in a message being sent to CCMP.  Any application specific messages are ignored.
    */
    public func RemoteNotificationReceived(userInfo: [AnyHashable: Any]?) throws
    {
        if (userInfo != nil)
        {
            self.Log("Raw Push Data Received: " + String(describing: userInfo))
            if let open_url = userInfo?["ems_open"] as? String
            {
                self.Log("Received EMS_OPEN: " + open_url)
                try? SendEMSMessage(url: open_url, body: nil, completionHandler: { response in
                    if (response.response?.statusCode == 200)
                    {
                        self.Log("Content URL Sent Successfully")
                    }
                })
            }
        }
    }
    
    public func APIPost(formId: Int, data: Parameters?)
    {
        let urlString: String = "\(EMSRegions.value(region: self.region))/ats/post.aspx?cr=\(self.customerID)&fm=\(formId)"
        try? self.SendEMSMessage(url: urlString, method: .post, body: data, completionHandler: { response in
            if (response.response?.statusCode == 200)
            {
                self.Log("Form Post Sent Successfully")
            }
            else
            {
                self.Log("Error posting to form: \(formId) - \(String(describing: response.response?.statusCode))")
            }
        })
    }
    
    func SendEMSMessage(url :String, method: HTTPMethod = .get, body: Parameters?, completionHandler :@escaping (DataResponse<Any>) throws -> Void) throws {
        Log("Calling URL: " + url)
        
        self.backgroundSession.request(url, method: method, parameters: body, encoding: JSONEncoding.default).validate().responseJSON {
            response in
            print ("Received: " + String(describing: response.response?.statusCode))
            try? completionHandler(response)
        }
    }
}
