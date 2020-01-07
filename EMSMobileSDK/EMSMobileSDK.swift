//
//  EMSMobileSDK.swift
//  EMSMobileSDK
//
//  Created by Paul Ballard on 1/12/17.
//  Copyright © 2017 Experian Marketing Services. All rights reserved.
//

import Alamofire
import Foundation
import UIKit

/** ##Monitor Delegate##
 This delegate is used to receive debug and information messages from the SDK.  It should only be used for debugging
 and not for functional logic as it can change at any time.
 */
@objc public protocol EMSMobileSDKWatcherDelegate: class {
    func sdkMessage(sender: EMSMobileSDK, message: String)
}

public typealias StringCompletionHandlerType = (_ result: String) -> Void
public typealias BoolCompletionHandlerType = (_ success: Bool) -> Void

/**
    This is the base class for accessing the EMS Mobile SDK.  It is a singleton and is referenced via
 `EMSMobileSDK.default`
 */
@objc
public class EMSMobileSDK: NSObject {
    private let keychainPRID = KeychainItem(serviceName: "com.cheetahdigital.emsmobilesdk",
                                            account: "EMSMobileSDK.PRID")
    private let keychainDeviceTokenHex = KeychainItem(serviceName: "com.cheetahdigital.emsmobilesdk",
                                                      account: "EMSMobileSDK.DeviceTokenHex")
    
    /// Singleton Reference for accessing EMSMobileSDK
    public static let `default` = EMSMobileSDK()
    
    // Delegate Property
    public weak var watcherDelegate: EMSMobileSDKWatcherDelegate?
    
    // fields
    var backgroundSession: Alamofire.SessionManager
    /// The Customer ID set in the Initialize function
    public var customerID: Int = 0
    /// The Application ID set in the Initialize function
    ///  **This application ID is found in the Mobile App Group settings on CCMP**
    public var applicationID: String = ""
    /// The Region to use for all interations with CCMP, set in the Initialize function.
    public var region: EMSRegions = EMSRegions.sandbox
    /// The PRID returned fro device registration with CCMP
    @objc public private(set) dynamic var prid: String?
    /// The current DeviceToken for this device expressed as Hex
    @objc public private(set) dynamic var deviceTokenHex: String?
    /// The current DeviceToken for this device as returned by APNS
    @objc public private(set) dynamic var deviceToken: Data?
    
    //Logging messages to Debug and WatcherDelegate
    private func log(_ message: String) {
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
        self.prid = try? keychainPRID.readPassword()
        if self.prid != nil {
            log("Retrieved Stored PRID: " + self.prid!)
        }
        self.deviceTokenHex = try? keychainDeviceTokenHex.readPassword()
        if self.deviceTokenHex != nil {
            log("Retrieved Stored DeviceToken(Hex): " + self.deviceTokenHex!)
        }
    }
    
    deinit {
        log("SDK DeInit")
    }

    // Private Functions
    func hexEncodedString(data: Data) -> String {
        return data.map { String(format: "%02hhx", $0) }.joined()
    }

    func sendEMSMessage(url: String,
                        method: HTTPMethod = .get,
                        body: Parameters?,
                        completionHandler: @escaping (DataResponse<Any>) throws -> Void) throws {
        log("Calling URL: " + url)
        
        let request = self.backgroundSession.request(url,
                                                     method: method,
                                                     parameters: body,
                                                     encoding: JSONEncoding.default)
        
        request.validate().responseJSON { response in
            try? completionHandler(response)
        }
    }
  
    private func postOptInOutSetting(urlString: String, method: HTTPMethod, body: Parameters?) {
        if !urlString.isEmpty {
            let request = self.backgroundSession.request(urlString,
                                                         method: method,
                                                         parameters: body,
                                                         encoding: JSONEncoding.default)
            request.validate().responseJSON { response in
                self.log("OptInOut request status: " + String(describing: response.response?.statusCode))
            }
        }
    }
  
