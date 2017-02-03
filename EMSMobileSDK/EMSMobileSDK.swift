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
extension String: ParameterEncoding {
    public func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        var request = try urlRequest.asURLRequest()
        request.httpBody = data(using: .utf8, allowLossyConversion: false)
        return request
    }
}

public protocol EMSMobileSDKWatcherDelegate: class {
    func sdkMessage(sender: EMSMobileSDK, message: String)
}

public class EMSMobileSDK
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
    init() {
        //Configure SessgionManager
        let configuration = URLSessionConfiguration.background(withIdentifier: "com.experian.emsmobilesdk")
        self.backgroundSession = Alamofire.SessionManager(configuration: configuration)
        Log("Background Configuration Set")
        
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
            let urlString : String = "http://\(self.region.rawValue)/xts/registration/cust/\(self.customerID)/application/\(self.applicationID)/token/\(tokenString)"
            try
                SendEMSMessage(url: urlString, method: .post, completionHandler: { response in
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
            let urlString : String = "http://\(self.region.rawValue)/xts/registration/cust/\(self.customerID)/application/\(self.applicationID)/token/\(self.deviceTokenHex)"
            try
                SendEMSMessage(url: urlString, method: .delete, completionHandler: { response in
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
            if let userInfo = options?[UIApplicationLaunchOptionsKey.remoteNotification] as! NSDictionary?
            {
                //Woken up by Push Notification - Notify CCMP
                Log("Awoken by Remote Notification")
                RemoteNotificationReceived(userInfo: userInfo)
            }
        }
        Log("Initialized with CustomerID: \(self.customerID), AppID: \(self.applicationID), Region: \(self.region.rawValue)")
    }

    //Temporary - Remove this
    public func DisplayMessage(message: String)
    {
        let alertController = UIAlertController(title: "Data", message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default)
        {
            (result : UIAlertAction) -> Void in
            print("You pressed OK")
        }
        alertController.addAction(okAction)
        UIApplication.shared.keyWindow?.rootViewController?.present(alertController, animated: true, completion: nil)
    }
    
    public func RemoteNotificationReceived(userInfo: NSDictionary)
    {
        if (userInfo != nil)
        {
            DisplayMessage(message: String(describing: userInfo))
            if let content = userInfo["content"] as? NSDictionary
            {
                if let open_url = content["open_url"] as? String
                {
                    try? SendEMSMessage(url: open_url, completionHandler: { response in
                        self.Log("Content URL Sent")})
                }
            }
        }
    }
    
    
    func SendEMSMessage(url :String, method: HTTPMethod = .get, body: Any? = nil, completionHandler :@escaping (DataResponse<Any>) throws -> Void) throws {
        Log("Calling URL: " + url)
        var encoding : ParameterEncoding
        if body != nil
        {
            encoding = body as! ParameterEncoding
        }
        else
        {
            encoding = JSONEncoding()
        }
        self.backgroundSession.request(url, method: method, encoding: encoding).validate().responseJSON {
            response in
            print ("Received: " + String(describing: response.response?.statusCode))
            try? completionHandler(response)
        }
    }
}
