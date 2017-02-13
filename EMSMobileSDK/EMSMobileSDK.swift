//
//  EMSMobileSDK.swift
//  EMSMobileSDK
//
//  Created by Paul Ballard on 1/12/17.
//  Copyright © 2017 Experian Marketing Services. All rights reserved.
//

import Foundation
import Alamofire

// Internal Extensions
@objc public protocol EMSMobileSDKWatcherDelegate: class {
    func sdkMessage(sender: EMSMobileSDK, message: String)
}

@objc public class EMSMobileSDK : NSObject
{
    // Create Singleton Reference
    public static let `default` = EMSMobileSDK()
    
    // Monitor Delegate
    public weak var watcherDelegate:EMSMobileSDKWatcherDelegate?
    
    // fields
    var backgroundSession: Alamofire.SessionManager
    public var customerID: Int = 0
    public var applicationID: String = ""
    public var region: EMSRegions = EMSRegions.NorthAmericaSB
    public dynamic var prid: String?
    public dynamic var deviceTokenHex: String?
    public dynamic var deviceToken: Data? = nil
    
    private func Log(_ message: String)
    {
        //For Debugging
        print (message)
        //For any UI Listeners
        self.watcherDelegate?.sdkMessage(sender: self, message: message)
    }
    
    // Constructor/Destructor
    override init() {
        //Configure SessgionManager
        let configuration = URLSessionConfiguration.background(withIdentifier: "com.experian.emsmobilesdk")
        self.backgroundSession = Alamofire.SessionManager(configuration: configuration)
        super.init()
        self.Log("Background Configuration Set")
        
        //Retrieve Defaults
        self.prid = UserDefaults.standard.string(forKey: "PRID")
        if (self.prid != nil) { Log("Retrieved Stored PRID: " + self.prid!) }
        self.deviceTokenHex = UserDefaults.standard.string(forKey: "DeviceTokenHex")
        if (self.deviceTokenHex != nil) { Log("Retrieved Stored DeviceToken(Hex): " + self.deviceTokenHex!) }
    }
    
    deinit {
        Log("SDK DeInit")
        //NotificationCenter.default.removeObserver(self)
    }
    
    func hexEncodedString(data: Data) -> String {
        return data.map { String(format: "%02hhx", $0) }.joined()
    }
    
    // Public Functions
    public func Subscribe(deviceToken: Data) throws -> Void {
        var tokenString: String = ""
        
        self.deviceToken = deviceToken
        tokenString = hexEncodedString(data: deviceToken)
        Log("RegisterDeviceToken Received Token: " + tokenString)
        
        if (tokenString != self.deviceTokenHex)
        {
            let urlString : String = "http://\(EMSRegions.value(region: self.region))/xts/registration/cust/\(self.customerID)/application/\(self.applicationID)/token"
            try
                SendEMSMessage(url: urlString, method: .post, body: ["DeviceToken": tokenString], completionHandler: { response in
                    if let status = response.response?.statusCode {
                        switch(status){
                        case 201:
                            if let result = response.result.value {
                                self.Log("JSON Received: " + String(describing: response.result.value))
                                let JSON = result as! NSDictionary
                                let prid = JSON["Push_Registration_Id"] as! String
                                self.prid = prid
                                self.Log("PRID: " + String(describing: prid))
                                self.deviceTokenHex = tokenString
                                UserDefaults.standard.set(tokenString, forKey: "DeviceTokenHex")
                                UserDefaults.standard.set(prid, forKey: "PRID")
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
                })
        }
        return
    }
    public func UnSubscribe() throws -> Void {
        if (self.deviceTokenHex != nil)
        {
            let urlString : String = "http://\(EMSRegions.value(region: self.region))/xts/registration/cust/\(self.customerID)/application/\(self.applicationID)/token/\(self.deviceTokenHex)"
            try
                SendEMSMessage(url: urlString, method: .delete, body: nil, completionHandler: { response in
                    if let status = response.response?.statusCode {
                        switch(status){
                        case 201:
                            if let result = response.result.value {
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
    
    public func Initialize(customerID: Int, appID: String, region: EMSRegions = EMSRegions.NorthAmericaSB, options: [UIApplicationLaunchOptionsKey : Any]?){
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
    
    public func RemoteNotificationReceived(userInfo: [AnyHashable: Any]) throws
    {
        if (userInfo != nil)
        {
            self.Log("Raw Data Received: " + String(describing: userInfo))
            if let open_url = userInfo["ems_open"] as? String
            {
                self.Log("Received EMS_OPEN: " + open_url)
                try? SendEMSMessage(url: open_url, body: nil, completionHandler: { response in
                    if (response.response?.statusCode == 200)
                    {
                        self.Log("Content URL Sent")
                    }
                })
            }
        }
    }
    
    func SendEMSMessage(url :String, method: HTTPMethod = .get, body: Parameters?, completionHandler :@escaping (DataResponse<Any>) throws -> Void) throws {
        Log("Calling URL: " + url)

        self.backgroundSession.request(url, method: method, parameters: body, encoding: JSONEncoding.default, headers: nil).validate().responseJSON {
            response in
            print ("Received: " + String(describing: response.response?.statusCode))
            try? completionHandler(response)
        }
    }
}