    // Public Functions
  /*
   
   If notifications are turned off at the operating system level, the SDK should detect this,
   and send an http DELETE containing the _cust id_, _application id_, and _device token_ to the {{xts/registration}} API,
   in order to mark the PRID as opted out, so that it is not processed in during MLC.
   
   Upon detection of notifications being turned back on, the SDK should send an http POST containing the same details in order to mark the record as opted back in.
   */
    public func checkOSNotificationSettings() {
      //inidcates user has at least enabled push once to initially subscribe
      if self.deviceTokenHex != nil {
        let previousPushSetting = UserDefaults.standard.bool(forKey: "EMSPreviousPushSetting")
        //available ios 8 and up
        let currentPushSetting = UIApplication.shared.isRegisteredForRemoteNotifications
        
        log("\n\n+++++\n")
        log("+app entered foreground:\n")
        log("+previous push setting: \(previousPushSetting ? "yes" : "no")\n")
        log("+retistration setting: \(currentPushSetting ? "yes" : "no")")
        log("\n+++++\n\n")
        
        guard let devToken = self.deviceTokenHex else {
          log("missing required param, device token in optinout check")
          return
        }
        
        var method: HTTPMethod = .post
        
        //if prev setting and current setting don't match handle optin/out
        //if setting = yes and prv = no then opt in
        //if setting = no and prev = yes then opt out
        if previousPushSetting != currentPushSetting {
          log("\n\n")
          log("OPTIN/OUT params:\n")
          log("customerID: \(self.customerID)\nappID: \(self.applicationID)\ndeviceToken: \(devToken)")
          log("\n")
          
          let urlString = "\(EMSRegions.XTS(region: self.region))/xts/registration/cust/\(self.customerID)/application/\(self.applicationID)/token/\(devToken)"
          
          if currentPushSetting == false {
            //opt out
            UserDefaults.standard.set(false, forKey: "EMSPreviousPushSetting")
            method = .delete
            log("OPTING OUT: \(UserDefaults.standard.object(forKey: "EMSPreviousPushSetting") ?? "..")\n")
          } else {
            //opt in
            UserDefaults.standard.set(true, forKey: "EMSPreviousPushSetting")
            log("OPTING IN: \(UserDefaults.standard.object(forKey: "EMSPreviousPushSetting") ?? "..")\n")
          }
          
          self.postOptInOutSetting(urlString: urlString, method: method, body: nil)
          
        }
      } else {
        log("+User has never subscribed with current app configuration")
      }
    }
  
    /**
        Used to subscribe a device to CCMP push notifications
        **NOTE:  The Initialize function must be called before calling the Subscribe function**
        - Parameter deviceToken:  The DeviceToken returned from APNS
        - Parameter completionHandler:  A callback function to be executed when the call is complete.  If successful, will pass the PRID received back.  Otherwise you will receive an error message or exception.
    */
    public func subscribe(deviceToken: Data, completionHandler: StringCompletionHandlerType? = nil) throws {
        var tokenString: String = ""
        var method: HTTPMethod = .post
        
        self.deviceToken = deviceToken
        tokenString = hexEncodedString(data: deviceToken)
        log("Subscribing Token: " + tokenString)
        
        if (tokenString != self.deviceTokenHex) || self.prid == nil {
            var urlString: String
            self.deviceTokenHex = tokenString
            try? keychainDeviceTokenHex.writePassword(tokenString)
            if self.prid != nil {
                urlString = "\(EMSRegions.XTS(region: self.region))/xts/registration/cust/\(self.customerID)/application/\(self.applicationID)/registration/\(self.prid!)/token"
                method = .put
            } else {
                urlString = "\(EMSRegions.XTS(region: self.region))/xts/registration/cust/\(self.customerID)/application/\(self.applicationID)/token"
                method = .post
            }
            try sendEMSMessage(url: urlString,
                               method: method,
                               body: ["DeviceToken": tokenString],
                               completionHandler: { response in
                                if let status = response.response?.statusCode {
                                    switch status {
                                    case 200, 201:
                                        if let result = response.result.value,
                                            let JSON = result as? NSDictionary,
                                            let prid = JSON["Push_Registration_Id"] as? String {
                                            self.log("JSON Received: " + String(describing: response.result.value!))
                                            self.prid = prid
                                            try? self.keychainPRID.writePassword(prid)
                                            self.log("PRID: " + String(describing: prid))
                                            self.log("Device Subscribed")
                                            //store setting for optin/out checks
                                            UserDefaults.standard.set(true, forKey: "EMSPreviousPushSetting")
                                            completionHandler?(prid)
                                        }
                                    case 400:
                                        throw EMSCommsError.invalidRequest
                                    case 401:
                                        throw EMSCommsError.notAuthenticated(userName: "")
                                    case 403:
                                        throw EMSCommsError.notAuthorized(userName: "")
                                    default:
                                        self.log("Error with response status: \(status)")
                                    }
                                }
            })
        } else {
          guard let customerPrid = self.prid else {
            log("could not access prid property")
            return
          }
          completionHandler?(customerPrid)
        }
    }
    
