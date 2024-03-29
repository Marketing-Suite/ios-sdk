//
//  EMSMobileSDK.swift
//  EMSMobileSDK
//
//  Created by Paul Ballard on 1/12/17.
//  Copyright © 2017 Experian Marketing Services. All rights reserved.
//

import Foundation
import UIKit

/** ##Monitor Delegate##
 This delegate is used to receive debug and information messages from the SDK.  It should only be used for debugging
 and not for functional logic as it can change at any time.
 */
@objc public protocol EMSMobileSDKWatcherDelegate: class {
    func sdkMessage(sender: EMSMobileSDK, message: String)
}

public typealias StringCompletionHandlerType = (_ result: String?, _ error: Error?) -> Void
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
    private let apiService = EMSAPI()
    
    /// Singleton Reference for accessing EMSMobileSDK
    @objc public static let `default` = EMSMobileSDK()
    
    // Delegate Property
    @objc public weak var watcherDelegate: EMSMobileSDKWatcherDelegate?
    
    /// The Customer ID set in the Initialize function
    @objc public var customerID = 0
    
    /// The Application ID set in the Initialize function
    ///  **This application ID is found in the Mobile App Group settings on CCMP**
    @objc public var applicationID = ""
    
    /// The Region to use for all interations with CCMP, set in the Initialize function.
    @objc public var region = EMSRegions.northAmerica
    
    /// The PRID returned fro device registration with CCMP
    @objc public dynamic var prid: String? {
        return try? keychainPRID.readPassword()
    }
    
    /// The current DeviceToken for this device
    @objc public dynamic var deviceToken: String? {
        return try? keychainDeviceTokenHex.readPassword()
    }
    
    //Logging messages to Debug and WatcherDelegate
    func log(_ message: String) {
        //For any UI Listeners
        self.watcherDelegate?.sdkMessage(sender: self, message: message)
    }
    
    override init() {
        super.init()
        log("Retrieved Stored PRID: \(prid ?? "Empty")")
        log("Retrieved Stored DeviceToken: \(deviceToken ?? "Empty")")
    }
    
    // MARK: - Public Functions
    /**
        This function is used to initialize the SDK values for subsequent calls to CCMP
        - Parameter customerID:  This is your Customer ID in the CCMP application
        - Parameter appID:  This is the Application ID created for this app in CCMP
        - Parameter region:  This is the reqion that your CCMP instance is hosted in.
        - Parameter options:  This is the collection of UILaunchOptionsKeys passed into the application on didFinishLaunching or nil if no options supplied.  This is used primarily for registring the launch of the application from a PUSH notification.
    */
    @objc
    public func initialize(customerID: Int,
                           appID: String,
                           region: EMSRegions = EMSRegions.northAmerica,
                           options: [UIApplication.LaunchOptionsKey: Any]?) {
        self.customerID = customerID
        self.applicationID = appID
        self.region = region
        if let userInfo = options?[UIApplication.LaunchOptionsKey.remoteNotification] as? [AnyHashable: Any] {
            //Woken up by Push Notification - Notify CCMP
            log("Awoken by Remote Notification")
            remoteNotificationReceived(userInfo: userInfo)
        }
        log("Initialized with CustomerID: \(self.customerID), AppID: \(self.applicationID), Region: \(self.region.rawValue)")
    }
    
    /**
        This function is called to allow the EMS Mobile SDK to process any push notifications relevant to CCMP
        - Parameter userInfo: An array of Hashable items sent from APNS which may or may not include data from CCMP.
        **NOTE:  Only messages that contain CCMP specific functionality will result in a message being sent to CCMP.**
        **Any application specific messages are ignored.**
    */
    @objc
    public func remoteNotificationReceived(userInfo: [AnyHashable: Any]?) {
        guard let openUrl = userInfo?["ems_open"] as? String else { return }
        
        log("Received EMS_OPEN: " + openUrl)
        
        apiService.logEMSOpen(url: openUrl) { [weak self] (response) in
            guard response?.statusCode == 200 else { return }
            self?.log("Content URL Sent Successfully")
        }
    }
    
    /**
        Used to subscribe a device to CCMP push notifications
        **NOTE:  The Initialize function must be called before calling the Subscribe function**
        - Parameter deviceToken:  The DeviceToken returned from APNS
        - Parameter completionHandler:  A callback function to be executed when the call is complete.  If successful, will pass the PRID received back.  Otherwise you will receive an error message or exception.
     */
    @objc
    public func subscribe(deviceToken: Data,
                          completionHandler: StringCompletionHandlerType? = nil) {
        subscribe(deviceTokenString: deviceToken.hexEncodedString, completionHandler: completionHandler)
    }
    
    func subscribe(deviceTokenString: String,
                   completionHandler: StringCompletionHandlerType? = nil) {
        let subscribeCompletionHandler: (Parameters?, HTTPURLResponse?, Error?) -> Void = { [weak self] (result, response, error) in
            guard let status = response?.statusCode else { return }
            switch status {
            case 200,
                 201:
                guard let JSON = result,
                    let prid = JSON["Push_Registration_Id"] as? String,
                    let tokenHex = JSON["Device_Token"] as? String else { return }
                self?.log("JSON Received: " + String(describing: JSON))
                try? self?.keychainPRID.writePassword(prid)
                try? self?.keychainDeviceTokenHex.writePassword(tokenHex)
                self?.log("PRID: " + String(describing: prid))
                self?.log("Device Subscribed")
                //store setting for optin/out checks
                UserDefaults.standard.set(true, forKey: "EMSPreviousPushSetting")
                completionHandler?(prid, nil)
            case 400: completionHandler?(nil, EMSCommsError.invalidRequest)
            case 401: completionHandler?(nil, EMSCommsError.notAuthenticated(userName: ""))
            case 403: completionHandler?(nil, EMSCommsError.notAuthorized(userName: ""))
            default:
                self?.log("Error with response status: \(status)")
                completionHandler?(nil, error)
            }
        }
        
        log("Subscribing Token: " + deviceTokenString)
        
        if prid == nil {
            apiService.subscribe(deviceToken: deviceTokenString, completionHandler: subscribeCompletionHandler)
        } else if deviceTokenString != deviceToken {
            apiService.resubscribe(deviceToken: deviceTokenString, completionHandler: subscribeCompletionHandler)
        } else {
            completionHandler?(prid, nil)
        }
    }
    
    /**
         Used to unsubscribe a device to CCMP push notifications
         - Parameter completionHandler: A callback function executed when the device is unsubscribed
     */
    @objc
    public func unsubscribe(completionHandler: StringCompletionHandlerType? = nil) {
        guard let deviceToken = deviceToken else {
            completionHandler?(nil, EMSCommsError.invalidRequest)
            return
        }
        
        apiService.unsubscribe(deviceToken: deviceToken, completionHandler: { [weak self] (result, response, error) in
            guard let status = response?.statusCode else { return }
            switch status {
            case 201:
                guard let result = result else { return }
                self?.log("JSON Received: " + result)
                try? self?.keychainDeviceTokenHex.delete()
                try? self?.keychainPRID.delete()
                self?.log("Device Unsubscribed")
                completionHandler?("Device Unsubscribed", nil)
            case 400: completionHandler?(nil, EMSCommsError.invalidRequest)
            case 401: completionHandler?(nil, EMSCommsError.notAuthenticated(userName: ""))
            case 403: completionHandler?(nil, EMSCommsError.notAuthorized(userName: ""))
            default:
                self?.log("Error with response status: \(status)")
                completionHandler?(nil, error)
            }
        })
    }
    
    /**
        If notifications are turned off at the operating system level, the SDK should detect this,
        and send an http DELETE containing the _cust id_, _application id_, and _device token_ to the {{xts/registration}} API,
        in order to mark the PRID as opted out, so that it is not processed in during MLC.
        
        Upon detection of notifications being turned back on, the SDK should send an http POST containing the same details in order to mark the record as opted back in.
    */
    @objc
    public func updateEMSSubscriptionIfNeeded() {
        let previousPushSetting = UserDefaults.standard.bool(forKey: "EMSPreviousPushSetting")
        let currentPushSetting = UIApplication.shared.isRegisteredForRemoteNotifications
        
        guard previousPushSetting != currentPushSetting else { return }
        
        //inidcates user has at least enabled push once to initially subscribe
        guard let devToken = self.deviceToken else {
            log("missing required param, device token in optinout check")
            log("+User has never subscribed with current app configuration")
            return
        }
        
        log("\n\n+++++\n")
        log("+app entered foreground:\n")
        log("+previous push setting: \(previousPushSetting ? "yes" : "no")\n")
        log("+registration setting: \(currentPushSetting ? "yes" : "no")")
        log("\n+++++\n\n")
        
        //if prev setting and current setting don't match handle optin/out
        //if setting = yes and prv = no then opt in
        //if setting = no and prev = yes then opt out
        UserDefaults.standard.set(currentPushSetting, forKey: "EMSPreviousPushSetting")
        
        log("\n\nOPTIN/OUT params:\n")
        log("customerID: \(self.customerID)\nappID: \(self.applicationID)\ndeviceToken: \(devToken)\n")
        log("\(currentPushSetting ? "OPTING IN" : "OPTING OUT")...\n")
        
        if currentPushSetting {
            subscribe(deviceTokenString: devToken)
        } else {
            unsubscribe()
        }
    }
    
    /**
        This function is used to post data to an API Post endpoing in CCMP
        - Parameter formId:  This is the Form ID for the API Post
        - Parameter data:  This is a dictionary of any key values you want to send.  These values should match those required by the API Post specification
        - Parameter completionHandler: A callback function executed after the call is complete.  Will return a bool value indicating if the call was successful
    */
    @objc
    public func APIPost(formId: Int, data: Parameters?, completionHandler: BoolCompletionHandlerType? = nil) {
        apiService.emsPost(formId: formId, data: data) { [weak self] response in
            var result = false
            if response?.statusCode == 200 {
                self?.log("API Post Successful")
                result = true
            } else {
                self?.log("Error Posting to API\nReceived: \(String(describing: response?.statusCode)))")
            }
            completionHandler?(result)
        }
    }
    
    /**
         The handleDeepLink function parses the information from the userActivity and returns the original Deep link URL,
         the Deep link Paramater if any, and finally register the link count on CCMP.
         - Parameter userActivity: This is the Passed-in userActivity
     */
    @objc
    public func handleDeepLink(continue userActivity: NSUserActivity) -> EMSDeepLink {
        let deepLink = EMSDeepLink()
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
            let url = userActivity.webpageURL,
            let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
                return deepLink
        }
        
        if let deepLinkParam = components.queryItems?.first(where: { $0.name == "dl" }),
            let deepLinkParamValue = deepLinkParam.value {
            deepLink.deepLinkParameter = deepLinkParamValue
        }
        
        deepLink.deepLinkUrl = url.absoluteString
        
        log("Getting response from Deep link URL \(String(describing: deepLink.deepLinkUrl))")
        
        apiService.logDeepLink(deepLink.deepLinkUrl) { [weak self] response in
            if response?.statusCode == 200 {
                self?.log("Deep Link URL Post Successful")
            } else {
                self?.log("Error Posting to Deep Link URL\nRecieved: \(String(describing: response?.statusCode))")
            }
        }
        return deepLink
    }
}

extension Data {
    var hexEncodedString: String {
        return map { String(format: "%02hhx", $0) }.joined()
    }
}