    /**
     Used to unsubscribe a device to CCMP push notifications
     - Parameter completionHandler: A callback function executed when the device is unsubscribed
     */
    public func unsubscribe(completionHandler: StringCompletionHandlerType? = nil) throws {
        if self.deviceTokenHex != nil {
            let urlString: String = "http://\(EMSRegions.XTS(region: self.region))/xts/registration/cust/\(self.customerID)/application/\(self.applicationID)/token/\(String(describing: self.deviceTokenHex))"
            try
                sendEMSMessage(url: urlString, method: .delete, body: nil, completionHandler: { response in
                    if let status = response.response?.statusCode {
                        switch status {
                        case 201:
                            if response.result.value != nil {
                                self.log("JSON Received: " + String(describing: response.result.value))
                                self.prid = nil
                                self.deviceTokenHex = nil
                                try? self.keychainDeviceTokenHex.delete()
                                try? self.keychainPRID.delete()
                                self.log("Device Unsubscribed")
                                completionHandler?("Device Unsubscribed")
                            }
                        case 400:
                            throw EMSCommsError.invalidRequest
                        case 401:
                            throw EMSCommsError.notAuthenticated(userName: "")
                        case 403:
                            throw EMSCommsError.notAuthorized(userName: "")
                        default:
                            self.log("Error with response status: \(status)")
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
    public func initialize(customerID: Int,
                           appID: String,
                           region: EMSRegions = EMSRegions.sandbox,
                           options: [UIApplication.LaunchOptionsKey: Any]?) {
        self.customerID = customerID
        self.applicationID = appID
        self.region = region
        if options != nil {
            if let userInfo = options?[UIApplication.LaunchOptionsKey.remoteNotification] as? [AnyHashable: Any] {
                //Woken up by Push Notification - Notify CCMP
                log("Awoken by Remote Notification")
                try? remoteNotificationReceived(userInfo: userInfo)
            }
        }
        log("Initialized with CustomerID: \(self.customerID), AppID: \(self.applicationID), Region: \(self.region.rawValue)")
    }
    /**
     This function is called to allow the EMS Mobile SDK to process any push notifications relevant to CCMP
     > Note:  Only messages that contain CCMP specific functionality will result in a message being sent to CCMP.  Any application specific messages are ignored.
    */
    public func remoteNotificationReceived(userInfo: [AnyHashable: Any]?) throws {
        if userInfo != nil {
            self.log("Raw Push Data Received: " + String(describing: userInfo))
            if let openUrl = userInfo?["ems_open"] as? String {
                self.log("Received EMS_OPEN: " + openUrl)
                try? sendEMSMessage(url: openUrl, body: nil, completionHandler: { response in
                    if response.response?.statusCode == 200 {
                        self.log("Content URL Sent Successfully")
                    }
                })
            }
        }
    }
    
    /**
        This function is used to post data to an API Post endpoing in CCMP
        - Parameter formId:  This is the Form ID for the API Post
        - Parameter data:  This is a dictionary of any key values you want to send.  These values should match those required by the API Post specification
        - Parameter completionHandler: A callback function executed after the call is complete.  Will return a bool value indicating if the call was successful
    */
    public func APIPost(formId: Int, data: Parameters?, completionHandler: BoolCompletionHandlerType? = nil) throws {
        let urlString: String = "\(EMSRegions.ATS(region: self.region))/ats/post.aspx?cr=\(self.customerID)&fm=\(formId)"
        var result = false
        let request = self.backgroundSession.request(urlString,
                                                     method: .post,
                                                     parameters: data,
                                                     encoding: URLEncoding.default)
        request.validate().responseJSON { response in
            if response.response?.statusCode == 200 {
                self.log("API Post Successful")
                result = true
            } else {
                self.log("Error Posting to API\nRecieved: \(String(describing: response.response?.statusCode))")
                result = false
            }
            completionHandler?(result)
        }
    }
    
    public func handleDeepLink(continue userActivity: NSUserActivity) -> EMSDeepLink {
        
        let deepLink = EMSDeepLink()
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
            let url = userActivity.webpageURL,
            let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
                return deepLink
        }
        
        if let deepLinkParam = components.queryItems?.first(where: { $0.name == "dl" }) {
            deepLink.deepLinkParameter = deepLinkParam.value!
        }
        
        deepLink.deepLinkUrl = url.absoluteString
        
        self.log("Getting response from Deep link URL \(String(describing: deepLink.deepLinkUrl))")
        
        self.backgroundSession.download(deepLink.deepLinkUrl).responseString { response in
            if response.response?.statusCode == 200 {
                self.log("Deep Link URL Post Successful")
            } else {
                self.log("Error Posting to Deep Link URL\nRecieved: \(String(describing: response.response?.statusCode))")
            }
        }
        return deepLink
    }
}
